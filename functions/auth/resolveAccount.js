const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

// ============================================================
// 👤 RESOLVE ACCOUNT (callable, auth-required) — phone → uid
// ============================================================
//
// Identity is ONE Firebase Auth account per phone across the WHOLE platform. A
// person can be staff at several nurseries AND a guardian — every one of those
// is a *membership* that hangs off the SAME uid (see users/{uid}/memberships).
//
// This is the single "get-or-create the identity for this phone" primitive that
// the staff / guardian creation flows call BEFORE attaching a membership. It is
// what lets the same phone be added as a second role (a teacher who is also a
// mum) or at a second nursery, instead of failing on Firebase Auth's global
// `email-already-in-use` collision — the bug this replaces.
//
// The synthetic email mirrors the client convention (`${phone}@gmail.com`), and
// the phone doubles as the initial password for brand-new accounts (matching the
// old client-side create), so activation-code login keeps working unchanged.
//
// Input : { phone, name? }
// Output: { ok, uid, created }   (created=false → the phone already had an account)
// ============================================================

// Egyptian mobiles are 11 digits; keep a permissive 6–15 range so the same
// min-length rule the client enforces (Firebase password ≥ 6) holds here too.
const PHONE_RE = /^[0-9]{6,15}$/;

exports.resolveAccount = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }

  const phone = ((request.data && request.data.phone) || "").toString().trim();
  const name = ((request.data && request.data.name) || "").toString().trim();

  if (!PHONE_RE.test(phone)) {
    throw new HttpsError("invalid-argument", "A valid phone number is required.");
  }

  const email = `${phone}@gmail.com`;
  const auth = admin.auth();

  // Existing identity? Reuse it — this is the whole point: the same phone can now
  // carry a second role / a second nursery instead of colliding on the email.
  try {
    const existing = await auth.getUserByEmail(email);
    console.log(`👤 RESOLVE reused uid=${existing.uid} phone=${phone}`);
    return { ok: true, uid: existing.uid, created: false };
  } catch (e) {
    if (!e || e.code !== "auth/user-not-found") {
      console.error("resolveAccount: getUserByEmail failed", e);
      throw new HttpsError("internal", "Could not resolve the account.");
    }
  }

  // First time this phone is seen anywhere on the platform — create the account.
  try {
    const created = await auth.createUser({
      email,
      password: phone,
      displayName: name || undefined,
    });
    console.log(`👤 RESOLVE created uid=${created.uid} phone=${phone}`);
    return { ok: true, uid: created.uid, created: true };
  } catch (e) {
    // Race: the account was created between the lookup and now — re-resolve it.
    if (e && e.code === "auth/email-already-exists") {
      const existing = await auth.getUserByEmail(email);
      return { ok: true, uid: existing.uid, created: false };
    }
    console.error("resolveAccount: createUser failed", e);
    throw new HttpsError("internal", "Could not create the account.");
  }
});
