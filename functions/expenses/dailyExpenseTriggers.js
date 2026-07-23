const { onValueCreated } = require("firebase-functions/v2/database");
const { RTDB_INSTANCE } = require("../shared/constants");
const { handleDailyExpense } = require("./dailyExpenseNotifications");

// ============================================================
// 🔥 TRIGGER: platform/{nurseryId}/invoices/{invoiceId}
// ============================================================
//
// Fires once per NEW invoice, but only acts on reception-created daily
// expenses (`source: 'daily_expense'`). Monthly-subscription / other invoices
// are ignored via the source guard. Recording a payment UPDATES the invoice
// (not a create), so it never re-notifies.
// ============================================================

exports.onDailyExpenseCreated = onValueCreated(
  {
    ref: "platform/{nurseryId}/invoices/{invoiceId}",
    instance: RTDB_INSTANCE,
  },
  async (event) => {
    const data = event.data.val();
    if (!data || data.source !== "daily_expense") return;

    const { nurseryId, invoiceId } = event.params;

    console.log(`🧾 DAILY EXPENSE: ${invoiceId} nursery=${nurseryId}`);

    await handleDailyExpense({
      invoice: { ...data, key: invoiceId },
      nurseryId,
    });
  },
);
