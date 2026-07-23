import 'dart:io';

import '../../../../../index/index_main.dart';
import '../star_of_week_controller.dart';

/// Bottom action bar shown once a child is selected: a caption field (which
/// becomes the post text) plus the publish button that fires the reveal.
class StarPickBar extends StatelessWidget {
  const StarPickBar({
    super.key,
    required this.controller,
    required this.onPublish,
  });

  final StarOfWeekController controller;
  final VoidCallback onPublish;

  static const _gold = Color(0xFFD9A400);

  @override
  Widget build(BuildContext context) {
    final child = controller.selectedChild.value;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        14.h,
        16.w,
        MediaQuery.of(context).padding.bottom + 14.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: _gold, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: AppText(
                  text: (child?.fullName ?? ''),
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
              ),
              GestureDetector(
                onTap: controller.clearSelection,
                child: Icon(Icons.close_rounded,
                    size: 20.sp, color: AppColors.textSecondaryParagraph),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _PhotoRow(controller: controller),
          SizedBox(height: 12.h),
          TextField(
            controller: controller.captionController,
            maxLines: 3,
            minLines: 2,
            textInputAction: TextInputAction.newline,
            style: context.typography.smRegular
                .copyWith(color: AppColors.textDefault),
            decoration: InputDecoration(
              hintText: 'sotw_caption_hint'.tr,
              hintStyle: context.typography.smRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              contentPadding: EdgeInsets.all(12.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: PrimaryTextButton(
                onTap: controller.isPublishing.value ? null : onPublish,
                customBackgroundColor: _gold,
                appButtonSize: AppButtonSize.xlarge,
                leading: (_) => Icon(Icons.auto_awesome,
                    color: AppColors.white, size: 18.sp),
                label: AppText(
                  text: 'sotw_publish'.tr,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Optional post-photo picker: a captured/uploaded image overrides the child's
/// avatar for this celebration; leaving it empty uses the child's photo.
class _PhotoRow extends StatelessWidget {
  const _PhotoRow({required this.controller});

  final StarOfWeekController controller;

  static const _gold = Color(0xFFD9A400);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final file = controller.customPhoto.value;
      return Row(
        children: [
          GestureDetector(
            onTap: controller.pickPhoto,
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: _gold.withValues(alpha: 0.5)),
                image: file != null
                    ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                    : null,
              ),
              child: file != null
                  ? null
                  : Icon(Icons.add_a_photo_rounded, color: _gold, size: 22.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppText(
              text: file != null
                  ? 'sotw_photo_selected'.tr
                  : 'sotw_photo_hint'.tr,
              maxLines: 2,
              textStyle: context.typography.xsRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ),
          if (file != null)
            GestureDetector(
              onTap: controller.removePhoto,
              child: Icon(Icons.close_rounded,
                  size: 20.sp, color: AppColors.textSecondaryParagraph),
            ),
        ],
      );
    });
  }
}
