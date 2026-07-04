import '../../../../index/index_main.dart';
import 'unpaid_subscription_screen.dart';

/// Dashboard card (owner · manager · reception) surfacing how many children
/// still owe this month's subscription. Tapping drills into the full list where
/// guardians can be nudged. Self-contained: resolves its own shared controller
/// so each dashboard just drops `const UnpaidSubscriptionCard()` into its list.
class UnpaidSubscriptionCard extends StatefulWidget {
  const UnpaidSubscriptionCard({super.key});

  @override
  State<UnpaidSubscriptionCard> createState() => _UnpaidSubscriptionCardState();
}

class _UnpaidSubscriptionCardState extends State<UnpaidSubscriptionCard> {
  late final UnpaidSubscriptionController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<UnpaidSubscriptionController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Nothing to show until the first load resolves — avoids a flash of "0".
      if (controller.isLoading.value && controller.unpaidChildren.isEmpty) {
        return const SizedBox.shrink();
      }
      final count = controller.count;
      final allPaid = count == 0;
      final accent =
          allPaid ? AppColors.successForeground : AppColors.activityAmberBrand;

      return GestureDetector(
        onTap: allPaid
            ? null
            : () => Get.to(() => const UnpaidSubscriptionScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: EdgeInsets.only(bottom: 22.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: accent.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  allPaid
                      ? Icons.verified_rounded
                      : Icons.report_gmailerrorred_rounded,
                  color: accent,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'unpaid_card_title'.tr,
                      style: context.typography.mdBold.copyWith(
                        color: AppColors.textDefault,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      allPaid
                          ? 'unpaid_all_paid'.tr
                          : 'unpaid_card_subtitle'.trParams({'n': '$count'}),
                      style: context.typography.xsMedium.copyWith(
                        color: AppColors.textSecondaryParagraph,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (!allPaid) ...[
                SizedBox(width: 10.w),
                _CountBadge(count: count, color: accent),
                SizedBox(width: 4.w),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondaryParagraph,
                  size: 22.sp,
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 34.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        '$count',
        style: context.typography.smSemiBold.copyWith(color: color),
      ),
    );
  }
}
