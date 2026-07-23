import '../../../../../index/index_main.dart';

class DailyNotesSection extends StatelessWidget {
  const DailyNotesSection({super.key, required this.controller});
  final ParentDashboardController controller;

  String _todayLabel() {
    final now = DateTime.now();
    return '${weekdayName(now.weekday)}${dateSep}${now.day} ${monthName(now.month)}';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final notes = controller.dailyNotes;
      if (notes.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
              blurRadius: 16.r,
              offset: Offset(0.w, 4.h)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────
            _Header(
              noteCount: notes.length,
              dateLabel: _todayLabel(),
              onViewAll: notes.length > 1
                  ? () => Get.find<MainPageViewModel>().changePage(1)
                  : null,
            ),
            // ── First note ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
              child: _NoteTile(note: notes.first),
            ),
          ],
        ),
      );
    });
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.noteCount,
    required this.dateLabel,
    this.onViewAll,
  });
  final int noteCount;
  final String dateLabel;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEDE9FE), Color(0xFFF5F3FF)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Row(
        children: [
          // teacher avatar
          Container(
            width: 46.w,
            height: 46.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                  blurRadius: 8.r,
                  offset: Offset(0.w, 3.h)),
              ],
            ),
            child: Icon(Icons.face_rounded, color: Colors.white, size: 24.sp)),
          SizedBox(width: 12.w),
          // title + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'parentcour21_teacher_notes'.tr,
                  style: context.typography.displaySmBold.copyWith(color: Color(0xFF4C1D95), fontSize: 15),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Icon(
                      Icons.school_rounded,
                      size: 11.sp,
                      color: Color(0xFF7C3AED)),
                    SizedBox(width: 4.w),
                    Text(
                      'parentcour21_teacher'.tr,
                      style: context.typography.xsMedium.copyWith(color: Color(0xFF7C3AED), fontSize: 11),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      width: 3.w,
                      height: 3.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7C3AED),
                        shape: BoxShape.circle,
                      )),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        dateLabel,
                        style: context.typography.xsRegular.copyWith(color: Color(0xFF8B5CF6), fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          // count badge or "view all" button
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$noteCount',
                      style: context.typography.mdBold.copyWith(color: Color(0xFF7C3AED), fontSize: 18, fontWeight: FontWeight.w800, height: 1),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'parentcour21_view_all'.tr,
                      style: context.typography.xsMedium.copyWith(color: Color(0xFF7C3AED), fontSize: 9),
                    ),
                  ],
                )),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                '1',
                style: context.typography.mdBold.copyWith(color: Color(0xFF7C3AED), fontSize: 18, fontWeight: FontWeight.w800, height: 1),
              )),
        ],
      ),
    );
  }
}

// ── Note tile ─────────────────────────────────────────────────────────────────

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note});
  final ParentDailyNote note;

  Color get _color {
    switch (note.severity) {
      case 'positive':       return const Color(0xFF059669);
      case 'needs_followup': return const Color(0xFFD97706);
      case 'important':      return const Color(0xFFDC2626);
      default:               return const Color(0xFF7C3AED);
    }
  }

  IconData get _icon {
    switch (note.severity) {
      case 'positive':       return Icons.thumb_up_rounded;
      case 'needs_followup': return Icons.edit_note_rounded;
      case 'important':      return Icons.warning_amber_rounded;
      default:               return Icons.info_outline_rounded;
    }
  }

  String get _label {
    switch (note.severity) {
      case 'positive':       return 'parentcour21_severity_positive'.tr;
      case 'needs_followup': return 'parentcour21_severity_needs_followup'.tr;
      case 'important':      return 'parentcour21_severity_important'.tr;
      default:               return 'parentcour21_severity_note'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // accent bar on the RTL-start side (right)
            Container(
              width: 4.w,
              decoration: BoxDecoration(
                color: _color,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(14.r),
                  bottomRight: Radius.circular(14.r),
                ),
              )),
            // content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30.w,
                          height: 30.h,
                          decoration: BoxDecoration(
                            color: _color.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(_icon, size: 16.sp, color: _color)),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _color.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            _label,
                            style: context.typography.smSemiBold.copyWith(color: _color, fontSize: 11),
                          )),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      note.text,
                      style: context.typography.xsRegular.copyWith(color: Color(0xFF1E293B), fontSize: 13, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
