import 'package:intl/intl.dart' hide TextDirection;
import '../../../../index/index_main.dart';
import 'widgets/outstanding_invoice_card.dart';

const _accent = Color(0xFF7C3AED);
const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF94A3B8);
const _green = Color(0xFF16A34A);
const _line = Color(0xFFEEF0F4);

class ParentInvoicesView extends StatefulWidget {
  const ParentInvoicesView({super.key});

  @override
  State<ParentInvoicesView> createState() => _ParentInvoicesViewState();
}

class _ParentInvoicesViewState extends State<ParentInvoicesView> {
  late final ParentInvoicesController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ParentInvoicesController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'parent_invoices_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const _LoadingSkeleton();
          }
          final items = controller.items;
          final outstanding = controller.outstanding;
          if (items.isEmpty && outstanding.isEmpty) {
            return RefreshIndicator(
              color: _accent,
              onRefresh: () => controller.loadData(showLoader: false),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  SizedBox(height: 120.h),
                  const _EmptyState(),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: _accent,
            onRefresh: () => controller.loadData(showLoader: false),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              children: [
                if (outstanding.isNotEmpty) ...[
                  Text(
                    'parent_pay_outstanding_title'.tr,
                    style: context.typography.smSemiBold.copyWith(
                      color: _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...outstanding.map((inv) => OutstandingInvoiceCard(
                        invoice: inv,
                        onPay: () => controller.openPay(inv),
                      )),
                  SizedBox(height: 20.h),
                ],
                _SummaryCard(
                  total: controller.totalPaid,
                  count: controller.count,
                ),
                SizedBox(height: 20.h),
                Text(
                  'parent_payments_history'.tr,
                  style: context.typography.smSemiBold.copyWith(
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 12.h),
                if (items.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      'parent_payments_empty'.tr,
                      textAlign: TextAlign.center,
                      style: context.typography.xsRegular
                          .copyWith(color: _muted),
                    ),
                  )
                else
                  ...items.map((t) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _PaymentCard(tx: t),
                      )),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Summary ───────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final double total;
  final int count;
  const _SummaryCard({required this.total, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_accent, Color(0xFF9D5CF0)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.28),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'parent_payments_total'.tr,
                  style: context.typography.xsMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.5,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      total.toStringAsFixed(0),
                      style: context.typography.mdBold.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Text(
                        'currency'.tr,
                        style: context.typography.smSemiBold.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 42.h,
            color: Colors.white.withValues(alpha: 0.25),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
          ),
          Column(
            children: [
              Text(
                '$count',
                style: context.typography.mdBold.copyWith(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                'parent_payments_count'.tr,
                style: context.typography.xsMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Payment card ──────────────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final FinancialTransactionModel tx;
  const _PaymentCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    final date = DateTime.fromMillisecondsSinceEpoch(tx.date);
    final hasNote = tx.notes != null && tx.notes!.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.check_circle_rounded,
                    size: 22.sp, color: _green),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.categoryName.isEmpty
                          ? 'parent_payments_uncategorized'.tr
                          : tx.categoryName,
                      style: context.typography.smSemiBold
                          .copyWith(color: _ink, fontSize: 15),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 12.sp, color: _muted),
                        SizedBox(width: 4.w),
                        Text(
                          DateFormat('d MMM yyyy', isAr ? 'ar' : 'en')
                              .format(date),
                          style: context.typography.xsRegular
                              .copyWith(color: _muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '${tx.amount.toStringAsFixed(0)} ${'currency'.tr}',
                style: context.typography.smSemiBold.copyWith(
                  color: _green,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (hasNote) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sticky_note_2_outlined,
                      size: 14.sp, color: _muted),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      tx.notes!.trim(),
                      style: context.typography.xsRegular
                          .copyWith(color: const Color(0xFF64748B), fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Receipt slot — a "view receipt" action / receipt number drops in
          // here once receipts are added to FinancialTransaction (vNext).
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 84.w,
          height: 84.w,
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.receipt_long_outlined, size: 40.sp, color: _accent),
        ),
        SizedBox(height: 18.h),
        Text(
          'parent_payments_empty'.tr,
          textAlign: TextAlign.center,
          style: context.typography.smSemiBold.copyWith(
            color: _ink,
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'parent_payments_empty_hint'.tr,
          textAlign: TextAlign.center,
          style: context.typography.xsRegular
              .copyWith(color: _muted, fontSize: 13),
        ),
      ],
    );
  }
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget box(double h, double r) => Container(
          height: h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(r),
          ),
        );
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE9ECF2),
      highlightColor: const Color(0xFFF7F8FB),
      period: const Duration(milliseconds: 1100),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        children: [
          box(18.h, 6.r),
          SizedBox(height: 12.h),
          box(96.h, 16.r),
          SizedBox(height: 10.h),
          box(96.h, 16.r),
          SizedBox(height: 24.h),
          box(110.h, 22.r),
          SizedBox(height: 20.h),
          box(18.h, 6.r),
          SizedBox(height: 12.h),
          ...List.generate(
            3,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: box(70.h, 16.r),
            ),
          ),
        ],
      ),
    );
  }
}
