const admin = require("firebase-admin");

// ============================================================
// 👥 AUDIENCE SERVICE — resolves an event into recipient uids
// ============================================================
//
// Kept separate from tokenService: this answers "WHO should hear
// about this event", tokenService answers "how do I reach a uid".
// ============================================================

function db() {
  return admin.database();
}

// All parents linked to a child (supports father + mother via parentChildren).
// Falls back to children/{childId}/parentId if no parentChildren links exist.
async function parentsOfChild(nurseryId, childId) {
  const ids = new Set();

  try {
    const snap = await db()
      .ref(`platform/${nurseryId}/parentChildren`)
      .orderByChild("childId")
      .equalTo(childId)
      .once("value");

    snap.forEach((c) => {
      const v = c.val();
      if (v && v.parentId) ids.add(v.parentId);
    });
  } catch (e) {
    console.error(`❌ parentsOfChild query error:`, e.message);
  }

  if (ids.size === 0) {
    const cs = await db()
      .ref(`platform/${nurseryId}/children/${childId}/parentId`)
      .once("value");
    if (cs.exists() && cs.val()) ids.add(cs.val());
  }

  return [...ids];
}

// All parents of ACTIVE children in a branch (father + mother via
// parentChildren, plus the child record's own parentId). Pass a falsy branchId
// to broadcast to the whole nursery. Only two reads per nursery regardless of
// how many children — safe for nursery-wide announcements (events / courses).
async function parentsOfBranch(nurseryId, branchId) {
  const parents = new Set();
  const allowedChildIds = new Set();

  try {
    const childrenSnap = await db()
      .ref(`platform/${nurseryId}/children`)
      .once("value");

    childrenSnap.forEach((c) => {
      const v = c.val() || {};
      if ((v.status || "active") !== "active") return;
      if (branchId && v.branchId !== branchId) return;
      allowedChildIds.add(c.key);
      if (v.parentId) parents.add(v.parentId);
    });
  } catch (e) {
    console.error(`❌ parentsOfBranch children error:`, e.message);
  }

  try {
    const pcSnap = await db()
      .ref(`platform/${nurseryId}/parentChildren`)
      .once("value");

    pcSnap.forEach((l) => {
      const v = l.val() || {};
      if (v.childId && allowedChildIds.has(v.childId) && v.parentId) {
        parents.add(v.parentId);
      }
    });
  } catch (e) {
    console.error(`❌ parentsOfBranch parentChildren error:`, e.message);
  }

  return [...parents];
}

// All active branch managers for a branch (falsy branchId → all managers in the
// nursery). Reads platform/{nid}/staff and filters by role.
async function branchManagers(nurseryId, branchId) {
  const uids = [];
  try {
    const snap = await db()
      .ref(`platform/${nurseryId}/staff`)
      .once("value");

    snap.forEach((s) => {
      const v = s.val() || {};
      if (v.role !== "branchManager") return;
      if (v.isActive === false) return;
      if (branchId && v.branchId && v.branchId !== branchId) return;
      uids.push(v.uid || s.key);
    });
  } catch (e) {
    console.error(`❌ branchManagers error:`, e.message);
  }
  return uids;
}

// Child's first name for personalised copy — "طفلك" fallback.
async function childFirstName(nurseryId, childId) {
  try {
    const snap = await db()
      .ref(`platform/${nurseryId}/children/${childId}/firstName`)
      .once("value");
    const name = snap.val();
    return name && String(name).trim() ? String(name).trim() : "طفلك";
  } catch (e) {
    console.error(`❌ childFirstName error:`, e.message);
    return "طفلك";
  }
}

// The parent's FIRST name so copy can address them directly ("أحمد 👋").
// Reads the global users/{uid}/name. Returns "" when unknown so callers can
// fall back to a nameless greeting.
async function parentFirstName(uid) {
  if (!uid) return "";
  try {
    const snap = await db().ref(`users/${uid}/name`).once("value");
    const full = snap.val();
    if (!full || !String(full).trim()) return "";
    return String(full).trim().split(/\s+/)[0];
  } catch (e) {
    console.error(`❌ parentFirstName error:`, e.message);
    return "";
  }
}

module.exports = {
  parentsOfChild,
  parentsOfBranch,
  branchManagers,
  childFirstName,
  parentFirstName,
};
