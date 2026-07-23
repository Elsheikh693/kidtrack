const admin = require("firebase-admin");
const notificationService = require("../shared/notificationService");
const { NotificationType, Role } = require("../shared/constants");

// ============================================================
// 📝 GUARDIAN NOTE → TEACHER NOTIFICATION
// ============================================================
//
// A guardian writes a note back on ONE session/activity in the Link Book
// (platform/{nurseryId}/guardianNotes/{key}). The teacher who ran that
// session should be told a new note arrived so they see it in the
// parent-notes inbox.
//
// The note record does NOT carry a teacherId (it only knows the activity),
// so we resolve the teacher from the activity that the note is attached to.
// ============================================================

function db() {
  return admin.database();
}

// The teacher who ran the session this note is attached to, or "" if unknown.
async function teacherForActivity(nurseryId, classroomId, activityId) {
  if (!classroomId || !activityId) return "";
  try {
    const snap = await db()
      .ref(
        `platform/${nurseryId}/classroomActivities/${classroomId}/${activityId}/teacherId`,
      )
      .once("value");
    return (snap.val() || "").toString();
  } catch (e) {
    console.error("❌ teacherForActivity error:", e.message);
    return "";
  }
}

async function handleGuardianNote({ note, nurseryId }) {
  try {
    const content = (note.content || "").toString().trim();
    if (!content) {
      console.log("⏭️ Empty guardian note — skip");
      return;
    }

    const teacherId = await teacherForActivity(
      nurseryId,
      note.classroomId,
      note.activityId,
    );
    if (!teacherId) {
      console.log("📭 No teacher resolved for guardian note — skip");
      return;
    }

    const childName = (note.childName || "").toString();
    const guardianName = (note.guardianName || "").toString() || "ولي الأمر";
    const subject = (note.subjectName || note.activityTitle || "").toString();

    const title = "ملاحظة جديدة من ولي الأمر";
    const body = subject
      ? `${guardianName} كتب ملاحظة عن ${childName} في ${subject}`
      : `${guardianName} كتب ملاحظة عن ${childName}`;

    await notificationService.send({
      recipients: [{ uid: teacherId, role: Role.staff }],
      nurseryId,
      title,
      body,
      type: NotificationType.general,
      entityId: note.key || note.activityId,
      data: {
        screen: "parent_notes_inbox",
        childId: note.childId,
        activityId: note.activityId,
      },
    });
  } catch (e) {
    console.error("❌ handleGuardianNote ERROR:", e);
  }
}

module.exports = { handleGuardianNote };
