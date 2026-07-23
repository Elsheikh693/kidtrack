import '../../../../../index/index_main.dart';
import '../../teacher_reports/widgets/tr_format.dart';
import '../models/teaching_slice.dart';
import 'live_pulse_dot.dart';

/// One running session on the manager home: a live card showing whether it is a
/// whole-class حصة or a subset نشاط, what's being taught, the teacher, and a
/// self-ticking elapsed timer. Tapping drills into the teacher's day.
class TeachingLiveCard extends StatefulWidget {
  const TeachingLiveCard({super.key, required this.slice, required this.onTap});

  final TeachingSlice slice;
  final VoidCallback onTap;

  @override
  State<TeachingLiveCard> createState() => _TeachingLiveCardState();
}

class _TeachingLiveCardState extends State<TeachingLiveCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Keep the elapsed label fresh without rebuilding the whole card list.
    _ticker = Timer.periodic(
      const Duration(seconds: 30),
      (_) => mounted ? setState(() {}) : null,
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _elapsedLabel {
    final ms = DateTime.now().millisecondsSinceEpoch - widget.slice.startedAt;
    final mins = (ms / 60000).floor().clamp(0, 1 << 30);
    if (mins < 60) {
      return 'live_teaching_elapsed_min'.trParams({'count': '$mins'});
    }
    return 'live_teaching_elapsed_hour'.trParams({
      'h': '${mins ~/ 60}',
      'm': (mins % 60).toString().padLeft(2, '0'),
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.slice;
    final accent = s.color;
    final title = s.activityTitle.isNotEmpty ? s.activityTitle : s.subjectLabel;
    final meta = s.isActivityMode
        ? 'live_teaching_participants'.trParams({'count': '${s.participantCount}'})
        : s.subjectLabel;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: accent.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ModeBadge(accent: accent, isActivity: s.isActivityMode),
                const Spacer(),
                LivePulseDot(color: accent, size: 6.w),
                SizedBox(width: 5.w),
                Text(
                  _elapsedLabel,
                  style: context.typography.xsRegular.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: accent.withValues(alpha: 0.14),
                  backgroundImage:
                      (s.teacherPhoto != null && s.teacherPhoto!.isNotEmpty)
                          ? appCachedImageProvider(s.teacherPhoto!)
                          : null,
                  child: (s.teacherPhoto == null || s.teacherPhoto!.isEmpty)
                      ? Text(
                          trInitial(s.teacherName),
                          style: context.typography.smSemiBold.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.smSemiBold
                            .copyWith(color: AppColors.textDefault),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '$meta · ${s.teacherName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.xsRegular.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                _ClassChip(name: s.className, accent: accent),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: AppColors.textSecondaryParagraph,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.accent, required this.isActivity});

  final Color accent;
  final bool isActivity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        isActivity
            ? 'live_teaching_mode_activity'.tr
            : 'live_teaching_mode_session'.tr,
        style: context.typography.xsRegular
            .copyWith(color: accent, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ClassChip extends StatelessWidget {
  const _ClassChip({required this.name, required this.accent});

  final String name;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Container(
        constraints: BoxConstraints(maxWidth: 90.w),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: AppColors.chartTrack,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.typography.xsRegular
              .copyWith(color: AppColors.textSecondaryParagraph),
        ),
      ),
    );
  }
}
