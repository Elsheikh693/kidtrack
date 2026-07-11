import '../../../../../index/index_main.dart';

/// One premium row in the Reports hub: a gradient icon tile, title and
/// description. Animates in with a staggered fade/slide (by [index]) and scales
/// down on press. Upcoming reports show a muted "coming soon" chip.
class ReportEntryCard extends StatefulWidget {
  final int index;
  final String labelKey;
  final String descKey;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool comingSoon;

  const ReportEntryCard({
    super.key,
    required this.index,
    required this.labelKey,
    required this.descKey,
    required this.icon,
    required this.color,
    this.onTap,
    this.comingSoon = false,
  });

  @override
  State<ReportEntryCard> createState() => _ReportEntryCardState();
}

class _ReportEntryCardState extends State<ReportEntryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  double _scale = 1;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(
      Duration(milliseconds: 120 + widget.index * 85),
      () {
        if (mounted) _c.forward();
      },
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _setScale(double v) => setState(() => _scale = v);

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Opacity(
          opacity: widget.comingSoon ? 0.65 : 1,
          child: GestureDetector(
            onTapDown: widget.comingSoon ? null : (_) => _setScale(0.97),
            onTapUp: widget.comingSoon ? null : (_) => _setScale(1),
            onTapCancel: widget.comingSoon ? null : () => _setScale(1),
            onTap: widget.comingSoon ? null : widget.onTap,
            child: AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 130),
              curve: Curves.easeOut,
              child: Container(
                margin: EdgeInsets.only(bottom: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.12),
                      blurRadius: 22.r,
                      spreadRadius: -6.r,
                      offset: Offset(0, 10.h),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                child: Row(
                  children: [
                    _iconTile(color),
                    SizedBox(width: 14.w),
                    Expanded(child: _texts(context)),
                    SizedBox(width: 8.w),
                    widget.comingSoon ? _comingSoon(context) : _chevron(color),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconTile(Color color) => Container(
        width: 52.w,
        height: 52.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, Color.lerp(color, Colors.black, 0.24)!],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Icon(widget.icon, color: Colors.white, size: 25.sp),
      );

  Widget _texts(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.labelKey.tr,
              style: context.typography.smSemiBold
                  .copyWith(color: const Color(0xFF1E293B))),
          SizedBox(height: 4.h),
          Text(widget.descKey.tr,
              style: context.typography.xsRegular
                  .copyWith(color: const Color(0xFF94A3B8))),
        ],
      );

  Widget _chevron(Color color) => Container(
        width: 30.w,
        height: 30.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.chevron_left_rounded, color: color, size: 22.sp),
      );

  Widget _comingSoon(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text('reports_coming_soon'.tr,
            style: context.typography.xsMedium
                .copyWith(fontSize: 10, color: const Color(0xFF94A3B8))),
      );
}
