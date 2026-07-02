const admin = require("firebase-admin");

admin.initializeApp();

// ============================================================
// 🍼 DAILY CARE (check-in / check-out / meal / nap / ...)
// ============================================================

const { onChildDailyEvent } = require("./careEvents/careTriggers");

exports.onChildDailyEvent = onChildDailyEvent;
