import '../../../../../index/index_main.dart';

enum SessionStatus { done, now, upcoming }

/// A single session in the teacher's day. The "now" card is a hero with a large
/// "start" button; done/upcoming render compact. RTL: status icon leads (right),
/// time trails (left).
class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.startTime,
    required this.title,
    required this.status,
    this.endTime,
    this.subtitle,
    this.onStart,
  });

  final String startTime;
  final String? endTime;
  final String title;
  final String? subtitle;
  final SessionStatus status;
  final VoidCallback? onStart;

  static const _green = AppColors.activityGreen;

  Color get _accent => switch (status) {
        SessionStatus.done => _green,
        SessionStatus.now => AppColors.activityOrange,
        SessionStatus.upcoming => AppColors.activityMuted,
      };

  @override
  Widget build(BuildContext context) {
    final isNow = status == SessionStatus.now;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: isNow
            ? Border.all(color: _green.withValues(alpha: 0.5), width: 1.5)
            : Border.all(
                color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: (isNow ? _green : Colors.black)
                .withValues(alpha: isNow ? 0.12 : 0.03),
            blurRadius: isNow ? 18.r : 10.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _Leading(status: status, accent: _accent),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.smSemiBold.copyWith(
                        color: status == SessionStatus.upcoming
                            ? AppColors.textSecondaryParagraph
                            : AppColors.textDefault,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        _StatusChip(status: status),
                        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              subtitle!.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.typography.xsRegular.copyWith(
                                color: AppColors.textSecondaryParagraph,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              _TimeChip(start: startTime, end: endTime, accent: _accent),
            ],
          ),
          if (isNow && onStart != null) ...[
            SizedBox(height: 14.h),
            _StartButton(onStart: onStart!),
          ],
        ],
      ),
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading({required this.status, required this.accent});

  final SessionStatus status;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      SessionStatus.done => Icons.check_rounded,
      SessionStatus.now => Icons.play_arrow_rounded,
      SessionStatus.upcoming => Icons.schedule_rounded,
    };
    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: accent, size: 20.sp),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.start, this.end, required this.accent});

  final String start;
  final String? end;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58.w,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(start,
              style: context.typography.smSemiBold.copyWith(color: accent)),
          if (end != null && end!.isNotEmpty)
            Text(end!,
                style: context.typography.xsRegular
                    .copyWith(color: AppColors.textSecondaryParagraph)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final SessionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      SessionStatus.done => ('teacher_session_done'.tr, AppColors.activityGreen),
      SessionStatus.now => ('teacher_session_now'.tr, AppColors.activityOrange),
      SessionStatus.upcoming => (
          'teacher_session_upcoming'.tr,
          AppColors.activityMuted
        ),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: context.typography.xsMedium.copyWith(color: color),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onStart();
      },
      child: Container(
        height: 50.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.activityGreen, AppColors.activityGreenDark],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.activityGreen.withValues(alpha: 0.35),
              blurRadius: 14.r,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow_rounded, color: AppColors.white, size: 22.sp),
            SizedBox(width: 6.w),
            Text(
              'teacher_session_start'.tr,
              style: context.typography.smSemiBold
                  .copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
