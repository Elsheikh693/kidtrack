import '../../../index/index_main.dart';

/// Reception-created "daily expense" charges (pampers, a book handed over today,
/// medicine…). These are modelled as ordinary [InvoiceModel] dues tagged with
/// `source: 'daily_expense'` so they flow through the existing collection /
/// revenue pipeline (التحصيل) and surface in the parent's "needs attention"
/// screen — while staying filterable and analysable as a distinct kind of due.
///
/// On creation the service also drops a direct message into the child's shared
/// nursery↔guardian chat thread; the `onChatMessageCreated` Cloud Function then
/// pushes the FCM to the parent — so one write covers both the chat message and
/// the notification.
class ChildChargeParentService {
  final BaseService<InvoiceModel> _service =
      Get.find<BaseService<InvoiceModel>>(tag: 'invoices');

  final _session = SessionService();

  /// Sentinel category used for the revenue-log bucket ("مصروفات يومية") so the
  /// owner analytics can total daily expenses separately from subscriptions.
  static const String categoryId = 'daily_expense';
  static const String source = 'daily_expense';

  /// All daily-expense charges in scope, newest first. Reuses the shared
  /// invoice list and filters to the tagged dues.
  Future<List<InvoiceModel>> getCharges() async {
    final result = <InvoiceModel>[];
    await _service.getData(
      data: {},
      voidCallBack: (list) {
        result.addAll(
          list.whereType<InvoiceModel>().where((i) => i.isDailyExpense),
        );
      },
    );
    result.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return result;
  }

  /// Creates a new daily-expense charge for [child], then messages the guardian.
  /// [parentId]/[parentName] are resolved by the caller (primary guardian).
  Future<void> addCharge({
    required ChildModel child,
    required String parentId,
    required String parentName,
    required double amount,
    required String reason,
    required Function(ResponseStatus) callBack,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final key = 'extra_${child.key}_$now';
    final resolvedParent = parentId.isNotEmpty ? parentId : (child.parentId ?? '');

    final invoice = InvoiceModel(
      key: key,
      nurseryId: _session.nurseryId ?? '',
      childId: child.key ?? '',
      parentId: resolvedParent.isEmpty ? null : resolvedParent,
      categoryId: categoryId,
      categoryName: 'daily_expense_category'.tr,
      title: reason,
      amount: amount,
      totalAmount: amount,
      status: 'pending',
      source: source,
      dueDate: now,
      createdAt: now,
    );

    await _service.addData(
      item: invoice,
      toJson: (m) => m.toJson(),
      id: key,
      voidCallBack: (status) {
        callBack(status);
        if (status == ResponseStatus.success && resolvedParent.isNotEmpty) {
          _notifyParent(
            child: child,
            parentId: resolvedParent,
            parentName: parentName,
            amount: amount,
            reason: reason,
          );
        }
      },
    );
  }

  /// Edits an existing (still-unpaid) charge — amount and/or reason only.
  Future<void> updateCharge({
    required InvoiceModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.updateData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
    );
  }

  Future<void> deleteCharge({
    required String id,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.deleteData(id: id, voidCallBack: callBack);
  }

  /// Drops the charge into the child's chat thread (nursery side). The chat
  /// trigger turns this single write into the parent push notification too.
  Future<void> _notifyParent({
    required ChildModel child,
    required String parentId,
    required String parentName,
    required double amount,
    required String reason,
  }) async {
    final amountStr = amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
    final text = '${'daily_expense_chat_title'.tr}\n'
        '${'daily_expense_chat_amount'.tr}: $amountStr ${'currency'.tr}\n'
        '${'daily_expense_chat_reason'.tr}: $reason';

    final meta = ChatConversationModel(
      childId: child.key ?? '',
      childName: child.fullName,
      childImage: child.profileImage,
      classroomId: child.classroomId,
      branchId: child.branchId,
      parentId: parentId,
      parentName: parentName,
    );

    await ChatService().sendMessage(
      meta: meta,
      text: text,
      senderRole: 'manager',
    );
  }
}
