import '../../index/index_main.dart';
import 'package:firebase_database/firebase_database.dart';



class AuthenticationRemoteDataSourceImpl
    implements AuthenticationRemoteDataSource {
  final FirebaseDatabase _database;
  final ClientSourceRepo _client;

  AuthenticationRemoteDataSourceImpl(this._database, this._client);

  static const _usersPath = "users";

  DatabaseReference? _rootRef;
  final List<StreamSubscription> _subscriptions = [];

  // ─── Stream Controllers ───────────────────────────────────────────────────

  final _addedController = StreamController<Map<String, dynamic>>.broadcast();
  final _changedController = StreamController<Map<String, dynamic>>.broadcast();
  final _removedController = StreamController<String>.broadcast();

  @override
  Stream<Map<String, dynamic>> get onAdded => _addedController.stream;

  @override
  Stream<Map<String, dynamic>> get onChanged => _changedController.stream;

  @override
  Stream<String> get onRemoved => _removedController.stream;

  // ─── Realtime ─────────────────────────────────────────────────────────────

  @override
  Future<void> startListening() async {
    await stopListening();

    _rootRef = _database.ref(_usersPath);

    _subscriptions.addAll([
      _rootRef!.onChildAdded.listen((e) {
        final json = _parseSnapshot(e.snapshot);
        if (json != null) _addedController.add(json);
      }),
      _rootRef!.onChildChanged.listen((e) {
        final json = _parseSnapshot(e.snapshot);
        if (json != null) _changedController.add(json);
      }),
      _rootRef!.onChildRemoved.listen((e) {
        if (e.snapshot.key != null) _removedController.add(e.snapshot.key!);
      }),
    ]);
  }

  @override
  Future<void> stopListening() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _rootRef = null;
  }

  // ─── Read ─────────────────────────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> fetchUsers(
    Map<String, dynamic> filters,
  ) async {
    try {
      final response = await _client.request(
        HttpMethod.get,
        "/$_usersPath.json",
        params: filters,
      );

      if (response == null || response is! Map) return [];

      return response.entries
          .whereType<MapEntry>()
          .where((e) => e.value is Map)
          .map((e) {
            final json = Map<String, dynamic>.from(
              (e.value as Map).map((k, v) => MapEntry(k.toString(), v)),
            );
            json['uid'] = e.key.toString();
            return json;
          })
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchUserByUid(String uid) async {
    try {
      final response = await _client.request(
        HttpMethod.get,
        "/$_usersPath/$uid.json",
        params: {},
      );

      if (response == null || response is! Map) return null;

      final json = Map<String, dynamic>.from(
        response.map((k, v) => MapEntry(k.toString(), v)),
      );
      json['uid'] = uid;
      return json;
    } catch (_) {
      return null;
    }
  }

  // ─── Write ────────────────────────────────────────────────────────────────

  @override
  Future<void> createUser(Map<String, dynamic> data) async {
    final uid = data['uid'];
    if (uid == null) return;

    await _client.request(
      HttpMethod.patch,
      "/$_usersPath/$uid.json",
      params: data,
    );
  }

  @override
  Future<void> updateUser(Map<String, dynamic> data) async {
    final uid = data['uid'];
    if (uid == null) return;

    await _client.request(
      HttpMethod.patch,
      "/$_usersPath/$uid.json",
      params: data,
    );
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _client.request(
      HttpMethod.delete,
      "/$_usersPath/$uid.json",
      params: {},
    );
  }

  // ─── Private ──────────────────────────────────────────────────────────────

  Map<String, dynamic>? _parseSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value;
    if (data == null || data is! Map) return null;

    final json = Map<String, dynamic>.from(
      data.map((k, v) => MapEntry(k.toString(), v)),
    );
    json['uid'] = snapshot.key;
    return json;
  }
}
