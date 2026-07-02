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

module.exports = { parentsOfChild, childFirstName };
