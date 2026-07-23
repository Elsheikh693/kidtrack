import '../../../../../index/index_main.dart';

/// Dashboard alert: scheduled sessions the (present) teacher hasn't started past
/// the grace window. One red card per late session with a one-tap nudge.
class LateSessionsBanner extends StatelessWidget {
  const LateSessionsBanner({super.key, required this.controller});

  final ManagerDashboardController controller;

  static const _red = AppColors.errorForeground;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sessions = controller.lateSessions;
      if (sessions.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 18.sp, color: _red),
                SizedBox(width: 6.w),
                Text(
                  'late_session_banner_title'.tr,
                  style: context.typography.smSemiBold.copyWith(color: _red),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ...sessions.map((e) => _LateCard(entry: e, controller: controller)),
          ],
        ),
      );
    });
  }
}

class _LateCard extends StatelessWidget {
  const _LateCard({required this.entry, required this.controller});

  final LateSessionEntry entry;
  final ManagerDashboardController controller;

  static const _red = AppColors.errorForeground;

  Future<void> _nudge() async {
    Loader.show();
    final ok = await controller.nudgeTeacher(entry);
    if (ok) {
      Loader.showSuccess('late_session_nudge_sent'.tr);
    } else {
      Loader.showError('late_session_nudge_error'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.schedule_rounded, color: _red, size: 21.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.classroomName} · ${entry.title}',
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  'late_session_late_by'.trParams({
                    'm': '${entry.minutesLate}',
                    'name': entry.teacherName,
                  }),
                  style: context.typography.xsRegular.copyWith(color: _red),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: entry.teacherId.isEmpty ? null : _nudge,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: entry.teacherId.isEmpty ? AppColors.grayMedium : _red,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'late_session_nudge'.tr,
                style: context.typography.xsMedium
                    .copyWith(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
