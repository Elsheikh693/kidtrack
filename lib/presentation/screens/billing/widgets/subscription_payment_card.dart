import '../../../../index/index_main.dart';

/// Read-only "how to pay your subscription" card shown to owners/managers on the
/// My-subscription screen: the platform's InstaPay number, wallet number and a
/// tappable InstaPay link. Numbers copy to the clipboard; the link opens.
class SubscriptionPaymentCard extends StatelessWidget {
  const SubscriptionPaymentCard({
    super.key,
    required this.controller,
    required this.info,
  });

  final MySubscriptionController controller;
  final PlatformPaymentInfoModel info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 20.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'subscription_payment_title'.tr,
                  style: context.typography.smSemiBold.copyWith(
                    color: AppColors.textDefault,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'subscription_payment_subtitle'.tr,
            style: context.typography.xsRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
          SizedBox(height: 14.h),
          if (info.instapayNumber.isNotEmpty)
            _PayRow(
              icon: Icons.qr_code_rounded,
              color: const Color(0xFF6D4AFF),
              label: 'pay_instapay_number'.tr,
              value: info.instapayNumber,
              onCopy: () => controller.copyValue(info.instapayNumber),
            ),
          if (info.walletNumber.isNotEmpty)
            _PayRow(
              icon: Icons.account_balance_wallet_outlined,
              color: const Color(0xFF16A34A),
              label: 'pay_wallet_number'.tr,
              value: info.walletNumber,
              onCopy: () => controller.copyValue(info.walletNumber),
            ),
          if (info.instapayLink.isNotEmpty)
            _PayRow(
              icon: Icons.link_rounded,
              color: const Color(0xFF0891B2),
              label: 'pay_instapay_link'.tr,
              value: info.instapayLink,
              openLabel: 'pay_open_link'.tr,
              onOpen: () => controller.openPaymentLink(info.instapayLink),
            ),
        ],
      ),
    );
  }
}

/// One payment method row: coloured icon, label + value, and a trailing action
/// — a copy button (numbers) or an "open" pill (the link).
class _PayRow extends StatelessWidget {
  const _PayRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.onCopy,
    this.onOpen,
    this.openLabel,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final VoidCallback? onCopy;
  final VoidCallback? onOpen;
  final String? openLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: GestureDetector(
        onTap: onOpen,
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 20.sp, color: color),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    style: context.typography.smSemiBold.copyWith(
                      color: AppColors.textDefault,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            if (onOpen != null && openLabel != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  openLabel!,
                  style: context.typography.mdMedium.copyWith(color: color),
                ),
              )
            else if (onCopy != null)
              GestureDetector(
                onTap: onCopy,
                child: Container(
                  padding: EdgeInsets.all(9.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.copy_rounded, size: 16.sp, color: color),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
