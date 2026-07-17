import '../../../../index/index_main.dart';

/// The header of the "Learn the App" stepper: a progress ring while videos
/// remain, swapped for a celebration card once every step is finished.
class TutorialProgressHeader extends StatelessWidget {
  final AppTutorialController controller;
  const TutorialProgressHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
        controller.allDone ? const _Celebration() : _Progress(controller));
  }
}

class _Progress extends StatelessWidget {
  final AppTutorialController c;
  const _Progress(this.c);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primary, AppColors.primary80],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'tutorial_header_title'.tr,
                  textStyle: context.typography.mdBold
                      .copyWith(color: AppColors.white),
                ),
                SizedBox(height: 6.h),
                AppText(
                  text: 'tutorial_remaining'
                      .trParams({'count': c.remaining.toString()}),
                  textStyle: context.typography.xsRegular
                      .copyWith(color: AppColors.white.withValues(alpha: 0.85)),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          _Ring(progress: c.progress, done: c.doneCount, total: c.total),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double progress;
  final int done;
  final int total;
  const _Ring({required this.progress, required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64.w,
      height: 64.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 64.w,
            height: 64.w,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6.w,
              backgroundColor: AppColors.white.withValues(alpha: 0.25),
              valueColor: AlwaysStoppedAnimation(AppColors.white),
            ),
          ),
          AppText(
            text: '$done/$total',
            textStyle: context.typography.smSemiBold
                .copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class _Celebration extends StatelessWidget {
  const _Celebration();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF16A34A), Color(0xFF0F9D58)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A34A).withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Lottie.asset(Animations.success, width: 90.w, height: 90.w, repeat: false),
          SizedBox(height: 8.h),
          AppText(
            text: 'tutorial_celebrate_title'.tr,
            textStyle:
                context.typography.mdBold.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          AppText(
            text: 'tutorial_celebrate_sub'.tr,
            textStyle: context.typography.xsRegular
                .copyWith(color: AppColors.white.withValues(alpha: 0.90)),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
