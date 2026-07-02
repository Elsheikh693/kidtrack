import '../../../index/index_main.dart';

class HolidaysController extends GetxController {
  final _service = HolidayService();

  final holidays = <HolidayModel>[].obs;
  final weekendDays = <int>{}.obs;
  final isLoading = true.obs;

  StreamSubscription<List<HolidayModel>>? _holidaysSub;
  StreamSubscription<Set<int>>? _weekendSub;

  @override
  void onInit() {
    super.onInit();
    _holidaysSub = _service.watchHolidays().listen((list) {
      holidays.assignAll(list);
      isLoading.value = false;
    }, onError: (_) => isLoading.value = false);
    _weekendSub = _service.watchWeekendDays().listen((set) {
      weekendDays.assignAll(set);
    });
  }

  @override
  void onClose() {
    _holidaysSub?.cancel();
    _weekendSub?.cancel();
    super.onClose();
  }

  /// Only future/today holidays are actionable; past ones are shown greyed.
  bool isPast(HolidayModel h) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    return h.date < today;
  }

  bool hasHolidayOn(DateTime day) {
    final key = HolidayService.dateKey(day);
    return holidays.any((h) => h.key == key);
  }

  Future<void> addHoliday(DateTime day, {String label = ''}) async {
    if (hasHolidayOn(day)) {
      Loader.showError('اليوم ده متسجّل إجازة بالفعل');
      return;
    }
    Loader.show();
    final ok = await _service.addHoliday(day, label: label);
    Loader.dismiss();
    if (ok) {
      Loader.showSuccess('تم إضافة الإجازة');
    } else {
      Loader.showError('حصل خطأ، حاول تاني');
    }
  }

  Future<void> deleteHoliday(HolidayModel h) async {
    Loader.show();
    final ok = await _service.removeHoliday(h.key);
    Loader.dismiss();
    if (!ok) Loader.showError('حصل خطأ، حاول تاني');
  }

  Future<void> toggleWeekday(int weekday) async {
    final next = Set<int>.from(weekendDays);
    if (next.contains(weekday)) {
      next.remove(weekday);
    } else {
      next.add(weekday);
    }
    weekendDays.assignAll(next); // optimistic
    final ok = await _service.setWeekendDays(next);
    if (!ok) Loader.showError('تعذّر حفظ العطلة الأسبوعية');
  }
}
