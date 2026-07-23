import '../../../../../index/index_main.dart';

class IdleQuickActionsRow extends StatelessWidget {
  const IdleQuickActionsRow({
    super.key,
    required this.onStartActivity,
    required this.onQuickHomework,
    required this.onGoToReports,
    required this.onGoToLinkBook,
  });

  final VoidCallback onStartActivity;
  final VoidCallback onQuickHomework;
  final VoidCallback onGoToReports;
  final VoidCallback onGoToLinkBook;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          _ActionBtn(
            icon: Icons.play_circle_outline_rounded,
            label: 'teacheract33_action_start_activity'.tr,
            color: AppColors.activityGreen,
            onTap: onStartActivity,
          ),
          const SizedBox(width: 8),
          _ActionBtn(
            icon: Icons.assignment_outlined,
            label: 'teacheract33_action_quick_homework'.tr,
            color: AppColors.activityAmberBrand,
            onTap: onQuickHomework,
          ),
          const SizedBox(width: 8),
          _ActionBtn(
            icon: Icons.bar_chart_rounded,
            label: 'teacheract33_action_reports'.tr,
            color: AppColors.activityBlue,
            onTap: onGoToReports,
          ),
          const SizedBox(width: 8),
          _ActionBtn(
            icon: Icons.menu_book_rounded,
            label: 'teacheract33_action_link_book'.tr,
            color: AppColors.activityPurple,
            onTap: onGoToLinkBook,
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.14), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: context.typography.xsMedium.copyWith(color: color),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
