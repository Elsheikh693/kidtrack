import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

class StaffDashboardController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxMap<String, bool> permissions = <String, bool>{}.obs;

  final _session = SessionService();

  String get staffName => _session.currentUser?.displayName ?? '';

  @override
  void onInit() {
    super.onInit();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    isLoading.value = true;
    final uid       = _session.userId;
    final nurseryId = _session.nurseryId;

    if (uid == null || nurseryId == null) {
      isLoading.value = false;
      return;
    }

    try {
      final snap = await FirebaseDatabase.instance
          .ref('platform/$nurseryId/permissionSets/$uid')
          .get();

      if (snap.exists && snap.value is Map) {
        final data  = Map<String, dynamic>.from(snap.value as Map);
        final perms = data['permissions'];
        if (perms is Map) {
          permissions.value = {
            for (final k in PermissionKeys.all) k: false,
            ...Map<String, bool>.from(
              perms.map((k, v) => MapEntry(
                k.toString(),
                v == true || v == 1 || v == '1',
              )),
            ),
          };
        }
      }
    } catch (_) {}

    isLoading.value = false;
  }

  bool has(String key) => permissions[key] == true;
}
