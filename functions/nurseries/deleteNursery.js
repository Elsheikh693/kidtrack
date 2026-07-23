const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

// ============================================================
// 🏚️ DELETE NURSERY (callable) — full cascade + auth cleanup
// ============================================================
//
// Called by the SuperAdmin from the nurseries list. A nursery is spread across
// three places the client-side delete can never fully reach:
//   • the global registry entry   platform/info/{nid}
//   • the entire scoped subtree    platform/{nid}/...  (children, staff, finance…)
//   • one Firebase Auth account + users/{uid} record per owner / staff / parent
//     — the client SDK can only delete the *signed-in* user, so every other
//     account needs the Admin SDK (same reason as withdrawChild).
//
// The old client delete removed ONLY platform/info/{nid}, orphaning every
// account, the scoped subtree, activation codes and per-user notifications.
//
// This gathers every uid tied to the nursery (owners from the registry, staff by
// their node keys, parents by their `uid` field), nulls all RTDB data in ONE
// multi-path update, then deletes each Auth account.
//
// Input : { nurseryId }
// Output: { ok, deletedAuth:[uid], accounts, codes, nurseryId }
// ============================================================

exports.deleteNursery = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const db = admin.database();

  // Only the SuperAdmin may wipe an entire nursery.
  const callerSnap = await db.ref(`users/${request.auth.uid}`).get();
  const callerType = ((callerSnap.val() || {}).userType || "").toString();
  if (callerType !== "superAdmin") {
    throw new HttpsError("permission-denied", "Only a SuperAdmin can delete a nursery.");
  }

  const nurseryId = ((request.data && request.data.nurseryId) || "").toString().trim();
  if (!nurseryId) {
    throw new HttpsError("invalid-argument", "nurseryId is required.");
  }

  const base = `platform/${nurseryId}`;
  const uids = new Set();

  // 1) Registry entry → owner uids. Idempotent: already gone ⇒ report success.
  const infoSnap = await db.ref(`platform/info/${nurseryId}`).get();
  if (!infoSnap.exists()) {
    return { ok: true, alreadyGone: true, deletedAuth: [], accounts: 0, codes: 0, nurseryId };
  }
  const info = infoSnap.val() || {};
  if (info.ownerId) uids.add(info.ownerId.toString());
  const ownerIds = info.ownerIds;
  if (Array.isArray(ownerIds)) {
    for (const id of ownerIds) if (id) uids.add(id.toString());
  } else if (ownerIds && typeof ownerIds === "object") {
    for (const id of Object.values(ownerIds)) if (id) uids.add(id.toString());
  }

  // 2) Staff uids = keys of platform/{nid}/staff (node is keyed by uid).
  const staffSnap = await db.ref(`${base}/staff`).get();
  if (staffSnap.exists()) {
    for (const uid of Object.keys(staffSnap.val() || {})) uids.add(uid.toString());
  }

  // 3) Parent uids = the `uid` field on each platform/{nid}/parents/* record
  //    (that node is keyed by push id, not uid).
  const parentsSnap = await db.ref(`${base}/parents`).get();
  if (parentsSnap.exists()) {
    for (const p of Object.values(parentsSnap.val() || {})) {
      if (p && p.uid) uids.add(p.uid.toString());
    }
  }

  // 4) Branch ids → per-branch bus tracking (global, branch-scoped node).
  const branchIds = [];
  const branchesSnap = await db.ref(`${base}/branches`).get();
  if (branchesSnap.exists()) {
    for (const bid of Object.keys(branchesSnap.val() || {})) branchIds.push(bid);
  }

  // 5) Activation codes for this nursery (global root, indexed on nurseryId).
  const codesSnap = await db
    .ref("activationCodes")
    .orderByChild("nurseryId")
    .equalTo(nurseryId)
    .get();
  const codeKeys = codesSnap.exists() ? Object.keys(codesSnap.val() || {}) : [];

  // 6) One multi-path delete for every RTDB record tied to the nursery.
  const updates = {};
  updates[base] = null;                          // whole scoped subtree
  updates[`platform/info/${nurseryId}`] = null;  // global registry entry
  updates[`platformBilling/${nurseryId}`] = null;
  updates[`platformFeedback/${nurseryId}`] = null;
  for (const code of codeKeys) updates[`activationCodes/${code}`] = null;
  for (const bid of branchIds) updates[`busTracking/${bid}`] = null;

  // A person can hold memberships in more than one nursery. The GLOBAL identity
  // (users/{uid}) + auth account are removed only when this nursery held their
  // LAST membership; otherwise we drop just this nursery's membership entries so
  // their login at the other nursery survives. (Never mix an ancestor path and a
  // descendant path in one update — Firebase rejects that.)
  const identityToDelete = [];
  for (const uid of uids) {
    const memSnap = await db.ref(`users/${uid}/memberships`).get();
    const mems = memSnap.exists() ? memSnap.val() || {} : {};
    const keys = Object.keys(mems);
    const hereKeys = keys.filter((k) =>
      mems[k] && mems[k].nurseryId
        ? mems[k].nurseryId.toString() === nurseryId
        : k.startsWith(`${nurseryId}_`)
    );

    if (keys.length === 0 || keys.length - hereKeys.length === 0) {
      // Legacy account (no memberships node) or nothing left elsewhere.
      updates[`users/${uid}`] = null;         // global profile record
      updates[`notifications/${uid}`] = null; // global per-user inbox
      identityToDelete.push(uid);
    } else {
      for (const k of hereKeys) {
        updates[`users/${uid}/memberships/${k}`] = null;
      }
    }
  }

  await db.ref().update(updates);

  // 7) Delete Firebase Auth ONLY for fully-orphaned identities (Admin SDK only).
  const deletedAuth = [];
  for (const uid of identityToDelete) {
    try {
      await admin.auth().deleteUser(uid);
      deletedAuth.push(uid);
    } catch (e) {
      // user-not-found is fine (a record existed without an auth account).
      if (e && e.code === "auth/user-not-found") {
        deletedAuth.push(uid);
      } else {
        console.error(`deleteNursery: failed to delete auth user ${uid}`, e);
      }
    }
  }

  console.log(
    `🏚️ DELETED nursery=${nurseryId} accounts=${uids.size} ` +
      `deletedAuth=${deletedAuth.length} codes=${codeKeys.length}`
  );

  return {
    ok: true,
    deletedAuth,
    accounts: uids.size,
    codes: codeKeys.length,
    nurseryId,
  };
});
