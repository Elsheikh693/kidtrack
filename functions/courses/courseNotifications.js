const notificationService = require("../shared/notificationService");
const { parentsOfBranch } = require("../shared/audienceService");
const { NotificationType, Role } = require("../shared/constants");

// ============================================================
// 📚 NEW COURSE → PARENT NOTIFICATIONS
// ============================================================
//
// The manager adds a course at platform/{nid}/courses/{courseId}.
// Audience: parents of the course's branches. A course with an empty
// branchIds list is nursery-wide (see NurseryCourse.isAllBranches).
// ============================================================

function scopesFor(course) {
  const ids = Array.isArray(course.branchIds)
    ? course.branchIds.filter(Boolean)
    : [];
  if (ids.length > 0) return ids;
  if (course.branchId) return [course.branchId];
  return [null]; // whole nursery
}

async function handleCourseCreated({ course, nurseryId, courseId }) {
  try {
    if (course.isActive === false) return;

    const parents = new Set();
    for (const branchId of scopesFor(course)) {
      const ids = await parentsOfBranch(nurseryId, branchId);
      ids.forEach((uid) => parents.add(uid));
    }

    if (parents.size === 0) {
      console.log(`📭 No parents for course ${courseId}`);
      return;
    }

    const recipients = [...parents].map((uid) => ({ uid, role: Role.parent }));

    await notificationService.send({
      recipients,
      nurseryId,
      title: "كورس جديد متاح",
      body: `${course.title} — سجّلي طفلك الآن`,
      type: NotificationType.course,
      entityId: courseId,
      data: { screen: "course_detail", courseId },
    });
  } catch (e) {
    console.error("❌ handleCourseCreated ERROR:", e);
  }
}

module.exports = { handleCourseCreated };
