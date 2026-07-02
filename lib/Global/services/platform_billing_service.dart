import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

/// Platform-level subscription billing: the SuperAdmin charges each nursery
/// `activeChildren × kPlatformPricePerChild` per month.
///
/// Uses direct RTDB access (not the session-scoped 4-layer CRUD) because it is
/// GLOBAL and cross-nursery: SuperAdmin reads all nurseries, and owner/manager
/// read their own nursery's bills at `platformBilling/{nurseryId}/{YYYYMM}`.
class PlatformBillingService {
  final _db = FirebaseDatabase.instance;

  DatabaseReference _billRef(String nurseryId, int month) =>
      _db.ref('${ApiConstants.platformBillingFor(nurseryId)}/$month');

  /// The stored bill for one nursery/month, or null if not yet collected.
  Future<PlatformBillModel?> getBill(String nurseryId, int month) async {
    final snap = await _billRef(nurseryId, month).get();
    if (snap.exists && snap.value is Map) {
      return PlatformBillModel.fromJson(
        Map<String, dynamic>.from(snap.value as Map),
        key: month.toString(),
      );
    }
    return null;
  }

  /// All stored bills for one nursery (owner/manager history), newest first.
  Future<List<PlatformBillModel>> getNurseryBills(String nurseryId) async {
    final snap = await _db.ref(ApiConstants.platformBillingFor(nurseryId)).get();
    final result = <PlatformBillModel>[];
    if (snap.exists && snap.value is Map) {
      final map = Map<String, dynamic>.from(snap.value as Map);
      map.forEach((k, v) {
        if (v is Map) {
          result.add(PlatformBillModel.fromJson(
            Map<String, dynamic>.from(v),
            key: k.toString(),
          ));
        }
      });
    }
    result.sort((a, b) => b.month.compareTo(a.month));
    return result;
  }

  /// Every nursery's stored bill for a given month, keyed by nurseryId. Reads
  /// the whole billing root once and picks each nursery's month slice.
  Future<Map<String, PlatformBillModel>> getMonthBills(int month) async {
    final snap = await _db.ref(ApiConstants.platformBilling).get();
    final result = <String, PlatformBillModel>{};
    if (snap.exists && snap.value is Map) {
      final byNursery = Map<String, dynamic>.from(snap.value as Map);
      byNursery.forEach((nurseryId, months) {
        if (months is Map && months[month.toString()] is Map) {
          result[nurseryId] = PlatformBillModel.fromJson(
            Map<String, dynamic>.from(months[month.toString()] as Map),
            key: month.toString(),
          );
        }
      });
    }
    return result;
  }

  /// Recount active children of a nursery **as of [month]**, grouped by branch,
  /// and turn each branch into a billable line (`count × kPlatformPricePerChild`).
  /// A child only counts once they have joined the nursery on or before that
  /// month (by `createdAt`), so past months bill the correct historical size.
  /// Reads the nursery's children + branches directly (outside session scope).
  Future<List<PlatformBillBranch>> computeBranchBreakdown(
      String nurseryId, int month) async {
    final childrenSnap = await _db.ref(ApiConstants.childrenFor(nurseryId)).get();
    final branchNames = await _branchNames(nurseryId);

    final counts = <String, int>{}; // branchId -> active child count
    if (childrenSnap.exists && childrenSnap.value is Map) {
      final map = Map<String, dynamic>.from(childrenSnap.value as Map);
      for (final v in map.values) {
        if (v is! Map) continue;
        final child = Map<String, dynamic>.from(v);
        final status = child['status']?.toString() ?? 'active';
        if (status != 'active') continue;
        if (_joinMonth(child['createdAt']) > month) continue;
        final branchId = child['branchId']?.toString() ?? '';
        counts[branchId] = (counts[branchId] ?? 0) + 1;
      }
    }

    final result = <PlatformBillBranch>[];
    counts.forEach((branchId, n) {
      result.add(PlatformBillBranch(
        branchId: branchId,
        branchName: branchNames[branchId] ?? 'billing_branch_unassigned'.tr,
        childCount: n,
        amount: n * kPlatformPricePerChild,
      ));
    });
    result.sort((a, b) => b.childCount.compareTo(a.childCount));
    return result;
  }

  /// The YYYYMM a child joined, from `createdAt` (epoch millis). Undated
  /// children return 0 so they always count (assumed to predate any bill).
  int _joinMonth(dynamic createdAt) {
    final ms = createdAt is int
        ? createdAt
        : int.tryParse(createdAt?.toString() ?? '');
    if (ms == null) return 0;
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return d.year * 100 + d.month;
  }

  Future<Map<String, String>> _branchNames(String nurseryId) async {
    final snap = await _db.ref(ApiConstants.branchesFor(nurseryId)).get();
    final names = <String, String>{};
    if (snap.exists && snap.value is Map) {
      final map = Map<String, dynamic>.from(snap.value as Map);
      map.forEach((k, v) {
        if (v is Map) {
          final b = Map<String, dynamic>.from(v);
          names[k.toString()] = b['name']?.toString() ?? '';
        }
      });
    }
    return names;
  }

  /// Build an unpaid, live-projected bill for a nursery/month from the current
  /// child count (no record yet). Used by owner/manager and the SA detail before
  /// collection.
  Future<PlatformBillModel> projectBill(String nurseryId, int month) async {
    final branches = await computeBranchBreakdown(nurseryId, month);
    final totalChildren =
        branches.fold<int>(0, (s, b) => s + b.childCount);
    return PlatformBillModel(
      key: month.toString(),
      nurseryId: nurseryId,
      month: month,
      totalChildCount: totalChildren,
      totalAmount: totalChildren * kPlatformPricePerChild,
      branches: branches,
      status: 'unpaid',
    );
  }

  /// Snapshot the current breakdown and mark the month PAID for the nursery.
  Future<void> markPaid({
    required String nurseryId,
    required int month,
    required List<PlatformBillBranch> branches,
    required int totalChildCount,
    required double totalAmount,
    String? note,
  }) async {
    final session = SessionService();
    final bill = PlatformBillModel(
      key: month.toString(),
      nurseryId: nurseryId,
      month: month,
      totalChildCount: totalChildCount,
      totalAmount: totalAmount,
      branches: branches,
      status: 'paid',
      paidAt: DateTime.now().millisecondsSinceEpoch,
      collectedBy: session.userId,
      collectedByName: session.currentUser?.displayName,
      note: note,
    );
    await _billRef(nurseryId, month).set(bill.toJson());
  }

  /// Undo a collection (remove the record → month projects as unpaid again).
  Future<void> markUnpaid(String nurseryId, int month) async {
    await _billRef(nurseryId, month).remove();
  }
}
