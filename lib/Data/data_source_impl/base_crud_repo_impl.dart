import '../../index/index_main.dart';

class BaseCrudRepoImpl<T> extends BaseCrudRepo<T> {
  final ClientSourceRepo client;
  final String Function() _endpointFn;
  final T Function(Map<String, dynamic>) fromJson;

  BaseCrudRepoImpl({
    required this.client,
    required String Function() endpoint,
    required this.fromJson,
  }) : _endpointFn = endpoint;

  String get endpoint => _endpointFn();

  // ─── Get All ──────────────────────────────────────────────────────────────

  @override
  Future<List<T?>> getAll(Map<String, dynamic> params) async {
    try {
      // ✅ Dio already has baseUrl — just send the relative path
      final response = await client.request(
        HttpMethod.get,
        '$endpoint.json',
        params: params,
      );

      return _parseFirebaseMap(response);
    } catch (_) {
      return [];
    }
  }

  // ─── Add ──────────────────────────────────────────────────────────────────

  @override
  Future<SuccessModel> add(Map<String, dynamic> data, String id) async {
    try {
      final response = await client.request(
        HttpMethod.patch,
        '$endpoint/$id.json',
        params: data,
      );
      return SuccessModel.fromJson(response ?? {});
    } catch (_) {
      return const SuccessModel(message: 'Add failed');
    }
  }

  // ─── Update ───────────────────────────────────────────────────────────────

  @override
  Future<SuccessModel> update(Map<String, dynamic> data, String id) async {
    try {
      final response = await client.request(
        HttpMethod.patch,
        '$endpoint/$id.json',
        params: data,
      );
      return SuccessModel.fromJson(response ?? {});
    } catch (_) {
      return const SuccessModel(message: 'Update failed');
    }
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  @override
  Future<SuccessModel> delete(Map<String, dynamic> data, String id) async {
    try {
      final response = await client.request(
        HttpMethod.delete,
        '$endpoint/$id.json',
      );
      return response == null
          ? const SuccessModel(message: 'تمت العملية بنجاح')
          : SuccessModel.fromJson(response);
    } catch (_) {
      return const SuccessModel(message: 'Delete failed');
    }
  }

  // ─── Parse Firebase Map Response ─────────────────────────────────────────
  // Firebase returns { "id1": {...}, "id2": {...} }
  // We convert it to List<T>

  List<T?> _parseFirebaseMap(dynamic response) {
    if (response == null || response is! Map) return [];

    return response.entries
        .whereType<MapEntry>()
        .where((e) => e.value is Map)
        .map((e) {
          try {
            final json = Map<String, dynamic>.from(
              (e.value as Map).map((k, v) => MapEntry(k.toString(), v)),
            );
            json['key'] = e.key.toString(); // ← inject Firebase key

            return fromJson(json);
          } catch (_) {
            return null;
          }
        })
        .toList();
  }
}
