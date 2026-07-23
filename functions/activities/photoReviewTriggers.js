const admin = require("firebase-admin");
const { onValueCreated } = require("firebase-functions/v2/database");
const { RTDB_INSTANCE, NotificationType, Role } = require("../shared/constants");
const { branchManagers } = require("../shared/audienceService");
const notificationService = require("../shared/notificationService");

// ============================================================
// 📸 PHOTO REVIEW — nudge reviewers when photos need approving
// ============================================================
//
// Teachers upload activity photos as `isApproved: false` (hidden from
// guardians). A reviewer (branch manager / owner / staff granted the
// `classroom.review_photos` permission) must approve them before they
// publish. This trigger tells the reviewer(s) that a batch is waiting.
//
// TRIGGER: platform/{nurseryId}/classroomActivities/{classroomId}/{activityId}/photos/{photoId}
//
// A teacher usually drops several photos at once — one write per photo.
// To send ONE notification per activity (not per photo) we set a
// `reviewNotifiedAt` flag on the activity via a transaction; only the
// write that actually sets it sends. The flag is cleared when the batch
// is approved (see TeacherActivityService.approveActivityPhotos), so a
// later batch on the same activity notifies again.
// ============================================================

function db() {
  return admin.database();
}

const REVIEW_PERM = "classroom.review_photos";

async function resolveBranchId(nurseryId, classroomId) {
  try {
    const snap = await db()
      .ref(`platform/${nurseryId}/classrooms/${classroomId}`)
      .once("value");
    const v = snap.val() || {};
    if (v.branchId) return v.branchId;
    const bids = v.branchIds;
    if (Array.isArray(bids) && bids.length) return bids[0];
    if (bids && typeof bids === "object") {
      const vals = Object.values(bids);
      if (vals.length) return vals[0];
    }
  } catch (e) {
    console.error("resolveBranchId error:", e.message);
  }
  return null;
}

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

async function staffName(nurseryId, uid) {
  try {
    const snap = await db()
      .ref(`platform/${nurseryId}/staff/${uid}/name`)
      .once("value");
    return snap.val() ? String(snap.val()) : "";
  } catch (_) {
    return "";
  }
}

exports.onActivityPhotoPending = onValueCreated(
  {
    ref: "platform/{nurseryId}/classroomActivities/{classroomId}/{activityId}/photos/{photoId}",
    instance: RTDB_INSTANCE,
  },
  async (event) => {
    const photo = event.data.val();
    if (!photo || typeof photo !== "object") return; // legacy string url
    if (photo.isApproved === true) return; // already visible → nothing to review

    const { nurseryId, classroomId, activityId } = event.params;

    // ── Debounce: one notification per activity batch ──────────────────────
    const flagRef = db().ref(
      `platform/${nurseryId}/classroomActivities/${classroomId}/${activityId}/reviewNotifiedAt`
    );
    const res = await flagRef.transaction((cur) => (cur ? undefined : Date.now()));
    if (!res.committed) return; // another photo already fired the notification

    // ── Compose ────────────────────────────────────────────────────────────
    const actSnap = await db()
      .ref(`platform/${nurseryId}/classroomActivities/${classroomId}/${activityId}`)
      .once("value");
    const act = actSnap.val() || {};
    const activityTitle =
      act.subjectName && String(act.subjectName).trim()
        ? String(act.subjectName).trim()
        : act.title && String(act.title).trim()
        ? String(act.title).trim()
        : "نشاط";
    const teacherName = act.teacherId
      ? await staffName(nurseryId, act.teacherId)
      : "";

    // ── Recipients: managers + permitted staff, minus the uploader ─────────
    const branchId = await resolveBranchId(nurseryId, classroomId);
    const [mgrs, staff] = await Promise.all([
      branchManagers(nurseryId, branchId),
      permittedStaff(nurseryId, branchId),
    ]);
    const uids = [...new Set([...mgrs, ...staff])].filter(
      (u) => u && u !== act.teacherId
    );
    if (uids.length === 0) return;

    const title = "صور بانتظار المراجعة";
    const body = teacherName
      ? `${teacherName} أضافت صورًا في «${activityTitle}» — راجعها لنشرها لأولياء الأمور`
      : `صور جديدة في «${activityTitle}» بانتظار المراجعة والنشر`;

    await notificationService.send({
      recipients: uids.map((uid) => ({ uid, role: Role.staff })),
      nurseryId,
      title,
      body,
      type: NotificationType.activity,
      entityId: activityId,
      data: { kind: "photo_review", classroomId, activityId },
    });

    console.log(
      `📸 Photo-review notice → ${uids.length} reviewer(s) for activity ${activityId}`
    );
  }
);
