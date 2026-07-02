import '../../../../index/index_main.dart';

class AboutUsView extends StatefulWidget {
  const AboutUsView({super.key});

  @override
  State<AboutUsView> createState() => _AboutUsViewState();
}

class _AboutUsViewState extends State<AboutUsView> {
  late final AboutUsController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => AboutUsController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          leading: GestureDetector(
            onTap: Get.back,
            child: Icon(Icons.arrow_back_rounded,
                color: AppColors.textDefault, size: 22.sp),
          ),
          title: AppText(
            text: 'settings_about_us'.tr,
            textStyle:
                context.typography.mdBold.copyWith(color: AppColors.textDefault),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const _AboutShimmer();
          }
          final about = controller.about.value;
          if (about == null || about.isEmpty) {
            return _Empty(message: 'about_empty'.tr);
          }
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _Hero(about: about),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: about.title,
                      maxLines: 3,
                      textStyle: context.typography.lgBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                    SizedBox(height: 12.h),
                    AppText(
                      text: about.description,
                      maxLines: 1000,
                      textStyle: context.typography.smRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                        height: 1.8,
                      ),
                    ),
                    if (about.hasMission) ...[
                      SizedBox(height: 20.h),
                      _InfoBlock(
                        icon: Icons.flag_rounded,
                        color: const Color(0xFF6366F1),
                        title: 'about_mission'.tr,
                        body: about.mission!,
                      ),
                    ],
                    if (about.hasVision) ...[
                      SizedBox(height: 14.h),
                      _InfoBlock(
                        icon: Icons.visibility_rounded,
                        color: const Color(0xFF0EA5E9),
                        title: 'about_vision'.tr,
                        body: about.vision!,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final AboutUsModel about;
  const _Hero({required this.about});

  @override
  Widget build(BuildContext context) {
    if (about.hasImage) {
      return SizedBox(
        height: 220.h,
        width: double.infinity,
        child: AppNetworkImage(
          url: about.imageUrl,
          width: double.infinity,
          height: 220.h,
          fit: BoxFit.contain,
          errorWidget: _gradientFallback(context),
        ),
      );
    }
    return _gradientFallback(context);
  }

  Widget _gradientFallback(BuildContext context) {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primary, AppColors.primary80],
        ),
      ),
      child: Center(
        child: Icon(Icons.child_friendly_rounded,
            size: 72.sp, color: AppColors.white.withValues(alpha: 0.9)),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _InfoBlock({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(icon, size: 20.sp, color: color),
              ),
              SizedBox(width: 12.w),
              AppText(
                text: title,
                textStyle: context.typography.smSemiBold
                    .copyWith(color: AppColors.textDefault),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AppText(
            text: body,
            maxLines: 1000,
            textStyle: context.typography.smRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String message;
  const _Empty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 56.sp, color: AppColors.grayMedium),
          SizedBox(height: 14.h),
          AppText(
            text: message,
            textStyle: context.typography.smRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}

class _AboutShimmer extends StatelessWidget {
  const _AboutShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Shimmer.fromColors(
          baseColor: AppColors.grayLight,
          highlightColor: AppColors.white,
          child: Container(height: 200.h, color: AppColors.white),
        ),
        Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              6,
              (i) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Shimmer.fromColors(
                  baseColor: AppColors.grayLight,
                  highlightColor: AppColors.white,
                  child: Container(
                    height: i == 0 ? 24.h : 14.h,
                    width: i == 0 ? 180.w : double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
