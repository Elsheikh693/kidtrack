import '../../../../../index/index_main.dart';
import '../widgets/report_skeleton.dart';
import '../widgets/report_empty_state.dart';
import 'widgets/financial_summary_card.dart';
import 'widgets/financial_category_card.dart';
import 'widgets/financial_transactions_list.dart';
import 'widgets/financial_report_pdf.dart';

class FinancialReportView extends StatefulWidget {
  const FinancialReportView({super.key});

  @override
  State<FinancialReportView> createState() => _FinancialReportViewState();
}

class _FinancialReportViewState extends State<FinancialReportView> {
  late final FinancialReportController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => FinancialReportController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Text('report_financial_title'.tr,
              style: context.typography.lgBold
                  .copyWith(color: AppColors.textDefault)),
          actions: [
            IconButton(
              tooltip: 'report_share_pdf'.tr,
              onPressed: () => shareFinancialReportPdf(controller),
              icon: const Icon(Icons.ios_share_rounded,
                  color: AppColors.textDefault),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const ReportSkeleton();
          }
          if (controller.isEmpty.value) {
            return ReportEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              titleKey: 'report_financial_empty_title',
              subKey: 'report_financial_empty_sub',
            );
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
            physics: const BouncingScrollPhysics(),
            children: [
              FinancialSummaryCard(controller: controller),
              SizedBox(height: 12.h),
              FinancialCategoryCard(controller: controller),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.only(right: 4.w, bottom: 8.h, top: 4.h),
                child: Text('report_financial_history'.tr,
                    style: context.typography.smSemiBold
                        .copyWith(color: const Color(0xFF1E293B))),
              ),
              FinancialTransactionsList(controller: controller),
            ],
          );
        }),
      ),
    );
  }
}
