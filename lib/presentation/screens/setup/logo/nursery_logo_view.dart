import '../../../../index/index_main.dart';
import 'widgets/nursery_logo_picker.dart';

class NurseryLogoView extends StatefulWidget {
  const NurseryLogoView({super.key});

  @override
  State<NurseryLogoView> createState() => _NurseryLogoViewState();
}

class _NurseryLogoViewState extends State<NurseryLogoView> {
  late final NurseryLogoController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => NurseryLogoController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: HomeAppBar(
          title: 'nursery_logo_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NurseryLogoPicker(controller: controller),
                    SizedBox(height: 24.h),
                    AppText(
                      text: 'nursery_logo_heading'.tr,
                      textStyle: context.typography.mdBold
                          .copyWith(color: AppColors.textDefault),
                    ),
                    SizedBox(height: 8.h),
                    AppText(
                      text: 'nursery_logo_sub'.tr,
                      textAlign: TextAlign.center,
                      textStyle: context.typography.xsMedium
                          .copyWith(color: AppColors.textSecondaryParagraph),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary10,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app_rounded,
                              color: AppColors.primary, size: 16.r),
                          SizedBox(width: 6.w),
                          AppText(
                            text: 'nursery_logo_hint'.tr,
                            textStyle: context.typography.xsMedium
                                .copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        bottomNavigationBar: Obx(() {
          if (controller.isLoading.value) return const SizedBox.shrink();
          return SafeArea(
            minimum: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
            child: PrimaryTextButton(
              label: AppText(
                text: 'manager_profile_save'.tr,
                textStyle: context.typography.smSemiBold
                    .copyWith(color: AppColors.white),
              ),
              appButtonSize: AppButtonSize.large,
              onTap: controller.isSaving.value ? null : controller.save,
            ),
          );
        }),
      ),
    );
  }
}
