const { onValueCreated } = require("firebase-functions/v2/database");
const { RTDB_INSTANCE } = require("../shared/constants");
const { handleGuardianNote } = require("./guardianNoteNotifications");

// ============================================================
// 🔥 TRIGGER: platform/{nurseryId}/guardianNotes/{noteId}
// ============================================================
//
// Fires once per NEW guardian note. The note key is deterministic
// (`gn_{activityId}_{childId}`), so a parent EDITING their note re-writes
// the same key → that is an update, not a create, and does not re-notify.
// This intentionally only fires for a brand-new note.
// ============================================================

exports.onGuardianNoteCreated = onValueCreated(
  {
    ref: "platform/{nurseryId}/guardianNotes/{noteId}",
    instance: RTDB_INSTANCE,
  },
  async (event) => {
    const data = event.data.val();
    if (!data) return;

    const { nurseryId, noteId } = event.params;

    console.log(`📝 GUARDIAN NOTE: ${noteId} nursery=${nurseryId}`);

    await handleGuardianNote({ note: { ...data, key: noteId }, nurseryId });
  },
);
