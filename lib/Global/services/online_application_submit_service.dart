import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

/// Submits an admission application before the parent has an account.
///
/// Pre-login, [ApiConstants.nurseryId] is empty so the standard scoped CRUD
/// cannot target the chosen nursery. This writes directly to
/// `platform/{nurseryId}/onlineApplications/{id}` with the explicit nursery id
/// (the documented pre-login direct-write exception).
class OnlineApplicationSubmitService {
  Future<bool> submit(OnlineApplicationModel application) async {
    final nurseryId = application.nurseryId;
    if (nurseryId.isEmpty) return false;

    final id = application.key?.isNotEmpty == true
        ? application.key!
        : const Uuid().v4();
    final toSave = application.copyWith(
      key: id,
      status: 'pending',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      await FirebaseDatabase.instance
          .ref('${ApiConstants.onlineApplicationsFor(nurseryId)}/$id')
          .set(toSave.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }
}
