import 'package:intl/intl.dart' hide TextDirection;
import '../../../index/index_main.dart';
import 'widgets/billing_month_bar.dart';
import 'widgets/billing_status_pill.dart';
import 'widgets/branch_breakdown_card.dart';
import 'widgets/subscription_payment_card.dart';

/// Owner / manager screen: "My platform subscription". Shows the monthly bill
/// (children × 50 EGP) with a per-branch breakdown and this month's payment
/// status, plus a month picker to browse past months. Read-only.
class MySubscriptionView extends StatefulWidget {
  const MySubscriptionView({super.key});

  @override
  State<MySubscriptionView> createState() => _MySubscriptionViewState();
}

class _MySubscriptionViewState extends State<MySubscriptionView> {
  late final MySubscriptionController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => MySubscriptionController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'billing_my_subscription'.tr,
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
          final bill = controller.bill.value;
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
            children: [
              BillingMonthBar(
                month: controller.selectedMonth.value,
                onChanged: controller.setMonth,
              ),
              SizedBox(height: 16.h),
              if (controller.isLoading.value)
                Padding(
                  padding: EdgeInsets.only(top: 80.h),
                  child: const Center(child: CircularProgressIndicator()),
                )
              else if (bill == null)
                Padding(
                  padding: EdgeInsets.only(top: 80.h),
                  child: Center(
                    child: Text(
                      'billing_no_children'.tr,
                      style: TextStyle(
                          fontSize: 14.sp, color: const Color(0xFF94A3B8)),
                    ),
                  ),
                )
              else ...[
                _HeroCard(bill: bill),
                SizedBox(height: 16.h),
                BranchBreakdownCard(bill: bill),
                if (controller.paymentInfo.value?.hasAny ?? false) ...[
                  SizedBox(height: 16.h),
                  SubscriptionPaymentCard(
                    controller: controller,
                    info: controller.paymentInfo.value!,
                  ),
                ],
              ],
            ],
          );
        }),
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
            'billing_children_count'.trParams({
              'n': bill.totalChildCount.toString(),
            }),
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
                  Text(
                    'billing_paid_on'.trParams({
                      'date': DateFormat('yyyy/MM/dd').format(
                        DateTime.fromMillisecondsSinceEpoch(bill.paidAt!),
                      ),
                    }),
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
