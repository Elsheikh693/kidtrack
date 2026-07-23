import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../Data/models/membership/membership_model.dart';

/// Owns the "one identity, many memberships" model.
///
/// * [resolveByPhone] wraps the `resolveAccount` Cloud Function — it returns the
///   single Firebase uid for a phone, creating the auth account only if the phone
///   is brand-new. This is what lets a phone that already belongs to a teacher be
///   added as a guardian (or as staff at a second nursery) without colliding.
/// * The membership helpers read/write `users/{uid}/memberships/{id}` — the list
///   the login flow reads to offer a role picker when a person wears more than
///   one hat.
class IdentityService {
  final _db = FirebaseDatabase.instance;

  /// Resolves (or creates) the single identity for [phone]. Returns its uid and
  /// whether the auth account was freshly created (`created == false` means the
  /// phone already had an account — attach a new membership rather than
  /// overwriting the existing identity). Throws on failure.
  Future<({String uid, bool created})> resolveByPhone({
    required String phone,
    required String name,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable('resolveAccount');
    final res = await callable.call<dynamic>({'phone': phone, 'name': name});
    final raw = res.data;
    final data =
        raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
    final uid = data['uid']?.toString() ?? '';
    if (uid.isEmpty) {
      throw Exception('resolveAccount returned no uid');
    }
    return (uid: uid, created: data['created'] == true);
  }

  /// Attaches one membership to an identity and merges the identity record.
  ///
  /// Handles the migration edge automatically: a legacy account (scalar
  /// userType/nurseryId on `users/{uid}`, no memberships node yet) keeps its
  /// prior hat by materialising it as a membership BEFORE the new one is added —
  /// so making a pre-existing teacher into a guardian never costs them their
  /// teacher login. Idempotent by [MembershipModel.id].
  ///
  /// The scalar userType/nurseryId are refreshed to this (latest) membership as
  /// the "default" the login flow falls back to only for single-membership
  /// accounts.
  Future<void> attachMembership({
    required String uid,
    required String role,
    required String nurseryId,
    String? branchId,
    required String name,
    required String phone,
  }) async {
    final ref = _db.ref('users/$uid');
    final snap = await ref.get();
    final existing = (snap.exists && snap.value is Map)
        ? Map<String, dynamic>.from(snap.value as Map)
        : <String, dynamic>{};

    final membershipsExist = existing['memberships'] is Map &&
        (existing['memberships'] as Map).isNotEmpty;

    if (!membershipsExist) {
      final oldRole = existing['userType']?.toString() ?? '';
      final oldNursery = existing['nurseryId']?.toString() ?? '';
      if (oldRole.isNotEmpty && oldNursery.isNotEmpty) {
        final legacy = MembershipModel(
          role: oldRole,
          nurseryId: oldNursery,
          branchId: existing['branchId']?.toString(),
        );
        await _db
            .ref('users/$uid/memberships/${legacy.id}')
            .set(legacy.toJson());
      }
    }

    final m = MembershipModel(
      role: role,
      nurseryId: nurseryId,
      branchId: branchId,
    );
    await _db.ref('users/$uid/memberships/${m.id}').set(m.toJson());

    await ref.update({
      'uid': uid,
      'name': name,
      'phone': phone,
      'nurseryId': nurseryId,
      'branchId': branchId ?? '',
      'userType': role,
    });
  }

  /// Every membership on an identity. Empty for legacy accounts created before
  /// the memberships node existed — callers fall back to the scalar
  /// userType/nurseryId on the `users/{uid}` node in that case.
  Future<List<MembershipModel>> memberships(String uid) async {
    final snap = await _db.ref('users/$uid/memberships').get();
    if (!snap.exists || snap.value is! Map) return const [];
    final map = Map<String, dynamic>.from(snap.value as Map);
    return map.values
        .whereType<Map>()
        .map((e) => MembershipModel.fromJson(Map<String, dynamic>.from(e)))
        .where((m) => m.role.isNotEmpty && m.nurseryId.isNotEmpty)
        .toList();
  }

  /// Removes a single membership. Does NOT touch the identity — the caller
  /// decides whether the identity is now orphaned (no memberships left).
  Future<void> removeMembership({
    required String uid,
    required String nurseryId,
    required String role,
  }) =>
      _db.ref('users/$uid/memberships/${nurseryId}_$role').remove();

  /// Display name of a nursery from the global registry (`platform/info/{id}`),
  /// used by the picker to distinguish two same-role memberships at different
  /// nurseries. Returns null if unavailable.
  Future<String?> nurseryName(String nurseryId) async {
    if (nurseryId.isEmpty) return null;
    try {
      final snap = await _db.ref('platform/info/$nurseryId/name').get();
      final v = snap.value?.toString();
      return (v == null || v.isEmpty) ? null : v;
    } catch (_) {
      return null;
    }
  }
}
