import '../../../../index/index_main.dart';

class NurseryProfileController extends GetxController {
  late final NurseryModel nursery;

  final _catalog = NurseryCatalogService();

  /// Active fee packages for this nursery (pre-login direct read).
  final packages = <PackageModel>[].obs;
  final packagesLoading = false.obs;

  /// Catalog branches (carry the real `key` that `package.branchId` points at).
  /// These are the source of truth for grouping packages under their branch.
  final catalogBranches = <BranchModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    nursery = Get.arguments as NurseryModel;
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final id = nursery.key ?? '';
    if (id.isEmpty) return;
    packagesLoading.value = true;
    final results = await Future.wait([
      _catalog.branches(id),
      _catalog.packages(id),
    ]);
    final branches = (results[0] as List<BranchModel>)
      // Main branch first, then by name for a stable order.
      ..sort((a, b) {
        if (a.isMain != b.isMain) return a.isMain ? -1 : 1;
        return a.name.compareTo(b.name);
      });
    final pkgs = (results[1] as List<PackageModel>)
      // Cheapest normalized first so each branch reads as a price ladder.
      ..sort((a, b) =>
          a.normalizedMonthlyPrice.compareTo(b.normalizedMonthlyPrice));

    catalogBranches.assignAll(branches);
    packages.assignAll(pkgs);
    packagesLoading.value = false;
  }

  /// The branches to render, joined to their own packages by branch id — the
  /// reliable key that every package references. Canonical catalog branches are
  /// the single source of truth and now carry their own WhatsApp number. Falls
  /// back to any legacy embedded profile branches only when no catalog data
  /// exists.
  List<BranchView> get branchViews {
    if (catalogBranches.isEmpty) {
      return nursery.branches
          .map((b) => BranchView(
                name: b.name,
                address: b.address,
                phone: b.phone,
                whatsapp: b.whatsapp,
                lat: b.lat,
                lng: b.lng,
                packages: const [],
              ))
          .toList();
    }
    return catalogBranches.map((b) {
      return BranchView(
        name: b.name,
        address: b.address,
        phone: b.phone,
        whatsapp: b.whatsapp,
        lat: b.lat,
        lng: b.lng,
        packages: packages.where((p) => p.branchId == b.key).toList(),
      );
    }).toList();
  }

  bool get hasBranchViews => branchViews.isNotEmpty;

  /// Packages whose branch id matches no catalog branch — surfaced in a
  /// fallback list so a price is never silently hidden.
  List<PackageModel> get unattributedPackages {
    final ids = catalogBranches.map((b) => b.key).whereType<String>().toSet();
    return packages.where((p) => !ids.contains(p.branchId)).toList();
  }

  bool get hasLocation => nursery.lat != null && nursery.lng != null;

  /// Whether there is any "key facts" data worth showing (age / price / fee).
  bool get hasOverview =>
      nursery.minAgeMonths != null ||
      nursery.maxAgeMonths != null ||
      nursery.priceFrom != null ||
      nursery.applicationFeeFree ||
      nursery.applicationFee != null;

  bool get hasPhone => (nursery.phone ?? '').trim().isNotEmpty;

  /// WhatsApp is available if a dedicated number is set, or we can fall back
  /// to the regular phone number.
  bool get hasWhatsapp =>
      (nursery.whatsapp ?? '').trim().isNotEmpty || hasPhone;

  bool get hasBranches => hasBranchViews;

  void call() {
    final phone = nursery.phone?.trim() ?? '';
    if (phone.isEmpty) return;
    MakeCall.makePhoneCall(phone);
  }

  Future<void> whatsapp() async {
    // Prefer the dedicated WhatsApp number, fall back to the phone number.
    final raw = (nursery.whatsapp?.trim().isNotEmpty ?? false)
        ? nursery.whatsapp!.trim()
        : (nursery.phone?.trim() ?? '');
    await _openWhatsapp(raw);
  }

  /// Prefer the branch's dedicated WhatsApp number, fall back to its phone.
  Future<void> whatsappBranch(BranchView branch) => _openWhatsapp(
        (branch.whatsapp?.trim().isNotEmpty ?? false)
            ? branch.whatsapp!.trim()
            : (branch.phone?.trim() ?? ''),
      );

  Future<void> _openWhatsapp(String raw) async {
    await MakeCall.openWhatsApp(raw);
  }

  Future<void> openMaps() async {
    if (!hasLocation) return;
    await _launchMaps(nursery.lat!, nursery.lng!);
  }

  Future<void> openBranchMaps(BranchView branch) async {
    if (!branch.hasLocation) return;
    await _launchMaps(branch.lat!, branch.lng!);
  }

  void callBranch(BranchView branch) {
    final phone = branch.phone?.trim() ?? '';
    if (phone.isEmpty) return;
    MakeCall.makePhoneCall(phone);
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void goToLogin() => openActivationLoginSheet();

  void goToApply() =>
      Get.toNamed(onlineApplicationView, arguments: nursery);
}

/// A branch ready for display: its contact details plus the subscription
/// packages that belong to it (joined by branch id, not name).
class BranchView {
  final String name;
  final String? address;
  final String? phone;
  final String? whatsapp;
  final double? lat;
  final double? lng;
  final List<PackageModel> packages;

  const BranchView({
    required this.name,
    required this.packages,
    this.address,
    this.phone,
    this.whatsapp,
    this.lat,
    this.lng,
  });

  bool get hasLocation => lat != null && lng != null;
}
