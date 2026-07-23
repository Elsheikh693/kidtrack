const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const { parentsOfChild } = require("../shared/audienceService");
const { RTDB_INSTANCE } = require("../shared/constants");

// ============================================================
// 📭 ABSENT-AT-SHIFT-END AUTO CHAT (scheduled, per-child)
// ============================================================
//
// User intent: at the END of the shift a child is registered for, if the
// child never showed up today, automatically message the parent from the
// nursery — a caring "we noticed {name} was absent, is everything ok, why?"
// — so reception doesn't have to chase anyone by hand.
//
// Mechanism: a scan every 30 min. For each nursery we resolve which shifts
// have already ended (Cairo minute-of-day ≥ shift.endMinutes), then for each
// ACTIVE child registered to an ended shift who has NO attendance record today
// we write a manager-side message into the shared per-child chat thread. The
// existing onChatMessageCreated trigger then pushes the FCM to the parent.
//
// A dedup marker at platform/{nid}/absentShiftEndSent/{date}/{childId}
// guarantees at-most-once per child per day.
// ============================================================

const TZ = "Africa/Cairo";

// Fallback shift end-times (minutes from midnight) mirroring ShiftDefaults in
// the app, used when a nursery hasn't seeded/customised its shifts yet so the
// legacy 'morning'/'between'/'evening' keys on child.shift still resolve.
const DEFAULT_SHIFT_END = { morning: 720, between: 900, evening: 1080 };

function db() {
  return admin.database();
}

// en-CA → "YYYY-MM-DD", matching the app's attendance _dateKey format.
function cairoDateKey(now = new Date()) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: TZ,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(now);
}

// Weekday of a Cairo date, in Dart's DateTime.weekday convention (Mon=1..Sun=7)
// so it lines up with the weekendDays keys the app writes. `date` is the
// "YYYY-MM-DD" Cairo key; we parse it as UTC midnight so the host timezone can't
// shift the weekday.
function cairoWeekday(date) {
  const [y, m, d] = String(date).split("-").map(Number);
  const jsDay = new Date(Date.UTC(y, m - 1, d)).getUTCDay(); // 0=Sun..6=Sat
  return jsDay === 0 ? 7 : jsDay; // → Mon=1..Sun=7
}

// Is the nursery closed today? Two independent sources, mirroring the app's
// HolidayService:
//   • specific holiday date → platform/{nid}/holidays/{date}
//   • weekly weekend        → platform/{nid}/holidaySettings/weekendDays
//     (map of DateTime.weekday int → true, e.g. {"5":true,"6":true} = Fri+Sat)
// Returns { off, reason }. When off, we must NOT send absence messages — a
// day-off is not an absence, and blasting parents on the weekend is a disaster.
async function nurseryDayOff(nurseryId, date, weekday) {
  const holidaySnap = await db()
    .ref(`platform/${nurseryId}/holidays/${date}`)
    .once("value");
  if (holidaySnap.exists()) return { off: true, reason: "holiday" };

  const weekendSnap = await db()
    .ref(`platform/${nurseryId}/holidaySettings/weekendDays`)
    .once("value");
  const weekend = weekendSnap.val();
  if (weekend && typeof weekend === "object" && weekend[String(weekday)] === true) {
    return { off: true, reason: "weekend" };
  }
  return { off: false };
}

// Minutes elapsed since midnight in Cairo time (0..1439).
function cairoMinuteOfDay(now = new Date()) {
  const parts = new Intl.DateTimeFormat("en-GB", {
    timeZone: TZ,
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).formatToParts(now);
  let h = 0;
  let m = 0;
  for (const p of parts) {
    if (p.type === "hour") h = Number(p.value);
    if (p.type === "minute") m = Number(p.value);
  }
  // "24:00" can appear at midnight in some environments — normalise to 0.
  if (h === 24) h = 0;
  return h * 60 + m;
}

function absenceMessage(firstName) {
  const name =
    firstName && String(firstName).trim() ? String(firstName).trim() : "طفلكم";
  // Warm, informal Egyptian tone. NO emoji here on purpose: the in-app chat
  // can't render color emoji (system-name fallback tofus on iOS, and bundling a
  // color-emoji font crashes the Flutter text engine — see app_typography.dart).
  // The WhatsApp version (absenceWhatsAppMessage on the client) keeps the emoji
  // because WhatsApp renders them natively.
  return (
    `أهلاً بيكم، وحشنا ${name} النهاردة في الحضانة وحبينا نطمن عليه. ` +
    `كله تمام معاكم؟ لو فيه أي حاجة إحنا جنبكم — بس طمنونا ${name} غاب ليه النهاردة.`
  );
}

// shift-key → endMinutes for a nursery, backfilled with the legacy defaults so
// a child.shift value always resolves to an end time.
async function shiftEndMap(nurseryId) {
  const snap = await db().ref(`platform/${nurseryId}/shifts`).once("value");
  const map = {};
  snap.forEach((s) => {
    const v = s.val() || {};
    if (v.isActive === false) return;
    const end = Number(v.endMinutes);
    if (!Number.isNaN(end)) map[s.key] = end;
  });
  for (const [k, v] of Object.entries(DEFAULT_SHIFT_END)) {
    if (map[k] === undefined) map[k] = v;
  }
  return map;
}

// Set of child ids with a dated attendance record today (present or late).
async function presentIdsToday(nurseryId, date) {
  const snap = await db()
    .ref(`platform/${nurseryId}/childAttendance`)
    .orderByChild("date")
    .equalTo(date)
    .once("value");
  const ids = new Set();
  snap.forEach((r) => {
    const v = r.val() || {};
    if (v.childId && (v.status === "present" || v.status === "late")) {
      ids.add(String(v.childId));
    }
  });
  return ids;
}

// Writes the caring absence message into the shared per-child chat thread as a
// manager-side message. Returns true when a message was actually sent.
async function sendAbsenceChat(nurseryId, childId, child, date) {
  const markerRef = db().ref(
    `platform/${nurseryId}/absentShiftEndSent/${date}/${childId}`
  );
  if ((await markerRef.once("value")).exists()) return false; // already sent today

  const parentIds = await parentsOfChild(nurseryId, childId);
  const parentId = parentIds[0];
  if (!parentId) return false; // no linked guardian to message

  const parentNameSnap = await db().ref(`users/${parentId}/name`).once("value");
  const parentName = parentNameSnap.val() ? String(parentNameSnap.val()) : "";

  const fullName = `${child.firstName || ""} ${child.lastName || ""}`.trim();
  const text = absenceMessage(child.firstName);
  const nowMs = Date.now();

  const chatRef = db().ref(`platform/${nurseryId}/chats/${childId}`);
  const metaRef = chatRef.child("meta");
  const existing = (await metaRef.once("value")).val() || {};

  // Write meta FIRST so the onChatMessageCreated trigger sees parentId/branchId
  // when it fires on the message below.
  await metaRef.update({
    childId,
    childName: fullName,
    childImage: child.profileImage || null,
    classroomId: child.classroomId || null,
    branchId: child.branchId || "",
    parentId,
    parentName,
    lastText: text,
    lastAt: nowMs,
    lastSenderRole: "manager",
    unreadParent: (Number(existing.unreadParent) || 0) + 1,
  });

  const msgRef = chatRef.child("messages").push();
  await msgRef.set({
    id: msgRef.key,
    senderId: "system",
    senderRole: "manager",
    text,
    createdAt: nowMs,
  });

  // Mark AFTER sending so a mid-send crash retries next tick rather than
  // silently skipping the child for the whole day.
  await markerRef.set(admin.database.ServerValue.TIMESTAMP);
  return true;
}

// Every nursery id under platform/*, discovered via a shallow read so nurseries
// that aren't in the platform/info registry are still scanned. Falls back to the
// registry if the shallow read fails.
async function allNurseryIds() {
  try {
    const { access_token: token } =
      await admin.app().options.credential.getAccessToken();
    const url =
      `https://${RTDB_INSTANCE}.firebaseio.com/platform.json` +
      `?shallow=true&access_token=${token}`;
    const resp = await fetch(url);
    if (resp.ok) {
      const json = await resp.json();
      if (json && typeof json === "object") {
        return Object.keys(json).filter((k) => k !== "info");
      }
    } else {
      console.error(`shallow platform read HTTP ${resp.status}`);
    }
  } catch (e) {
    console.error("allNurseryIds shallow read failed:", e.message);
  }
  const infoSnap = await db().ref("platform/info").once("value");
  const ids = [];
  infoSnap.forEach((n) => ids.push(n.key));
  return ids;
}

async function runAbsentScan() {
  const date = cairoDateKey();
  const minuteNow = cairoMinuteOfDay();
  const weekday = cairoWeekday(date);

  const nurseryIds = await allNurseryIds();

  let sent = 0;
  const summary = [];
  for (const nurseryId of nurseryIds) {
    // Never chase absences on a day the nursery is closed — a holiday or the
    // weekly weekend is not an absence. This MUST come before any scanning.
    const dayOff = await nurseryDayOff(nurseryId, date, weekday);
    if (dayOff.off) {
      summary.push({ nurseryId, sent: 0, note: `day off (${dayOff.reason})` });
      continue;
    }

    const ends = await shiftEndMap(nurseryId);
    const endedShifts = new Set(
      Object.entries(ends)
        .filter(([, end]) => minuteNow >= end)
        .map(([k]) => k)
    );
    if (endedShifts.size === 0) {
      summary.push({ nurseryId, endedShifts: [], sent: 0, note: "no shift ended yet" });
      continue; // no shift has ended yet today
    }

    const present = await presentIdsToday(nurseryId, date);

    const childrenSnap = await db()
      .ref(`platform/${nurseryId}/children`)
      .once("value");
    const perChild = childrenSnap.val() || {};
    const childrenCount = Object.keys(perChild).length;

    // Diagnostic counters — printed per nursery so a sent=0 run is explainable
    // (no shift set / shift not ended yet / attended / no linked parent).
    const skip = { inactive: 0, noShift: 0, shiftNotEnded: 0, present: 0, noParent: 0 };

    for (const [childId, child] of Object.entries(perChild)) {
      if (!child || typeof child !== "object") continue;
      if (child.status !== "active") {
        skip.inactive++;
        continue;
      }
      const shift = child.shift;
      if (!shift) {
        skip.noShift++;
        continue;
      }
      if (!endedShifts.has(shift)) {
        skip.shiftNotEnded++;
        continue;
      }
      if (present.has(childId)) {
        skip.present++;
        continue;
      }

      try {
        const ok = await sendAbsenceChat(nurseryId, childId, child, date);
        if (ok) sent++;
        else skip.noParent++; // eligible but no linked guardian to message
      } catch (e) {
        console.error(`❌ absentShiftEnd(${nurseryId}/${childId}):`, e.message);
      }
    }

    console.log(
      `📭 ${nurseryId}: endedShifts=[${[...endedShifts].join(",")}] ` +
        `sent=${sent} skips=${JSON.stringify(skip)}`
    );
    summary.push({
      nurseryId,
      childrenCount,
      endedShifts: [...endedShifts],
      skips: skip,
    });
  }

  console.log(
    `📭 absent shift-end scan done — date=${date} minute=${minuteNow} sent=${sent}`
  );
  return { date, minuteNow, scanned: nurseryIds.length, sent, nurseries: summary };
}

exports.absentShiftEndScan = onSchedule(
  { schedule: "every 30 minutes", timeZone: TZ },
  async () => {
    await runAbsentScan();
  }
);
