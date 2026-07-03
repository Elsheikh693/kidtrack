import '../../../../index/index_main.dart';

const _accent = Color(0xFF7C3AED);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);
const _line = Color(0xFFEEF0F4);

/// Reception's shared "collect money" flow, reused by the home quick-action and
/// the finance tab's (+). Presents a chooser — record a collected cash payment,
/// or broadcast a new fee (e.g. an app subscription) to every child — then the
/// matching sheet. Refreshes [collections] afterwards so totals update in place.
Future<void> openCollectionAddMenu(CollectionsController collections) async {
  final choice = await Get.bottomSheet<String>(
    const CollectionActionChooser(),
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
  );
  if (choice == 'payment') await _openPaymentSheet(collections);
  if (choice == 'fee') await _openFeeSheet(collections);
}

Future<void> _openPaymentSheet(CollectionsController collections) async {
  final pc = initController(() => PaymentController());
  final session = SessionService();
  await Get.bottomSheet(
    ReceptionPaymentSheet(nurseryId: session.nurseryId ?? ''),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
  );
  pc.loadData();
  collections.loadData();
}

Future<void> _openFeeSheet(CollectionsController collections) async {
  await Get.bottomSheet(
    CreateFeeSheet(controller: collections),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
  );
}

/// The chooser presented by [openCollectionAddMenu]. Returns 'payment' or 'fee'
/// via [Get.back].
class CollectionActionChooser extends StatelessWidget {
  const CollectionActionChooser({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: _line,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'finance_action_title'.tr,
              style: context.typography.mdBold.copyWith(
                fontSize: 18,
                color: _ink,
              ),
            ),
            SizedBox(height: 16.h),
            _ActionRow(
              icon: Icons.payments_rounded,
              title: 'finance_action_payment'.tr,
              subtitle: 'finance_action_payment_sub'.tr,
              onTap: () => Get.back(result: 'payment'),
            ),
            SizedBox(height: 10.h),
            _ActionRow(
              icon: Icons.campaign_rounded,
              title: 'finance_action_fee'.tr,
              subtitle: 'finance_action_fee_sub'.tr,
              onTap: () => Get.back(result: 'fee'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: _accent, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.typography.smSemiBold.copyWith(
                      color: _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: context.typography.xsRegular.copyWith(
                      color: _muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded, size: 22.sp, color: _muted),
          ],
        ),
      ),
    );
  }
}
