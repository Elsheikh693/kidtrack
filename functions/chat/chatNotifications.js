const admin = require("firebase-admin");
const notificationService = require("../shared/notificationService");
const {
  branchManagers,
  branchReceptionists,
} = require("../shared/audienceService");
const { NotificationType, Role } = require("../shared/constants");

// ============================================================
// 💬 CHAT MESSAGE → NOTIFICATION FOR THE OTHER SIDE
// ============================================================
//
// Per-child manager↔parent thread. A message carries senderRole
// ('manager' | 'parent'). We notify the OTHER side:
//   manager → parent (meta.parentId)
//   parent  → the responsible branch manager(s) (meta.branchId)
// ============================================================

function preview(text) {
  const t = String(text || "").trim();
  return t.length > 120 ? `${t.slice(0, 117)}…` : t;
}

async function handleChatMessage({ message, nurseryId, childId }) {
  try {
    const text = preview(message.text);
    if (!text) return;

    const metaSnap = await admin
      .database()
      .ref(`platform/${nurseryId}/chats/${childId}/meta`)
      .once("value");
    const meta = metaSnap.val() || {};

    const childName = meta.childName || "طفلك";

    if (message.senderRole === "manager") {
      // Nursery → parent
      if (!meta.parentId) {
        console.log(`📭 chat: no parentId in meta for child ${childId}`);
        return;
      }
      await notificationService.send({
        recipients: [{ uid: meta.parentId, role: Role.parent }],
        nurseryId,
        title: `رسالة من الحضانة بخصوص ${childName} 💬`,
        body: text,
        type: NotificationType.chat,
        entityId: childId,
        data: { screen: "chat_thread", childId },
      });
      return;
    }

    // Parent → responsible nursery staff. Reception shares the manager side of
    // the thread, so notify both branch managers AND receptionists.
    const [managerIds, receptionIds] = await Promise.all([
      branchManagers(nurseryId, meta.branchId),
      branchReceptionists(nurseryId, meta.branchId),
    ]);
    const staffIds = [...new Set([...managerIds, ...receptionIds])];
    if (staffIds.length === 0) {
      console.log(`📭 chat: no staff for branch ${meta.branchId}`);
      return;
    }
    const recipients = staffIds.map((uid) => ({ uid, role: Role.staff }));

    await notificationService.send({
      recipients,
      nurseryId,
      title: `رسالة من ${meta.parentName || "ولي أمر"} (${childName}) 💬`,
      body: text,
      type: NotificationType.chat,
      entityId: childId,
      data: { screen: "chat_thread", childId },
    });
  } catch (e) {
    console.error("❌ handleChatMessage ERROR:", e);
  }
}

module.exports = { handleChatMessage };
