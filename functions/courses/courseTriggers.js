const { onValueCreated } = require("firebase-functions/v2/database");
const { RTDB_INSTANCE } = require("../shared/constants");
const { handleCourseCreated } = require("./courseNotifications");

// ============================================================
// 🔥 TRIGGER: platform/{nurseryId}/courses/{courseId}
// ============================================================
//
// Fires when the manager publishes a new course. Notifies parents
// of the course's branches (or the whole nursery).
// ============================================================

exports.onCourseCreated = onValueCreated(
  {
    ref: "platform/{nurseryId}/courses/{courseId}",
    instance: RTDB_INSTANCE,
  },
  async (event) => {
    const data = event.data.val();
    if (!data) return;

    const { nurseryId, courseId } = event.params;

    console.log(
      `📚 COURSE CREATED: "${data.title}" — nursery=${nurseryId}`
    );

    await handleCourseCreated({ course: data, nurseryId, courseId });
  }
);
