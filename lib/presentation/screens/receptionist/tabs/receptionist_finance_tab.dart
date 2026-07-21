import 'package:intl/intl.dart' hide TextDirection;
import '../../../../index/index_main.dart';
import '../collections/monthly_collection_summary.dart';
import '../collections/reception_collection_controller.dart';
import '../collections/collect_payment_sheet.dart';
import '../collections/reception_directory_list.dart';

const _accent = Color(0xFF7C3AED);
const _bg = Color(0xFFF6F7FB);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);
const _line = Color(0xFFEEF0F4);
const _green = Color(0xFF16A34A);

/// Receptionist "الماليات" tab — a dead-simple cash-collection log.
///
/// Search a child → see what they already paid → record new cash. Built ONLY on
/// [FeeCategoryModel] + [FinancialTransactionModel]; the old Invoice/Payment
/// system is gone.
class ReceptionistFinanceTab extends StatefulWidget {
  const ReceptionistFinanceTab({super.key});

  @override
  State<ReceptionistFinanceTab> createState() => _ReceptionistFinanceTabState();
}

class _ReceptionistFinanceTabState extends State<ReceptionistFinanceTab> {
  static const _tag = 'reception_collection';
  late final ReceptionCollectionController controller;
  bool _searchOpen = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ReceptionCollectionController>(tag: _tag)
        ? Get.find<ReceptionCollectionController>(tag: _tag)
        : Get.put(ReceptionCollectionController(), tag: _tag, permanent: true);
  }

  /// Opens the collect sheet (full/partial + method) for [child].
  void _openCollect(ChildModel child) {
    Get.bottomSheet(
      CollectPaymentSheet(controller: controller, child: child),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
    );
  }

  void _openCollectSelected() {
    final child = controller.selectedChild.value;
    if (child != null) _openCollect(child);
  }

  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) {
        controller.searchCtrl.clear();
        controller.onSearch('');
      }
    });
  }

  /// The finance screen is reached from the reception home via a page switch
  /// (not a route push), so "back" returns to the home tab. Falls back to a
  /// normal pop when it WAS pushed as a route.
  bool get _canGoBack =>
      Navigator.of(context).canPop() || Get.isRegistered<MainPageViewModel>();

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Get.back();
    } else if (Get.isRegistered<MainPageViewModel>()) {
      Get.find<MainPageViewModel>().changePage(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: _canGoBack ? 4 : 20,
        automaticallyImplyLeading: false,
        leading: _canGoBack
            ? IconButton(
                onPressed: _goBack,
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20.sp, color: _ink),
              )
            : null,
        title: Obx(() {
          if (controller.selectedChild.value == null && _searchOpen) {
            return TextField(
              controller: controller.searchCtrl,
              autofocus: true,
              onChanged: controller.onSearch,
              textInputAction: TextInputAction.search,
              style: context.typography.smRegular
                  .copyWith(fontSize: 16, color: _ink),
              decoration: InputDecoration(
                hintText: 'collection_search_hint'.tr,
                hintStyle: context.typography.smRegular
                    .copyWith(color: _muted, fontSize: 15),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            );
          }
          return Text(
            'finance_dashboard_title'.tr,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _ink,
              letterSpacing: -0.4,
            ),
          );
        }),
        actions: [
          Obx(
            () => controller.selectedChild.value != null
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: _toggleSearch,
                    child: Icon(
                      _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                      size: 24,
                      color: const Color(0xFF374151),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => Get.toNamed(notificationsView),
            child: const Icon(Icons.notifications_none_rounded,
                size: 24, color: Color(0xFF374151)),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => Get.toNamed(settingsView),
            child: const Icon(Icons.settings_outlined,
                size: 24, color: Color(0xFF374151)),
          ),
          const SizedBox(width: 18),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const _LoadingSkeleton();
        final child = controller.selectedChild.value;
        if (child != null) {
          return _ChildFinanceView(
            controller: controller,
            onNewCollection: _openCollectSelected,
          );
        }
        final q = controller.searchQuery.value.trim();
        final list =
            q.isEmpty ? controller.orderedChildren : controller.filteredChildren;
        if (list.isEmpty) {
          return _Hint(
            icon: q.isEmpty
                ? Icons.child_care_outlined
                : Icons.person_off_outlined,
            title: q.isEmpty
                ? 'collection_directory_empty'.tr
                : 'collection_no_child_found'.tr,
            hint: q.isEmpty ? '' : 'collection_no_child_found_hint'.tr,
          );
        }
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            if (q.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: const MonthlyCollectionSummary(),
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final c = list[i];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: CollectionChildCard(
                        child: c,
                        subtitle: controller.classroomName(c.classroomId),
                        outstanding: controller.outstandingFor(c.key),
                        hasProof: controller.proofFor(c.key) != null,
                        onCollect: () => _openCollect(c),
                        onHistory: () => controller.selectChild(c),
                      ),
                    );
                  },
                  childCount: list.length,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Avatar extends StatelessWidget {
  final ChildModel child;
  const _Avatar({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: child.hasImage
          ? AppNetworkImage(url: child.profileImage, fit: BoxFit.cover)
          : Center(
              child: Text(
                child.firstName.isNotEmpty ? child.firstName[0] : '?',
                style: context.typography.mdBold
                    .copyWith(color: _accent, fontSize: 18),
              ),
            ),
    );
  }
}

// ── Selected child finance view ───────────────────────────────────────────────

class _ChildFinanceView extends StatelessWidget {
  final ReceptionCollectionController controller;
  final VoidCallback onNewCollection;
  const _ChildFinanceView({
    required this.controller,
    required this.onNewCollection,
  });

  @override
  Widget build(BuildContext context) {
    final child = controller.selectedChild.value!;
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 100.h),
          children: [
            GestureDetector(
              onTap: controller.clearSelection,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18.sp, color: _accent),
                  SizedBox(width: 6.w),
                  Text(
                    'collection_change_child'.tr,
                    style: context.typography.smSemiBold
                        .copyWith(color: _accent, fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            _ChildCard(controller: controller, child: child),
            SizedBox(height: 20.h),
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'collection_history_title'.tr,
                  style: context.typography.smSemiBold.copyWith(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Obx(() {
              if (controller.isLoadingHistory.value) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.h),
                  child: const Center(
                    child: CircularProgressIndicator(color: _accent),
                  ),
                );
              }
              final list = controller.history;
              if (list.isEmpty) {
                return _Hint(
                  icon: Icons.receipt_long_outlined,
                  title: 'collection_no_history'.tr,
                  hint: 'collection_no_history_hint'.tr,
                  compact: true,
                );
              }
              return Column(
                children: list
                    .map((t) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: _HistoryRow(tx: t),
                        ))
                    .toList(),
              );
            }),
          ],
        ),
        Positioned(
          bottom: 18.h,
          left: 20.w,
          right: 20.w,
          child: _CollectButton(onTap: onNewCollection),
        ),
      ],
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ReceptionCollectionController controller;
  final ChildModel child;
  const _ChildCard({required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    final parent = controller.parentName(child.key);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.06),
            blurRadius: 18.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _Avatar(child: child),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.fullName,
                      style: context.typography.smSemiBold
                          .copyWith(color: _ink, fontSize: 16),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      controller.classroomName(child.classroomId),
                      style: context.typography.xsRegular
                          .copyWith(color: _muted, fontSize: 12.5),
                    ),
                    if (parent.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 13.sp, color: _muted),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              parent,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.typography.xsRegular
                                  .copyWith(color: _muted, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() {
            final due = controller.outstandingFor(child.key);
            final owes = due > 0.5;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: (owes ? const Color(0xFFDC2626) : _green)
                    .withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Icon(
                    owes
                        ? Icons.account_balance_wallet_rounded
                        : Icons.verified_rounded,
                    size: 18.sp,
                    color: owes ? const Color(0xFFDC2626) : _green,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'collect_outstanding'.tr,
                    style: context.typography.xsMedium
                        .copyWith(color: _muted, fontSize: 12.5),
                  ),
                  const Spacer(),
                  Text(
                    owes
                        ? '${due.toStringAsFixed(0)} ${'overdue_currency'.tr}'
                        : 'collect_settled'.tr,
                    style: context.typography.smSemiBold.copyWith(
                      color: owes ? const Color(0xFFDC2626) : _green,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          }),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Icon(Icons.savings_rounded, size: 18.sp, color: _green),
                SizedBox(width: 8.w),
                Text(
                  'collection_total_paid'.tr,
                  style: context.typography.xsMedium
                      .copyWith(color: _muted, fontSize: 12.5),
                ),
                const Spacer(),
                Obx(() => Text(
                      '${controller.childTotalPaid.toStringAsFixed(0)} ${'overdue_currency'.tr}',
                      style: context.typography.smSemiBold.copyWith(
                        color: _green,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final FinancialTransactionModel tx;
  const _HistoryRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    final date = DateTime.fromMillisecondsSinceEpoch(tx.date);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(Icons.receipt_rounded, size: 19.sp, color: _accent),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.categoryName.isEmpty
                      ? 'collection_uncategorized'.tr
                      : tx.categoryName,
                  style: context.typography.smSemiBold
                      .copyWith(color: _ink, fontSize: 14),
                ),
                SizedBox(height: 2.h),
                Text(
                  DateFormat('d MMM yyyy', isAr ? 'ar' : 'en').format(date),
                  style: context.typography.xsRegular
                      .copyWith(color: _muted, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Text(
            '${tx.amount.toStringAsFixed(0)} ${'overdue_currency'.tr}',
            style: context.typography.smSemiBold.copyWith(
              color: _green,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CollectButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _accent,
      borderRadius: BorderRadius.circular(16.r),
      elevation: 4,
      shadowColor: _accent.withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          height: 54.h,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                'collection_new'.tr,
                style: context.typography.smSemiBold.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared bits ───────────────────────────────────────────────────────────────

class _Hint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String hint;
  final bool compact;
  const _Hint({
    required this.icon,
    required this.title,
    required this.hint,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          vertical: compact ? 28.h : 60.h, horizontal: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30.sp, color: _accent),
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.typography.smSemiBold.copyWith(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: context.typography.xsRegular
                .copyWith(color: _muted, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE9ECF2),
      highlightColor: const Color(0xFFF7F8FB),
      period: const Duration(milliseconds: 1100),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
        children: [
          Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          SizedBox(height: 16.h),
          ...List.generate(
            4,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Container(
                height: 68.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
