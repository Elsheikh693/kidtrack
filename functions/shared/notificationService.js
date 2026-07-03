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
// A recipient may carry its OWN `title`/`body` (e.g. copy addressed to
// that parent by name); those win over the shared title/body for that
// recipient only. Omit them to use the shared copy.
//
// For each recipient it: saves the in-app notification, then pushes
// FCM to each of their tokens, pruning any dead tokens along the way.
// ============================================================

async function send({ recipients, nurseryId, title, body, type, entityId, data }) {
  if (!recipients || recipients.length === 0) return;

  const payload = { ...data, type, nurseryId };
  if (entityId) payload.entityId = entityId;

  for (const r of recipients) {
    const { uid, role = Role.parent } = r;
    if (!uid) continue;

    const rTitle = r.title || title;
    const rBody = r.body || body;

    // ── In-app notification ──────────────────────────────────
    await saveInApp({ uid, nurseryId, title: rTitle, body: rBody, type, entityId });

    // ── Push to every device ─────────────────────────────────
    const tokens = await tokensFor({ role, nurseryId, uid });
    for (const token of tokens) {
      const res = await sendToToken(token, { title: rTitle, body: rBody, data: payload });
      if (res.invalid) {
        await removeToken({ role, nurseryId, uid, token });
      }
    }
  }

  console.log(`✅ Notified ${recipients.length} recipient(s) — type=${type}`);
}

module.exports = { send };
