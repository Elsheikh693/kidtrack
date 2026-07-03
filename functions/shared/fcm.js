const admin = require("firebase-admin");

// ============================================================
// 📲 RAW FCM SENDER — one token at a time
// ============================================================
//
// Returns { ok, invalid } so the caller can prune dead tokens.
// `invalid: true` means the token is permanently unusable
// (unregistered / malformed) and should be removed from RTDB.
// ============================================================

const INVALID_TOKEN_CODES = new Set([
  "messaging/invalid-registration-token",
  "messaging/registration-token-not-registered",
]);

// iOS aligns notification text by the RECIPIENT device's language, so Arabic
// copy shows left-aligned on an English-locale phone. Prefixing a Right-to-Left
// Mark (U+200F) forces the bidi base direction to RTL → right alignment on every
// device. Invisible; harmless on Android (already RTL via app locale).
const RLM = "‏";
function rtl(s) {
  if (!s) return s;
  return s.startsWith(RLM) ? s : RLM + s;
}

// FCM data payload values must all be strings.
function stringifyData(data) {
  if (!data) return undefined;
  const out = {};
  for (const [k, v] of Object.entries(data)) {
    if (v === null || v === undefined) continue;
    out[k] = typeof v === "string" ? v : String(v);
  }
  return out;
}

async function sendToToken(token, { title, body, data }) {
  if (!token) return { ok: false, invalid: false };

  try {
    await admin.messaging().send({
      token,
      notification: { title: rtl(title), body: rtl(body) },
      data: stringifyData(data),
      android: { priority: "high" },
      apns: { headers: { "apns-priority": "10" } },
    });
    return { ok: true, invalid: false };
  } catch (e) {
    const invalid = INVALID_TOKEN_CODES.has(e.code);
    console.error("❌ FCM error:", e.code || e.message);
    return { ok: false, invalid };
  }
}

module.exports = { sendToToken };
