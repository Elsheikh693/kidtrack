import '../../../../index/index_main.dart';

/// Dedicated type so the receptionist Children tab gets its own controller
/// instance (separate fenix singleton) — prevents shift/status filter state
/// from leaking into the shared owner [ChildListController] screen.
///
/// Reception also surfaces the branch's monthly withdrawals: withdrawn children
/// are hard-deleted, so the roster only ever shows active children ([showActiveOnly]),
/// and departures are read from the withdrawal log instead.
class ReceptionistChildrenController extends ChildListController {
  @override
  bool get showActiveOnly => true;

  final _rcSession = SessionService();
  late final WithdrawalParentService _withdrawalSvc;

  /// This month's withdrawals for this branch, newest first (surviving log of
  /// hard-deleted children — name + reason + date).
  final withdrawnThisMonth = <WithdrawalLogModel>[].obs;

  /// Count for the tappable "withdrawn this month" stat.
  final leftThisMonth = 0.obs;

  @override
  void onInit() {
    // Resolve before super.onInit() — the base onInit calls loadData(), which is
    // overridden here to also read withdrawals, so the service must exist first.
    _withdrawalSvc = Get.find<WithdrawalParentService>();
    super.onInit();
  }

  @override
  Future<void> loadData() async {
    await super.loadData();
    await _loadWithdrawals();
  }

  Future<void> _loadWithdrawals() async {
    final now = DateTime.now();
    final branchId = _rcSession.branchId ?? '';
    await _withdrawalSvc.getAll(
      callBack: (list) {
        final entries = list
            .whereType<WithdrawalLogModel>()
            .where((w) => branchId.isEmpty || w.branchId == branchId)
            .where((w) {
          final d = w.withdrawnDate;
          return d != null && d.year == now.year && d.month == now.month;
        }).toList()
          ..sort((a, b) => (b.withdrawnAt ?? 0).compareTo(a.withdrawnAt ?? 0));
        withdrawnThisMonth.assignAll(entries);
        leftThisMonth.value = entries.length;
      },
    );
  }

  /// Opens the read-only list of this month's withdrawn children with reasons.
  void openWithdrawnList() {
    Get.bottomSheet(
      WithdrawnChildrenSheet(entries: withdrawnThisMonth.toList()),
      isScrollControlled: true,
    );
  }

  /// Opens the bulk "invite guardians to the app" screen.
  void openInviteParents() => Get.toNamed(bulkInvitationsView);
}
