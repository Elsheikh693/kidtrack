import '../../../../../index/index_main.dart';
import 'analytics_reveal.dart';

/// Full-width report entry in the Analytics Center. A whisper-tinted card with a
/// gradient icon chip, title, description and a trailing chevron. When
/// [enabled] is false the row dims and shows a "coming soon" badge instead of a
/// chevron — advertising the roadmap without pretending the report exists.
class AnalyticsListRow extends StatelessWidget {
  final int index;
  final String labelKey;
  final String descKey;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;

  const AnalyticsListRow({
    super.key,
    required this.index,
    required this.labelKey,
    required this.descKey,
    required this.icon,
    required this.color,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final ink = Color.lerp(const Color(0xFF1E293B), color, 0.22)!;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: AnalyticsReveal(
        index: index,
        onTap: enabled ? onTap : null,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              color.withValues(alpha: 0.05),
              Colors.white,
            ),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: color.withValues(alpha: 0.14)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 18.r,
                spreadRadius: -10.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Row(
            children: [
              _iconChip(),
              SizedBox(width: 14.w),
              Expanded(child: _texts(context, ink)),
              SizedBox(width: 8.w),
              enabled ? _arrow() : _soonBadge(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _texts(BuildContext context, Color ink) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelKey.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.smSemiBold.copyWith(color: ink),
          ),
          SizedBox(height: 4.h),
          Text(
            descKey.tr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.typography.xsRegular
                .copyWith(color: const Color(0xFF94A3B8)),
          ),
        ],
      );

  Widget _iconChip() => Container(
        width: 52.w,
        height: 52.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.darken(0.16)],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 10.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 25.sp),
      );

  Widget _arrow() => Container(
        width: 30.w,
        height: 30.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Icon(Icons.chevron_left_rounded, color: color, size: 20.sp),
        ),
      );

  Widget _soonBadge(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: const Color(0xFF94A3B8).withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          'owner_analytics_soon'.tr,
          style: context.typography.xsMedium
              .copyWith(color: const Color(0xFF64748B)),
        ),
      );
}
