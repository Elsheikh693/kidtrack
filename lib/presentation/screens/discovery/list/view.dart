import '../../../../index/index_main.dart';
import 'widgets/discovery_search_bar.dart';
import 'widgets/discovery_nursery_card.dart';
import 'widgets/discovery_carousel.dart';
import 'widgets/discovery_hero.dart';
import 'widgets/discovery_notifications_sheet.dart';
import 'widgets/discovery_empty.dart';
import 'widgets/discovery_shimmer.dart';

class DiscoveryView extends StatefulWidget {
  const DiscoveryView({super.key});

  @override
  State<DiscoveryView> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends State<DiscoveryView> {
  late final DiscoveryController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => DiscoveryController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const _AnimatedLogo(),
                        SizedBox(width: 10.w),
                        const _AnimatedBrand(),
                        const Spacer(),
                        Obx(
                          () => _HeaderIcon(
                            icon: controller.searchOpen.value
                                ? Icons.close_rounded
                                : Icons.search_rounded,
                            onTap: controller.toggleSearch,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        _HeaderIcon(
                          icon: Icons.notifications_none_rounded,
                          onTap: showDiscoveryNotificationsSheet,
                        ),
                        SizedBox(width: 10.w),
                        _HeaderIcon(
                          icon: Icons.settings_outlined,
                          onTap: () => Get.toNamed(appSettingsView),
                        ),
                      ],
                    ),

                    Obx(
                      () => AnimatedSize(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: controller.searchOpen.value
                            ? Padding(
                                padding: EdgeInsets.only(top: 14.h),
                                child: DiscoverySearchBar(
                                  onChanged: controller.onSearch,
                                  textController: controller.searchTextCtrl,
                                  autofocus: true,
                                ),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return ListView(
                      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 10.h),
                      children: const [DiscoveryShimmer()],
                    );
                  }
                  final isEmpty = controller.filtered.isEmpty;
                  return RefreshIndicator(
                    onRefresh: controller.loadData,
                    color: AppColors.primary,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // Collapsing promo carousel: folds away on scroll-down
                        // and snaps back open on scroll-up.
                        SliverAppBar(
                          automaticallyImplyLeading: false,
                          pinned: false,
                          floating: true,
                          snap: true,
                          backgroundColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          toolbarHeight: 0,
                          collapsedHeight: 0,
                          expandedHeight: 222.h,
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.pin,
                            background: Padding(
                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 14.h),
                              child: const DiscoveryCarousel(),
                            ),
                          ),
                        ),
                        // Filter + sort bar sits right under the banner.
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: DiscoveryFilterBar(controller: controller),
                          ),
                        ),
                        if (isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: DiscoveryEmpty(),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 15.h),
                            sliver: SliverList.builder(
                              itemCount: controller.filtered.length,
                              itemBuilder: (_, index) {
                                final nursery = controller.filtered[index];
                                return _CardEntrance(
                                  index: index,
                                  child: DiscoveryNurseryCard(
                                    nursery: nursery,
                                    onTap: () =>
                                        controller.openProfile(nursery),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Eye-catching one-time entrance for the brand name in the header:
/// the word pops in with a fade + elastic scale and a soft glow when the
/// screen first opens.
class _AnimatedBrand extends StatefulWidget {
  const _AnimatedBrand();

  @override
  State<_AnimatedBrand> createState() => _AnimatedBrandState();
}

class _AnimatedBrandState extends State<_AnimatedBrand>
    with TickerProviderStateMixin {
  // One-shot entrance: pop + slide + fade.
  late final AnimationController _entry;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  // Looping highlight sweep that gives the wordmark a premium sheen.
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scale = CurvedAnimation(parent: _entry, curve: Curves.elasticOut);
    _fade = CurvedAnimation(
      parent: _entry,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _slide = CurvedAnimation(
      parent: _entry,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );

    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _entry.forward().whenComplete(() {
      if (mounted) _shimmer.repeat();
    });
  }

  @override
  void dispose() {
    _entry.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = AppText(
      text: 'app_brand_name'.tr,
      textStyle: context.typography.xlBold.copyWith(
        color: AppColors.primary,
        shadows: [
          Shadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 14,
          ),
        ],
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_entry, _shimmer]),
      builder: (context, child) {
        return Opacity(
          opacity: _fade.value.clamp(0.0, 1.0),
          child: Transform.translate(
            // Slide in from the right (RTL) as it pops.
            offset: Offset((1 - _slide.value) * 26.w, 0),
            child: Transform.scale(
              scale: 0.4 + _scale.value * 0.6,
              alignment: Alignment.centerRight,
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => _sheenShader(bounds),
                child: child,
              ),
            ),
          ),
        );
      },
      child: brand,
    );
  }

  /// Builds the moving-highlight gradient. The bright band travels across the
  /// word and rests (pauses) between passes for a polished, intentional feel.
  Shader _sheenShader(Rect bounds) {
    // Stretch the active sweep over the first ~40% of the loop, pause after.
    final raw = (_shimmer.value / 0.4).clamp(0.0, 1.0);
    final p = -0.25 + raw * 1.5; // band centre travels off-edge to off-edge
    final s1 = (p - 0.18).clamp(0.0, 1.0);
    final s2 = p.clamp(0.0, 1.0);
    final s3 = (p + 0.18).clamp(0.0, 1.0);
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        AppColors.primary,
        AppColors.primary,
        AppColors.white,
        AppColors.primary,
        AppColors.primary,
      ],
      stops: [0.0, s1, s2, s3, 1.0],
    ).createShader(bounds);
  }
}

/// Animated app-logo chip shown next to the wordmark. It pops in with a fade +
/// elastic scale when the screen first opens, then gently "breathes" (a subtle
/// looping pulse) so the header feels alive instead of empty.
class _AnimatedLogo extends StatefulWidget {
  const _AnimatedLogo();

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with TickerProviderStateMixin {
  late final AnimationController _entry;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _scale = CurvedAnimation(parent: _entry, curve: Curves.elasticOut);
    _fade = CurvedAnimation(
      parent: _entry,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _entry.forward().whenComplete(() {
      if (mounted) _pulse.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _entry.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: 64.w,
      height: 64.w,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.grayLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Image.asset(Images.splash, fit: BoxFit.contain),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_entry, _pulse]),
      builder: (context, child) {
        final breathe = 1 + _pulse.value * 0.06;
        return Opacity(
          opacity: _fade.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: (0.4 + _scale.value * 0.6) * breathe,
            child: child,
          ),
        );
      },
      child: box,
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.grayLight),
        ),
        child: Icon(icon, size: 21.sp, color: AppColors.primary),
      ),
    );
  }
}

/// Staggered fade + slide-up entrance for list cards.
/// Each card holds at opacity 0 for a short index-based delay, then eases in.
class _CardEntrance extends StatelessWidget {
  const _CardEntrance({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Cap the stagger so cards deep in the list don't wait too long.
    final delayMs = (index.clamp(0, 6)) * 80;
    final totalMs = 460 + delayMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(delayMs / totalMs, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) {
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 26),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
