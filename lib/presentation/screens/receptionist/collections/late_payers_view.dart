import '../../../../index/index_main.dart';

const _accent = Color(0xFF7C3AED);
const _overdue = Color(0xFFDC2626);
const _partial = Color(0xFFD97706);
const _green = Color(0xFF16A34A);
const _bg = Color(0xFFF6F7FB);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);
const _line = Color(0xFFEEF0F4);

/// Which slice of debtors a [LatePayersView] shows.
enum LatePayersMode { owes, unpaid, partial }

class LatePayersView extends StatefulWidget {
  /// When opened from the receptionist finance tab we pass that tab's
  /// month-aware controller so the list matches the selected month. Opened
  /// from the home card (no arg) it falls back to the shared current-month one.
  final CollectionsController? controller;

  /// Which bucket to render: everyone who owes (default), never-paid only, or
  /// partially-paid only.
  final LatePayersMode mode;

  const LatePayersView({
    super.key,
    this.controller,
    this.mode = LatePayersMode.owes,
  });

  @override
  State<LatePayersView> createState() => _LatePayersViewState();
}

class _LatePayersViewState extends State<LatePayersView> {
  late final CollectionsController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? initController(() => CollectionsController());
  }

  String get _title => switch (widget.mode) {
        LatePayersMode.unpaid => 'collections_unpaid_title'.tr,
        LatePayersMode.partial => 'collections_partial_title'.tr,
        LatePayersMode.owes => 'collections_late_title'.tr,
      };

  List<LatePayer> get _payers => switch (widget.mode) {
        LatePayersMode.unpaid => controller.unpaidPayers,
        LatePayersMode.partial => controller.partialPayers,
        LatePayersMode.owes => controller.latePayers,
      };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: HomeAppBar(
          title: _title,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: _accent),
            );
          }
          final payers = _payers;
          if (payers.isEmpty) return const _EmptyState();
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                  itemCount: payers.length,
                  separatorBuilder: (_, _) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) =>
                      _PayerTile(controller: controller, payer: payers[i]),
                ),
              ),
              _RemindAllBar(controller: controller),
            ],
          );
        }),
      ),
    );
  }
}

class _PayerTile extends StatelessWidget {
  final CollectionsController controller;
  final LatePayer payer;
  const _PayerTile({required this.controller, required this.payer});

  @override
  Widget build(BuildContext context) {
    final amount =
        '${payer.amount.toStringAsFixed(0)} ${'overdue_currency'.tr}';
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 13.h, 14.w, 13.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  payer.childName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.smSemiBold.copyWith(
                    color: _ink,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              _StatusBadge(payer: payer),
            ],
          ),
          if (payer.isPartial) ...[
            SizedBox(height: 6.h),
            Text(
              'collections_partial_progress'.trParams({
                'paid': payer.paidSoFar.toStringAsFixed(0),
                'remaining': payer.amount.toStringAsFixed(0),
                'currency': 'overdue_currency'.tr,
              }),
              style: context.typography.xsMedium.copyWith(
                color: _green,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (payer.title.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.receipt_long_rounded, size: 13.sp, color: _accent),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    payer.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.xsMedium.copyWith(
                      color: _accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  payer.parentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.xsRegular.copyWith(
                    color: _muted,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                amount,
                style: context.typography.smSemiBold.copyWith(
                  color: _accent,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _CollectButton(onTap: () => _collect(context)),
              ),
              SizedBox(width: 10.w),
              _RemindButton(onTap: () => controller.remindOne(payer)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _collect(BuildContext context) async {
    // Reception only ever collects cash, so a method picker adds a needless
    // step — just confirm, then record the cash collection.
    final confirmed = await confirmCashCollection(context, payer);
    if (confirmed != true) return;
    await controller.collect(payer, 'cash');
  }
}

/// Confirmation dialog for recording a cash collection from one late payer.
/// Returns true if the receptionist confirms.
Future<bool?> confirmCashCollection(BuildContext context, LatePayer payer) {
  final amount = '${payer.amount.toStringAsFixed(0)} ${'overdue_currency'.tr}';
  return Get.dialog<bool>(
    Directionality(
      textDirection: appTextDirection,
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.payments_rounded,
                    color: _accent, size: 30.sp),
              ),
              SizedBox(height: 18.h),
              Text(
                'collections_collect_confirm_title'.tr,
                style: context.typography.lgBold.copyWith(color: _ink),
              ),
              SizedBox(height: 8.h),
              Text(
                'collections_collect_confirm_message'.trParams({
                  'amount': amount,
                  'child': payer.childName,
                }),
                textAlign: TextAlign.center,
                style: context.typography.smRegular.copyWith(
                  color: _muted,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 26.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        side: const BorderSide(color: _line),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'common_cancel'.tr,
                        style: context.typography.smSemiBold
                            .copyWith(color: _ink),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        'collections_collect'.tr,
                        style: context.typography.smSemiBold
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: true,
  );
}

class _CollectButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CollectButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(13.r),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.28),
              blurRadius: 12.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, size: 18.sp, color: Colors.white),
            SizedBox(width: 7.w),
            Text(
              'collections_collect'.tr,
              style: context.typography.smSemiBold.copyWith(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final LatePayer payer;
  const _StatusBadge({required this.payer});

  @override
  Widget build(BuildContext context) {
    final (color, key) = payer.isPartial
        ? (_partial, 'collections_partial_badge')
        : payer.isOverdue
            ? (_overdue, 'collections_overdue_badge')
            : (const Color(0xFFD97706), 'collections_due_badge');
    final label = key.tr;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Text(
        label,
        style: context.typography.xsMedium.copyWith(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RemindButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RemindButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(13.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_active_rounded,
                size: 16.sp, color: _accent),
            SizedBox(width: 6.w),
            Text(
              'collections_remind_one'.tr,
              style: context.typography.xsMedium.copyWith(
                color: _accent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemindAllBar extends StatelessWidget {
  final CollectionsController controller;
  const _RemindAllBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: Obx(() {
        final busy = controller.sendingAll.value;
        return GestureDetector(
          onTap: busy ? null : controller.remindAll,
          child: Container(
            height: 52.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), _accent],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.3),
                  blurRadius: 14.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Center(
              child: busy
                  ? SizedBox(
                      width: 22.w,
                      height: 22.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.4,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.campaign_rounded,
                            size: 20.sp, color: Colors.white),
                        SizedBox(width: 8.w),
                        Text(
                          'collections_remind_all'.tr,
                          style: context.typography.smSemiBold.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76.w,
            height: 76.h,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_rounded,
                size: 40.sp, color: const Color(0xFF16A34A)),
          ),
          SizedBox(height: 16.h),
          Text(
            'collections_late_empty'.tr,
            style: context.typography.smSemiBold.copyWith(
              color: _muted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
