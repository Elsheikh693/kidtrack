const notificationService = require("../shared/notificationService");
const { parentsOfChild, childFirstName } = require("../shared/audienceService");
const { NotificationType, Role } = require("../shared/constants");

// ============================================================
// 🍼 DAILY CARE → PARENT NOTIFICATIONS
// ============================================================
//
// ONE handler for every childDailyEvents entry. Branch on eventType.
// A new care type = a new case here, NOT a new trigger.
// Return null for event types that shouldn't notify (yet).
// ============================================================

function buildMessage(eventType, name) {
  switch (eventType) {
    case "check_in":
      return {
        title: `${name} وصل الحضانة بأمان 🎉`,
        body: "تم تسجيل وصوله الآن. نتمنى له يوماً سعيداً!",
      };
    case "check_out":
      return {
        title: `${name} غادر الحضانة`,
        body: "تم تسجيل مغادرته الآن بأمان.",
      };
    default:
      return null; // not wired for notifications yet
  }
}

async function handleCareEvent({ event, nurseryId, childId }) {
  try {
    const eventType = event.eventType;

    const name = await childFirstName(nurseryId, childId);
    const msg = buildMessage(eventType, name);
    if (!msg) {
      console.log(`⏭️ eventType '${eventType}' not wired — skip`);
      return;
    }

    const parentIds = await parentsOfChild(nurseryId, childId);
    if (parentIds.length === 0) {
      console.log(`📭 No parents linked to child ${childId}`);
      return;
    }

    const recipients = parentIds.map((uid) => ({ uid, role: Role.parent }));

    await notificationService.send({
      recipients,
      nurseryId,
      title: msg.title,
      body: msg.body,
      type: NotificationType.attendance,
      entityId: childId,
      data: { screen: "child_timeline", childId, eventType },
    });
  } catch (e) {
    console.error("❌ handleCareEvent ERROR:", e);
  }
}

module.exports = { handleCareEvent };
