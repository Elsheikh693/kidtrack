// ============================================================
// 🔖 SHARED CONSTANTS — mirror the Flutter side
// ============================================================

// Realtime Database instance for this project.
// (project: kidtrack-bed28 → default RTDB instance)
const RTDB_INSTANCE = "kidtrack-bed28-default-rtdb";

// NotificationModel.type — must stay in sync with the Flutter
// NotificationModel (lib/Data/models/notification/notification_model.dart).
const NotificationType = {
  attendance: "attendance",
  announcement: "announcement",
  incident: "incident",
  report: "report",
  finance: "finance",
  general: "general",
};

// Recipient roles — decides which path tokenService reads the FCM token from.
const Role = {
  parent: "parent",
  staff: "staff",
};

module.exports = {
  RTDB_INSTANCE,
  NotificationType,
  Role,
};
