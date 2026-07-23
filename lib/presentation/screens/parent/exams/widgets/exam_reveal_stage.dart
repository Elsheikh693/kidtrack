import '../../../../../index/index_main.dart';
import '../../../shared/exams/exam_grade_meta.dart';

/// The animated centrepiece of the exam reveal: the grade emoji pops in inside a
/// rotating halo, the verbal grade rises underneath, then the paper photo, note
/// and share button. Motion is driven off the shared [reveal]/[glow]
/// controllers so it stays in sync with the confetti.
class ExamRevealStage extends StatelessWidget {
  const ExamRevealStage({
    super.key,
    required this.result,
    required this.childName,
    required this.reveal,
    required this.glow,
    required this.onShare,
  });

  final ExamResultModel result;
  final String childName;
  final AnimationController reveal;
  final AnimationController glow;
  final VoidCallback onShare;

  Animation<double> _fade(double a, double b) => CurvedAnimation(
        parent: reveal,
        curve: Interval(a, b, curve: Curves.easeOut),
      );

  @override
  Widget build(BuildContext context) {
    final grade = ExamGrade.fromKey(result.grade) ?? ExamGrade.good;
    final meta = ExamGradeMeta.of(grade);
    final pop = CurvedAnimation(
      parent: reveal,
      curve: const Interval(0.15, 0.62, curve: Curves.elasticOut),
    );
    final heading =
        result.examTitle.trim().isNotEmpty ? result.examTitle : result.subjectName;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _title(context),
            SizedBox(height: 22.h),
            ScaleTransition(scale: pop, child: _halo()),
            SizedBox(height: 22.h),
            _gradeLabel(context, meta),
            SizedBox(height: 10.h),
            _subjectPill(context, heading),
            SizedBox(height: 20.h),
            if (_hasDetail) _detailCard(context),
            SizedBox(height: 20.h),
            _shareButton(context),
          ],
        ),
      ),
    );
  }

  bool get _hasDetail =>
      (result.paperUrl != null && result.paperUrl!.isNotEmpty) ||
      result.note.trim().isNotEmpty;

  Widget _title(BuildContext context) {
    return FadeTransition(
      opacity: _fade(0.0, 0.35),
      child: SlideTransition(
        position: Tween(begin: const Offset(0, -0.4), end: Offset.zero)
            .animate(_fade(0.0, 0.4)),
        child: AppText(
          text: '${'exam_reveal_title'.tr} $childName',
          textAlign: TextAlign.center,
          maxLines: 2,
          textStyle: context.typography.lgBold.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _halo() {
    return SizedBox(
      width: 190.w,
      height: 190.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: glow,
            child: Container(
              width: 190.w,
              height: 190.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Color(0x00FFFFFF),
                    Colors.white,
                    Color(0x66FFFFFF),
                    Colors.white,
                    Color(0x00FFFFFF),
                  ],
                  stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
              ),
            ),
          ),
          Container(
            width: 158.w,
            height: 158.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 34,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(result.grade.isEmpty ? '⭐' : _emoji,
                style: TextStyle(fontSize: 84.sp)),
          ),
        ],
      ),
    );
  }

  String get _emoji =>
      ExamGradeMeta.of(ExamGrade.fromKey(result.grade) ?? ExamGrade.good).emoji;

  Widget _gradeLabel(BuildContext context, ExamGradeMeta meta) {
    return FadeTransition(
      opacity: _fade(0.55, 0.8),
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.5), end: Offset.zero)
            .animate(_fade(0.55, 0.82)),
        child: AppText(
          text: meta.label,
          textAlign: TextAlign.center,
          textStyle: context.typography.xxlBold.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _subjectPill(BuildContext context, String heading) {
    return FadeTransition(
      opacity: _fade(0.62, 0.85),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: AppText(
          text: heading == result.subjectName
              ? result.subjectName
              : '$heading • ${result.subjectName}',
          textStyle:
              context.typography.xsMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _detailCard(BuildContext context) {
    return FadeTransition(
      opacity: _fade(0.75, 0.98),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.paperUrl != null && result.paperUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: AppNetworkImage(
                  url: result.paperUrl,
                  width: double.infinity,
                  height: 180.h,
                  fit: BoxFit.cover,
                ),
              ),
            if (result.note.trim().isNotEmpty) ...[
              if (result.paperUrl != null && result.paperUrl!.isNotEmpty)
                SizedBox(height: 12.h),
              AppText(
                text: result.note,
                maxLines: 6,
                overflow: TextOverflow.visible,
                textStyle: context.typography.smRegular
                    .copyWith(color: const Color(0xFF334155)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _shareButton(BuildContext context) {
    return FadeTransition(
      opacity: _fade(0.82, 1.0),
      child: GestureDetector(
        onTap: onShare,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 13.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.ios_share_rounded,
                  color: Color(0xFF334155), size: 20),
              SizedBox(width: 8.w),
              AppText(
                text: 'exam_share_button'.tr,
                textStyle: context.typography.smSemiBold
                    .copyWith(color: const Color(0xFF334155)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
