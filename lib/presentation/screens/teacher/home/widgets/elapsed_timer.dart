import 'dart:ui' show FontFeature;
import '../../../../../index/index_main.dart';
import '../../../../../Data/models/classroom_activity/classroom_activity_model.dart';

class ElapsedTimer extends StatefulWidget {
  const ElapsedTimer({super.key, required this.activity});

  final ClassroomActivityModel activity;

  @override
  State<ElapsedTimer> createState() => _ElapsedTimerState();
}

class _ElapsedTimerState extends State<ElapsedTimer> {
  late final Stream<Duration> _stream;

  @override
  void initState() {
    super.initState();
    _stream = Stream.periodic(
      const Duration(seconds: 30),
      (_) => widget.activity.elapsed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: _stream,
      initialData: widget.activity.elapsed,
      builder: (_, snap) {
        final d = snap.data ?? Duration.zero;
        final h = d.inHours;
        final m = d.inMinutes % 60;
        final hUnit = 'teacher_home_hours_unit'.tr;
        final mUnit = 'teacher_home_mins_unit'.tr;
        final label = h > 0
            ? '$h:${m.toString().padLeft(2, '0')} $hUnit'
            : '$m $mUnit';
        return Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        );
      },
    );
  }
}
