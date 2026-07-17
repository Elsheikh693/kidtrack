import '../../../../../../index/index_main.dart';
import 'daily_eval_style.dart';

/// The month's headline: a soft gradient tinted by the attendance status, an
/// attendance ring, the month's status label, and three quick facts.
class MonthlyHeroCard extends StatelessWidget {
  final MonthlyReportController controller;
  const MonthlyHeroCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final color = controller.statusColor;
      final rate = controller.attendanceRate.value;
      return Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.16),
              color.withValues(alpha: 0.04),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Ring(rate: rate, color: color),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('report_monthly_overview'.tr,
                          style: context.typography.xsMedium
                              .copyWith(color: const Color(0xFF64748B))),
                      SizedBox(height: 4.h),
                      Text(controller.statusLabelKey.tr,
                          style: context.typography.xlBold.copyWith(
                              color: color, height: 1.1)),
                      SizedBox(height: 4.h),
                      Text(
                        'report_monthly_attend_days'.trParams({
                          'done': '${controller.attendedDays}',
                          'total': '${controller.schoolDays.value}',
                        }),
                        style: context.typography.xsRegular
                            .copyWith(color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(height: 1, color: color.withValues(alpha: 0.12)),
            SizedBox(height: 14.h),
            Row(
              children: [
                _Fact(
                  icon: DailyEvalStyle.icon(controller.dominant.value),
                  color: DailyEvalStyle.color(controller.dominant.value),
                  label: 'report_evaluation_title'.tr,
                  value: controller.evalTotal == 0
                      ? '—'
                      : DailyEvalStyle.labelKey(controller.dominant.value).tr,
                ),
                _Divider(),
                _Fact(
                  icon: Icons.auto_awesome_rounded,
                  color: const Color(0xFF7C3AED),
                  label: 'report_monthly_assessed'.tr,
                  value: '${controller.assessedCount.value}',
                ),
                _Divider(),
                _Fact(
                  icon: Icons.payments_rounded,
                  color: const Color(0xFF16A34A),
                  label: 'report_financial_title'.tr,
                  value: controller.monthPaid.value == 0
                      ? '—'
                      : controller.monthPaid.value.toStringAsFixed(0),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _Ring extends StatelessWidget {
  final int rate;
  final Color color;
  const _Ring({required this.rate, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78.w,
      height: 78.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 78.w,
            height: 78.w,
            child: CircularProgressIndicator(
              value: rate / 100,
              strokeWidth: 8.w,
              backgroundColor: Colors.white.withValues(alpha: 0.7),
              valueColor: AlwaysStoppedAnimation(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$rate%',
                  style: context.typography.mdBold.copyWith(color: color)),
              Text('report_attendance_title'.tr,
                  style: context.typography.xsRegular.copyWith(
                      fontSize: 8, color: const Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _Fact({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 6.h),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.smSemiBold
                  .copyWith(color: const Color(0xFF1E293B))),
          SizedBox(height: 2.h),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.xsRegular
                  .copyWith(fontSize: 10, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 34.h, color: const Color(0x11000000));
  }
}
