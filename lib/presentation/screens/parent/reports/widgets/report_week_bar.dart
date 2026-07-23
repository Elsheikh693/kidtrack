import '../../../../../index/index_main.dart';

/// Reusable previous/next period bar shared by the weekly & monthly reports.
/// Decoupled from any controller — the screen wires the callbacks and state.
class ReportWeekBar extends StatelessWidget {
  final String rangeLabel;
  final String subtitle;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const ReportWeekBar({
    super.key,
    required this.rangeLabel,
    required this.subtitle,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavButton(
            icon: Icons.chevron_right_rounded,
            label: 'report_prev_week'.tr,
            enabled: true,
            onTap: onPrev,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(rangeLabel,
                  style: context.typography.smSemiBold
                      .copyWith(color: const Color(0xFF1E293B))),
              Text(subtitle,
                  style: context.typography.xsRegular
                      .copyWith(color: const Color(0xFF94A3B8))),
            ],
          ),
          _NavButton(
            icon: Icons.chevron_left_rounded,
            label: 'report_next_week'.tr,
            enabled: canGoNext,
            onTap: onNext,
            trailing: true,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool trailing;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.trailing = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.primary : const Color(0xFFCBD5E1);
    final content = [
      Directionality(
        textDirection: TextDirection.ltr,
        child: Icon(icon, color: color, size: 20.sp),
      ),
      Text(label, style: context.typography.xsMedium.copyWith(color: color)),
    ];
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: trailing ? content.reversed.toList() : content,
        ),
      ),
    );
  }
}
