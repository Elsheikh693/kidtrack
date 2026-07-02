import '../../../../index/index_main.dart';

class ContactInfoFormView extends StatefulWidget {
  const ContactInfoFormView({super.key});

  @override
  State<ContactInfoFormView> createState() => _ContactInfoFormViewState();
}

class _ContactInfoFormViewState extends State<ContactInfoFormView> {
  late final ContactInfoFormController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ContactInfoFormController());
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
          'pcontent_contact'.tr,
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
            _Section(title: 'pcontent_section_direct'.tr),
            _Field(
              label: 'contact_phone'.tr,
              controller: controller.phoneCtrl,
              keyboardType: TextInputType.phone,
            ),
            _Field(
              label: 'contact_whatsapp'.tr,
              controller: controller.whatsappCtrl,
              keyboardType: TextInputType.phone,
            ),
            _Field(
              label: 'contact_email'.tr,
              controller: controller.emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
            _Field(
              label: 'contact_working_hours'.tr,
              controller: controller.workingHoursCtrl,
            ),
            SizedBox(height: 8.h),
            _Section(title: 'pcontent_section_location'.tr),
            _Field(
              label: 'contact_address'.tr,
              controller: controller.addressCtrl,
              maxLines: 2,
            ),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: 'pcontent_lat'.tr,
                    controller: controller.latCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _Field(
                    label: 'pcontent_lng'.tr,
                    controller: controller.lngCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            _Section(title: 'pcontent_section_social'.tr),
            _Field(label: 'Facebook', controller: controller.facebookCtrl),
            _Field(label: 'Instagram', controller: controller.instagramCtrl),
            _Field(label: 'TikTok', controller: controller.tiktokCtrl),
            _Field(label: 'YouTube', controller: controller.youtubeCtrl),
            _Field(
                label: 'contact_website'.tr,
                controller: controller.websiteCtrl),
            SizedBox(height: 24.h),
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

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 4.h),
      child: Text(
        title,
        style: context.typography.smSemiBold.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType,
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
            keyboardType: keyboardType,
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
