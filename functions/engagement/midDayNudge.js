const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const notificationService = require("../shared/notificationService");
const { parentsOfChild, childFirstName } = require("../shared/audienceService");
const { NotificationType, Role } = require("../shared/constants");

// ============================================================
// 💗 MID-DAY "CHECK ON YOUR CHILD" NUDGE (scheduled, per-child)
// ============================================================
//
// User intent: mid-day, invite the parent to open the app and follow
// their child's day. Shifts differ, so this is NOT a fixed clock time —
// it fires per child ~2.5h AFTER that child's own check-in, while they
// are still present (checked-in today, not yet checked-out), once a day.
//
// Mechanism: a scan every 30 min over each nursery's today events.
// A dedup marker at platform/{nid}/midDayNudgeSent/{date}/{childId}
// guarantees at-most-once per child per day.
// ============================================================

const NUDGE_DELAY_MINUTES = 150; // ~2.5h after check-in (user said "ساعتين تلاتة")
const TZ = "Africa/Cairo";

function cairoDateKey(now = new Date()) {
  // en-CA → "YYYY-MM-DD", matching the app's _dateKey format.
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: TZ,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(now);
}

function db() {
  return admin.database();
}

// From a child's map of today's events, return the check-in timestamp if the
// child is currently present (has a check_in and no check_out), else null.
function presentSince(eventsMap) {
  let checkInAt = null;
  let checkedOut = false;
  for (const ev of Object.values(eventsMap || {})) {
    if (!ev || typeof ev !== "object") continue;
    if (ev.eventType === "check_in") {
      const t = Number(ev.createdAt) || 0;
      if (checkInAt === null || t < checkInAt) checkInAt = t;
    } else if (ev.eventType === "check_out") {
      checkedOut = true;
    }
  }
  if (checkInAt === null || checkedOut) return null;
  return checkInAt;
}

async function nudgeChild(nurseryId, childId, date) {
  const markerRef = db().ref(
    `platform/${nurseryId}/midDayNudgeSent/${date}/${childId}`
  );
  const marker = await markerRef.once("value");
  if (marker.exists()) return false; // already nudged today

  const parentIds = await parentsOfChild(nurseryId, childId);
  if (parentIds.length === 0) return false;

  const name = await childFirstName(nurseryId, childId);
  const recipients = parentIds.map((uid) => ({ uid, role: Role.parent }));

  await notificationService.send({
    recipients,
    nurseryId,
    title: `${name} بيقضّي يوم جميل 💕`,
    body: `ادخلي تابعي أخبار ${name} ونشاطه لحد دلوقتي`,
    type: NotificationType.engagement,
    entityId: childId,
    data: { screen: "child_timeline", childId, eventType: "mid_day_nudge" },
  });

  // Mark AFTER sending so a mid-send crash retries next tick rather than
  // silently skipping the child for the whole day.
  await markerRef.set(admin.database.ServerValue.TIMESTAMP);
  return true;
}

async function runNudgeScan() {
  const date = cairoDateKey();
  const nowMs = Date.now();
  const cutoffMs = NUDGE_DELAY_MINUTES * 60 * 1000;

  // Nursery ids come from the registry (platform/info/{nid}) — lighter than
  // reading the whole platform tree.
  const infoSnap = await db().ref("platform/info").once("value");
  const nurseryIds = [];
  infoSnap.forEach((n) => nurseryIds.push(n.key));

  let sent = 0;
  for (const nurseryId of nurseryIds) {
    const daySnap = await db()
      .ref(`platform/${nurseryId}/childDailyEvents/${date}`)
      .once("value");
    if (!daySnap.exists()) continue;

    const perChild = daySnap.val() || {};
    for (const [childId, eventsMap] of Object.entries(perChild)) {
      const checkInAt = presentSince(eventsMap);
      if (checkInAt === null) continue;
      if (nowMs - checkInAt < cutoffMs) continue; // not yet 2.5h since arrival

      try {
        if (await nudgeChild(nurseryId, childId, date)) sent++;
      } catch (e) {
        console.error(`❌ nudgeChild(${nurseryId}/${childId}):`, e.message);
      }
    }
  }

  console.log(`💗 mid-day nudge scan done — date=${date} sent=${sent}`);
}

exports.midDayNudgeScan = onSchedule(
  { schedule: "every 30 minutes", timeZone: TZ },
  async () => {
    await runNudgeScan();
  }
);
