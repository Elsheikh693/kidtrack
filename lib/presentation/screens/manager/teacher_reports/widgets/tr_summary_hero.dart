import '../../../../../index/index_main.dart';
import '../models/teacher_report_models.dart';
import 'tr_format.dart';

/// Gradient hero summarizing the whole span: headline activity count plus a
/// row of supporting stats (active teachers / working time / evaluations).
class TrSummaryHero extends StatelessWidget {
  const TrSummaryHero({super.key, required this.summary, required this.accent});

  final TrSummary summary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 18.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [accent, Color.lerp(accent, Colors.black, 0.28)!],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.32),
            blurRadius: 22.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(11.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.insights_rounded,
                    color: Colors.white, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${summary.totalActivities}',
                      style: context.typography.xxlBold.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    Text(
                      'tr_summary_activities'.tr,
                      style: context.typography.smSemiBold.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _ActiveBadge(
                active: summary.activeTeachers,
                total: summary.totalTeachers,
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.16)),
          SizedBox(height: 14.h),
          Row(
            children: [
              _Stat(
                icon: Icons.timer_outlined,
                value: trDuration(summary.totalWorkingMinutes),
                labelKey: 'tr_summary_worktime',
              ),
              _divider(),
              _Stat(
                icon: Icons.verified_outlined,
                value: '${summary.totalEvaluations}',
                labelKey: 'tr_summary_evaluations',
              ),
              _divider(),
              _Stat(
                icon: Icons.photo_camera_outlined,
                value: '${summary.totalPhotos}',
                labelKey: 'tr_summary_photos',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 34.h, color: Colors.white.withValues(alpha: 0.16));
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge({required this.active, required this.total});
  final int active;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            '$active/$total',
            style: context.typography.mdBold.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'tr_summary_active'.tr,
            style: context.typography.smSemiBold.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.labelKey});
  final IconData icon;
  final String value;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 19.sp),
          SizedBox(height: 6.h),
          Text(
            value,
            textAlign: TextAlign.center,
            style: context.typography.displaySmBold.copyWith(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            labelKey.tr,
            style: context.typography.smSemiBold.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
