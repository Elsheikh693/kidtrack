const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

// ============================================================
// 🔑 ACTIVATE (callable, PUBLIC) — code → Firebase custom token
// ============================================================
//
// The role-agnostic activation engine's login endpoint. An activation code IS
// the credential: whoever holds it (parent, reception, teacher, manager, owner)
// enters/scans it and is signed straight in — no username, no password.
//
// Intentionally callable WITHOUT auth, because it runs BEFORE login, before the
// nursery/session is known. The code is the secret; codes live at the global
// root `activationCodes/{code}` (the code IS the key).
//
// A code is DURABLE: it keeps working as a login key until the creator rotates
// it (Regenerate deletes this key and mints a new one). `isActivated` is pure
// telemetry ("used at least once") and never disables the code.
//
// Input : { code }
// Output: { ok, token, role, nurseryId, targetId }
// ============================================================

// RTDB keys can't contain . $ # [ ] / — reject early so a malformed code can
// never turn into a wildcard path read.
const FORBIDDEN_KEY_CHARS = /[.$#\[\]/]/;

exports.activate = onCall(async (request) => {
  const code = ((request.data && request.data.code) || "")
    .toString()
    .trim()
    .toUpperCase();

  if (!code || FORBIDDEN_KEY_CHARS.test(code)) {
    throw new HttpsError("invalid-argument", "A valid activation code is required.");
  }

  const db = admin.database();
  const ref = db.ref(`activationCodes/${code}`);

  const snap = await ref.get();
  if (!snap.exists()) {
    throw new HttpsError("not-found", "This activation code is not valid.");
  }

  const data = snap.val() || {};
  const targetId = (data.targetId || "").toString();
  const role = (data.role || "").toString();
  const nurseryId = (data.nurseryId || "").toString();

  if (!targetId) {
    throw new HttpsError("failed-precondition", "This code is not linked to an account.");
  }

  // Telemetry only — flag first use, never gate on it.
  if (data.isActivated !== true) {
    await ref.child("isActivated").set(true);
  }

  // The custom token's subject is the target account's Firebase Auth uid, so the
  // client signs in AS that account. Role/nursery ride along as claims so the
  // app shell can route without a second round-trip.
  const token = await admin.auth().createCustomToken(targetId, {
    activationRole: role,
    nurseryId,
  });

  console.log(`🔑 ACTIVATED code=${code} target=${targetId} role=${role} nursery=${nurseryId}`);

  return { ok: true, token, role, nurseryId, targetId };
});
