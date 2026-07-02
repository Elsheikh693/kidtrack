import 'package:intl/intl.dart' hide TextDirection;
import '../../../../index/index_main.dart';
import '../../billing/billing_utils.dart';
import '../../billing/widgets/billing_status_pill.dart';
import '../../billing/widgets/branch_breakdown_card.dart';

/// SuperAdmin: a single nursery's platform bill for the chosen month, with the
/// collect (تحصيل) / undo action. The month is fixed (shown in the header).
class SaBillingDetailView extends StatefulWidget {
  const SaBillingDetailView({super.key});

  @override
  State<SaBillingDetailView> createState() => _SaBillingDetailViewState();
}

class _SaBillingDetailViewState extends State<SaBillingDetailView> {
  late final SaBillingDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => SaBillingDetailController());
  }

  void _confirmCollect() {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
          title: Text(
            'billing_collect_confirm_title'.tr,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
          ),
          content: Text(
            'billing_collect_confirm_msg'.trParams({
              'amount': controller.bill.value?.totalAmount.toStringAsFixed(0) ??
                  '0',
              'nursery': controller.nursery.name,
            }),
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF475569)),
          ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text('cancel'.tr,
                  style: const TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Get.back();
                controller.collect();
              },
              child: Text('billing_collect'.tr),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmUndo() {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
          title: Text(
            'billing_undo_confirm_title'.tr,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
          ),
          content: Text(
            'billing_undo_confirm_msg'.tr,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF475569)),
          ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text('cancel'.tr,
                  style: const TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Get.back();
                controller.undo();
              },
              child: Text('billing_undo'.tr),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            controller.nursery.name,
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: const Color(0xFF334155), size: 18.sp),
            onPressed: Get.back,
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final bill = controller.bill.value;
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
            children: [
              _MonthChip(month: controller.month),
              SizedBox(height: 16.h),
              if (bill != null) ...[
                _HeroCard(bill: bill),
                SizedBox(height: 16.h),
                BranchBreakdownCard(bill: bill),
                SizedBox(height: 20.h),
                _ActionButton(
                  controller: controller,
                  onCollect: _confirmCollect,
                  onUndo: _confirmUndo,
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  const _MonthChip({required this.month});

  final int month;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_rounded,
                color: const Color(0xFF4F46E5), size: 16.sp),
            SizedBox(width: 8.w),
            Text(
              BillingMonth.label(month),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.bill});

  final PlatformBillModel bill;

  @override
  Widget build(BuildContext context) {
    final paid = bill.isPaid;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: paid
              ? const [Color(0xFF16A34A), Color(0xFF15803D)]
              : const [Color(0xFFDC2626), Color(0xFFB91C1C)],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'billing_amount_due'.tr,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              BillingStatusPill(paid: paid),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '${bill.totalAmount.toStringAsFixed(0)} ${'currency'.tr}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'billing_children_count'
                .trParams({'n': bill.totalChildCount.toString()}),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13.sp,
            ),
          ),
          if (paid && bill.paidAt != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_available_rounded,
                      color: Colors.white, size: 15.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _collectedLine(bill),
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _collectedLine(PlatformBillModel bill) {
    final date = DateFormat('yyyy/MM/dd')
        .format(DateTime.fromMillisecondsSinceEpoch(bill.paidAt!));
    final by = bill.collectedByName;
    if (by != null && by.isNotEmpty) {
      return 'billing_collected_by'.trParams({'date': date, 'by': by});
    }
    return 'billing_paid_on'.trParams({'date': date});
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.controller,
    required this.onCollect,
    required this.onUndo,
  });

  final SaBillingDetailController controller;
  final VoidCallback onCollect;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final saving = controller.isSaving.value;
    final paid = controller.isPaid;
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              paid ? const Color(0xFFFEE2E2) : const Color(0xFF16A34A),
          foregroundColor:
              paid ? const Color(0xFFDC2626) : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r)),
        ),
        onPressed: saving ? null : (paid ? onUndo : onCollect),
        icon: saving
            ? SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF64748B)),
              )
            : Icon(paid
                ? Icons.undo_rounded
                : Icons.payments_rounded),
        label: Text(
          paid ? 'billing_undo'.tr : 'billing_collect'.tr,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
