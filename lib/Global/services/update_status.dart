import 'package:get/get.dart';
import '../constants/app_strings.dart';
import 'storage_service.dart';

class ForceUpdate extends GetxController {
  static const _key = Strings.forceUpdate;

  final StorageService _storage = StorageService();

  Future<bool> save(bool isForceUpdate) {
    return _storage.setData(_key, {"value": isForceUpdate});
  }

  bool get isForceUpdateRequired {
    final data = _storage.getData(_key);
    return data?["value"] == true;
  }

  Future<void> clear() => _storage.remove(_key);
}

class OnboardLocalCheck {
  static const _key = Strings.hasSeenOnboard;
  static final _storage = StorageService();

  static bool isOnboardSeen() {
    final data = _storage.getData(_key);
    return data?["seen"] == true;
  }

  static Future<void> markSeen() {
    return _storage.setData(_key, {"seen": true});
  }
}
