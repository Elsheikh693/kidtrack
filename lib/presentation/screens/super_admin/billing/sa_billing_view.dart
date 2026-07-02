import '../../../../index/index_main.dart';
import '../../billing/widgets/billing_month_bar.dart';
import 'widgets/sa_billing_row_card.dart';
import 'widgets/sa_billing_summary.dart';

/// SuperAdmin: platform subscription billing across all nurseries for a chosen
/// month. Tap a nursery to open its detail and collect payment.
class SaBillingView extends StatefulWidget {
  const SaBillingView({super.key});

  @override
  State<SaBillingView> createState() => _SaBillingViewState();
}

class _SaBillingViewState extends State<SaBillingView> {
  late final SaBillingController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => SaBillingController());
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
            'sa_billing_title'.tr,
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
          return RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
              children: [
                BillingMonthBar(
                  month: controller.selectedMonth.value,
                  onChanged: controller.setMonth,
                ),
                SizedBox(height: 16.h),
                SaBillingSummary(
                  collected: controller.totalCollected,
                  outstanding: controller.totalOutstanding,
                  paidCount: controller.paidCount,
                  total: controller.rows.length,
                ),
                SizedBox(height: 16.h),
                if (controller.rows.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 60.h),
                    child: Center(
                      child: Text(
                        'sa_billing_empty'.tr,
                        style: TextStyle(
                            fontSize: 14.sp, color: const Color(0xFF94A3B8)),
                      ),
                    ),
                  )
                else
                  ...controller.rows.map((r) => SaBillingRowCard(
                        row: r,
                        onTap: () => controller.openDetail(r.nursery),
                      )),
              ],
            ),
          );
        }),
      ),
    );
  }
}
