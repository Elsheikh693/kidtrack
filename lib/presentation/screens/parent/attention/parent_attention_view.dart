import '../../../../index/index_main.dart';
import 'widgets/attention_card.dart';

/// Dedicated "محتاج انتباهك" screen — aggregates everything that needs the
/// guardian's attention (unpaid fees, required homework, teacher notes) that
/// used to sit inline on the home. Reached from the home quick-action card.
class ParentAttentionView extends StatefulWidget {
  const ParentAttentionView({super.key});

  @override
  State<ParentAttentionView> createState() => _ParentAttentionViewState();
}

class _ParentAttentionViewState extends State<ParentAttentionView> {
  late final ParentDashboardController controller;

  static const _amber = Color(0xFFD97706);
  static const _red = Color(0xFFDC2626);
  static const _blue = Color(0xFF2563EB);
  static const _pink = Color(0xFFDB2777);

  @override
  void initState() {
    super.initState();
    controller = Get.find<ParentDashboardController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: HomeAppBar(title: 'parent_attention_title'.tr),
        body: Obx(() {
          final invoices = controller.pendingInvoices;
          final expenses = invoices.where((i) => i.isDailyExpense).toList();
          final fees = invoices.where((i) => !i.isDailyExpense).toList();
          final homework = controller.pendingHomework;
          final notes = controller.dailyNotes;
          if (invoices.isEmpty && homework.isEmpty && notes.isEmpty) {
            return const _AttentionEmpty();
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
            children: [
              if (fees.isNotEmpty) ...[
                _GroupLabel('parent_attention_fees'.tr),
                for (final inv in fees)
                  AttentionCard(
                    color: inv.status == 'overdue' ? _red : _amber,
                    icon: Icons.payments_rounded,
                    title: _invoiceTitle(inv),
                    subtitle: _invoiceSubtitle(inv),
                    subIsAlert: inv.status == 'overdue',
                    onTap: () => Get.toNamed(parentInvoicesView),
                  ),
                SizedBox(height: 8.h),
              ],
              if (expenses.isNotEmpty) ...[
                _GroupLabel('parent_attention_expenses'.tr),
                for (final inv in expenses)
                  AttentionCard(
                    color: _pink,
                    icon: Icons.receipt_long_rounded,
                    title: _invoiceTitle(inv),
                    subtitle: _invoiceSubtitle(inv),
                    onTap: () => Get.toNamed(parentInvoicesView),
                  ),
                SizedBox(height: 8.h),
              ],
              if (homework.isNotEmpty) ...[
                _GroupLabel('parent_attention_homework'.tr),
                for (final h in homework)
                  AttentionCard(
                    color: _amber,
                    icon: Icons.assignment_rounded,
                    title: h.displayTitle?.isNotEmpty == true
                        ? h.displayTitle!
                        : h.titleKey,
                    subtitle:
                        h.subjectKey.isNotEmpty ? h.subjectKey : null,
                    onTap: _goEducation,
                  ),
                SizedBox(height: 8.h),
              ],
              if (notes.isNotEmpty) ...[
                _GroupLabel('parent_attention_notes'.tr),
                for (final n in notes)
                  AttentionCard(
                    color: _blue,
                    icon: Icons.chat_bubble_rounded,
                    title: n.text,
                    onTap: _goEducation,
                  ),
              ],
            ],
          );
        }),
      ),
    );
  }

  void _goEducation() {
    Get.back();
    Get.find<MainPageViewModel>().changePage(1);
  }

  String _invoiceTitle(dynamic inv) {
    if (inv.title?.isNotEmpty == true) return inv.title as String;
    if (inv.categoryName?.isNotEmpty == true) return inv.categoryName as String;
    return 'parent_attention_fee_fallback'.tr;
  }

  String _invoiceSubtitle(dynamic inv) {
    final amount = ParentDashboardController.ar(
      (inv.totalAmount as num).toStringAsFixed(0),
    );
    return '$amount ${'currency'.tr}';
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(2.w, 4.h, 2.w, 10.h),
      child: Text(
        label,
        style: context.typography.smSemiBold
            .copyWith(color: AppColors.textSecondaryParagraph),
      ),
    );
  }
}

class _AttentionEmpty extends StatelessWidget {
  const _AttentionEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_outline_rounded,
                size: 42.sp, color: const Color(0xFF16A34A)),
          ),
          SizedBox(height: 16.h),
          Text(
            'parent_attention_empty'.tr,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textDefault),
          ),
        ],
      ),
    );
  }
}
