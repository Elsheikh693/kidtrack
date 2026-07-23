import '../../../../../index/index_main.dart';

class ActiveActivityBanner extends StatelessWidget {
  const ActiveActivityBanner({
    super.key,
    required this.activity,
    required this.onTap,
  });

  final ClassroomActivityModel activity;
  final VoidCallback onTap;

  static const _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF15803D), Color(0xFF22C55E)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: _green.withValues(alpha: 0.35),
              blurRadius: 18.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pulse indicator
            _PulsingDot(),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'teacherhom35_activity_running_now'.tr,
                    style: context.typography.smSemiBold.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    activity.title,
                    style: context.typography.mdBold.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (activity.subjectName != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      activity.subjectName!,
                      style: context.typography.xsRegular.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ElapsedTimer(activity: activity),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'teacherhom35_open'.tr,
                    style: context.typography.displaySmBold.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 12.w,
        height: 12.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.6 * _anim.value),
              blurRadius: (8 + 4 * _anim.value).r,
              spreadRadius: (2 * _anim.value).r,
            ),
          ],
        ),
      ),
    );
  }
}

class _ElapsedTimer extends StatefulWidget {
  const _ElapsedTimer({required this.activity});
  final ClassroomActivityModel activity;

  @override
  State<_ElapsedTimer> createState() => _ElapsedTimerState();
}

class _ElapsedTimerState extends State<_ElapsedTimer> {
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
        final label = h > 0
            ? '$h:${m.toString().padLeft(2, '0')} ${'teacherhom35_hours_suffix'.tr}'
            : '$m ${'teacherhom35_minutes_suffix'.tr}';
        return Text(
          label,
          style: context.typography.displaySmBold.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        );
      },
    );
  }
}
