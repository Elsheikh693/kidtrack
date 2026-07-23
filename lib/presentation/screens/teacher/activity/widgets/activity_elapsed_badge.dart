import 'dart:async';
import '../../../../../index/index_main.dart';

class ActivityElapsedBadge extends StatefulWidget {
  const ActivityElapsedBadge({super.key, required this.startedAtMs});
  final int startedAtMs;

  @override
  State<ActivityElapsedBadge> createState() => _ActivityElapsedBadgeState();
}

class _ActivityElapsedBadgeState extends State<ActivityElapsedBadge> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _label {
    final elapsed = Duration(
      milliseconds: DateTime.now().millisecondsSinceEpoch - widget.startedAtMs,
    );
    final h = elapsed.inHours;
    final m = elapsed.inMinutes % 60;
    final s = elapsed.inSeconds % 60;
    if (h > 0) {
      return '$h${'teacheract32_unit_hour'.tr} '
          '${m.toString().padLeft(2, '0')}${'teacheract32_unit_minute'.tr}';
    }
    if (m > 0) {
      return '$m${'teacheract32_unit_minute'.tr} '
          '${s.toString().padLeft(2, '0')}${'teacheract32_unit_second'.tr}';
    }
    return '${elapsed.inSeconds}${'teacheract32_unit_second'.tr}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.white.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            _label,
            style: context.typography.xsMedium.copyWith(
              color: AppColors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
