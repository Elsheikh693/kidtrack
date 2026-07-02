import '../../../../../index/index_main.dart';
import '../controller.dart';

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key, required this.achievements});

  final List<EduAchievement> achievements;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: achievements.map((a) => _AchievementCard(achievement: a)).toList(),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});

  final EduAchievement achievement;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: achievement.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: achievement.color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: achievement.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(achievement.icon, color: achievement.color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              achievement.titleKey.tr,
              style: TextStyle(
                color: AppColors.textDefault,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            Text(
              achievement.date,
              style: TextStyle(
                color: achievement.color,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
