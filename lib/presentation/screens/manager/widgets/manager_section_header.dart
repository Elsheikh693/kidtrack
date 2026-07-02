import '../../../../index/index_main.dart';

/// Section title used across the Branch Manager tabs: an icon badge, a title,
/// and an optional trailing label (usually a count).
class ManagerSectionHeader extends StatelessWidget {
  const ManagerSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: context.typography.mdBold
                  .copyWith(color: AppColors.textDefault),
            ),
          ),
          if ((trailing ?? '').isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                trailing!,
                style: context.typography.displaySmBold.copyWith(color: color),
              ),
            ),
        ],
      ),
    );
  }
}
