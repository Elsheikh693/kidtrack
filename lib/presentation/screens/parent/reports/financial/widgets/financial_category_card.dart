import '../../../../../../index/index_main.dart';

/// Collected amounts broken down by fee category, each with a proportional bar.
class FinancialCategoryCard extends StatelessWidget {
  final FinancialReportController controller;
  const FinancialCategoryCard({super.key, required this.controller});

  static const _palette = [
    Color(0xFF0D9488),
    Color(0xFFD97706),
    Color(0xFF7C3AED),
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFFDB2777),
    Color(0xFF64748B),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Obx(() {
        final cats = controller.categories;
        final max = cats.isEmpty
            ? 1.0
            : cats.map((c) => c.amount).reduce((a, b) => a > b ? a : b);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 14.h, right: 2.w),
              child: Text('report_financial_by_category'.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: const Color(0xFF1E293B))),
            ),
            for (var i = 0; i < cats.length; i++)
              _Row(
                name: cats[i].name,
                amount: cats[i].amount,
                fraction: max == 0 ? 0 : cats[i].amount / max,
                color: _palette[i % _palette.length],
              ),
          ],
        );
      }),
    );
  }
}

class _Row extends StatelessWidget {
  final String name;
  final double amount;
  final double fraction;
  final Color color;
  const _Row({
    required this.name,
    required this.amount,
    required this.fraction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: context.typography.xsMedium
                      .copyWith(color: const Color(0xFF475569))),
              Text('${amount.toStringAsFixed(0)} ${'currency'.tr}',
                  style: context.typography.xsBold.copyWith(color: color)),
            ],
          ),
          SizedBox(height: 5.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 7.h,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
