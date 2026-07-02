const { onValueCreated } = require("firebase-functions/v2/database");
const { RTDB_INSTANCE } = require("../shared/constants");
const { handleCareEvent } = require("./careNotifications");

// ============================================================
// 🔥 TRIGGER: platform/{nurseryId}/childDailyEvents/{date}/{childId}/{eventId}
// ============================================================
//
// Fires once per NEW daily-care event (append-only journal).
// Handles ALL care types (check_in / check_out / meal / nap / ...)
// via a switch inside handleCareEvent.
// ============================================================

exports.onChildDailyEvent = onValueCreated(
  {
    ref: "platform/{nurseryId}/childDailyEvents/{date}/{childId}/{eventId}",
    instance: RTDB_INSTANCE,
  },
  async (event) => {
    const data = event.data.val();
    if (!data) return;

    const { nurseryId, childId } = event.params;

    console.log(
      `🍼 CARE EVENT: ${data.eventType} — child=${childId} nursery=${nurseryId}`
    );

    await handleCareEvent({ event: data, nurseryId, childId });
  }
);
