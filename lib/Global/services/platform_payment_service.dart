import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

/// The platform's own collection accounts (InstaPay number / wallet number /
/// InstaPay link) that every nursery pays its monthly subscription TO.
///
/// A single GLOBAL record at `platformPaymentInfo`. Uses direct RTDB access
/// (not the session-scoped 4-layer CRUD) because it is cross-nursery: the
/// SuperAdmin edits it, owners/managers read it on "My subscription" — same
/// rationale as [PlatformBillingService].
class PlatformPaymentService {
  final _db = FirebaseDatabase.instance;

  DatabaseReference get _ref => _db.ref(ApiConstants.platformPaymentInfo);

  /// The stored payment accounts, or an empty record if never set.
  Future<PlatformPaymentInfoModel> get() async {
    final snap = await _ref.get();
    if (snap.exists && snap.value is Map) {
      return PlatformPaymentInfoModel.fromJson(
        Map<String, dynamic>.from(snap.value as Map),
      );
    }
    return const PlatformPaymentInfoModel();
  }

  Future<void> save(PlatformPaymentInfoModel info) async {
    await _ref.set(info.toJson());
  }
}
