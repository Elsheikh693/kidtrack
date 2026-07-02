const { sendToToken } = require("./fcm");
const { tokensFor, removeToken } = require("./tokenService");
const { saveInApp } = require("./notificationRepository");
const { Role } = require("./constants");

// ============================================================
// 🔔 NOTIFICATION SERVICE — the single entry point for every feature
// ============================================================
//
// A feature never touches FCM or RTDB directly. It just calls:
//
//   await notificationService.send({
//     recipients: [{ uid, role }],   // role: 'parent' | 'staff'
//     nurseryId,
//     title, body,
//     type,        // NotificationType.*
//     entityId,    // optional — the record the notif points at
//     data,        // optional — extra FCM payload for deep-linking
//   });
//
// For each recipient it: saves the in-app notification, then pushes
// FCM to each of their tokens, pruning any dead tokens along the way.
// ============================================================

async function send({ recipients, nurseryId, title, body, type, entityId, data }) {
  if (!recipients || recipients.length === 0) return;

  const payload = { ...data, type, nurseryId };
  if (entityId) payload.entityId = entityId;

  for (const { uid, role = Role.parent } of recipients) {
    if (!uid) continue;

    // ── In-app notification ──────────────────────────────────
    await saveInApp({ uid, nurseryId, title, body, type, entityId });

    // ── Push to every device ─────────────────────────────────
    const tokens = await tokensFor({ role, nurseryId, uid });
    for (const token of tokens) {
      const res = await sendToToken(token, { title, body, data: payload });
      if (res.invalid) {
        await removeToken({ role, nurseryId, uid, token });
      }
    }
  }

  console.log(`✅ Notified ${recipients.length} recipient(s) — type=${type}`);
}

module.exports = { send };
