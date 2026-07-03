import '../../../../../index/index_main.dart';

/// The teacher's written notes about the child (the `platform/notes` feed),
/// scoped to the selected window. This is the manager's go-to log when a parent
/// complains — every guardian-visible note in one place, newest first.
class ChildProfileTeacherNotesSection extends StatelessWidget {
  final ChildProfileController controller;
  const ChildProfileTeacherNotesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'ملاحظات المعلمة',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Obx(() {
          if (controller.isRangeLoading.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
            );
          }
          final items = controller.teacherNotes;
          if (items.isEmpty) return const _Empty();
          return Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _NoteCard(note: items[i]),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.sticky_note_2_outlined,
              size: 28, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            'لا توجد ملاحظات من المعلمة في هذه الفترة',
            textAlign: TextAlign.center,
            style: context.typography.xsMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}

typedef _CatMeta = ({String label, Color color, IconData icon});

_CatMeta _metaFor(String category) {
  switch (category) {
    case 'positive':
      return (
        label: 'إيجابية',
        color: const Color(0xFF16A34A),
        icon: Icons.sentiment_very_satisfied_rounded,
      );
    case 'needs_follow':
      return (
        label: 'تحتاج متابعة',
        color: const Color(0xFFD97706),
        icon: Icons.flag_rounded,
      );
    case 'important':
      return (
        label: 'مهمة',
        color: const Color(0xFFDC2626),
        icon: Icons.priority_high_rounded,
      );
    default:
      return (
        label: 'ملاحظة',
        color: const Color(0xFF2563EB),
        icon: Icons.chat_bubble_rounded,
      );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final meta = _metaFor(note.category);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: meta.color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: meta.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(meta.icon, size: 17, color: meta.color),
              ),
              const SizedBox(width: 9),
              Text(
                meta.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: meta.color,
                ),
              ),
              const Spacer(),
              if (note.createdAt != null)
                Text(
                  _stamp(note.createdAt!),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            note.content.trim(),
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

const _arMonths = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

String _stamp(int ms) {
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final period = d.hour < 12 ? 'ص' : 'م';
  final minute = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${_arMonths[d.month - 1]} · $hour12:$minute $period';
}
