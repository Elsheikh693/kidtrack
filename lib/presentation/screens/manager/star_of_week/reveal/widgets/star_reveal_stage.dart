import '../../../../../../index/index_main.dart';

/// The centrepiece of the reveal: the child's avatar exploding in with an
/// elastic pop inside a rotating golden halo, then the name and caption rising
/// underneath. All motion is driven off the shared [reveal] controller so the
/// choreography stays in sync with the confetti.
class StarRevealStage extends StatelessWidget {
  const StarRevealStage({
    super.key,
    required this.star,
    required this.reveal,
    required this.glow,
    required this.gold,
  });

  final StarOfWeekModel star;
  final AnimationController reveal;
  final AnimationController glow;
  final Color gold;

  Animation<double> _fade(double a, double b) => CurvedAnimation(
        parent: reveal,
        curve: Interval(a, b, curve: Curves.easeOut),
      );

  @override
  Widget build(BuildContext context) {
    final pop = CurvedAnimation(
      parent: reveal,
      curve: const Interval(0.15, 0.62, curve: Curves.elasticOut),
    );

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _title(context),
            SizedBox(height: 26.h),
            ScaleTransition(
              scale: pop,
              child: _halo(),
            ),
            SizedBox(height: 26.h),
            _name(context),
            SizedBox(height: 10.h),
            _weekPill(context),
            SizedBox(height: 22.h),
            _caption(context),
          ],
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    return FadeTransition(
      opacity: _fade(0.0, 0.35),
      child: SlideTransition(
        position: Tween(begin: const Offset(0, -0.4), end: Offset.zero)
            .animate(_fade(0.0, 0.4)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: gold, size: 22.sp),
            SizedBox(width: 8.w),
            AppText(
              text: 'sotw_title'.tr,
              textStyle: context.typography.xlBold.copyWith(color: gold),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.auto_awesome, color: gold, size: 22.sp),
          ],
        ),
      ),
    );
  }

  Widget _halo() {
    return SizedBox(
      width: 210.w,
      height: 210.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating conic glow ring.
          RotationTransition(
            turns: glow,
            child: Container(
              width: 210.w,
              height: 210.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    gold.withValues(alpha: 0.0),
                    gold,
                    Colors.white,
                    gold,
                    gold.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
              ),
            ),
          ),
          // Dark inset so the ring reads as a rim, not a disc.
          Container(
            width: 184.w,
            height: 184.w,
            decoration: const BoxDecoration(
              color: Color(0xFF190A3A),
              shape: BoxShape.circle,
            ),
          ),
          // The child's photo.
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gold.withValues(alpha: 0.55),
                  blurRadius: 34,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ChildAvatar(
              name: star.childName,
              imageUrl: star.childPhotoUrl,
              size: 158.w,
              color: gold,
            ),
          ),
          // Crown badge.
          Positioned(
            top: -6.h,
            child: _crown(),
          ),
        ],
      ),
    );
  }

  Widget _crown() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: gold,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: gold.withValues(alpha: 0.6), blurRadius: 16),
        ],
      ),
      child: Icon(Icons.emoji_events_rounded,
          color: const Color(0xFF190A3A), size: 22.sp),
    );
  }

  Widget _name(BuildContext context) {
    return FadeTransition(
      opacity: _fade(0.55, 0.78),
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.5), end: Offset.zero)
            .animate(_fade(0.55, 0.8)),
        child: AppText(
          text: star.childName,
          textAlign: TextAlign.center,
          maxLines: 2,
          textStyle: context.typography.xxlBold.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _weekPill(BuildContext context) {
    return FadeTransition(
      opacity: _fade(0.62, 0.82),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: gold.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: gold.withValues(alpha: 0.5)),
        ),
        child: AppText(
          text: 'sotw_reveal_subtitle'.tr,
          textStyle: context.typography.xsMedium.copyWith(color: gold),
        ),
      ),
    );
  }

  Widget _caption(BuildContext context) {
    if (star.caption.trim().isEmpty) return const SizedBox.shrink();
    return FadeTransition(
      opacity: _fade(0.75, 0.95),
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: AppText(
          text: star.caption,
          textAlign: TextAlign.center,
          maxLines: 6,
          textStyle: context.typography.mdRegular.copyWith(
            color: Colors.white.withValues(alpha: 0.92),
          ),
        ),
      ),
    );
  }
}
