import '../../../../../../index/index_main.dart';
import '../../services/owner_finance_data_service.dart';

/// A family that repeatedly settles late — child name + how many of their
/// invoices were paid after the due month closed.
class LatePayerCount {
  final String name;
  final int count;
  const LatePayerCount(this.name, this.count);
}

/// Payment Behaviour — across every settled invoice in scope: how many were
/// paid within the due month (on-time) vs after it closed (late), the average
/// days late, and the families who are late repeatedly.
class OwnerPaymentBehaviorController extends GetxController {
  late final OwnerFinanceDataService _data;
  late final OwnerScopeService _scope;

  @override
  void onInit() {
    super.onInit();
    _data = Get.find<OwnerFinanceDataService>();
    _scope = Get.find<OwnerScopeService>();
    _data.ensureLoaded();
  }

  RxBool get firstLoading => _data.isFirstLoading;
  Future<void> reload() => _data.refresh();

  OwnerScope get _s => _scope.scope.value;

  /// Start of the month AFTER the invoice's due month — the on-time cutoff.
  int _dueMonthEnd(int dueDate) {
    final d = DateTime.fromMillisecondsSinceEpoch(dueDate);
    return DateTime(d.year, d.month + 1, 1).millisecondsSinceEpoch;
  }

  List<InvoiceModel> get _paid => _data
      .invoicesFor(_s)
      .where((i) =>
          i.status != 'cancelled' &&
          i.dueDate != null &&
          i.paidAt != null &&
          i.collectedAmount > 0.5)
      .toList();

  int get paidCount => _paid.length;

  int get onTimeCount =>
      _paid.where((i) => i.paidAt! < _dueMonthEnd(i.dueDate!)).length;

  int get lateCount => paidCount - onTimeCount;

  int get onTimeRate =>
      paidCount == 0 ? 0 : ((onTimeCount / paidCount) * 100).round();

  /// Mean days past the due-month close, over the late invoices only.
  int get avgDaysLate {
    final late = _paid.where((i) => i.paidAt! >= _dueMonthEnd(i.dueDate!));
    if (late.isEmpty) return 0;
    final totalDays = late.fold<double>(0, (s, i) {
      final ms = i.paidAt! - _dueMonthEnd(i.dueDate!);
      return s + (ms / 86400000);
    });
    return (totalDays / late.length).round();
  }

  /// Families with ≥2 late invoices, ranked by lateness count.
  List<LatePayerCount> get repeatLate {
    final names = <String, String>{
      for (final c in (_data.data.value?.children ?? const <ChildModel>[]))
        if (c.key != null) c.key!: c.fullName,
    };
    final counts = <String, int>{};
    for (final i in _paid) {
      if (i.paidAt! >= _dueMonthEnd(i.dueDate!)) {
        counts[i.childId] = (counts[i.childId] ?? 0) + 1;
      }
    }
    final list = counts.entries
        .where((e) => e.value >= 2)
        .map((e) => LatePayerCount(
            names[e.key] ?? 'reception_unknown_child'.tr, e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    return list;
  }
}
