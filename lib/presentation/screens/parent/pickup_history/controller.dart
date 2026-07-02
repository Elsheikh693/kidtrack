import '../../../../index/index_main.dart';
import '../../../../Global/services/pickup_realtime_service.dart';

class PickupRecord {
  final String date;
  final String dayLabel;
  final int completedAt;

  const PickupRecord({
    required this.date,
    required this.dayLabel,
    required this.completedAt,
  });

  String get formattedTime {
    final dt = DateTime.fromMillisecondsSinceEpoch(completedAt);
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'م' : 'ص';
    return '$h:$m $period';
  }
}

class PickupHistoryController extends GetxController {
  final records = <PickupRecord>[].obs;
  final isLoading = true.obs;
  String childName = '';

  late final SessionService _session;
  late final PickupRealtimeService _pickupSvc;

  @override
  void onInit() {
    super.onInit();
    _session = SessionService();
    _pickupSvc = Get.find<PickupRealtimeService>();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;

    final nurseryId = _session.nurseryId ?? '';
    final parentId = _session.userId ?? '';
    if (nurseryId.isEmpty || parentId.isEmpty) {
      isLoading.value = false;
      return;
    }

    final svc = Get.find<ActiveChildService>();
    childName = svc.childName.value;

    final requests = await _pickupSvc.fetchCompletedByParent(nurseryId, parentId);

    final loaded = requests.map((r) {
      final ts = r.updatedAt ?? r.createdAt ?? DateTime.now().millisecondsSinceEpoch;
      final dt = DateTime.fromMillisecondsSinceEpoch(ts);
      return PickupRecord(
        date: _formatDate(dt),
        dayLabel: _dayLabel(dt),
        completedAt: ts,
      );
    }).toList();

    records.assignAll(loaded);
    isLoading.value = false;
  }

  String _formatDate(DateTime dt) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    const days = ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    final base = '$dayName ${dt.day} $monthName';
    if (_sameDay(dt, today)) return 'اليوم، $base';
    if (_sameDay(dt, yesterday)) return 'أمس، $base';
    return base;
  }

  String _dayLabel(DateTime dt) {
    final today = DateTime.now();
    if (_sameDay(dt, today)) return 'اليوم';
    if (_sameDay(dt, today.subtract(const Duration(days: 1)))) return 'أمس';
    return '';
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
