import 'dart:io';

class FirebaseRemoteConfigKeys {
  static String get buildNumber =>
      Platform.isAndroid ? 'android_build_number' : 'ios_build_number';

  static String get forceEnabled =>
      Platform.isAndroid
          ? 'android_force_update_enabled'
          : 'ios_force_update_enabled';

  static String get forceRoles =>
      Platform.isAndroid
          ? 'android_force_update_roles'
          : 'ios_force_update_roles';

}
