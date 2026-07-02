import '../../../../../index/index_main.dart';

/// A single promo slide definition for the discovery carousel.
class _BannerData {
  final String titleKey;
  final String subtitleKey;
  final IconData icon;
  final List<Color> gradient;

  const _BannerData({
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    required this.gradient,
  });
}

/// Auto-playing promo carousel shown at the top of the discovery screen.
///
/// Cycles through a few app-highlight banners on a timer, supports manual
/// swiping, and shows an animated page indicator. Lives inside a collapsing
/// [SliverAppBar] so it folds away on scroll and snaps back on scroll-up.
class DiscoveryCarousel extends StatefulWidget {
  const DiscoveryCarousel({super.key});

  @override
  State<DiscoveryCarousel> createState() => _DiscoveryCarouselState();
}

class _DiscoveryCarouselState extends State<DiscoveryCarousel> {
  static const _autoPlay = Duration(seconds: 4);

  late final List<_BannerData> _banners = [
    _BannerData(
      titleKey: 'discovery_hero_title',
      subtitleKey: 'discovery_hero_subtitle',
      icon: Icons.child_friendly_rounded,
      gradient: [AppColors.primary, AppColors.primary80],
    ),
    _BannerData(
      titleKey: 'discovery_banner2_title',
      subtitleKey: 'discovery_banner2_subtitle',
      icon: Icons.photo_camera_front_rounded,
      gradient: [AppColors.secondary80, AppColors.secondary100],
    ),
    _BannerData(
      titleKey: 'discovery_banner3_title',
      subtitleKey: 'discovery_banner3_subtitle',
      icon: Icons.directions_bus_rounded,
      gradient: [AppColors.teal, AppColors.primary80],
    ),
    _BannerData(
      titleKey: 'discovery_banner4_title',
      subtitleKey: 'discovery_banner4_subtitle',
      icon: Icons.forum_rounded,
      gradient: [AppColors.primary60, AppColors.primary80],
    ),
  ];

  // Start in the middle of a large virtual range for seamless looping.
  late final int _initialPage = _banners.length * 1000;
  late final PageController _pageCtrl =
      PageController(initialPage: _initialPage);

  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(_autoPlay, (_) {
      if (!mounted || !_pageCtrl.hasClients) return;
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 184.h,
          child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (page) {
              setState(() => _current = page % _banners.length);
              // Reset the timer so a manual swipe gets a full dwell.
              _startAutoPlay();
            },
            itemBuilder: (context, index) {
              return _BannerCard(data: _banners[index % _banners.length]);
            },
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: active ? 18.w : 7.w,
              height: 7.h,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4.r),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// One gradient promo card inside the carousel.
class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.data});

  final _BannerData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 22.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: data.gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: data.gradient.last.withValues(alpha: 0.32),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Soft decorative circle for depth, like a real promo banner.
          Positioned(
            top: -28.h,
            left: -24.w,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: data.titleKey.tr,
                      textDirection: TextDirection.rtl,
                      textStyle: context.typography.lgBold
                          .copyWith(color: AppColors.white, height: 1.35),
                      maxLines: 2,
                    ),
                    SizedBox(height: 10.h),
                    AppText(
                      text: data.subtitleKey.tr,
                      textDirection: TextDirection.rtl,
                      textStyle: context.typography.smRegular.copyWith(
                        color: AppColors.white.withValues(alpha: 0.88),
                        height: 1.45,
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Container(
                width: 78.w,
                height: 78.w,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Icon(data.icon, size: 40.sp, color: AppColors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
