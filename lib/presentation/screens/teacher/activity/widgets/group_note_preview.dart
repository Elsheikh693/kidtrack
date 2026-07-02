import '../../../../../index/index_main.dart';

class GroupNotePreview extends StatelessWidget {
  const GroupNotePreview({super.key, required this.note, required this.onEdit});
  final String note;
  final VoidCallback onEdit;

  static const _kPurple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kPurple.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kPurple.withValues(alpha: 0.15)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.edit_note_rounded, color: _kPurple, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                note,
                style: context.typography.xsMedium.copyWith(
                  color: const Color(0xFF6D28D9),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: _kPurple.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }
}
