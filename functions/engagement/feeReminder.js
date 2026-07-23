const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const { parentsOfChild } = require("../shared/audienceService");
const { RTDB_INSTANCE } = require("../shared/constants");

// ============================================================
// 💰 FEE-COLLECTION REMINDER AUTO CHAT (scheduled, per-child)
// ============================================================
//
// User intent: each nursery sets a monthly fee-collection window (e.g. day 1
// → day 5). Once that window closes, any guardian who still owes this month's
// fees should automatically get ONE polite, respectful chat message from the
// nursery gently asking about the payment — so nobody has to chase families by
// hand, and the tone stays warm.
//
// Mechanism: a daily scan. For each nursery that has a window configured, once
// the current Cairo day-of-month is PAST `feeCollectionToDay`, we look at every
// active child's monthly invoice (`month_{childId}_{YYYYMM}`); if it still has
// an outstanding balance (and no pending transfer-proof awaiting review) we
// write a manager-side message into the shared per-child chat thread. The
// existing onChatMessageCreated trigger then pushes the FCM to the parent.
//
// A dedup marker at platform/{nid}/feeReminderSent/{YYYYMM}/{childId}
// guarantees at-most-once per child per month — we never nag.
// ============================================================

const TZ = "Africa/Cairo";

function db() {
  return admin.database();
}

// Cairo day-of-month (1..31) and YYYYMM period key for "this month".
function cairoMonthContext(now = new Date()) {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: TZ,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(now);
  let y = "";
  let m = "";
  let d = "";
  for (const p of parts) {
    if (p.type === "year") y = p.value;
    if (p.type === "month") m = p.value;
    if (p.type === "day") d = p.value;
  }
  return { period: `${y}${m}`, day: Number(d), month: Number(m), year: Number(y) };
}

// Ported from InvoiceModel.hasOutstanding (Dart): still owes money, excluding
// fully-paid and cancelled invoices. Legacy 'paid' invoices with paidAmount 0
// count as fully paid via status.
function invoiceOutstanding(inv) {
  if (!inv || typeof inv !== "object") return false;
  const status = String(inv.status || "pending");
  if (status === "cancelled") return false;
  const total = Number(inv.totalAmount) || 0;
  const paid = Number(inv.paidAmount) || 0;
  const fullyPaid = status === "paid" || paid >= total - 0.5;
  if (fullyPaid) return false;
  const collected = paid < 0 ? 0 : Math.min(paid, total);
  const remaining = Math.max(0, total - collected);
  return remaining > 0.5;
}

function invoiceRemaining(inv) {
  const total = Number(inv.totalAmount) || 0;
  const paid = Number(inv.paidAmount) || 0;
  const collected = paid < 0 ? 0 : Math.min(paid, total);
  return Math.max(0, total - collected);
}

// A guardian-uploaded transfer screenshot is awaiting reception review — don't
// nag someone who has already sent proof.
function invoiceHasPendingProof(inv) {
  return inv && inv.proofUrl && String(inv.proofUrl).trim() !== "";
}

// Formats an amount with no trailing ".0" for whole numbers.
function money(n) {
  const v = Number(n) || 0;
  return Number.isInteger(v) ? String(v) : v.toFixed(2);
}

function feeReminderMessage(firstName, month, remaining) {
  const name =
    firstName && String(firstName).trim() ? String(firstName).trim() : "طفلكم";
  // Warm, respectful Egyptian tone. NO emoji here on purpose: the in-app chat
  // can't render color emoji (see the note in absentShiftEnd.js /
  // app_typography.dart). The guardian can just reply in the same thread.
  return (
    `أهلاً بيكم، حابين نفكّركم بلطف إن مصروفات ${name} عن شهر ${month} ` +
    `المتبقّي منها ${money(remaining)} ج.م لسه ما اتسجلتش عندنا. ` +
    `لو حضرتكم دفعتوها بالفعل يبقى تجاهلوا الرسالة دي ومتشكرين جدًا، ` +
    `ولو محتاجين أي مساعدة أو ترتيب للدفع إحنا في خدمتكم. متشكرين لتعاونكم معانا.`
  );
}

// Writes the polite reminder into the shared per-child chat thread as a
// manager-side message. Returns true when a message was actually sent.
async function sendFeeReminderChat(nurseryId, childId, child, period, remaining) {
  const markerRef = db().ref(
    `platform/${nurseryId}/feeReminderSent/${period}/${childId}`
  );
  if ((await markerRef.once("value")).exists()) return false; // already sent this month

  const parentIds = await parentsOfChild(nurseryId, childId);
  const parentId = parentIds[0];
  if (!parentId) return false; // no linked guardian to message

  const parentNameSnap = await db().ref(`users/${parentId}/name`).once("value");
  const parentName = parentNameSnap.val() ? String(parentNameSnap.val()) : "";

  const fullName = `${child.firstName || ""} ${child.lastName || ""}`.trim();
  const monthLabel = `${period.slice(4)}/${period.slice(0, 4)}`; // MM/YYYY
  const text = feeReminderMessage(child.firstName, monthLabel, remaining);
  const nowMs = Date.now();

  const chatRef = db().ref(`platform/${nurseryId}/chats/${childId}`);
  const metaRef = chatRef.child("meta");
  const existing = (await metaRef.once("value")).val() || {};

  // Write meta FIRST so the onChatMessageCreated trigger sees parentId/branchId
  // when it fires on the message below.
  await metaRef.update({
    childId,
    childName: fullName,
    childImage: child.profileImage || null,
    classroomId: child.classroomId || null,
    branchId: child.branchId || "",
    parentId,
    parentName,
    lastText: text,
    lastAt: nowMs,
    lastSenderRole: "manager",
    unreadParent: (Number(existing.unreadParent) || 0) + 1,
  });

  const msgRef = chatRef.child("messages").push();
  await msgRef.set({
    id: msgRef.key,
    senderId: "system",
    senderRole: "manager",
    text,
    createdAt: nowMs,
  });

  // Mark AFTER sending so a mid-send crash retries next tick rather than
  // silently skipping the child for the whole month.
  await markerRef.set(admin.database.ServerValue.TIMESTAMP);
  return true;
}

// Every nursery id under platform/*, discovered via a shallow read so nurseries
// that aren't in the platform/info registry are still scanned. Falls back to the
// registry if the shallow read fails.
async function allNurseryIds() {
  try {
    const { access_token: token } =
      await admin.app().options.credential.getAccessToken();
    const url =
      `https://${RTDB_INSTANCE}.firebaseio.com/platform.json` +
      `?shallow=true&access_token=${token}`;
    const resp = await fetch(url);
    if (resp.ok) {
      const json = await resp.json();
      if (json && typeof json === "object") {
        return Object.keys(json).filter((k) => k !== "info");
      }
    } else {
      console.error(`shallow platform read HTTP ${resp.status}`);
    }
  } catch (e) {
    console.error("allNurseryIds shallow read failed:", e.message);
  }
  const infoSnap = await db().ref("platform/info").once("value");
  const ids = [];
  infoSnap.forEach((n) => ids.push(n.key));
  return ids;
}

async function runFeeReminderScan() {
  const { period, day } = cairoMonthContext();

  const nurseryIds = await allNurseryIds();

  let sent = 0;
  const summary = [];
  for (const nurseryId of nurseryIds) {
    // Config lives on the nursery profile node (platform/info/{nid}), same node
    // the manager profile screen writes.
    const infoSnap = await db()
      .ref(`platform/info/${nurseryId}`)
      .once("value");
    const info = infoSnap.val() || {};
    const toDay = Number(info.feeCollectionToDay);
    if (Number.isNaN(toDay)) {
      summary.push({ nurseryId, note: "no window configured" });
      continue; // feature off for this nursery
    }
    if (day <= toDay) {
      summary.push({ nurseryId, note: `window still open (day ${day} ≤ ${toDay})` });
      continue; // collection window hasn't closed yet
    }

    const [childrenSnap, invoicesSnap] = await Promise.all([
      db().ref(`platform/${nurseryId}/children`).once("value"),
      db().ref(`platform/${nurseryId}/invoices`).once("value"),
    ]);
    const perChild = childrenSnap.val() || {};
    const invoices = invoicesSnap.val() || {};

    const skip = { inactive: 0, noInvoice: 0, paid: 0, pendingProof: 0, noParent: 0 };

    for (const [childId, child] of Object.entries(perChild)) {
      if (!child || typeof child !== "object") continue;
      if (child.status !== "active") {
        skip.inactive++;
        continue;
      }

      // This month's monthly fee invoice: month_{childId}_{YYYYMM}.
      const inv = invoices[`month_${childId}_${period}`];
      if (!inv) {
        skip.noInvoice++;
        continue; // no dues on record — never invent a bill
      }
      if (invoiceHasPendingProof(inv)) {
        skip.pendingProof++;
        continue; // guardian already sent proof, awaiting review
      }
      if (!invoiceOutstanding(inv)) {
        skip.paid++;
        continue;
      }

      try {
        const ok = await sendFeeReminderChat(
          nurseryId,
          childId,
          child,
          period,
          invoiceRemaining(inv)
        );
        if (ok) sent++;
        else skip.noParent++; // eligible but no linked guardian to message
      } catch (e) {
        console.error(`❌ feeReminder(${nurseryId}/${childId}):`, e.message);
      }
    }

    console.log(
      `💰 ${nurseryId}: day=${day} toDay=${toDay} sent=${sent} skips=${JSON.stringify(skip)}`
    );
    summary.push({ nurseryId, toDay, skips: skip });
  }

  console.log(
    `💰 fee reminder scan done — period=${period} day=${day} sent=${sent}`
  );
  return { period, day, scanned: nurseryIds.length, sent, nurseries: summary };
}

exports.feeReminderScan = onSchedule(
  { schedule: "every day 10:00", timeZone: TZ },
  async () => {
    await runFeeReminderScan();
  }
);
