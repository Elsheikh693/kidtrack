const { onValueCreated } = require("firebase-functions/v2/database");
const { RTDB_INSTANCE } = require("../shared/constants");
const { handleEventCreated } = require("./eventNotifications");

// ============================================================
// 🔥 TRIGGER: platform/{nurseryId}/events/{eventId}
// ============================================================
//
// Fires when reception creates a nursery event. Notifies parents
// of the event's branch (or the whole nursery if branch-less).
// ============================================================

exports.onNurseryEventCreated = onValueCreated(
  {
    ref: "platform/{nurseryId}/events/{eventId}",
    instance: RTDB_INSTANCE,
  },
  async (event) => {
    const data = event.data.val();
    if (!data) return;

    const { nurseryId, eventId } = event.params;

    console.log(
      `🎪 EVENT CREATED: "${data.title}" — nursery=${nurseryId} branch=${data.branchId || "ALL"}`
    );

    await handleEventCreated({ event: data, nurseryId, eventId });
  }
);
