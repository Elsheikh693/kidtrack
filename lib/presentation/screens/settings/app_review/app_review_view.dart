import '../../../../index/index_main.dart';

/// "قولنا كلمة حلوة" — a full-screen KidTrack app rating captured pre-login
/// from the Discovery settings hub. Mirrors the nursery rating star UI.
class AppReviewView extends StatefulWidget {
  const AppReviewView({super.key});

  @override
  State<AppReviewView> createState() => _AppReviewViewState();
}

class _AppReviewViewState extends State<AppReviewView> {
  late final AppReviewController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => AppReviewController());
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
            text: 'app_review_title'.tr,
            textStyle:
                context.typography.mdBold.copyWith(color: AppColors.textDefault),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
          children: [
            Center(
              child: Container(
                width: 74.w,
                height: 74.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite_rounded,
                    color: AppColors.primary, size: 36.sp),
              ),
            ),
            SizedBox(height: 16.h),
            Center(
              child: AppText(
                text: 'app_review_heading'.tr,
                textStyle: context.typography.lgBold
                    .copyWith(color: AppColors.textDefault),
              ),
            ),
            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: AppText(
                text: 'app_review_sub'.tr,
                textAlign: TextAlign.center,
                textStyle: context.typography.xsRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
                maxLines: 3,
              ),
            ),
            SizedBox(height: 26.h),
            Obx(() => _Stars(
                  rating: controller.rating.value,
                  onTap: controller.setRating,
                )),
            SizedBox(height: 8.h),
            Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: controller.rating.value == 0
                    ? const SizedBox.shrink()
                    : AppText(
                        key: ValueKey(controller.rating.value),
                        text: AppReviewController
                            .ratingKeys[controller.rating.value].tr,
                        textAlign: TextAlign.center,
                        textStyle: context.typography.smMedium.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 26.h),
            _Label(text: 'app_review_tags'.tr),
            SizedBox(height: 12.h),
            Obx(
              () => Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: AppReviewController.tagKeys.map((tagKey) {
                  final selected = controller.selectedTags.contains(tagKey);
                  return GestureDetector(
                    onTap: () => controller.toggleTag(tagKey),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 9.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.dividerAndLines,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: AppText(
                        text: tagKey.tr,
                        textStyle: context.typography.xsMedium.copyWith(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondaryParagraph,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 22.h),
            _Label(text: 'app_review_comment'.tr),
            SizedBox(height: 8.h),
            AppTextField(
              controller: controller.commentCtrl,
              hintText: 'app_review_comment_hint'.tr,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              maxLines: 5,
            ),
            SizedBox(height: 30.h),
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
                        text: 'app_review_submit'.tr,
                        textStyle: context.typography.mdBold
                            .copyWith(color: AppColors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onTap;
  const _Stars({required this.rating, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return GestureDetector(
          onTap: () => onTap(i + 1),
          child: AnimatedScale(
            scale: filled ? 1.18 : 1.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.elasticOut,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_border_rounded,
                color: AppColors.ratingStar,
                size: 46.sp,
              ),
            ),
          ),
        );
      }),
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
