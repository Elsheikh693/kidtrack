const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const { RTDB_INSTANCE } = require("../shared/constants");

// ============================================================
// 🧹 OLD-EVENT CLEANUP (scheduled, per-nursery)
// ============================================================
//
// User intent: reception-created events (trips / parties / "Fun Day")
// never expired on their own — they only dropped out of the parents'
// upcoming list and reception's default filter once their date passed,
// but the record lived in the DB forever and could only be removed by
// hand. This scan deletes events whose date is older than the retention
// window so the database stays clean without any manual work.
//
// Grace period: an event is kept RETENTION_DAYS days AFTER its date, so
// reception can still review the past event + its attendance for a while,
// then it is hard-deleted. Mirrors EventService.deleteEvent on the client:
// removes the event node, its attendees node, and the cover image.
// ============================================================

const TZ = "Africa/Cairo";
const RETENTION_DAYS = 30; // keep past events this long, then delete
const DAY_MS = 24 * 60 * 60 * 1000;

function db() {
  return admin.database();
}

// Every nursery id under platform/*, discovered via a shallow read so
// nurseries missing from platform/info are still scanned. Falls back to the
// registry if the shallow read fails. (Mirrors absentShiftEnd.allNurseryIds.)
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

// Deletes the event node, its attendees node, and the cover image. Storage is
// removed by prefix so a missing/absent cover never throws.
async function deleteEvent(nurseryId, eventId) {
  await db().ref(`platform/${nurseryId}/events/${eventId}`).remove();
  await db().ref(`platform/${nurseryId}/eventAttendees/${eventId}`).remove();
  try {
    await admin
      .storage()
      .bucket()
      .deleteFiles({ prefix: `nurseries/${nurseryId}/events/${eventId}/` });
  } catch (e) {
    console.error(`cover cleanup ${nurseryId}/${eventId}:`, e.message);
  }
}

async function runEventCleanup() {
  const cutoff = Date.now() - RETENTION_DAYS * DAY_MS;
  const nurseryIds = await allNurseryIds();

  let deleted = 0;
  for (const nurseryId of nurseryIds) {
    // Only events with date < cutoff are in scope; orderByChild+endAt keeps the
    // read small instead of pulling the whole events node.
    const snap = await db()
      .ref(`platform/${nurseryId}/events`)
      .orderByChild("date")
      .endAt(cutoff - 1)
      .once("value");

    const stale = [];
    snap.forEach((e) => {
      const v = e.val() || {};
      if (typeof v.date === "number" && v.date < cutoff) stale.push(e.key);
    });
    if (stale.length === 0) continue;

    for (const eventId of stale) {
      try {
        await deleteEvent(nurseryId, eventId);
        deleted++;
      } catch (err) {
        console.error(`❌ eventCleanup(${nurseryId}/${eventId}):`, err.message);
      }
    }
    console.log(`🧹 ${nurseryId}: deleted ${stale.length} old event(s)`);
  }

  console.log(
    `🧹 event cleanup done — cutoff=${new Date(cutoff).toISOString()} ` +
      `scanned=${nurseryIds.length} deleted=${deleted}`
  );
  return { cutoff, scanned: nurseryIds.length, deleted };
}

exports.eventCleanupScan = onSchedule(
  { schedule: "every day 03:00", timeZone: TZ },
  async () => {
    await runEventCleanup();
  }
);
