const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

// ============================================================
// 👤 REMOVE GUARDIAN (callable) — unlink + orphan cleanup
// ============================================================
//
// Called from the child profile when a guardian was added by mistake / to the
// wrong child. Unlinks that one guardian from that one child. If the guardian
// is left with NO remaining children in this nursery, their records and — when
// this was their last membership on the platform — their global identity and
// Firebase Auth account are deleted too, so the same phone/email can register
// cleanly later. This mirrors the orphan-parent branch of `withdrawChild`, but
// scoped to a single guardian instead of a whole child.
//
// A guardian who still has other children here is only unlinked; nothing else
// about them is touched.
//
// Input : { nurseryId, childId, parentUid }
// Output: { ok, unlinked, deletedIdentity }
// ============================================================

exports.removeGuardian = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const nurseryId = (request.data && request.data.nurseryId || "").toString().trim();
  const childId = (request.data && request.data.childId || "").toString().trim();
  const parentUid = (request.data && request.data.parentUid || "").toString().trim();

  if (!nurseryId || !childId || !parentUid) {
    throw new HttpsError(
      "invalid-argument",
      "nurseryId, childId and parentUid are required."
    );
  }

  const db = admin.database();
  const base = `platform/${nurseryId}`;

  // 1) Find this guardian's parentChildren links: the one(s) to this child (to
  //    delete) and whether any link to OTHER children remains.
  const linksSnap = await db.ref(`${base}/parentChildren`).get();
  const linkKeysToDelete = [];
  let hasOtherChildren = false;
  if (linksSnap.exists()) {
    const links = linksSnap.val() || {};
    for (const [key, link] of Object.entries(links)) {
      if (!link) continue;
      const pid = (link.parentId || "").toString();
      if (pid !== parentUid) continue;
      const cid = (link.childId || "").toString();
      if (cid === childId) {
        linkKeysToDelete.push(key);
      } else {
        hasOtherChildren = true;
      }
    }
  }

  const updates = {};
  for (const key of linkKeysToDelete) {
    updates[`${base}/parentChildren/${key}`] = null;
  }

  // Legacy fallback: a child may still carry a direct `parentId` field pointing
  // at this guardian (pre-links data). Clear it so the guardian doesn't resurface.
  const childSnap = await db.ref(`${base}/children/${childId}`).get();
  if (childSnap.exists()) {
    const child = childSnap.val() || {};
    if ((child.parentId || "").toString() === parentUid) {
      updates[`${base}/children/${childId}/parentId`] = null;
    }
  }

  // 2) If the guardian still has other children here, unlink only — keep them.
  if (hasOtherChildren) {
    if (Object.keys(updates).length > 0) await db.ref().update(updates);
    console.log(
      `👤 UNLINKED guardian=${parentUid} child=${childId} nursery=${nurseryId} (kept — other children)`
    );
    return { ok: true, unlinked: true, deletedIdentity: false };
  }

  // 3) Orphaned in this nursery — remove the guardian's nursery-scoped records.
  const parentsSnap = await db.ref(`${base}/parents`).get();
  if (parentsSnap.exists()) {
    const parents = parentsSnap.val() || {};
    for (const [key, p] of Object.entries(parents)) {
      if (p && (p.uid || "").toString() === parentUid) {
        updates[`${base}/parents/${key}`] = null;
      }
    }
  }
  updates[`${base}/courseProgress/${parentUid}`] = null;

  // The GLOBAL identity + Auth account go only when this nursery's guardian
  // membership was the person's LAST one — they may still be staff here or a
  // guardian at another nursery, and wiping the identity would break those logins.
  let deleteIdentity = false;
  const memSnap = await db.ref(`users/${parentUid}/memberships`).get();
  const mems = memSnap.exists() ? memSnap.val() || {} : {};
  const thisKey = `${nurseryId}_parent`;
  const remaining = Object.keys(mems).filter((k) => k !== thisKey);
  if (remaining.length === 0) {
    // (Don't also null the membership child path: Firebase rejects overlapping
    // ancestor/descendant paths in one multi-location update.)
    updates[`users/${parentUid}`] = null;
    deleteIdentity = true;
  } else {
    updates[`users/${parentUid}/memberships/${thisKey}`] = null;
  }

  await db.ref().update(updates);

  // 4) Delete the Firebase Auth account only for a fully-orphaned identity.
  let deletedIdentity = false;
  if (deleteIdentity) {
    try {
      await admin.auth().deleteUser(parentUid);
      deletedIdentity = true;
    } catch (e) {
      if (e && e.code !== "auth/user-not-found") {
        console.error(`removeGuardian: failed to delete auth user ${parentUid}`, e);
      } else {
        deletedIdentity = true;
      }
    }
  }

  console.log(
    `👤 REMOVED guardian=${parentUid} child=${childId} nursery=${nurseryId} deletedIdentity=${deletedIdentity}`
  );

  return { ok: true, unlinked: true, deletedIdentity };
});
