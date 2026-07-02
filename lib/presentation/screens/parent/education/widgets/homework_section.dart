import '../../../../../index/index_main.dart';
import '../controller.dart';
import 'homework_submit_sheet.dart';

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

class HomeworkSection extends StatelessWidget {
  const HomeworkSection({super.key, required this.controller});
  final ParentEducationController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pending   = controller.pendingHomework;
      final completed = controller.completedHomework;
      final total     = controller.homework.length;
      final doneCount = completed.length;
      final allDone   = controller.allHomeworkDone;

      if (total == 0) return const _EmptyHomework();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── progress bar ──────────────────────────────────────────
          _ProgressHeader(done: doneCount, total: total),
          const SizedBox(height: 12),
          // ── all-done celebration ──────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            child: allDone ? _AllDoneBanner() : const SizedBox.shrink(),
          ),
          if (allDone) const SizedBox(height: 10),
          // ── pending group ─────────────────────────────────────────
          if (pending.isNotEmpty) ...[
            _GroupLabel(labelKey: 'parent_edu_homework_pending'),
            const SizedBox(height: 6),
            ...pending.map((hw) => _HomeworkTile(
              hw: hw,
              onTap: (ctx) => _openSubmitSheet(ctx, hw),
            )),
            const SizedBox(height: 10),
          ],
          // ── completed group ───────────────────────────────────────
          if (completed.isNotEmpty) ...[
            _GroupLabel(labelKey: 'parent_edu_homework_completed'),
            const SizedBox(height: 6),
            ...completed.map((hw) => _HomeworkTile(
              hw: hw,
              onTap: (ctx) => _confirmUndo(ctx, hw),
            )),
          ],
        ],
      );
    });
  }

  void _openSubmitSheet(BuildContext context, EduHomework hw) {
    showHomeworkSubmitSheet(
      context,
      homeworkTitle: hw.displayTitle ?? _hwTitles[hw.titleKey] ?? hw.titleKey,
      onConfirm: (by, note) =>
          controller.submitHomework(hw.titleKey, by: by, note: note),
    );
  }

  Future<void> _confirmUndo(BuildContext context, EduHomework hw) async {
    final undo = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'إلغاء تأكيد الحل؟',
            style: context.typography.mdBold
                .copyWith(color: AppColors.textDefault),
          ),
          content: Text(
            hw.displayTitle ?? _hwTitles[hw.titleKey] ?? hw.titleKey,
            style: context.typography.smRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'تراجع',
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'إلغاء التأكيد',
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.errorForeground),
              ),
            ),
          ],
        ),
      ),
    );
    if (undo == true) controller.unsubmitHomework(hw.titleKey);
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyHomework extends StatelessWidget {
  const _EmptyHomework();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF059669).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_rounded,
                size: 22, color: Color(0xFF059669)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لا توجد واجبات لهذا اليوم',
                  style: context.typography.smSemiBold
                      .copyWith(color: const Color(0xFF047857)),
                ),
                const SizedBox(height: 2),
                Text(
                  'استمتع بوقتك مع طفلك 🌿',
                  style: context.typography.xsRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.done, required this.total});
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : done / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$done / $total',
              style: context.typography.smSemiBold
                  .copyWith(color: AppColors.primary),
            ),
            const SizedBox(width: 6),
            Text(
              'parent_edu_homework_completed'.tr,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: AppColors.borderNeutralPrimary.withValues(alpha: 0.4),
            valueColor: AlwaysStoppedAnimation<Color>(
              done == total && total > 0
                  ? AppColors.successForeground
                  : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── All-done banner ───────────────────────────────────────────────────────────

class _AllDoneBanner extends StatefulWidget {
  @override
  State<_AllDoneBanner> createState() => _AllDoneBannerState();
}

class _AllDoneBannerState extends State<_AllDoneBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _slide = Tween<double>(begin: -20, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: child,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF059669).withValues(alpha: 0.12),
              const Color(0xFF34D399).withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF059669).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            _StarsRow(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ممتاز! أنجزنا كل الواجبات 🎉',
                    style: context.typography.smSemiBold.copyWith(
                      color: const Color(0xFF059669),
                    ),
                  ),
                  Text(
                    'استمر في التقدم الرائع!',
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarsRow extends StatefulWidget {
  @override
  State<_StarsRow> createState() => _StarsRowState();
}

class _StarsRowState extends State<_StarsRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final start = i * 0.2;
        final end = start + 0.5;
        final anim = CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, end.clamp(0, 1), curve: Curves.elasticOut),
        );
        return AnimatedBuilder(
          animation: anim,
          builder: (_, __) => Transform.scale(
            scale: anim.value,
            child: Icon(
              Icons.star_rounded,
              size: 22,
              color: const Color(0xFFD97706),
            ),
          ),
        );
      }),
    );
  }
}

// ── Group label ───────────────────────────────────────────────────────────────

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.labelKey});
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Text(
      labelKey.tr,
      style: context.typography.smSemiBold
          .copyWith(color: AppColors.textDefault),
    );
  }
}

// ── Homework tile ─────────────────────────────────────────────────────────────

class _HomeworkTile extends StatefulWidget {
  const _HomeworkTile({required this.hw, required this.onTap});
  final EduHomework hw;
  final void Function(BuildContext context) onTap;

  @override
  State<_HomeworkTile> createState() => _HomeworkTileState();
}

class _HomeworkTileState extends State<_HomeworkTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  Color get _accent =>
      _subjectColors[widget.hw.subjectKey] ?? AppColors.primary;

  IconData get _subjectIcon =>
      _subjectIcons[widget.hw.subjectKey] ?? Icons.assignment_rounded;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: done
              ? AppColors.successBackground
              : AppColors.backgroundNeutral100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: done
                ? AppColors.successForeground.withValues(alpha: 0.3)
                : AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            // ── radio / check icon with bounce ────────────────────
            AnimatedBuilder(
              animation: _scale,
              builder: (_, child) =>
                  Transform.scale(scale: _scale.value, child: child),
              child: Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: done ? AppColors.successForeground : AppColors.grayMedium,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            // ── subject icon ──────────────────────────────────────
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_subjectIcon, size: 15, color: accent),
            ),
            const SizedBox(width: 10),
            // ── title + subject ───────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hw.displayTitle ??
                        _hwTitles[widget.hw.titleKey] ??
                        widget.hw.titleKey,
                    style: context.typography.smMedium.copyWith(
                      color: done
                          ? AppColors.textSecondaryParagraph
                          : AppColors.textDefault,
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.textSecondaryParagraph,
                    ),
                  ),
                  Text(
                    widget.hw.subjectKey.tr,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ],
              ),
            ),
            // ── due date ──────────────────────────────────────────
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
