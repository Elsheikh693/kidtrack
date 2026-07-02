import '../../../../index/index_main.dart';

class AboutUsFormView extends StatefulWidget {
  const AboutUsFormView({super.key});

  @override
  State<AboutUsFormView> createState() => _AboutUsFormViewState();
}

class _AboutUsFormViewState extends State<AboutUsFormView> {
  late final AboutUsFormController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => AboutUsFormController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: Get.back,
          child: Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textDefault, size: 20.sp),
        ),
        title: Text(
          'pcontent_about'.tr,
          style:
              context.typography.mdBold.copyWith(color: AppColors.textDefault),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        return ListView(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
          children: [
            _ImagePicker(controller: controller),
            SizedBox(height: 20.h),
            _Field(
              label: 'pcontent_about_title'.tr,
              controller: controller.titleCtrl,
            ),
            _Field(
              label: 'pcontent_about_desc'.tr,
              controller: controller.descriptionCtrl,
              maxLines: 6,
            ),
            _Field(
              label: 'about_mission'.tr,
              controller: controller.missionCtrl,
              maxLines: 4,
            ),
            _Field(
              label: 'about_vision'.tr,
              controller: controller.visionCtrl,
              maxLines: 4,
            ),
            SizedBox(height: 12.h),
            Obx(
              () => controller.isSaving.value
                  ? Container(
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    )
                  : PrimaryTextButton(
                      appButtonSize: AppButtonSize.xxLarge,
                      onTap: controller.save,
                      label: AppText(
                        text: 'pcontent_save'.tr,
                        textStyle: context.typography.mdBold
                            .copyWith(color: AppColors.white),
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  final AboutUsFormController controller;
  const _ImagePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final url = controller.imageUrl.value;
      final uploading = controller.isUploading.value;
      return GestureDetector(
        onTap: uploading ? null : controller.pickImage,
        child: Container(
          height: 180.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.grayLight),
          ),
          clipBehavior: Clip.antiAlias,
          child: uploading
              ? Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : (url == null || url.isEmpty)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 40.sp, color: AppColors.grayMedium),
                        SizedBox(height: 8.h),
                        Text(
                          'pcontent_pick_image'.tr,
                          style: context.typography.xsRegular.copyWith(
                              color: AppColors.textSecondaryParagraph),
                        ),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        AppNetworkImage(url: url, fit: BoxFit.contain),
                        Positioned(
                          top: 10.h,
                          right: 10.w,
                          child: GestureDetector(
                            onTap: controller.removeImage,
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close_rounded,
                                  size: 18.sp, color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      );
    });
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const _Field({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.typography.xsMedium
                .copyWith(color: AppColors.textDefault),
          ),
          SizedBox(height: 6.h),
          AppTextField(
            controller: controller,
            maxLines: maxLines,
            textInputAction: maxLines > 1
                ? TextInputAction.newline
                : TextInputAction.next,
          ),
        ],
      ),
    );
  }
}
