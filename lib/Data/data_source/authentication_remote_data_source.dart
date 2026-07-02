abstract class AuthenticationRemoteDataSource {
  // ─── Write ────────────────────────────────────────────────────────────────
  Future<void> createUser(Map<String, dynamic> data);
  Future<void> updateUser(Map<String, dynamic> data);
  Future<void> deleteUser(String uid);

  // ─── Read ─────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> fetchUsers(Map<String, dynamic> filters);
  Future<Map<String, dynamic>?> fetchUserByUid(String uid);

  // ─── Realtime ─────────────────────────────────────────────────────────────
  Future<void> startListening();
  Future<void> stopListening();

  Stream<Map<String, dynamic>> get onAdded;
  Stream<Map<String, dynamic>> get onChanged;
  Stream<String> get onRemoved;
}
