import '../../../../../index/index_main.dart';
import '../controller.dart';

class DevelopmentSection extends StatelessWidget {
  const DevelopmentSection({super.key, required this.groups});

  final List<DevSkillGroup> groups;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: groups.map((g) => _SkillGroupCard(group: g)).toList(),
    );
  }
}

class _SkillGroupCard extends StatelessWidget {
  const _SkillGroupCard({required this.group});

  final DevSkillGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.titleKey.tr,
            style: context.typography.smSemiBold.copyWith(
              color: AppColors.textDefault,
            ),
          ),
          const SizedBox(height: 10),
          ...group.skills.map((skill) => _SkillRow(skill: skill)),
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.skill});

  final DevSkill skill;

  Color get _color {
    if (skill.level >= 0.8) return AppColors.successForeground;
    if (skill.level >= 0.6) return AppColors.primary;
    return AppColors.yellowForeground;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              skill.labelKey.tr,
              style: context.typography.xsRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: skill.level,
                backgroundColor: AppColors.backgroundNeutral100,
                valueColor: AlwaysStoppedAnimation<Color>(_color),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(skill.level * 100).toInt()}%',
            style: TextStyle(
              color: _color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
