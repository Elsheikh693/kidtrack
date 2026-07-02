import '../../../../../index/index_main.dart';
import 'idle_header_expanded_content.dart';
import 'idle_wave_clipper.dart';

class IdleHeaderDelegate extends SliverPersistentHeaderDelegate {
  const IdleHeaderDelegate({
    required this.ctrl,
    required this.topPadding,
  });

  final TeacherActivityController ctrl;
  final double topPadding;

  static const double _expandedBody = 160.0;
  static const double _wavePad = 36.0;
  static const double _collapsedBody = 56.0;

  @override
  double get minExtent => topPadding + _collapsedBody;
  @override
  double get maxExtent => topPadding + _expandedBody + _wavePad;

  static double _ease(double t) => t * t;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    return SizedBox.expand(
      child: ClipPath(
        clipper: IdleWaveClipper(t: t),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.activityGreenDark, AppColors.activityGreen],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: topPadding + 8,
                left: 16,
                right: 16,
                height: _expandedBody - 8,
                child: Transform.translate(
                  offset: Offset(0, -26 * _ease(t)),
                  child: Transform.scale(
                    scale: 1.0 - 0.06 * _ease(t),
                    alignment: Alignment.topCenter,
                    child: Opacity(
                      opacity: (1.0 - t * 2.2).clamp(0.0, 1.0),
                      child: IgnorePointer(
                        ignoring: t > 0.3,
                        child: IdleHeaderExpandedContent(ctrl: ctrl),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: topPadding,
                left: 16,
                right: 16,
                height: _collapsedBody,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    -20 * (1.0 - ((t - 0.45) * 2.0).clamp(0.0, 1.0)),
                  ),
                  child: Opacity(
                    opacity: ((t - 0.5) * 2.2).clamp(0.0, 1.0),
                    child: IgnorePointer(
                      ignoring: t < 0.7,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_rounded,
                            color: AppColors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'teacher_tab_activities'.tr,
                              style: context.typography.lgBold
                                  .copyWith(color: AppColors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(IdleHeaderDelegate old) => old.topPadding != topPadding;
}
