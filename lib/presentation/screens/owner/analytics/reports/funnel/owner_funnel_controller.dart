import '../../../../../../index/index_main.dart';

/// Recruitment Funnel — the intake pipeline the owner watches alongside churn:
/// online applications → waiting list → active enrollments, plus the end-to-end
/// conversion rate. Network-level; self-loads its three flat collections.
class OwnerFunnelController extends GetxController {
  late final OnlineApplicationParentService _appSvc;
  late final WaitingListParentService _waitSvc;
  late final EnrollmentParentService _enrollSvc;

  final RxBool isLoading = false.obs;

  final _apps = <OnlineApplicationModel>[].obs;
  final _waiting = <WaitingListModel>[].obs;
  final _enrollments = <EnrollmentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _appSvc = Get.find<OnlineApplicationParentService>();
    _waitSvc = Get.find<WaitingListParentService>();
    _enrollSvc = Get.find<EnrollmentParentService>();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final r = await Future.wait([
        _fetch<OnlineApplicationModel>(_appSvc.getAll),
        _fetch<WaitingListModel>(_waitSvc.getAll),
        _fetch<EnrollmentModel>(_enrollSvc.getAll),
      ]);
      _apps.assignAll(r[0].cast<OnlineApplicationModel>());
      _waiting.assignAll(r[1].cast<WaitingListModel>());
      _enrollments.assignAll(r[2].cast<EnrollmentModel>());
    } finally {
      isLoading.value = false;
    }
  }

  // ── Stage counts ─────────────────────────────────────────────────────────
  int get applications => _apps.length;
  int get appsPending => _apps.where((a) => a.status == 'pending').length;
  int get appsApproved => _apps.where((a) => a.status == 'approved').length;
  int get appsRejected => _apps.where((a) => a.status == 'rejected').length;

  /// Families still in the queue (not yet enrolled or cancelled).
  int get waitingActive => _waiting
      .where((w) => w.status == 'pending' || w.status == 'contacted')
      .length;

  int get enrolled =>
      _enrollments.where((e) => e.status == 'enrolled').length;

  /// End-to-end: how many applications became active enrollments.
  int get conversionRate =>
      applications == 0 ? 0 : ((enrolled / applications) * 100).round();

  bool get isEmpty =>
      applications == 0 && waitingActive == 0 && enrolled == 0;

  /// The three funnel stages as bars (fill relative to the widest stage).
  List<FunnelStage> get stages {
    final data = [
      FunnelStage(labelKey: 'owner_report_fn_applications', count: applications),
      FunnelStage(labelKey: 'owner_report_fn_waiting', count: waitingActive),
      FunnelStage(labelKey: 'owner_report_fn_enrolled', count: enrolled),
    ];
    final max = data.fold<int>(0, (m, s) => s.count > m ? s.count : m);
    return data
        .map((s) => FunnelStage(
              labelKey: s.labelKey,
              count: s.count,
              share: max == 0 ? 0 : s.count / max,
            ))
        .toList();
  }

  /// Application outcomes.
  List<FunnelStage> get appStatus {
    final total = applications;
    return [
      FunnelStage(labelKey: 'owner_report_fn_pending', count: appsPending),
      FunnelStage(labelKey: 'owner_report_fn_approved', count: appsApproved),
      FunnelStage(labelKey: 'owner_report_fn_rejected', count: appsRejected),
    ]
        .map((s) => FunnelStage(
              labelKey: s.labelKey,
              count: s.count,
              share: total == 0 ? 0 : s.count / total,
            ))
        .toList();
  }

  Future<List<T>> _fetch<T>(
      Future<void> Function({required Function(List<T?>) callBack}) getAll) {
    final c = Completer<List<T>>();
    getAll(callBack: (list) {
      if (!c.isCompleted) c.complete(list.whereType<T>().toList());
    });
    return c.future;
  }
}

/// One funnel stage / status bar.
class FunnelStage {
  final String labelKey;
  final int count;
  final double share;
  const FunnelStage({
    required this.labelKey,
    required this.count,
    this.share = 0,
  });
}
