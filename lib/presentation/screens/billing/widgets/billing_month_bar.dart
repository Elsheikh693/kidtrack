import '../../../../index/index_main.dart';
import '../billing_utils.dart';

/// Top-of-page month selector shared by all billing screens. Shows the current
/// month as a pill; tapping opens a sheet of the last 12 months.
class BillingMonthBar extends StatelessWidget {
  const BillingMonthBar({
    super.key,
    required this.month,
    required this.onChanged,
  });

  final int month;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
              blurRadius: 12.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'billing_month_label'.tr,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    BillingMonth.label(month),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white, size: 24.sp),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context) {
    final months = BillingMonth.recent(count: 12);
    Get.bottomSheet(
      Directionality(
        textDirection: appTextDirection,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Text(
                'billing_pick_month'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 12.h),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: months.length,
                  separatorBuilder: (_, _) => SizedBox(height: 6.h),
                  itemBuilder: (_, i) {
                    final m = months[i];
                    final selected = m == month;
                    return GestureDetector(
                      onTap: () {
                        Get.back();
                        if (m != month) onChanged(m);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF4F46E5).withValues(alpha: 0.08)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF4F46E5)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                BillingMonth.label(m),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: selected
                                      ? const Color(0xFF4F46E5)
                                      : const Color(0xFF334155),
                                ),
                              ),
                            ),
                            if (selected)
                              Icon(Icons.check_circle_rounded,
                                  color: const Color(0xFF4F46E5), size: 20.sp),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
