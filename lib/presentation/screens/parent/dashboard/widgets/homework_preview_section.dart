import '../../../../../index/index_main.dart';
import '../controller.dart';
import '../../education/widgets/homework_submit_sheet.dart';
import 'section_header.dart';

const _hwTitles = <String, String>{
  'hw_english_1': 'تمارين حروف الأبجدية الإنجليزية',
  'hw_math_1':    'تمارين الأعداد من 1 إلى 20',
  'hw_arabic_1':  'تمارين حرف الألف',
  'hw_quran_1':   'حفظ سورة الفاتحة',
};

const _subjectColors = <String, Color>{
  'parent_course_arabic':  Color(0xFFE67E22),
  'parent_course_english': Color(0xFF2980B9),
  'parent_course_math':    Color(0xFF8E44AD),
  'parent_course_quran':   Color(0xFF27AE60),
};

const _subjectIcons = <String, IconData>{
  'parent_course_arabic':  Icons.menu_book_rounded,
  'parent_course_english': Icons.translate_rounded,
  'parent_course_math':    Icons.calculate_rounded,
  'parent_course_quran':   Icons.auto_stories_rounded,
};

class HomeworkPreviewSection extends StatelessWidget {
  const HomeworkPreviewSection({super.key, required this.controller});
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.homework.isEmpty) return const SizedBox.shrink();
      return _buildCard(context);
    });
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h),
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0.w, 4.h)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParentSectionHeader(
            titleKey: 'parent_edu_homework_title',
            onViewAll: () => Get.find<MainPageViewModel>().changePage(1),
            viewAllKey: 'parent_live_track_view_full',
          ),
          SizedBox(height: 10.h),
          Obx(() {
            final total     = controller.homework.length;
            final doneCount = controller.completedHomework.length;
            final allDone   = controller.allHomeworkDone;
            final pending   = controller.pendingHomework;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── mini progress ─────────────────────────────────
                Row(
                  children: [
                    Text(
                      '$doneCount/$total',
                      style: context.typography.xsMedium
                          .copyWith(color: AppColors.primary),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : doneCount / total,
                          minHeight: 5,
                          backgroundColor: AppColors.borderNeutralPrimary
                              .withValues(alpha: 0.35),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            allDone
                                ? AppColors.successForeground
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                // ── all-done state ────────────────────────────────
                if (allDone)
                  _AllDoneMini()
                // ── pending items (max 3) ─────────────────────────
                else
                  ...pending.take(3).map((hw) => _PreviewTile(
                        hw: hw,
                        onTap: (ctx) => _openSubmitSheet(ctx, hw),
                      )),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _openSubmitSheet(BuildContext context, EduHomework hw) {
    showHomeworkSubmitSheet(
      context,
      homeworkTitle: hw.displayTitle ?? _hwTitles[hw.titleKey] ?? hw.titleKey,
      onConfirm: (neededHelp, guidedHand, didEasily, note) =>
          controller.submitHomework(
        hw.titleKey,
        neededHelp: neededHelp,
        guidedHand: guidedHand,
        didEasily: didEasily,
        note: note,
      ),
    );
  }
}

// ── All-done mini banner ──────────────────────────────────────────────────────

class _AllDoneMini extends StatefulWidget {
  @override
  State<_AllDoneMini> createState() => _AllDoneMiniState();
}

class _AllDoneMiniState extends State<_AllDoneMini>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF059669).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFF059669).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Text('🎉', style: context.typography.mdRegular.copyWith(fontSize: 20)),
            SizedBox(width: 10.w),
            Text(
              'parentcour21_all_homework_done'.tr,
              style: context.typography.smSemiBold
                  .copyWith(color: const Color(0xFF059669)),
            ),
          ],
        )),
    );
  }
}

// ── Preview tile ──────────────────────────────────────────────────────────────

class _PreviewTile extends StatefulWidget {
  const _PreviewTile({required this.hw, required this.onTap});
  final EduHomework hw;
  final void Function(BuildContext context) onTap;

  @override
  State<_PreviewTile> createState() => _PreviewTileState();
}

class _PreviewTileState extends State<_PreviewTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  Color get _accent =>
      _subjectColors[widget.hw.subjectKey] ?? AppColors.primary;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.4), weight: 35),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.4, end: 0.85), weight: 30),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.85, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    _ctrl.forward(from: 0);
    widget.onTap(context);
  }

  @override
  Widget build(BuildContext context) {
    final done  = widget.hw.isCompleted;
    final accent = done ? AppColors.successForeground : _accent;

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 7.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: done
              ? AppColors.successBackground
              : AppColors.backgroundNeutral100,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: done
                ? AppColors.successForeground.withValues(alpha: 0.3)
                : AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _scale,
              builder: (_, child) =>
                  Transform.scale(scale: _scale.value, child: child),
              child: Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: done
                    ? AppColors.successForeground
                    : AppColors.grayMedium,
                size: 20.sp),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 26.w,
              height: 26.h,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(7.r),
              ),
              child: Icon(
                _subjectIcons[widget.hw.subjectKey] ?? Icons.assignment_rounded,
                size: 13.sp,
                color: accent)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                widget.hw.displayTitle ??
                    _hwTitles[widget.hw.titleKey] ??
                    widget.hw.titleKey,
                style: context.typography.xsMedium.copyWith(
                  color: done
                      ? AppColors.textSecondaryParagraph
                      : AppColors.textDefault,
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textSecondaryParagraph,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              widget.hw.dueDate,
              style: context.typography.xsRegular.copyWith(
                color: done
                    ? AppColors.successForeground
                    : AppColors.errorForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
