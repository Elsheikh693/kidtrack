import '../../../../index/index_main.dart';

/// One step in the "Learn the App" vertical stepper: a timeline rail (connector
/// line + status indicator) on the leading side and a tappable content card.
class TutorialStepTile extends StatelessWidget {
  final AppTutorialController controller;
  final int index;
  final bool isFirst;
  final bool isLast;

  const TutorialStepTile({
    super.key,
    required this.controller,
    required this.index,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final video = controller.videos[index];
      final done = controller.isWatched(video);
      final unlocked = controller.isUnlocked(index);
      final isCurrent = unlocked && !done;

      final Color lineTop = isFirst
          ? Colors.transparent
          : (done || unlocked ? AppColors.primary : AppColors.grayLight);
      final Color lineBottom = isLast
          ? Colors.transparent
          : (done ? AppColors.primary : AppColors.grayLight);

      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Rail(
              lineTop: lineTop,
              lineBottom: lineBottom,
              done: done,
              isCurrent: isCurrent,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _Card(
                  video: video,
                  done: done,
                  isCurrent: isCurrent,
                  unlocked: unlocked,
                  onTap: () => controller.openStep(index),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Rail extends StatelessWidget {
  final Color lineTop;
  final Color lineBottom;
  final bool done;
  final bool isCurrent;

  const _Rail({
    required this.lineTop,
    required this.lineBottom,
    required this.done,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final Color circleColor = done
        ? AppColors.successForeground
        : isCurrent
            ? AppColors.primary
            : AppColors.grayLight;
    final IconData icon = done
        ? Icons.check_rounded
        : isCurrent
            ? Icons.play_arrow_rounded
            : Icons.lock_rounded;
    final Color iconColor =
        (done || isCurrent) ? AppColors.white : AppColors.grayMedium;

    return SizedBox(
      width: 36.w,
      child: Column(
        children: [
          Expanded(child: Container(width: 2.w, color: lineTop)),
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, size: 20.sp, color: iconColor),
          ),
          Expanded(child: Container(width: 2.w, color: lineBottom)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final TutorialVideoModel video;
  final bool done;
  final bool isCurrent;
  final bool unlocked;
  final VoidCallback onTap;

  const _Card({
    required this.video,
    required this.done,
    required this.isCurrent,
    required this.unlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Ink(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isCurrent
                    ? AppColors.primary.withValues(alpha: 0.45)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                _Thumb(video: video),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: video.title,
                        textStyle: context.typography.smSemiBold
                            .copyWith(color: AppColors.textDefault),
                        maxLines: 2,
                      ),
                      SizedBox(height: 6.h),
                      _StatusChip(
                          done: done, isCurrent: isCurrent, unlocked: unlocked),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final TutorialVideoModel video;
  const _Thumb({required this.video});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: SizedBox(
        width: 74.w,
        height: 56.w,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (video.hasThumbnail)
              AppNetworkImage(url: video.thumbnailUrl, fit: BoxFit.cover)
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primary80],
                  ),
                ),
              ),
            Center(
              child: Icon(Icons.play_circle_fill_rounded,
                  color: AppColors.white.withValues(alpha: 0.90), size: 24.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool done;
  final bool isCurrent;
  final bool unlocked;
  const _StatusChip(
      {required this.done, required this.isCurrent, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final IconData icon;
    late final String label;
    if (done) {
      color = AppColors.successForeground;
      icon = Icons.check_circle_rounded;
      label = 'tutorial_status_done'.tr;
    } else if (isCurrent) {
      color = AppColors.primary;
      icon = Icons.play_arrow_rounded;
      label = 'tutorial_status_start'.tr;
    } else {
      color = AppColors.grayMedium;
      icon = Icons.lock_rounded;
      label = 'tutorial_status_locked'.tr;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15.sp, color: color),
        SizedBox(width: 4.w),
        AppText(
          text: label,
          textStyle: context.typography.xsMedium.copyWith(color: color),
        ),
      ],
    );
  }
}
