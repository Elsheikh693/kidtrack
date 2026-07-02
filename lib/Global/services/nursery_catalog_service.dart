import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

/// Reads a nursery's branches and fee packages before the parent has an account.
///
/// Pre-login, [ApiConstants.nurseryId] is empty so the standard scoped CRUD
/// cannot target the chosen nursery. This reads directly from
/// `platform/{nurseryId}/branches` and `/packages` with the explicit nursery id
/// (the documented pre-login direct-read exception). Only active records are
/// returned, since a guest should not see disabled branches or packages.
class NurseryCatalogService {
  Future<List<BranchModel>> branches(String nurseryId) async {
    if (nurseryId.isEmpty) return const [];
    try {
      final snap = await FirebaseDatabase.instance
          .ref(ApiConstants.branchesFor(nurseryId))
          .get();
      return _parse<BranchModel>(
        snap.value,
        (map, key) => BranchModel.fromJson(map, key: key),
      ).where((b) => b.isActive).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<PackageModel>> packages(String nurseryId) async {
    if (nurseryId.isEmpty) return const [];
    try {
      final snap = await FirebaseDatabase.instance
          .ref(ApiConstants.packagesFor(nurseryId))
          .get();
      return _parse<PackageModel>(
        snap.value,
        (map, key) => PackageModel.fromJson(map, key: key),
      ).where((p) => p.isActive).toList();
    } catch (_) {
      return const [];
    }
  }

  List<T> _parse<T>(
    Object? raw,
    T Function(Map<String, dynamic> map, String? key) build,
  ) {
    if (raw is! Map) return const [];
    final result = <T>[];
    raw.forEach((key, value) {
      if (value is Map) {
        result.add(build(Map<String, dynamic>.from(value), key?.toString()));
      }
    });
    return result;
  }
}
