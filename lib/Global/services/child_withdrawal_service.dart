import 'package:cloud_functions/cloud_functions.dart';
import '../../index/index_main.dart';

/// Orchestrates a permanent child withdrawal. The actual delete (child data +
/// orphaned-parent records + Firebase Auth) runs server-side in the
/// `withdrawChild` Cloud Function, since deleting another user's Auth account
/// requires the Admin SDK. This client wrapper just invokes it and reports
/// success/failure back to the caller.
class ChildWithdrawalService {
  final _session = SessionService();

  /// Withdraws [childId] with a human [reason]. Returns true on success.
  Future<bool> withdrawChild({
    required String childId,
    required String reason,
  }) async {
    final nurseryId = _session.nurseryId ?? '';
    if (nurseryId.isEmpty || childId.isEmpty) return false;
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('withdrawChild');
      final result = await callable.call<Map<String, dynamic>>({
        'nurseryId': nurseryId,
        'childId': childId,
        'reason': reason,
      });
      return result.data['ok'] == true;
    } catch (_) {
      return false;
    }
  }
}
