const notificationService = require("../shared/notificationService");
const { parentsOfChild, childFirstName } = require("../shared/audienceService");
const { NotificationType, Role } = require("../shared/constants");

// ============================================================
// 🧾 DAILY EXPENSE → PARENT NOTIFICATION
// ============================================================
//
// Reception charges a specific child's guardian for an ad-hoc daily expense
// (pampers, a book, medicine…). The charge is stored as an invoice tagged
// `source: 'daily_expense'`. This resolves the child's guardian(s) directly
// from `parentChildren` (father + mother) and pushes a dedicated finance
// notification — independent of the chat message the app also writes, so the
// notification is reliable even for a brand-new chat thread.
// ============================================================

function fmtAmount(v) {
  const n = Number(v || 0);
  return Number.isInteger(n) ? String(n) : n.toFixed(2);
}

async function handleDailyExpense({ invoice, nurseryId }) {
  try {
    const childId = (invoice.childId || "").toString();
    if (!childId) return;

    const parentIds = await parentsOfChild(nurseryId, childId);
    if (parentIds.length === 0) {
      console.log(`📭 daily-expense: no parents for child ${childId}`);
      return;
    }

    const firstName = (await childFirstName(nurseryId, childId)) || "طفلك";
    const amount = fmtAmount(invoice.totalAmount != null ? invoice.totalAmount : invoice.amount);
    const reason = (invoice.title || "").toString().trim();

    const title = `مصروف جديد على ${firstName}`;
    const body = reason
      ? `المبلغ: ${amount} ج.م — ${reason}`
      : `المبلغ: ${amount} ج.م`;

    await notificationService.send({
      recipients: parentIds.map((uid) => ({ uid, role: Role.parent })),
      nurseryId,
      title,
      body,
      type: NotificationType.finance,
      entityId: invoice.key || childId,
      data: { screen: "parent_attention", childId },
    });
  } catch (e) {
    console.error("❌ handleDailyExpense ERROR:", e);
  }
}

module.exports = { handleDailyExpense };
