import '../../../../../index/index_main.dart';
import '../controller.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key, required this.skills});

  final List<EduSkill> skills;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'parent_edu_skills_monthly_note'.tr,
          style: context.typography.xsRegular.copyWith(
            color: AppColors.textSecondaryParagraph,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        ...skills.map((skill) => _SkillBar(skill: skill)),
      ],
    );
  }
}

class _SkillBar extends StatelessWidget {
  const _SkillBar({required this.skill});

  final EduSkill skill;

  Color get _color {
    if (skill.level >= 0.8) return AppColors.successForeground;
    if (skill.level >= 0.6) return AppColors.primary;
    return AppColors.yellowForeground;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (skill.level * 100).toInt();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill.labelKey.tr,
                style: context.typography.smMedium.copyWith(color: AppColors.textDefault),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  color: _color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: skill.level,
              backgroundColor: AppColors.backgroundNeutral100,
              valueColor: AlwaysStoppedAnimation<Color>(_color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
