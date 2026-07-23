const admin = require("firebase-admin");

// ============================================================
// 🔕 PARENT NOTIFICATION PREFERENCES
// ============================================================
//
// Per-parent toggles stored at users/{uid}/notifPrefs, written by the Flutter
// NotificationPrefsService. Defaults MUST mirror that service:
//   attendance → true  (on even before the parent opens settings)
//   activities → false (opt-in)
//
// A missing node/field falls back to these defaults, so existing parents keep
// getting attendance notifications without any migration.
// ============================================================

const DEFAULTS = { attendance: true, activities: false };

async function parentAllows(uid, category) {
  const fallback = DEFAULTS[category] ?? true;
  if (!uid || !category) return fallback;
  try {
    const snap = await admin
      .database()
      .ref(`users/${uid}/notifPrefs/${category}`)
      .once("value");
    const val = snap.val();
    return typeof val === "boolean" ? val : fallback;
  } catch (e) {
    console.error(`❌ parentAllows(${uid}, ${category}) error:`, e.message);
    return fallback;
  }
}

module.exports = { parentAllows };
