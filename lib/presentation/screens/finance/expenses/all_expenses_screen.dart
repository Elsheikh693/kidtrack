import '../../../../index/index_main.dart';
import 'expense_form_sheet.dart';

/// Full "عرض كل المصروفات" list for the dashboard's current scope + month.
/// Reuses the shared controller cache (by [tag]), supports add + delete, and
/// rebuilds via the controller's [revision] counter.
class AllExpensesScreen extends StatelessWidget {
  final String tag;
  const AllExpensesScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FinanceDashboardController>(tag: tag);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
          title: Text(
            '${'finance_all_expenses_title'.tr} · ${controller.monthLabel}',
            style: context.typography.smSemiBold
                .copyWith(color: const Color(0xFF1E293B), fontSize: 15),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFDC2626),
          onPressed: () => showExpenseFormSheet(controller: controller),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
        body: Obx(() {
          controller.revision.value; // rebuild trigger
          final items = controller.allExpensesForPeriod();
          if (items.isEmpty) {
            return Center(
              child: Text(
                'finance_dash_no_expenses'.tr,
                style: context.typography.smRegular
                    .copyWith(color: const Color(0xFF94A3B8)),
              ),
            );
          }
          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 90.h),
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (_, i) => ExpenseTile(
              item: items[i],
              onDelete: () => _confirmDelete(context, controller, items[i]),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    FinanceDashboardController controller,
    RecentExpense expense,
  ) async {
    final ok = await Get.dialog<bool>(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('expense_delete_title'.tr),
          content: Text('expense_delete_confirm'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(
                'delete'.tr,
                style: const TextStyle(color: Color(0xFFDC2626)),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok == true) await controller.deleteExpense(expense.expenseId);
  }
}
