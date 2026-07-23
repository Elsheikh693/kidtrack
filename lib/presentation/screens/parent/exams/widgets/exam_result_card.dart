import '../../../../../index/index_main.dart';
import '../../education/widgets/journal_meta.dart';
import '../../../shared/exams/exam_grade_meta.dart';

/// One exam result in the parent's list: a coloured grade badge, the exam
/// subject/title, date and verbal grade. Tap opens the celebratory detail.
class ExamResultCard extends StatelessWidget {
  const ExamResultCard({super.key, required this.result, required this.onTap});

  final ExamResultModel result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final grade = ExamGrade.fromKey(result.grade) ?? ExamGrade.good;
    final meta = ExamGradeMeta.of(grade);
    final heading =
        result.examTitle.trim().isNotEmpty ? result.examTitle : result.subjectName;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kJBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: meta.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(meta.emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    heading,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: kJInk,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result.subjectName} · ${_date(result.examDate)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: kJMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meta.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: meta.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_outlined, color: kJMuted, size: 14),
          ],
        ),
      ),
    );
  }

  static String _date(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  }
}
