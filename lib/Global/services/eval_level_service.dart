import 'package:firebase_database/firebase_database.dart';
import '../../Data/models/eval_level_template/eval_level_template_model.dart';

/// Read path for the nursery's activity evaluation levels. Mirrors
/// `ChildStateService.loadActiveTemplates`. CRUD goes through the generic
/// BaseService (tag 'evalLevelTemplates'); this is the runtime read used by the
/// activity end sheet and the reports.
class EvalLevelService {
  final _db = FirebaseDatabase.instance;

  Future<List<EvalLevelTemplateModel>> loadActiveTemplates(
      String nurseryId) async {
    if (nurseryId.isEmpty) return [];
    try {
      final snap =
          await _db.ref('platform/$nurseryId/evalLevelTemplates').get();
      if (!snap.exists || snap.value == null) return [];
      final data = snap.value as Map? ?? {};
      final list = data.entries
          .where((e) => e.value is Map)
          .map((e) => EvalLevelTemplateModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .where((t) => t.isActive)
          .toList()
        // Highest score first (ممتاز → دعم), ties by insertion order.
        ..sort((a, b) {
          final s = b.score.compareTo(a.score);
          return s != 0 ? s : a.createdAt.compareTo(b.createdAt);
        });
      return list;
    } catch (_) {
      return [];
    }
  }
}
