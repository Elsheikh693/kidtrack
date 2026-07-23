import '../../../../index/index_main.dart';

/// Drives the post-login "which hat am I wearing?" screen. Reached only when a
/// single identity holds two or more memberships (a teacher who is also a mum, a
/// teacher working at two nurseries, …). Picking one hands the choice to
/// [AuthBootstrapService.finalizeMembership], which runs the normal login guards.
class MembershipPickerController extends GetxController {
  final options = <MembershipModel>[].obs;

  /// nurseryId → display name, resolved lazily so two same-role memberships at
  /// different nurseries are distinguishable.
  final nurseryNames = <String, String>{}.obs;

  final isBusy = false.obs;

  late final IdentityService _identity;
  late final AuthBootstrapService _bootstrap;

  String _uid = '';
  Map<String, dynamic> _identityData = const {};

  /// True when opened as an in-app switcher (a logged-in user changing hats) —
  /// then the screen is dismissible. False on the login gate (must pick to enter).
  bool canCancel = false;

  String get displayName => _identityData['name']?.toString() ?? '';

  @override
  void onInit() {
    super.onInit();
    _identity = Get.find<IdentityService>();
    _bootstrap = Get.find<AuthBootstrapService>();

    final args = Get.arguments as Map? ?? const {};
    _uid = (args['uid'] as String?) ?? '';
    _identityData = (args['identity'] is Map)
        ? Map<String, dynamic>.from(args['identity'] as Map)
        : const {};
    canCancel = args['canCancel'] == true;
    final raw = (args['memberships'] as List?) ?? const [];
    options.value = raw
        .whereType<Map>()
        .map((e) => MembershipModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    _loadNurseryNames();
  }

  /// Localized role label (keys mirror the UserType enum names).
  String roleLabel(MembershipModel m) => 'membership_role_${m.role}'.tr;

  String nurseryLabel(MembershipModel m) =>
      nurseryNames[m.nurseryId] ?? 'membership_nursery_fallback'.tr;

  Future<void> _loadNurseryNames() async {
    for (final m in options) {
      if (nurseryNames.containsKey(m.nurseryId)) continue;
      final name = await _identity.nurseryName(m.nurseryId);
      if (name != null && name.isNotEmpty) nurseryNames[m.nurseryId] = name;
    }
  }

  Future<void> select(MembershipModel m) async {
    if (isBusy.value) return;
    isBusy.value = true;
    Loader.show();
    final ok = await _bootstrap.finalizeMembership(
      uid: _uid,
      identity: _identityData,
      role: m.role,
      nurseryId: m.nurseryId,
      branchId: m.branchId ?? '',
    );
    // On success finalize already routed to main. On failure it surfaced an
    // error + signed out — send the user back to the code screen to retry.
    if (!ok) {
      isBusy.value = false;
      Get.offAllNamed(activationCodeView);
    }
  }
}
