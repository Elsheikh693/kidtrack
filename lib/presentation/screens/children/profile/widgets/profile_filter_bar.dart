import '../../../../../index/index_main.dart';

/// Day/Week granularity toggle + range navigator. Drives BOTH the absences row
/// and the attended-activities list, so the manager reads one coherent window.
class ProfileFilterBar extends StatelessWidget {
  final ChildProfileController controller;
  const ProfileFilterBar({super.key, required this.controller});

  static const _accent = Color(0xFF6C4DDB);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            _Segment(
              label: 'أسبوع',
              selected: controller.filterByWeek.value,
              onTap: () => controller.setWeekMode(true),
            ),
            const SizedBox(width: 4),
            _Segment(
              label: 'يوم',
              selected: !controller.filterByWeek.value,
              onTap: () => controller.setWeekMode(false),
            ),
            const Spacer(),
            _NavButton(
              icon: Icons.chevron_right_rounded,
              enabled: true,
              onTap: controller.stepBack,
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 96),
              alignment: Alignment.center,
              child: Text(
                controller.rangeLabel,
                style: context.typography.xsMedium
                    .copyWith(color: AppColors.textDefault),
              ),
            ),
            _NavButton(
              icon: Icons.chevron_left_rounded,
              enabled: controller.canGoForward,
              onTap: controller.stepForward,
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? ProfileFilterBar._accent
              : ProfileFilterBar._accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : ProfileFilterBar._accent,
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}
