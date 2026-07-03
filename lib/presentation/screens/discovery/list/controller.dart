import 'dart:math' as math;
import '../../../../index/index_main.dart';

/// Discovery sort options. `null` = default (name A→Z).
enum DiscoverySort { nearest, lowestPrice, highestRated, mostPopular }

class DiscoveryController extends GetxController {
  late final NurseryParentService _service;
  late final CityParentService _cityService;
  final LocationManager _location = LocationManager();

  final RxList<NurseryModel> _all = <NurseryModel>[].obs;
  final RxList<NurseryModel> filtered = <NurseryModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool searchOpen = false.obs;
  final RxString searchQuery = ''.obs;
  final searchTextCtrl = TextEditingController();

  // ─── Filters ───────────────────────────────────────────────────────────────
  /// Child age in months (the strongest narrowing filter). null = inactive.
  final RxnInt childAgeMonths = RxnInt();

  /// Selected normalized monthly price window. null = inactive.
  final Rxn<RangeValues> priceRange = Rxn<RangeValues>();

  /// Max distance in km. Only effective when [useLocation] resolved a position.
  final RxnDouble distanceKm = RxnDouble();

  /// Selected city filter (matches `NurseryModel.cityId`). null = all cities.
  final RxnString cityId = RxnString();

  /// The global city list (SuperAdmin managed), used to populate the dropdown.
  final RxList<CityModel> cities = <CityModel>[].obs;

  final RxBool useLocation = false.obs;
  final RxBool locating = false.obs;
  final RxnDouble userLat = RxnDouble();
  final RxnDouble userLng = RxnDouble();

  // ─── Sort ────────────────────────────────────────────────────────────────
  final Rxn<DiscoverySort> sort = Rxn<DiscoverySort>();

  Worker? _searchWorker;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<NurseryParentService>();
    _cityService = Get.find<CityParentService>();
    _searchWorker = debounce(
      searchQuery,
      (_) => _apply(),
      time: const Duration(milliseconds: 300),
    );
    loadData();
    loadCities();
  }

  Future<void> loadCities() async {
    await _cityService.getAll(callBack: (list) {
      cities.assignAll(list.whereType<CityModel>().toList()
        ..sort((a, b) => a.name.compareTo(b.name)));
    });
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    searchTextCtrl.dispose();
    super.onClose();
  }

  void toggleSearch() {
    searchOpen.value = !searchOpen.value;
    if (!searchOpen.value && searchQuery.value.isNotEmpty) {
      searchTextCtrl.clear();
      searchQuery.value = '';
    }
  }

  bool get hasActiveFilter =>
      childAgeMonths.value != null ||
      priceRange.value != null ||
      cityId.value != null ||
      (distanceKm.value != null && hasUserLocation);

  int get activeFilterCount {
    var n = 0;
    if (childAgeMonths.value != null) n++;
    if (priceRange.value != null) n++;
    if (cityId.value != null) n++;
    if (distanceKm.value != null && hasUserLocation) n++;
    return n;
  }

  bool get hasUserLocation => userLat.value != null && userLng.value != null;

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        _all.value = list
            .whereType<NurseryModel>()
            .where((n) => n.isActive && n.isListed)
            .toList();
      },
    );
    _apply();
    isLoading.value = false;
  }

  // ─── Price bounds (from the loaded data) ───────────────────────────────────
  double get priceBoundMin {
    final vals = _all.map((n) => n.priceFrom).whereType<double>();
    if (vals.isEmpty) return 0;
    return vals.reduce(math.min).floorToDouble();
  }

  double get priceBoundMax {
    final vals = _all.map((n) => n.priceTo).whereType<double>();
    if (vals.isEmpty) return 5000;
    final mx = vals.reduce(math.max).ceilToDouble();
    return mx <= priceBoundMin ? priceBoundMin + 1000 : mx;
  }

  void onSearch(String value) => searchQuery.value = value;

  // ─── Filter mutations ──────────────────────────────────────────────────────
  void applyFilters({
    required int? age,
    required RangeValues? price,
    required double? distance,
    required String? city,
  }) {
    childAgeMonths.value = age;
    priceRange.value = price;
    distanceKm.value = distance;
    cityId.value = city;
    _apply();
  }

  void clearFilters() {
    childAgeMonths.value = null;
    priceRange.value = null;
    distanceKm.value = null;
    cityId.value = null;
    _apply();
  }

  void setSort(DiscoverySort? value) {
    sort.value = value;
    _apply();
  }

  /// Resolves the device position (asking for permission the first time). Called
  /// only when the user opts in via the "Use my location" toggle — never on open.
  Future<bool> enableLocation() async {
    locating.value = true;
    final pos = await _location.getCurrentPosition();
    locating.value = false;
    if (pos == null) {
      useLocation.value = false;
      return false;
    }
    userLat.value = pos.latitude;
    userLng.value = pos.longitude;
    useLocation.value = true;
    _apply();
    return true;
  }

  void disableLocation() {
    useLocation.value = false;
    userLat.value = null;
    userLng.value = null;
    _apply();
  }

  /// Straight-line distance (km) from the user to a nursery, using the main
  /// location or the first located branch. null when either side lacks coords.
  double? distanceKmFor(NurseryModel n) {
    final ulat = userLat.value, ulng = userLng.value;
    if (ulat == null || ulng == null) return null;
    double? nlat = n.lat, nlng = n.lng;
    if (nlat == null || nlng == null) {
      final b = n.branches.firstWhereOrNull((b) => b.hasLocation);
      nlat = b?.lat;
      nlng = b?.lng;
    }
    if (nlat == null || nlng == null) return null;
    final meters = _location.calculateDistance(
      startLat: ulat,
      startLng: ulng,
      endLat: nlat,
      endLng: nlng,
    );
    return meters / 1000;
  }

  void _apply() {
    final q = searchQuery.value.trim().toLowerCase();
    final age = childAgeMonths.value;
    final pr = priceRange.value;
    final city = cityId.value;
    final maxKm = distanceKm.value;
    final distanceActive = maxKm != null && hasUserLocation;

    var list = _all.where((n) {
      if (q.isNotEmpty) {
        final match = n.name.toLowerCase().contains(q) ||
            (n.address?.toLowerCase().contains(q) ?? false);
        if (!match) return false;
      }
      if (city != null && n.cityId != city) return false;
      if (age != null && !n.acceptsAgeMonths(age)) return false;
      if (pr != null) {
        final from = n.priceFrom, to = n.priceTo;
        if (from == null || to == null) return false;
        if (to < pr.start || from > pr.end) return false;
      }
      if (distanceActive) {
        final d = distanceKmFor(n);
        if (d == null || d > maxKm) return false;
      }
      return true;
    }).toList();

    switch (sort.value) {
      case DiscoverySort.nearest:
        list.sort((a, b) {
          final da = distanceKmFor(a), db = distanceKmFor(b);
          if (da == null && db == null) return a.name.compareTo(b.name);
          if (da == null) return 1;
          if (db == null) return -1;
          return da.compareTo(db);
        });
        break;
      case DiscoverySort.lowestPrice:
        list.sort((a, b) {
          final pa = a.priceFrom, pb = b.priceFrom;
          if (pa == null && pb == null) return a.name.compareTo(b.name);
          if (pa == null) return 1;
          if (pb == null) return -1;
          return pa.compareTo(pb);
        });
        break;
      case DiscoverySort.highestRated:
        list.sort((a, b) => (b.rating ?? -1).compareTo(a.rating ?? -1));
        break;
      case DiscoverySort.mostPopular:
        list.sort(
            (a, b) => (b.childrenCount ?? 0).compareTo(a.childrenCount ?? 0));
        break;
      case null:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    filtered.value = list;
  }

  void openProfile(NurseryModel nursery) =>
      Get.toNamed(nurseryProfileView, arguments: nursery);

  void applyTo(NurseryModel nursery) =>
      Get.toNamed(onlineApplicationView, arguments: nursery);
}
