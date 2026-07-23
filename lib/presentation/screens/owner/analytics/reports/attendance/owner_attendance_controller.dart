import '../../../../../../index/index_main.dart';

/// One day's attendance volume — present/late check-ins recorded that day.
class OwnerAttendanceDay {
  final String label; // "d/M"
  final int count;
  const OwnerAttendanceDay(this.label, this.count);
}

/// Attendance report — recent daily check-in volume from the childAttendance
/// log (present + late records). Honest counts, not a fabricated rate: the
/// historical active-children baseline isn't reconstructable, so we show today's
/// present count and a 14-day check-in trend. Network-level.
class OwnerAttendanceController extends GetxController {
  late final ChildAttendanceParentService _attendance;

  final RxBool isLoading = false.obs;
  final RxList<OwnerAttendanceDay> days = <OwnerAttendanceDay>[].obs;
  final RxInt presentToday = 0.obs;

  static const int _windowDays = 14;

  @override
  void onInit() {
    super.onInit();
    _attendance = Get.find<ChildAttendanceParentService>();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final all = await _fetch();
      _aggregate(all);
    } finally {
      isLoading.value = false;
    }
  }

  bool _isPresent(ChildAttendanceModel a) =>
      a.status == 'present' || a.status == 'late';

  void _aggregate(List<ChildAttendanceModel> all) {
    // date-string → present/late count
    final counts = <String, int>{};
    for (final a in all) {
      if (_isPresent(a)) counts[a.date] = (counts[a.date] ?? 0) + 1;
    }
    final now = DateTime.now();
    final out = <OwnerAttendanceDay>[];
    for (var i = _windowDays - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      final key = _dateKey(d);
      out.add(OwnerAttendanceDay('${d.day}/${d.month}', counts[key] ?? 0));
    }
    days.assignAll(out);
    presentToday.value = counts[_dateKey(now)] ?? 0;
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${_two(d.month)}-${_two(d.day)}';
  String _two(int n) => n < 10 ? '0$n' : '$n';

  int get peak =>
      days.isEmpty ? 1 : days.map((d) => d.count).reduce((a, b) => a > b ? a : b);
  int get windowTotal => days.fold(0, (s, d) => s + d.count);
  int get avgPerDay =>
      days.isEmpty ? 0 : (windowTotal / days.length).round();

  Future<List<ChildAttendanceModel>> _fetch() {
    final c = Completer<List<ChildAttendanceModel>>();
    _attendance.getAll(callBack: (list) {
      if (!c.isCompleted) {
        c.complete(list.whereType<ChildAttendanceModel>().toList());
      }
    });
    return c.future;
  }
}
