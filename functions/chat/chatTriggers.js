const { onValueCreated } = require("firebase-functions/v2/database");
const { RTDB_INSTANCE } = require("../shared/constants");
const { handleChatMessage } = require("./chatNotifications");

// ============================================================
// 🔥 TRIGGER: platform/{nurseryId}/chats/{childId}/messages/{messageId}
// ============================================================
//
// Fires on every new chat message. Notifies the other side of the
// per-child manager↔parent conversation.
// ============================================================

exports.onChatMessageCreated = onValueCreated(
  {
    ref: "platform/{nurseryId}/chats/{childId}/messages/{messageId}",
    instance: RTDB_INSTANCE,
  },
  async (event) => {
    const data = event.data.val();
    if (!data) return;

    const { nurseryId, childId } = event.params;

    console.log(
      `💬 CHAT MSG: from=${data.senderRole} child=${childId} nursery=${nurseryId}`
    );

    await handleChatMessage({ message: data, nurseryId, childId });
  }
);
