const notificationService = require("../shared/notificationService");
const {
  parentsOfChild,
  childFirstName,
  parentFirstName,
} = require("../shared/audienceService");
const { NotificationType, Role } = require("../shared/constants");

// ============================================================
// 🍼 DAILY CARE → PARENT NOTIFICATIONS
// ============================================================
//
// ONE handler for every childDailyEvents entry. Branch on eventType.
// A new care type = a new case here, NOT a new trigger.
// Return null for event types that shouldn't notify (yet).
//
// Copy is PERSONAL: it greets the parent by their own first name so the
// notification feels addressed to them, not a broadcast. When we don't
// know the parent's name we fall back to a warm nameless greeting.
// ============================================================

function greeting(parentName) {
  return parentName ? `${parentName} 👋` : "تحديث من الحضانة 👋";
}

// eventType → { title, body } addressed to THIS parent. childName is neutral
// (we don't say ابنك/ابنتك). Returns null for event types we don't notify yet.
function buildMessage(eventType, childName, parentName) {
  switch (eventType) {
    case "check_in":
      return {
        title: greeting(parentName),
        body: `${childName} وصل الحضانة بأمان 🎉 نتمنى له يوماً سعيداً!`,
      };
    case "check_out":
      return {
        title: greeting(parentName),
        body: `${childName} غادر الحضانة الآن بأمان.`,
      };
    default:
      return null; // not wired for notifications yet
  }
}

async function handleCareEvent({ event, nurseryId, childId }) {
  try {
    const eventType = event.eventType;

    // Skip early if this event type never notifies — avoids needless reads.
    if (!buildMessage(eventType, "", "")) {
      console.log(`⏭️ eventType '${eventType}' not wired — skip`);
      return;
    }

    const childName = await childFirstName(nurseryId, childId);

    const parentIds = await parentsOfChild(nurseryId, childId);
    if (parentIds.length === 0) {
      console.log(`📭 No parents linked to child ${childId}`);
      return;
    }

    // Build a message addressed to each parent by their own name.
    const recipients = await Promise.all(
      parentIds.map(async (uid) => {
        const parentName = await parentFirstName(uid);
        const msg = buildMessage(eventType, childName, parentName);
        return { uid, role: Role.parent, title: msg.title, body: msg.body };
      }),
    );

    await notificationService.send({
      recipients,
      nurseryId,
      type: NotificationType.attendance,
      entityId: childId,
      data: { screen: "child_timeline", childId, eventType },
    });
  } catch (e) {
    console.error("❌ handleCareEvent ERROR:", e);
  }
}

module.exports = { handleCareEvent };
