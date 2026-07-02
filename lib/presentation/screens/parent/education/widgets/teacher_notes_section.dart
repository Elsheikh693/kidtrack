import '../../../../../index/index_main.dart';

class TeacherNotesSection extends StatelessWidget {
  const TeacherNotesSection({super.key, required this.notes, this.date});
  final List<TeacherNote> notes;
  final DateTime? date;

  String _dateLabel() {
    final d = date ?? DateTime.now();
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    const days = ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    return '${days[d.weekday - 1]}، ${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          _Header(noteCount: notes.length, dateLabel: _dateLabel()),

          // ── Notes list ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < notes.length; i++)
                  _NoteTile(
                    note: notes[i],
                    isLast: i == notes.length - 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.noteCount, required this.dateLabel});
  final int noteCount;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEDE9FE), Color(0xFFF5F3FF)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // teacher avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.face_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          // title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'parent_edu_teacher_feedback'.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4C1D95),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.school_rounded, size: 11, color: Color(0xFF7C3AED)),
                    const SizedBox(width: 4),
                    Text(
                      'parent_edu_teacher_role'.tr,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7C3AED),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        dateLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8B5CF6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$noteCount',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7C3AED),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'parent_edu_notes_count'.tr,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Note tile — NO Expanded/Row for the text, purely flat Column ──────────────

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note, required this.isLast});
  final TeacherNote note;
  final bool isLast;

  Color get _color {
    switch (note.severity) {
      case NoteSeverity.positive:  return const Color(0xFF059669);
      case NoteSeverity.followup:  return const Color(0xFFD97706);
      case NoteSeverity.important: return const Color(0xFFDC2626);
      case NoteSeverity.info:      return const Color(0xFF7C3AED);
    }
  }

  IconData get _icon {
    switch (note.severity) {
      case NoteSeverity.positive:  return Icons.thumb_up_rounded;
      case NoteSeverity.followup:  return Icons.edit_note_rounded;
      case NoteSeverity.important: return Icons.warning_amber_rounded;
      case NoteSeverity.info:      return Icons.info_outline_rounded;
    }
  }

  String get _label {
    switch (note.severity) {
      case NoteSeverity.positive:  return 'إيجابي';
      case NoteSeverity.followup:  return 'يحتاج متابعة';
      case NoteSeverity.important: return 'تنبيه';
      case NoteSeverity.info:      return 'ملاحظة';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEF0F4)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // subtle accent bar on the RTL-start side (right)
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.65),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
              ),
              // content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_icon, size: 15, color: _color.withValues(alpha: 0.85)),
                          const SizedBox(width: 7),
                          Text(
                            _label,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _color.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        note.text,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF334155),
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
