import '../../../../index/index_main.dart';

class SupportRequestView extends StatefulWidget {
  const SupportRequestView({super.key});

  @override
  State<SupportRequestView> createState() => _SupportRequestViewState();
}

class _SupportRequestViewState extends State<SupportRequestView> {
  late final SupportRequestController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => SupportRequestController());
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
            text: 'settings_support'.tr,
            textStyle:
                context.typography.mdBold.copyWith(color: AppColors.textDefault),
          ),
        ),
        body: Form(
          key: controller.formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.confirmation_number_outlined,
                        size: 30.sp, color: const Color(0xFFF59E0B)),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: AppText(
                        text: 'support_intro'.tr,
                        textStyle: context.typography.xsRegular.copyWith(
                          color: AppColors.textSecondaryParagraph,
                          height: 1.5,
                        ),
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              _Label(text: 'support_name'.tr),
              SizedBox(height: 8.h),
              AppTextField(
                controller: controller.nameCtrl,
                hintText: 'support_name_hint'.tr,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.notEmpty(
                  v,
                  errorMessage: 'support_name_required'.tr,
                ),
              ),
              SizedBox(height: 16.h),
              _Label(text: 'support_phone'.tr),
              SizedBox(height: 8.h),
              AppTextField(
                controller: controller.phoneCtrl,
                hintText: 'support_phone_hint'.tr,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.notEmpty(
                  v,
                  errorMessage: 'support_phone_required'.tr,
                ),
              ),
              SizedBox(height: 16.h),
              _Label(text: 'support_email'.tr),
              SizedBox(height: 8.h),
              AppTextField(
                controller: controller.emailCtrl,
                hintText: 'support_email_hint'.tr,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 16.h),
              _Label(text: 'support_subject'.tr),
              SizedBox(height: 8.h),
              AppTextField(
                controller: controller.subjectCtrl,
                hintText: 'support_subject_hint'.tr,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.notEmpty(
                  v,
                  errorMessage: 'support_subject_required'.tr,
                ),
              ),
              SizedBox(height: 16.h),
              _Label(text: 'support_message'.tr),
              SizedBox(height: 8.h),
              AppTextField(
                controller: controller.messageCtrl,
                hintText: 'support_message_hint'.tr,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLines: 6,
                validator: (v) => Validators.notEmpty(
                  v,
                  errorMessage: 'support_message_required'.tr,
                ),
              ),
              SizedBox(height: 28.h),
              Obx(
                () => controller.isSubmitting.value
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
                        onTap: controller.submit,
                        label: AppText(
                          text: 'support_submit'.tr,
                          textStyle: context.typography.mdBold
                              .copyWith(color: AppColors.white),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: AppText(
        text: text,
        textStyle: context.typography.smMedium
            .copyWith(color: AppColors.textDefault),
      ),
    );
  }
}
