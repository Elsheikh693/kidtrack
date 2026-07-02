import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../index/index_main.dart';

// owner,branchManager,teacher,parent,receptionist
class FirebaseRemoteConfigService {
  FirebaseRemoteConfigService._internal()
    : _remoteConfig = FirebaseRemoteConfig.instance;

  static final FirebaseRemoteConfigService _instance =
      FirebaseRemoteConfigService._internal();

  factory FirebaseRemoteConfigService() => _instance;

  final FirebaseRemoteConfig _remoteConfig;

  late int _localBuild;
  late int _remoteBuild;
  late bool _forceEnabled;
  late List<String> _forceRoles;

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> checkForceUpdate() async {
    await _setupRemoteConfig();
    await _loadLocalBuild();
    _loadRemoteValues();
    await ForceUpdate().save(_shouldForceUpdate());
  }

  // ── Setup ─────────────────────────────────────────────────────────────────

  Future<void> _setupRemoteConfig() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 4),
        minimumFetchInterval: const Duration(seconds: 5),
      ),
    );
    await _remoteConfig.fetchAndActivate();
  }

  // ── Loaders ───────────────────────────────────────────────────────────────

  Future<void> _loadLocalBuild() async {
    final info = await PackageInfo.fromPlatform();
    _localBuild = int.tryParse(info.buildNumber) ?? 0;
  }

  void _loadRemoteValues() {
    _remoteBuild = _remoteConfig.getInt(FirebaseRemoteConfigKeys.buildNumber);
    _forceEnabled = _remoteConfig.getBool(
      FirebaseRemoteConfigKeys.forceEnabled,
    );

    final rolesString = _remoteConfig.getString(
      FirebaseRemoteConfigKeys.forceRoles,
    );
    _forceRoles = rolesString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // ── Decision Logic ────────────────────────────────────────────────────────

  bool _shouldForceUpdate() {
    // Feature disabled remotely
    if (!_forceEnabled) return false;

    // Already up to date
    if (_localBuild >= _remoteBuild) return false;

    // No roles list = force everyone
    if (_forceRoles.isEmpty) return true;

    // Check current user's role
    final userType = SessionService().currentUser?.userType;
    if (userType == null) return false;

    return _forceRoles.contains(userType.name);
  }
}
