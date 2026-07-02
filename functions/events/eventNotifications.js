const notificationService = require("../shared/notificationService");
const { parentsOfBranch } = require("../shared/audienceService");
const { NotificationType, Role } = require("../shared/constants");

// ============================================================
// 🎪 NURSERY EVENTS → PARENT NOTIFICATIONS
// ============================================================
//
// Reception creates an event (trip / party / meeting / ...) at
// platform/{nid}/events/{eventId}. We notify every parent in the
// event's branch (or the whole nursery when the event has no branch).
// User decision: notify for ALL event categories, not just trips.
// ============================================================

const AR_MONTHS = [
  "يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو",
  "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر",
];

const CATEGORY_EMOJI = {
  trip: "🚌",
  fun: "🎉",
  graduation: "🎓",
  sports: "⚽",
  meeting: "👥",
  cultural: "🎨",
  other: "📅",
};

function formatDate(ms) {
  if (!ms) return "";
  const d = new Date(Number(ms));
  return `${d.getDate()} ${AR_MONTHS[d.getMonth()]}`;
}

async function handleEventCreated({ event, nurseryId, eventId }) {
  try {
    if (event.isActive === false) return;

    const emoji = CATEGORY_EMOJI[event.category] || CATEGORY_EMOJI.other;
    const title = `فعالية جديدة ${emoji}`;

    const dateStr = formatDate(event.date);
    const bits = [event.title, dateStr, event.location].filter(Boolean);
    const body = bits.join(" • ");

    const parentIds = await parentsOfBranch(nurseryId, event.branchId);
    if (parentIds.length === 0) {
      console.log(`📭 No parents for event ${eventId}`);
      return;
    }

    const recipients = parentIds.map((uid) => ({ uid, role: Role.parent }));

    await notificationService.send({
      recipients,
      nurseryId,
      title,
      body,
      type: NotificationType.event,
      entityId: eventId,
      data: { screen: "event_detail", eventId, category: event.category || "" },
    });
  } catch (e) {
    console.error("❌ handleEventCreated ERROR:", e);
  }
}

module.exports = { handleEventCreated };
