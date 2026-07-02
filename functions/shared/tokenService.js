const admin = require("firebase-admin");
const { Role } = require("./constants");

// ============================================================
// 🔑 TOKEN SERVICE — the ONLY place that knows where FCM tokens live
// ============================================================
//
// Current KidTrack storage (single token, overwritten on refresh):
//   parent → users/{uid}/fcmToken
//   staff  → platform/{nurseryId}/staff/{uid}/fcmToken
//
// Returns an array (already multi-device ready) even though there is
// only one token per user today. When multi-device lands, only this
// file changes.
// ============================================================

function db() {
  return admin.database();
}

function tokenPath({ role, nurseryId, uid }) {
  return role === Role.staff
    ? `platform/${nurseryId}/staff/${uid}/fcmToken`
    : `users/${uid}/fcmToken`;
}

async function tokensFor({ role, nurseryId, uid }) {
  try {
    const snap = await db().ref(tokenPath({ role, nurseryId, uid })).once("value");
    const token = snap.val();
    return token ? [token] : [];
  } catch (e) {
    console.error(`❌ tokensFor(${uid}) error:`, e.message);
    return [];
  }
}

// Remove a dead token so we stop trying to reach it.
async function removeToken({ role, nurseryId, uid, token }) {
  try {
    const ref = db().ref(tokenPath({ role, nurseryId, uid }));
    const snap = await ref.once("value");
    if (snap.val() === token) {
      await ref.remove();
      console.log(`🧹 Removed dead token for ${uid}`);
    }
  } catch (e) {
    console.error(`❌ removeToken(${uid}) error:`, e.message);
  }
}

module.exports = { tokensFor, removeToken };
