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

// ------------------------------------------------------------
// 🧹 EVENT CLEANUP (scheduled — hard-delete events past retention)
// ------------------------------------------------------------

const { eventCleanupScan } = require("./events/eventCleanup");

exports.eventCleanupScan = eventCleanupScan;

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
// 📭 ABSENT AT SHIFT END (scheduled — auto-message parents of absent children)
// ============================================================

const { absentShiftEndScan } = require("./engagement/absentShiftEnd");

exports.absentShiftEndScan = absentShiftEndScan;

// ============================================================
// 🚪 WITHDRAW CHILD (callable — hard delete + parent/auth cleanup)
// ============================================================

const { withdrawChild } = require("./children/withdrawChild");

exports.withdrawChild = withdrawChild;

// ============================================================
// 🔑 ACTIVATE (callable, public) — activation code → custom token
// ============================================================

const { activate } = require("./auth/activate");

exports.activate = activate;

// ============================================================
// 🏚️ DELETE NURSERY (callable — full cascade + owner/staff/parent auth cleanup)
// ============================================================

const { deleteNursery } = require("./nurseries/deleteNursery");

exports.deleteNursery = deleteNursery;

// ============================================================
// 📸 ACTIVITY PHOTO REVIEW (nudge reviewers when photos await approval)
// ============================================================

const { onActivityPhotoPending } = require("./activities/photoReviewTriggers");

exports.onActivityPhotoPending = onActivityPhotoPending;

// ============================================================
// 📝 GUARDIAN NOTES (notify the teacher when a parent writes a note)
// ============================================================

const { onGuardianNoteCreated } = require("./guardianNotes/guardianNoteTriggers");

exports.onGuardianNoteCreated = onGuardianNoteCreated;
