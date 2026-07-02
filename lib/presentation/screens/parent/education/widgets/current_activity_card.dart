import '../../../../../index/index_main.dart';
import '../controller.dart';
import 'today_activities_sheet.dart';

class CurrentActivityCard extends StatelessWidget {
  const CurrentActivityCard({
    super.key,
    required this.activity,
    required this.allActivities,
  });

  final CurrentActivity activity;
  final List<TodayActivity> allActivities;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryFaint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── top row: live badge + time ──────────────────────────
          Row(
            children: [
              _LiveBadge(),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: AppColors.textSecondaryParagraph,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    activity.startTime,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── subject + lesson ────────────────────────────────────
          Text(
            activity.subjectKey.tr,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            activity.lessonTitle,
            style: context.typography.lgBold.copyWith(
              color: AppColors.textDefault,
            ),
          ),
          const SizedBox(height: 12),
          // ── footer: started ago + view all ─────────────────────
          Row(
            children: [
              Icon(
                Icons.timelapse_rounded,
                size: 14,
                color: AppColors.textSecondaryParagraph,
              ),
              const SizedBox(width: 4),
              Text(
                activity.startedAgo,
                style: context.typography.xsRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => showTodayActivitiesSheet(context, allActivities),
                child: Row(
                  children: [
                    Text(
                      'parent_edu_view_all_activities'.tr,
                      style: context.typography.xsMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 11,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── pulsing "جارية الآن" badge ────────────────────────────────────────────────

class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08 + _ctrl.value * 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(
                  alpha: 0.6 + _ctrl.value * 0.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: _ctrl.value * 0.5,
                    ),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'parent_edu_live_now'.tr,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
