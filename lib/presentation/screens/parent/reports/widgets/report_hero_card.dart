import '../../../../../index/index_main.dart';
import 'report_reveal.dart';

/// Featured, full-width card for the live weekly report. A rich brand gradient
/// ground with a frosted icon, a context chip, title and description — the
/// hero of the Reports hub.
class ReportHeroCard extends StatelessWidget {
  final int index;
  final String labelKey;
  final String descKey;
  final String badgeKey;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ReportHeroCard({
    super.key,
    required this.index,
    required this.labelKey,
    required this.descKey,
    required this.badgeKey,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ReportReveal(
      index: index,
      onTap: onTap,
      child: Container(
        height: 140.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.darken(0.16)],
          ),
          borderRadius: BorderRadius.circular(26.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 26.r,
              spreadRadius: -8.r,
              offset: Offset(0, 14.h),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: -18.w,
              bottom: -22.h,
              child: Icon(
                icon,
                size: 130.sp,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18.w),
              child: Row(
                children: [
                  _frostedIcon(),
                  SizedBox(width: 16.w),
                  Expanded(child: _texts(context)),
                  _arrow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _frostedIcon() => Container(
        width: 60.w,
        height: 60.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, color: Colors.white, size: 30.sp),
      );

  Widget _texts(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _badge(context),
          SizedBox(height: 9.h),
          Text(
            labelKey.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.mdBold.copyWith(color: Colors.white),
          ),
          SizedBox(height: 3.h),
          Text(
            descKey.tr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.typography.xsRegular
                .copyWith(color: Colors.white.withValues(alpha: 0.82)),
          ),
        ],
      );

  Widget _badge(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              badgeKey.tr,
              style:
                  context.typography.xsMedium.copyWith(color: Colors.white),
            ),
          ],
        ),
      );

  Widget _arrow() => Container(
        width: 34.w,
        height: 34.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          shape: BoxShape.circle,
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Icon(Icons.chevron_left_rounded,
              color: Colors.white, size: 24.sp),
        ),
      );
}
