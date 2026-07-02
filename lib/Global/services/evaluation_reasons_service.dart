import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import '../../Data/models/evaluation_reason/evaluation_reason_model.dart';

class EvaluationReasonsService extends GetxService {
  final _db = FirebaseDatabase.instance;

  DatabaseReference _ref(String nurseryId) =>
      _db.ref('platform/$nurseryId/evaluationReasons');

  Future<List<EvaluationReasonModel>> getAll(String nurseryId) async {
    final snap = await _ref(nurseryId).get();
    if (!snap.exists || snap.value == null) return [];
    final map = Map<dynamic, dynamic>.from(snap.value as Map);
    final list = map.entries
        .where((e) => e.value is Map)
        .map((e) => EvaluationReasonModel.fromJson(
              Map<dynamic, dynamic>.from(e.value as Map),
              key: e.key.toString(),
            ))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Stream<List<EvaluationReasonModel>> watchAll(String nurseryId) {
    return _ref(nurseryId).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final map = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      return map.entries
          .where((e) => e.value is Map)
          .map((e) => EvaluationReasonModel.fromJson(
                Map<dynamic, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
  }

  /// Adds a new reason. Returns existing one if title already exists (case-insensitive).
  Future<EvaluationReasonModel> addOrGet(
      String nurseryId, String title) async {
    final trimmed = title.trim();
    final all = await getAll(nurseryId);
    final existing = all.cast<EvaluationReasonModel?>().firstWhere(
          (r) => r!.title.trim().toLowerCase() == trimmed.toLowerCase(),
          orElse: () => null,
        );
    if (existing != null) return existing;

    final ref = _ref(nurseryId).push();
    final reason = EvaluationReasonModel(
      key: ref.key,
      nurseryId: nurseryId,
      title: trimmed,
      isActive: true,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await ref.set(reason.toJson());
    return reason;
  }

  Future<void> updateReason(
      String nurseryId, EvaluationReasonModel reason) async {
    if (reason.key == null) return;
    await _ref(nurseryId)
        .child(reason.key!)
        .update({'title': reason.title, 'isActive': reason.isActive});
  }

  Future<void> deleteReason(String nurseryId, String key) async {
    await _ref(nurseryId).child(key).remove();
  }
}
