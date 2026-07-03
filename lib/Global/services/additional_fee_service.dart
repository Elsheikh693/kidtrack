import '../../index/index_main.dart';

/// Creates a one-off "additional fee" (e.g. app subscription) and bills EVERY
/// active child in the receptionist's branch by fanning out one [InvoiceModel]
/// each. The fee's invoices use a shared key prefix `fee_{feeId}_{childId}` and
/// a current-month dueDate, so the charge merges straight into this month's
/// collection worklist alongside the package fees.
///
/// When [notifyParents] is set, each child's parent gets one in-app notification
/// that a new amount is due (deduped, so a parent of siblings is notified once).
class AdditionalFeeService {
  final InvoiceParentService _invoiceSvc = Get.find<InvoiceParentService>();
  final ChildParentService _childSvc = Get.find<ChildParentService>();
  final _notifSvc = NotificationSendService();
  final _session = SessionService();

  /// Bills all active branch children for [title]/[amount]. Returns the number
  /// of children billed (0 when nothing was configured or no children match).
  Future<int> createForAllChildren({
    required String title,
    required double amount,
    bool notifyParents = true,
  }) async {
    final nurseryId = _session.nurseryId ?? '';
    final branchId = _session.branchId ?? '';
    final cleanTitle = title.trim();
    if (nurseryId.isEmpty || cleanTitle.isEmpty || amount <= 0) return 0;

    // Active children of this branch (fee applies to everyone, package or not).
    final children = <ChildModel>[];
    await _childSvc.getAll(callBack: (list) {
      for (final c in list.whereType<ChildModel>()) {
        if (c.key == null || c.status != 'active') continue;
        if (branchId.isNotEmpty && c.branchId != branchId) continue;
        children.add(c);
      }
    });
    if (children.isEmpty) return 0;

    final feeId = DateTime.now().millisecondsSinceEpoch.toString();
    final dueDate = DateTime.now().millisecondsSinceEpoch;

    for (final child in children) {
      final invoice = InvoiceModel(
        key: 'fee_${feeId}_${child.key}',
        nurseryId: nurseryId,
        childId: child.key!,
        parentId: child.parentId,
        title: cleanTitle,
        amount: amount,
        totalAmount: amount,
        status: 'pending',
        dueDate: dueDate,
      );
      // silent: background write, no global loader spinner per invoice.
      await _invoiceSvc.add(item: invoice, callBack: (_) {}, silent: true);
    }

    if (notifyParents) {
      final amountLabel =
          '${amount.toStringAsFixed(0)} ${'overdue_currency'.tr}';
      final seen = <String>{};
      for (final child in children) {
        final uid = child.parentId;
        if (uid == null || uid.isEmpty || seen.contains(uid)) continue;
        seen.add(uid);
        await _notifSvc.sendToUser(
          uid,
          NotificationModel(
            userId: uid,
            nurseryId: nurseryId,
            title: 'fee_notif_title'.tr,
            body: 'fee_notif_body'.trParams({
              'title': cleanTitle,
              'amount': amountLabel,
            }),
            type: 'finance',
            entityId: feeId,
          ),
        );
      }
    }

    return children.length;
  }
}
