import '../../../../../../index/index_main.dart';

/// Homework Engagement — how families are engaging with homework, from the
/// parent `HomeworkSubmissionModel` (last 30 days): submission volume, distinct
/// homework and children, and the "how did it go" quality signal (needed help /
/// guided hand / did it easily). Network-level.
class OwnerHomeworkController extends GetxController {
  late final TeacherActivityService _activitySvc;
  final SessionService _session = SessionService();

  final RxBool isLoading = false.obs;
  static const int _spanDays = 30;

  final _subs = <HomeworkSubmissionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _activitySvc = Get.find<TeacherActivityService>();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final all = await _activitySvc
          .getAllHomeworkSubmissions(_session.nurseryId ?? '');
      final cutoff = DateTime.now()
          .subtract(const Duration(days: _spanDays))
          .millisecondsSinceEpoch;
      _subs.assignAll(all.where((s) => s.submittedAt >= cutoff));
    } finally {
      isLoading.value = false;
    }
  }

  int get submissions => _subs.length;
  int get homeworkCovered => _subs.map((s) => s.homeworkId).toSet().length;
  int get childrenSubmitting => _subs.map((s) => s.childId).toSet().length;

  /// Share of submissions the parent flagged as done easily.
  int get didEasilyRate => _rate((s) => s.didEasily == true);

  bool get isEmpty => _subs.isEmpty;

  /// The three "how did it go" answers as bars (share of submissions that
  /// answered yes).
  List<QualityBar> get quality => [
        QualityBar('owner_report_hw_did_easily',
            _count((s) => s.didEasily == true), const Color(0xFF16A34A)),
        QualityBar('owner_report_hw_needed_help',
            _count((s) => s.neededHelp == true), const Color(0xFFF59E0B)),
        QualityBar('owner_report_hw_guided_hand',
            _count((s) => s.guidedHand == true), const Color(0xFFEF4444)),
      ];

  int _count(bool Function(HomeworkSubmissionModel) test) =>
      _subs.where(test).length;

  int _rate(bool Function(HomeworkSubmissionModel) test) {
    if (_subs.isEmpty) return 0;
    return ((_count(test) / _subs.length) * 100).round();
  }

  double shareOf(int count) => submissions == 0 ? 0 : count / submissions;
}

/// One "how did it go" answer bar.
class QualityBar {
  final String labelKey;
  final int count;
  final Color color;
  const QualityBar(this.labelKey, this.count, this.color);
}
