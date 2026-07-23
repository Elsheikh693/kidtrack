const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onValueCreated } = require("firebase-functions/v2/database");
const admin = require("firebase-admin");
const notificationService = require("../shared/notificationService");
const { branchManagers } = require("../shared/audienceService");
const { RTDB_INSTANCE, NotificationType, Role } = require("../shared/constants");

// ============================================================
// ⏰ LATE-SESSION START ALERT (scheduled scan + manual nudge)
// ============================================================
//
// User intent: if a teacher is in the classroom but hasn't started the session
// the timetable says should be running, the manager wants to know AT THAT MOMENT
// so she can nudge — before the gap disrupts the child's day (and the parent
// notices). The teacher gets the first, gentle reminder; if she still hasn't
// started after an extra window, it escalates to the manager.
//
// Detection is anchored to the manager-owned timetable (platform/{nid}/schedules)
// and matched EXACTLY to whether an activity was started for that slot today
// (ClassroomActivityModel.scheduleSlotId), so it never guesses by time alone.
//
// Grace is per-nursery (platform/info/{nid}): lateSessionGraceMinutes (nudge the
// teacher) + lateSessionEscalateMinutes (then the manager). Master switch:
// lateSessionAlertEnabled (default ON).
//
// Dedup markers at platform/{nid}/lateSessionSent/{date}/{teacher|manager}/{slotId}
// guarantee at-most-once per slot per day per audience.
// ============================================================

const TZ = "Africa/Cairo";
const DEFAULT_GRACE = 15;
const DEFAULT_ESCALATE = 15;

const DAY_NAMES = [
  "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday",
];

function db() {
  return admin.database();
}

function cairoDateKey(now = new Date()) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: TZ, year: "numeric", month: "2-digit", day: "2-digit",
  }).format(now);
}

function cairoWeekday(date) {
  const [y, m, d] = String(date).split("-").map(Number);
  const jsDay = new Date(Date.UTC(y, m - 1, d)).getUTCDay(); // 0=Sun..6=Sat
  return jsDay === 0 ? 7 : jsDay; // → Mon=1..Sun=7
}

function cairoMinuteOfDay(now = new Date()) {
  const parts = new Intl.DateTimeFormat("en-GB", {
    timeZone: TZ, hour: "2-digit", minute: "2-digit", hour12: false,
  }).formatToParts(now);
  let h = 0, m = 0;
  for (const p of parts) {
    if (p.type === "hour") h = Number(p.value);
    if (p.type === "minute") m = Number(p.value);
  }
  if (h === 24) h = 0;
  return h * 60 + m;
}

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

function toMinutes(hhmm) {
  const parts = String(hhmm).split(":");
  if (parts.length < 2) return null;
  const h = Number(parts[0]);
  const m = Number(parts[1]);
  if (Number.isNaN(h) || Number.isNaN(m)) return null;
  return h * 60 + m;
}

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
    }
  } catch (e) {
    console.error("allNurseryIds shallow read failed:", e.message);
  }
  const infoSnap = await db().ref("platform/info").once("value");
  const ids = [];
  infoSnap.forEach((n) => ids.push(n.key));
  return ids;
}

async function lateSettings(nurseryId) {
  const snap = await db().ref(`platform/info/${nurseryId}`).once("value");
  const v = snap.val() || {};
  const enabled = v.lateSessionAlertEnabled !== false; // default ON
  const grace = Number.isFinite(Number(v.lateSessionGraceMinutes))
    ? Number(v.lateSessionGraceMinutes) : DEFAULT_GRACE;
  const escalate = Number.isFinite(Number(v.lateSessionEscalateMinutes))
    ? Number(v.lateSessionEscalateMinutes) : DEFAULT_ESCALATE;
  return { enabled, grace, escalate };
}

// classroomId → { name, teacherId, branchId }
async function classroomMap(nurseryId) {
  const snap = await db().ref(`platform/${nurseryId}/classrooms`).once("value");
  const map = {};
  snap.forEach((c) => {
    const v = c.val() || {};
    let branchId = "";
    if (Array.isArray(v.branchIds)) branchId = v.branchIds[0] || "";
    else if (v.branchIds && typeof v.branchIds === "object") {
      branchId = Object.values(v.branchIds)[0] || "";
    }
    map[c.key] = { name: v.name || "", teacherId: v.teacherId || "", branchId };
  });
  return map;
}

// uid → name
async function staffNameMap(nurseryId) {
  const snap = await db().ref(`platform/${nurseryId}/staff`).once("value");
  const map = {};
  snap.forEach((s) => {
    const v = s.val() || {};
    const uid = v.uid || s.key;
    if (uid) map[uid] = v.name || "";
  });
  return map;
}

// id → name
async function subjectNameMap(nurseryId) {
  const snap = await db().ref(`platform/${nurseryId}/subjects`).once("value");
  const map = {};
  snap.forEach((s) => {
    map[s.key] = (s.val() || {}).name || "";
  });
  return map;
}

// Staff ids present (or late) today, or null when attendance wasn't taken.
async function presentStaffToday(nurseryId, date) {
  const snap = await db()
    .ref(`platform/${nurseryId}/staffAttendance`)
    .orderByChild("date").equalTo(date)
    .once("value");
  if (!snap.exists()) return null;
  const present = new Set();
  snap.forEach((r) => {
    const v = r.val() || {};
    if (v.status !== "absent" && v.status !== "on_leave" && v.checkInTime != null) {
      present.add(String(v.staffId));
    }
  });
  return present;
}

// scheduleSlotId set + subjectId set for activities started TODAY in a classroom.
async function fulfilledForClassroom(nurseryId, classroomId, date) {
  const slotIds = new Set();
  const subjectIds = new Set();
  const snap = await db()
    .ref(`platform/${nurseryId}/classroomActivities/${classroomId}`)
    .once("value");
  snap.forEach((a) => {
    const v = a.val() || {};
    const started = Number(v.startedAt);
    if (!started || cairoDateKey(new Date(started)) !== date) return;
    if (v.scheduleSlotId) slotIds.add(String(v.scheduleSlotId));
    if (v.subjectId) subjectIds.add(String(v.subjectId));
  });
  return { slotIds, subjectIds };
}

function slotTitle(slot, subjectNames) {
  const topic = slot.topic && String(slot.topic).trim();
  if (topic) return topic;
  const sub = subjectNames[slot.subjectId];
  if (sub && String(sub).trim()) return String(sub).trim();
  return "الحصة";
}

async function markSent(nurseryId, date, audience, slotId) {
  await db()
    .ref(`platform/${nurseryId}/lateSessionSent/${date}/${audience}/${slotId}`)
    .set(admin.database.ServerValue.TIMESTAMP);
}

async function alreadySent(nurseryId, date, audience, slotId) {
  const snap = await db()
    .ref(`platform/${nurseryId}/lateSessionSent/${date}/${audience}/${slotId}`)
    .once("value");
  return snap.exists();
}

async function runLateScan() {
  const date = cairoDateKey();
  const minuteNow = cairoMinuteOfDay();
  const weekday = cairoWeekday(date);
  const todayName = DAY_NAMES[(weekday - 1) % 7];

  const nurseryIds = await allNurseryIds();
  let teacherSent = 0;
  let managerSent = 0;

  for (const nurseryId of nurseryIds) {
    const dayOff = await nurseryDayOff(nurseryId, date, weekday);
    if (dayOff.off) continue;

    const { enabled, grace, escalate } = await lateSettings(nurseryId);
    if (!enabled) continue;

    const schedSnap = await db()
      .ref(`platform/${nurseryId}/schedules`)
      .orderByChild("day").equalTo(todayName)
      .once("value");
    if (!schedSnap.exists()) continue;

    const slots = [];
    schedSnap.forEach((s) => {
      slots.push({ key: s.key, ...(s.val() || {}) });
    });
    if (slots.length === 0) continue;

    const [classrooms, staffNames, subjectNames, present] = await Promise.all([
      classroomMap(nurseryId),
      staffNameMap(nurseryId),
      subjectNameMap(nurseryId),
      presentStaffToday(nurseryId, date),
    ]);

    // Cache fulfilled sets per classroom (one read per classroom, reused).
    const fulfilledCache = {};

    for (const slot of slots) {
      const startMin = toMinutes(slot.startTime);
      const endMin = toMinutes(slot.endTime);
      if (startMin == null || endMin == null) continue;
      if (minuteNow < startMin + grace) continue; // still within grace
      if (minuteNow >= endMin) continue; // slot window already over

      const classroom = classrooms[slot.classroomId] || {};
      const teacherId = slot.teacherId || classroom.teacherId || "";

      // Absent teacher → attendance issue, not a late start. Skip.
      if (present && teacherId && !present.has(teacherId)) continue;

      if (!fulfilledCache[slot.classroomId]) {
        fulfilledCache[slot.classroomId] =
          await fulfilledForClassroom(nurseryId, slot.classroomId, date);
      }
      const fulfilled = fulfilledCache[slot.classroomId];
      if (fulfilled.slotIds.has(slot.key)) continue;
      if (slot.subjectId && fulfilled.subjectIds.has(String(slot.subjectId))) {
        continue;
      }

      const title = slotTitle(slot, subjectNames);
      const className = classroom.name || "";

      // ── 1) Nudge the teacher first ──────────────────────────────────────
      if (teacherId && !(await alreadySent(nurseryId, date, "teacher", slot.key))) {
        try {
          await notificationService.send({
            recipients: [{ uid: teacherId, role: Role.staff }],
            nurseryId,
            title: "تذكير ببدء الحصة",
            body:
              `حصة «${title}»${className ? ` في ${className}` : ""} معادها ` +
              `${slot.startTime} ولسه مبدأتش — تقدري تبدئيها دلوقتي.`,
            type: NotificationType.engagement,
            entityId: slot.key,
            data: { kind: "late_session_teacher", classroomId: slot.classroomId, slotId: slot.key },
          });
          await markSent(nurseryId, date, "teacher", slot.key);
          teacherSent++;
        } catch (e) {
          console.error(`late teacher nudge ${nurseryId}/${slot.key}:`, e.message);
        }
      }

      // ── 2) Escalate to the manager after the extra window ───────────────
      if (
        minuteNow >= startMin + grace + escalate &&
        !(await alreadySent(nurseryId, date, "manager", slot.key))
      ) {
        const mgrs = await branchManagers(nurseryId, classroom.branchId || "");
        if (mgrs.length > 0) {
          const teacherName = staffNames[teacherId] || "";
          try {
            await notificationService.send({
              recipients: mgrs.map((uid) => ({ uid, role: Role.staff })),
              nurseryId,
              title: "حصة متأخرة عن معادها",
              body:
                `${className ? `${className}: ` : ""}` +
                `${teacherName ? `${teacherName} ` : "المدرّسة "}` +
                `لسه مبدأتش حصة «${title}» (معادها ${slot.startTime}).`,
              type: NotificationType.engagement,
              entityId: slot.key,
              data: { kind: "late_session_manager", classroomId: slot.classroomId, slotId: slot.key },
            });
            await markSent(nurseryId, date, "manager", slot.key);
            managerSent++;
          } catch (e) {
            console.error(`late manager escalate ${nurseryId}/${slot.key}:`, e.message);
          }
        }
      }
    }
  }

  console.log(
    `⏰ late-session scan — date=${date} minute=${minuteNow} ` +
      `teacherSent=${teacherSent} managerSent=${managerSent}`
  );
  return { date, minuteNow, teacherSent, managerSent };
}

exports.lateSessionStartScan = onSchedule(
  { schedule: "every 5 minutes", timeZone: TZ },
  async () => {
    await runLateScan();
  }
);

// ── Manual "nudge the teacher" from the manager's live dashboard card ─────────
// The client writes an intent node; we turn it into a push and clean it up.
exports.onTeacherNudgeCreated = onValueCreated(
  {
    ref: "platform/{nurseryId}/teacherNudges/{nudgeId}",
    instance: RTDB_INSTANCE,
  },
  async (event) => {
    const nudge = event.data.val();
    if (!nudge || typeof nudge !== "object") return;
    const { nurseryId, nudgeId } = event.params;
    const teacherId = nudge.teacherId;
    if (!teacherId) {
      await db().ref(`platform/${nurseryId}/teacherNudges/${nudgeId}`).remove();
      return;
    }
    const title = nudge.title && String(nudge.title).trim()
      ? String(nudge.title).trim() : "الحصة";
    try {
      await notificationService.send({
        recipients: [{ uid: teacherId, role: Role.staff }],
        nurseryId,
        title: "تنبيه من الإدارة",
        body: `الإدارة بتذكّرك ببدء حصة «${title}» — لو سمحتي ابدئيها دلوقتي.`,
        type: NotificationType.engagement,
        entityId: nudge.slotId || nudgeId,
        data: {
          kind: "late_session_nudge",
          classroomId: nudge.classroomId || "",
          slotId: nudge.slotId || "",
        },
      });
    } catch (e) {
      console.error(`teacher nudge push ${nurseryId}/${nudgeId}:`, e.message);
    }
    // One-shot intent — remove so it doesn't linger.
    await db().ref(`platform/${nurseryId}/teacherNudges/${nudgeId}`).remove();
  }
);
