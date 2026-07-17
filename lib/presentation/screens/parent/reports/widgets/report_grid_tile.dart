import '../../../../../index/index_main.dart';
import 'report_reveal.dart';

/// One tile in the Reports hub grid. Owns its [color] as a whisper-tinted
/// ground with a solid gradient icon chip, a title and a short description.
class ReportGridTile extends StatelessWidget {
  final int index;
  final String labelKey;
  final String descKey;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ReportGridTile({
    super.key,
    required this.index,
    required this.labelKey,
    required this.descKey,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ink = Color.lerp(const Color(0xFF1E293B), color, 0.22)!;
    return ReportReveal(
      index: index,
      onTap: onTap,
      child: Container(
        height: 158.h,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            color.withValues(alpha: 0.05),
            Colors.white,
          ),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: color.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.10),
              blurRadius: 20.r,
              spreadRadius: -8.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _iconChip(),
                const Spacer(),
                _arrow(),
              ],
            ),
            const Spacer(),
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
        ),
      ),
    );
  }

  Widget _iconChip() => Container(
        width: 46.w,
        height: 46.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.darken(0.16)],
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 10.r,
              offset: Offset(0, 5.h),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22.sp),
      );

  Widget _arrow() => Container(
        width: 28.w,
        height: 28.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child:
              Icon(Icons.chevron_left_rounded, color: color, size: 20.sp),
        ),
      );
}
