const admin = require("firebase-admin");

// ============================================================
// 💾 NOTIFICATION REPOSITORY — writes the in-app notification
// ============================================================
//
// Path: notifications/{uid}/{id}  (GLOBAL — the Flutter app reads here)
// Shape MUST match NotificationModel
// (lib/Data/models/notification/notification_model.dart):
//   { key, userId, nurseryId, title, body, type, entityId?, isRead, createdAt }
// ============================================================

async function saveInApp({ uid, nurseryId, title, body, type, entityId }) {
  if (!uid) return null;

  const ref = admin.database().ref(`notifications/${uid}`).push();

  const notif = {
    key: ref.key,
    userId: uid,
    nurseryId: nurseryId || "",
    title,
    body,
    type,
    isRead: false,
    createdAt: Date.now(),
  };
  if (entityId) notif.entityId = entityId;

  await ref.set(notif);
  return ref.key;
}

module.exports = { saveInApp };
