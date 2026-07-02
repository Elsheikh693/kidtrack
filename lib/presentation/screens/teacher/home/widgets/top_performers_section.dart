import '../../../../../index/index_main.dart';
import '../top_performer_entry.dart';

class TopPerformersSection extends StatelessWidget {
  const TopPerformersSection({super.key, required this.performers});

  final List<TopPerformerEntry> performers;

  static const _medals = ['🥇', '🥈', '🥉'];
  static const _colors = [
    AppColors.activityAmber,
    AppColors.grayMedium,
    AppColors.closedBackground,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: performers.asMap().entries.map((e) {
          final p = e.value;
          final color = _colors[e.key % _colors.length];
          final medal = _medals[e.key % _medals.length];
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: e.key < performers.length - 1 ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.20)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(medal, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(
                    p.childName.split(' ').first,
                    style: context.typography.xsMedium
                        .copyWith(color: AppColors.activitySlate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.avgScore.toStringAsFixed(1),
                    style: context.typography.mdBold.copyWith(color: color),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
