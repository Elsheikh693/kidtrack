const admin = require("firebase-admin");
const { onValueCreated } = require("firebase-functions/v2/database");
const { RTDB_INSTANCE, NotificationType, Role } = require("../shared/constants");
const { branchManagers } = require("../shared/audienceService");
const notificationService = require("../shared/notificationService");

// ============================================================
// 📸 EVENT PHOTO REVIEW — nudge reviewers when event photos need approving
// ============================================================
//
// Any staff member may upload photos to a nursery event. Uploads land as
// `isApproved: false` (hidden from guardians). A reviewer (branch manager /
// owner / staff granted the `classroom.review_photos` permission) approves
// them before they publish. This trigger tells the reviewer(s) a batch waits.
//
// TRIGGER: platform/{nurseryId}/events/{eventId}/photos/{photoId}
//
// Several photos usually arrive at once — one write per photo. To send ONE
// notification per event (not per photo) we set a `reviewNotifiedAt` flag on
// the event via a transaction; only the write that sets it sends. The flag is
// cleared on approve (see EventService.approveEventPhotos), so a later batch on
// the same event notifies again.
// ============================================================

function db() {
  return admin.database();
}

const REVIEW_PERM = "classroom.review_photos";

// Active staff (e.g. reception) granted the review-photos permission, scoped to
// the branch when known.
async function permittedStaff(nurseryId, branchId) {
  const uids = [];
  try {
    const [staffSnap, permSnap] = await Promise.all([
      db().ref(`platform/${nurseryId}/staff`).once("value"),
      db().ref(`platform/${nurseryId}/permissionSets`).once("value"),
    ]);
    const granted = new Set();
    permSnap.forEach((p) => {
      const v = p.val() || {};
      const perms = v.permissions || {};
      if (perms[REVIEW_PERM] === true) granted.add(v.employeeId || p.key);
    });
    staffSnap.forEach((s) => {
      const v = s.val() || {};
      const uid = v.uid || s.key;
      if (v.isActive === false) return;
      if (branchId && v.branchId && v.branchId !== branchId) return;
      if (granted.has(uid)) uids.push(uid);
    });
  } catch (e) {
    console.error("permittedStaff error:", e.message);
  }
  return uids;
}

exports.onEventPhotoPending = onValueCreated(
  {
    ref: "platform/{nurseryId}/events/{eventId}/photos/{photoId}",
    instance: RTDB_INSTANCE,
  },
  async (event) => {
    const photo = event.data.val();
    if (!photo || typeof photo !== "object") return; // legacy string url
    if (photo.isApproved === true) return; // already visible → nothing to review

    const { nurseryId, eventId } = event.params;

    // ── Debounce: one notification per event batch ─────────────────────────
    const flagRef = db().ref(
      `platform/${nurseryId}/events/${eventId}/reviewNotifiedAt`
    );
    const res = await flagRef.transaction((cur) => (cur ? undefined : Date.now()));
    if (!res.committed) return; // another photo already fired the notification

    // ── Compose ────────────────────────────────────────────────────────────
    const evSnap = await db()
      .ref(`platform/${nurseryId}/events/${eventId}`)
      .once("value");
    const ev = evSnap.val() || {};
    const eventTitle =
      ev.title && String(ev.title).trim() ? String(ev.title).trim() : "فاعلية";
    const branchId = ev.branchId || null;

    // ── Recipients: managers + permitted staff, minus the uploader ─────────
    const [mgrs, staff] = await Promise.all([
      branchManagers(nurseryId, branchId),
      permittedStaff(nurseryId, branchId),
    ]);
    const uploader = photo.uploadedBy || null;
    const uids = [...new Set([...mgrs, ...staff])].filter(
      (u) => u && u !== uploader
    );
    if (uids.length === 0) return;

    const title = "صور فاعلية بانتظار المراجعة";
    const body = `صور جديدة في «${eventTitle}» بانتظار المراجعة والنشر لأولياء الأمور`;

    await notificationService.send({
      recipients: uids.map((uid) => ({ uid, role: Role.staff })),
      nurseryId,
      title,
      body,
      type: NotificationType.event,
      entityId: eventId,
      data: { kind: "event_photo_review", eventId },
    });

    console.log(
      `📸 Event-photo-review notice → ${uids.length} reviewer(s) for event ${eventId}`
    );
  }
);
