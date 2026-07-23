import '../../../../../index/index_main.dart';

/// Clean, light day-progress summary at the top of the Activities tab.
class IdleProgressCard extends StatelessWidget {
  const IdleProgressCard({
    super.key,
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  static const _green = AppColors.activityGreen;

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    final pct = (completed / total).clamp(0.0, 1.0);
    final remaining = total - completed;
    final allDone = remaining == 0;

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52.w,
            height: 52.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 52.w,
                  height: 52.w,
                  child: CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 5.w,
                    strokeCap: StrokeCap.round,
                    backgroundColor: _green.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation(_green),
                  ),
                ),
                Text('${(pct * 100).round()}%',
                    style: context.typography.xsBold.copyWith(color: _green)),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  allDone
                      ? 'teacher_activity_all_done'.tr
                      : 'teacher_activity_progress_title'.tr,
                  style: context.typography.mdBold
                      .copyWith(color: AppColors.textDefault),
                ),
                SizedBox(height: 4.h),
                Text(
                  allDone
                      ? 'teacher_activity_all_done_sub'.tr
                      : 'teacher_activity_progress_sub'.trParams({
                          'done': '$completed',
                          'total': '$total',
                          'left': '$remaining',
                        }),
                  style: context.typography.xsRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
