import '../../../../../index/index_main.dart';

/// Collapsing hero app bar for the nursery profile.
///
/// Expanded: full cover photo with a strong scrim and the nursery logo, name,
/// rating and address overlaid at the bottom.
/// Collapsed: a solid primary bar showing just the nursery name + back button.
/// The back button lives inside the safe-area toolbar, so it never collides
/// with the status bar.
class ProfileSliverHeader extends StatelessWidget {
  final NurseryModel nursery;
  const ProfileSliverHeader({super.key, required this.nursery});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 250.h,
      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: const _BackButton(),
      flexibleSpace: LayoutBuilder(
        builder: (context, _) {
          final settings = context
              .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
          double t = 0; // 0 = expanded, 1 = collapsed
          if (settings != null) {
            final delta = settings.maxExtent - settings.minExtent;
            if (delta > 0) {
              t = ((settings.maxExtent - settings.currentExtent) / delta)
                  .clamp(0.0, 1.0);
            }
          }
          final expandedOpacity = (1 - t * 1.6).clamp(0.0, 1.0);
          final collapsedOpacity = ((t - 0.55) / 0.45).clamp(0.0, 1.0);
          // Cover + scrim fade out completely as we collapse, leaving the
          // solid primary app-bar background underneath (a normal bar).
          final coverOpacity = (1 - t * 1.25).clamp(0.0, 1.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: coverOpacity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(
                      url: nursery.coverPhoto,
                      fit: BoxFit.cover,
                      errorWidget: _coverFallback(),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.45, 1.0],
                            colors: [
                              Colors.black.withValues(alpha: 0.18),
                              Colors.black.withValues(alpha: 0.42),
                              Colors.black.withValues(alpha: 0.82),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Expanded hero content (fades out as it collapses)
              Positioned(
                right: 20.w,
                left: 20.w,
                bottom: 18.h,
                child: Opacity(
                  opacity: expandedOpacity,
                  child: _titleRow(context),
                ),
              ),
              // Collapsed title (fades in inside the toolbar)
              Positioned(
                top: 0,
                right: 56.w,
                left: 56.w,
                child: SafeArea(
                  bottom: false,
                  child: SizedBox(
                    height: kToolbarHeight,
                    child: Center(
                      child: Opacity(
                        opacity: collapsedOpacity,
                        child: AppText(
                          text: nursery.name,
                          textStyle: context.typography.mdBold
                              .copyWith(color: AppColors.white),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _coverFallback() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary80],
        ),
      ),
    );
  }

  Widget _titleRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 70.w,
          height: 70.w,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppNetworkImage(
            url: nursery.logo,
            borderRadius: BorderRadius.circular(15.r),
            errorWidget: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(Icons.home_work_rounded,
                  color: AppColors.primary, size: 28.sp),
            ),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: nursery.name,
                textStyle: context.typography.lgBold.copyWith(
                  color: AppColors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 8,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                maxLines: 2,
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  if (nursery.rating != null) ...[
                    _RatingBadge(rating: nursery.rating!),
                    SizedBox(width: 8.w),
                  ],
                  if ((nursery.address ?? '').isNotEmpty)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 13.sp,
                              color: AppColors.white.withValues(alpha: 0.85)),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: AppText(
                              text: nursery.address!,
                              textStyle: context.typography.xsRegular.copyWith(
                                color: AppColors.white.withValues(alpha: 0.9),
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded,
              size: 14.sp, color: AppColors.yellowForeground),
          SizedBox(width: 3.w),
          AppText(
            text: rating.toStringAsFixed(1),
            textStyle:
                context.typography.xsBold.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: Get.back,
        child: Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(Icons.arrow_back_rounded,
              size: 20.sp, color: AppColors.textDefault),
        ),
      ),
    );
  }
}
