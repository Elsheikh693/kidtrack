const admin = require("firebase-admin");

admin.initializeApp();

// ============================================================
// 🍼 DAILY CARE (check-in / check-out / meal / nap / ...)
// ============================================================

const { onChildDailyEvent } = require("./careEvents/careTriggers");

exports.onChildDailyEvent = onChildDailyEvent;

// ============================================================
// 🎪 EVENTS (trips / parties / meetings — created by reception)
// ============================================================

const { onNurseryEventCreated } = require("./events/eventTriggers");

exports.onNurseryEventCreated = onNurseryEventCreated;

// ============================================================
// 📚 COURSES (published by the manager)
// ============================================================

const { onCourseCreated } = require("./courses/courseTriggers");

exports.onCourseCreated = onCourseCreated;

// ============================================================
// 💬 CHAT (per-child manager ↔ parent messages)
// ============================================================

const { onChatMessageCreated } = require("./chat/chatTriggers");

exports.onChatMessageCreated = onChatMessageCreated;

// ============================================================
// 💗 MID-DAY NUDGE (scheduled — "come follow your child's day")
// ============================================================

const { midDayNudgeScan } = require("./engagement/midDayNudge");

exports.midDayNudgeScan = midDayNudgeScan;

// ============================================================
// 🚪 WITHDRAW CHILD (callable — hard delete + parent/auth cleanup)
// ============================================================

const { withdrawChild } = require("./children/withdrawChild");

exports.withdrawChild = withdrawChild;
