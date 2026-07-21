import '../../../index/index_main.dart';

/// CRUD access to guardian-authored session notes. Reads pull the whole node and
/// filter client-side (MVP — same approach as [FinancialTransactionParentService];
/// swap for a server-side `orderBy` once an `.indexOn` rule ships for
/// `guardianNotes`).
class GuardianNoteParentService {
  final BaseService<GuardianNoteModel> _service =
      Get.find<BaseService<GuardianNoteModel>>(tag: 'guardianNotes');

  Future<void> getAll({
    required Function(List<GuardianNoteModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  /// Upsert (add == update — both PATCH the deterministic key).
  Future<void> upsert({
    required GuardianNoteModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.updateData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
    );
  }

  Future<void> delete({
    required String id,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.deleteData(id: id, voidCallBack: callBack);
  }

  /// Every note the guardian wrote for one child (used to prefill the parent's
  /// Link Book note UI).
  Future<List<GuardianNoteModel>> getForChild(String childId) async {
    final out = <GuardianNoteModel>[];
    await getAll(
      callBack: (list) => out.addAll(
        list.whereType<GuardianNoteModel>().where((n) => n.childId == childId),
      ),
    );
    return out;
  }

  /// Every note attached to a session in one of [classroomIds] (the staff-side
  /// inbox scope). Empty set → returns nothing.
  Future<List<GuardianNoteModel>> getForClassrooms(
      Set<String> classroomIds) async {
    if (classroomIds.isEmpty) return const [];
    final out = <GuardianNoteModel>[];
    await getAll(
      callBack: (list) => out.addAll(
        list
            .whereType<GuardianNoteModel>()
            .where((n) => classroomIds.contains(n.classroomId)),
      ),
    );
    out.sort((a, b) => (b.updatedAt ?? b.createdAt ?? 0)
        .compareTo(a.updatedAt ?? a.createdAt ?? 0));
    return out;
  }
}
