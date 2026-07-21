import '../../../../index/index_main.dart';

/// Role-agnostic controller behind the "children who haven't paid the monthly
/// subscription this month" card + list. ONE class serves the owner, branch
/// manager and reception dashboards; scope is resolved dynamically:
///   • Owner (network shell) → follows [OwnerScopeService] (null = all branches).
///   • Manager / reception / owner-acting-as-manager → pinned to the session
///     branch + shift.
///
/// "Paid" = the child has at least one COLLECTION transaction THIS calendar
/// month against a MONTHLY package (duration == 'monthly' — the الاشتراك الشهري
/// the receptionist picks from the branch's price list when recording money).
/// Display-only: the owner never executes — the only action is nudging a
/// child's guardians with a custom reminder.
class UnpaidSubscriptionController extends GetxController {
  final isLoading = false.obs;
  final unpaidChildren = <ChildModel>[].obs;

  /// childId → active guardian recipient uids (who the reminder is sent to).
  final Map<String, List<String>> _recipientsByChild = {};

  /// childId → display string of the linked guardian names ("أحمد، منى").
  final Map<String, String> parentNamesByChild = {};

  late final ChildParentService _children;
  late final PackageParentService _packages;
  late final FinancialTransactionParentService _transactions;
  late final InvoiceParentService _invoices;
  late final ParentChildParentService _links;
  late final GuardianParentService _guardians;
  final _sender = NotificationSendService();

  Worker? _scopeWorker;

  /// Names the app seeds as the recurring "monthly subscription" (e.g.
  /// "اشتراك شهري"). Used as a name-level fallback so a payment recorded against
  /// a category carrying this name still counts even if that specific category
  /// record was never flagged recurring.
  static final Set<String> _canonicalSubscriptionNames = FeeCategoryDefaults.seed
      .where((d) => d.type == FeeCategoryType.recurring)
      .map((d) => d.name.trim())
      .toSet();

  int get count => unpaidChildren.length;

  @override
  void onInit() {
    super.onInit();
    _children = Get.find<ChildParentService>();
    _packages = Get.find<PackageParentService>();
    _transactions = Get.find<FinancialTransactionParentService>();
    _invoices = Get.find<InvoiceParentService>();
    _links = Get.find<ParentChildParentService>();
    _guardians = Get.find<GuardianParentService>();

    // Owner network shell: reload whenever the branch scope switches.
    if (SessionService().effectiveRole == UserType.owner &&
        Get.isRegistered<OwnerScopeService>()) {
      _scopeWorker = ever(
        Get.find<OwnerScopeService>().scope,
        (_) => load(),
      );
    }

    load();
  }

  @override
  void onClose() {
    _scopeWorker?.dispose();
    super.onClose();
  }

  /// The branch the current viewer is scoped to (null = whole network).
  String? _resolveBranchId() {
    final session = SessionService();
    if (session.effectiveRole == UserType.owner &&
        Get.isRegistered<OwnerScopeService>()) {
      return Get.find<OwnerScopeService>().scope.value.branchId;
    }
    return session.branchId;
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final session = SessionService();
      final branchId = _resolveBranchId();

      // 1. Which packages count as "the monthly subscription": the in-scope,
      // active packages whose duration is monthly. A collection stores the
      // package key + name it was recorded against, so we match on BOTH: the
      // key resolves current packages, and the snapshotted name resolves a
      // package that was later renamed/deactivated. The canonical seed names
      // (e.g. "اشتراك شهري") stay in the name set as a legacy fallback for
      // money collected before packages drove the flow.
      final packages = await _loadPackages();
      final monthly = packages
          .where((p) => p.isActive &&
              p.duration == 'monthly' &&
              _packageInScope(p, branchId))
          .toList();
      final recurringIds =
          monthly.map((p) => p.key).whereType<String>().toSet();
      final subscriptionNames = <String>{
        ...monthly.map((p) => p.name.trim()),
        ..._canonicalSubscriptionNames,
      }..removeWhere((n) => n.isEmpty);

      // The feature only applies once the branch has a monthly package. Without
      // one there's nothing owed monthly, so the list stays empty rather than
      // flagging every child as "unpaid".
      final hasSubscriptionCategory = monthly.isNotEmpty;

      // 2. Active children in scope (branch + shift).
      final children = await _loadChildren();
      final scoped = children
          .where((c) =>
              c.status == 'active' &&
              (branchId == null || c.branchId == branchId) &&
              session.seesShift(c.shift))
          .toList();

      // 3. This-month subscription collections → the set of children who paid.
      final txs = branchId != null
          ? await _transactions.getByBranch(branchId)
          : await _loadAllTransactions();
      final now = DateTime.now();
      final paidIds = txs
          .where((t) =>
              t.type == TransactionType.collection &&
              (recurringIds.contains(t.categoryId) ||
                  subscriptionNames.contains(t.categoryName.trim())) &&
              _inMonth(t.date, now))
          .map((t) => t.childId)
          .toSet();

      // 3b. Also count a child as paid when their current-month subscription
      // invoice (`month_{childId}_{YYYYMM}`) has ANY money collected against it.
      // Reception's invoice-based collection settles the invoice but records a
      // generic "fees" transaction that wouldn't match the package above — so
      // the invoice itself is the reliable signal.
      final ym = '${now.year}${now.month.toString().padLeft(2, '0')}';
      await _invoices.getAll(callBack: (list) {
        for (final inv in list.whereType<InvoiceModel>()) {
          final k = inv.key ?? '';
          if (k.startsWith('month_') &&
              k.endsWith(ym) &&
              inv.collectedAmount > 0.5) {
            paidIds.add(inv.childId);
          }
        }
      });

      // 4. Unpaid = active scoped children with no such collection. With no
      // recurring category configured there's nothing to owe, so the list is
      // empty rather than "everyone is unpaid".
      final unpaid = !hasSubscriptionCategory
          ? <ChildModel>[]
          : scoped.where((c) => !paidIds.contains(c.key)).toList();
      unpaid.sort((a, b) => a.fullName.compareTo(b.fullName));

      // 5. Resolve each unpaid child's guardian recipients + display names.
      await _buildRecipients(unpaid);

      unpaidChildren.assignAll(unpaid);
    } finally {
      isLoading.value = false;
    }
  }

  /// Guardian uids the reminder for [child] will be delivered to.
  List<String> recipientsFor(ChildModel child) =>
      child.key == null ? const [] : (_recipientsByChild[child.key] ?? const []);

  /// Sends the [message] reminder to ALL of [child]'s linked, active guardians.
  Future<void> sendReminder(ChildModel child, String message) async {
    final recipients = recipientsFor(child);
    if (recipients.isEmpty) {
      Loader.showError('unpaid_no_guardian'.tr);
      return;
    }
    Loader.show();
    try {
      final nurseryId = SessionService().nurseryId ?? '';
      var sent = 0;
      for (final uid in recipients) {
        final ok = await _sender.sendToUser(
          uid,
          NotificationModel(
            userId: uid,
            nurseryId: nurseryId,
            title: 'unpaid_reminder_title'.tr,
            body: message,
            type: 'finance',
            entityId: child.key,
          ),
        );
        if (ok) sent++;
      }
      if (sent > 0) {
        Loader.showSuccess('unpaid_reminder_sent'.tr);
      } else {
        Loader.showError('unpaid_reminder_failed'.tr);
      }
    } catch (_) {
      Loader.showError('unpaid_reminder_failed'.tr);
    }
  }

  // ── Loading helpers (bridge the callback-style parent services) ────────────

  Future<List<PackageModel>> _loadPackages() async {
    final out = <PackageModel>[];
    await _packages.getAll(
      callBack: (list) => out.addAll(list.whereType<PackageModel>()),
    );
    return out;
  }

  /// A package applies to the viewer's scope when it has no branch pinned
  /// (network-wide) or its branch matches. [branchId] null = whole network.
  bool _packageInScope(PackageModel p, String? branchId) {
    if (branchId == null || branchId.isEmpty) return true;
    return p.branchId == null || p.branchId!.isEmpty || p.branchId == branchId;
  }

  Future<List<ChildModel>> _loadChildren() async {
    final out = <ChildModel>[];
    await _children.getAll(
      callBack: (list) => out.addAll(list.whereType<ChildModel>()),
    );
    return out;
  }

  Future<List<FinancialTransactionModel>> _loadAllTransactions() async {
    final out = <FinancialTransactionModel>[];
    await _transactions.getAll(
      callBack: (list) =>
          out.addAll(list.whereType<FinancialTransactionModel>()),
    );
    return out;
  }

  /// Loads the parent↔child links + guardian records once, then maps each
  /// unpaid child to its active guardians (uids for sending, names for display).
  Future<void> _buildRecipients(List<ChildModel> unpaid) async {
    _recipientsByChild.clear();
    parentNamesByChild.clear();
    if (unpaid.isEmpty) return;

    final links = <ParentChildModel>[];
    await _links.getAll(
      callBack: (list) => links.addAll(list.whereType<ParentChildModel>()),
    );

    final guardians = <ParentModel>[];
    await _guardians.getAll(
      callBack: (list) => guardians.addAll(list.whereType<ParentModel>()),
    );
    final guardianByUid = {for (final g in guardians) g.uid: g};

    for (final child in unpaid) {
      final cid = child.key;
      if (cid == null) continue;

      // Links table is the source of truth; fall back to the child's legacy
      // single parentId so a child added before the links existed still resolves.
      final parentIds = <String>{
        ...links.where((l) => l.childId == cid).map((l) => l.parentId),
        if (child.parentId != null && child.parentId!.isNotEmpty) child.parentId!,
      };

      final uids = <String>[];
      final names = <String>[];
      for (final pid in parentIds) {
        final g = guardianByUid[pid];
        if (g != null && g.isActive) {
          uids.add(g.uid);
          names.add(g.name);
        }
      }
      _recipientsByChild[cid] = uids;
      parentNamesByChild[cid] = names.join('، ');
    }
  }

  bool _inMonth(int? ms, DateTime month) {
    if (ms == null) return false;
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return d.year == month.year && d.month == month.month;
  }
}
