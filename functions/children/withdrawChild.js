const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

// ============================================================
// 🚪 WITHDRAW CHILD (callable) — hard delete + parent cleanup
// ============================================================
//
// Called by reception/manager when a child leaves the nursery for good.
// Unlike a soft "status = withdrawn" flip, this fully removes the child so
// they never resurface in any roster, count, or lookup — and, when a guardian
// is left with no remaining children, deletes that guardian's records AND their
// Firebase Auth account, so the same phone/email can register cleanly at
// another nursery on the platform later.
//
// A compact record is written to `platform/{nid}/withdrawals/{id}` BEFORE the
// delete so the manager's "left this month" movement stat survives the wipe —
// UNLESS `skipLog` is set. `skipLog` is the "permanent delete" variant used to
// erase a child registered by mistake: same full cleanup, but nothing is left
// behind (no departure record), so it never counts as a nursery movement.
//
// Input : { nurseryId, childId, reason, skipLog? }
// Output: { ok, deletedChild, deletedParents:[uid], keptParents:[uid] }
// ============================================================

// Child-scoped collections that carry a `childId` field and are indexed on it
// (see database.rules.json). Queried by childId and deleted.
const CHILD_INDEXED_NODES = [
  "enrollments",
  "childAttendance",
  "medicalProfiles",
  "documents",
  "authorizedPickups",
  "pickupRequests",
  "childLeaveRequests",
  "incidents",
  "notes",
  "childReports",
  "assessments",
  "careEvents",
];

// Child-scoped collections keyed DIRECTLY by childId ({node}/{childId}).
const CHILD_KEYED_NODES = ["childCurrentStatus", "homeworkProgress"];

exports.withdrawChild = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const nurseryId = (request.data && request.data.nurseryId || "").toString().trim();
  const childId = (request.data && request.data.childId || "").toString().trim();
  const reason = (request.data && request.data.reason || "").toString().trim();
  const skipLog = request.data && request.data.skipLog === true;

  if (!nurseryId || !childId) {
    throw new HttpsError("invalid-argument", "nurseryId and childId are required.");
  }

  const db = admin.database();
  const base = `platform/${nurseryId}`;

  // 1) Load the child. Idempotent: if already gone, report success.
  const childSnap = await db.ref(`${base}/children/${childId}`).get();
  if (!childSnap.exists()) {
    return { ok: true, deletedChild: false, alreadyGone: true, deletedParents: [], keptParents: [] };
  }
  const child = childSnap.val() || {};

  // 2) Find this child's parent links.
  const linksSnap = await db.ref(`${base}/parentChildren`).get();
  const linkKeysForChild = []; // parentChildren keys to delete
  const parentIds = new Set();
  const linksByParent = {}; // parentId -> [childId, ...] (all their links)
  if (linksSnap.exists()) {
    const links = linksSnap.val() || {};
    for (const [key, link] of Object.entries(links)) {
      if (!link) continue;
      const pid = (link.parentId || "").toString();
      const cid = (link.childId || "").toString();
      if (!pid) continue;
      (linksByParent[pid] = linksByParent[pid] || []).push(cid);
      if (cid === childId) {
        linkKeysForChild.push(key);
        parentIds.add(pid);
      }
    }
  }

  // 3) Write the withdrawal log BEFORE deleting anything — unless this is a
  // permanent "delete a mistake" wipe (skipLog), which leaves no trace.
  if (!skipLog) {
    const logRef = db.ref(`${base}/withdrawals`).push();
    await logRef.set({
      key: logRef.key,
      childId,
      childName: `${child.firstName || ""} ${child.lastName || ""}`.trim(),
      branchId: child.branchId || "",
      classroomId: child.classroomId || null,
      reason: reason || null,
      withdrawnBy: request.auth.uid,
      withdrawnAt: Date.now(),
      parentIds: Array.from(parentIds),
    });
  }

  // 4) Decide which parents are orphaned (no children left after this removal).
  const orphanParents = [];
  const keptParents = [];
  for (const pid of parentIds) {
    const remaining = (linksByParent[pid] || []).filter((cid) => cid !== childId);
    if (remaining.length === 0) orphanParents.push(pid);
    else keptParents.push(pid);
  }

  // 5) Build one multi-path delete for all child + orphan-parent DB records.
  const updates = {};
  updates[`${base}/children/${childId}`] = null;
  for (const node of CHILD_KEYED_NODES) {
    updates[`${base}/${node}/${childId}`] = null;
  }
  for (const key of linkKeysForChild) {
    updates[`${base}/parentChildren/${key}`] = null;
  }
  // Query + null every indexed child-scoped record.
  await Promise.all(
    CHILD_INDEXED_NODES.map(async (node) => {
      const snap = await db
        .ref(`${base}/${node}`)
        .orderByChild("childId")
        .equalTo(childId)
        .get();
      if (snap.exists()) {
        for (const key of Object.keys(snap.val() || {})) {
          updates[`${base}/${node}/${key}`] = null;
        }
      }
    })
  );

  // Orphan-parent records: the guardian profile + nursery-scoped data always go.
  // The GLOBAL identity (users/{uid}) + auth account are removed only when this
  // nursery's guardian membership was the person's LAST one — they may still be
  // staff here, or a guardian at another nursery, and wiping the identity would
  // break those logins (a teacher who is also this child's mum).
  const parentsSnap = await db.ref(`${base}/parents`).get();
  const parentRecordKeyByUid = {};
  if (parentsSnap.exists()) {
    const parents = parentsSnap.val() || {};
    for (const [key, p] of Object.entries(parents)) {
      if (p && p.uid) parentRecordKeyByUid[p.uid.toString()] = key;
    }
  }

  const identityToDelete = []; // uids whose users/{uid} + auth account to remove
  for (const uid of orphanParents) {
    const recKey = parentRecordKeyByUid[uid];
    if (recKey) updates[`${base}/parents/${recKey}`] = null;
    updates[`${base}/courseProgress/${uid}`] = null;

    const memSnap = await db.ref(`users/${uid}/memberships`).get();
    const mems = memSnap.exists() ? memSnap.val() || {} : {};
    const thisKey = `${nurseryId}_parent`;
    const remaining = Object.keys(mems).filter((k) => k !== thisKey);

    if (remaining.length === 0) {
      // Legacy pure-parent, or their only membership — wipe the whole identity.
      // (Don't also null the membership child path: Firebase rejects overlapping
      // ancestor/descendant paths in one multi-location update.)
      updates[`users/${uid}`] = null;
      identityToDelete.push(uid);
    } else {
      // Other hats remain — drop just this nursery's guardian membership.
      updates[`users/${uid}/memberships/${thisKey}`] = null;
    }
  }

  await db.ref().update(updates);

  // 6) Delete Firebase Auth accounts ONLY for fully-orphaned identities.
  const deletedParents = [];
  for (const uid of identityToDelete) {
    try {
      await admin.auth().deleteUser(uid);
      deletedParents.push(uid);
    } catch (e) {
      // user-not-found is fine (record existed without an auth account).
      if (e && e.code !== "auth/user-not-found") {
        console.error(`withdrawChild: failed to delete auth user ${uid}`, e);
      } else {
        deletedParents.push(uid);
      }
    }
  }

  console.log(
    `🚪 ${skipLog ? "DELETED" : "WITHDREW"} child=${childId} nursery=${nurseryId} ` +
      `deletedParents=${deletedParents.length} keptParents=${keptParents.length}`
  );

  return {
    ok: true,
    deletedChild: true,
    deletedParents,
    keptParents,
  };
});
