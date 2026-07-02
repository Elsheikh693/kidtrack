import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../Data/models/feed/nursery_post_model.dart';
import '../../../../index/index_main.dart';
import '../feed_controller.dart';
import 'post_card.dart';

void showCreatePostSheet(
  BuildContext context, {
  required FeedController controller,
  NurseryPostModel? editPost,
}) {
  final ctrl = CreatePostController(editPost: editPost);
  Get.to(
    () => GetBuilder<CreatePostController>(
      init: ctrl,
      builder: (c) => _CreatePostScreen(controller: c),
    ),
    fullscreenDialog: true,
  );
}

class _CreatePostScreen extends StatelessWidget {
  const _CreatePostScreen({required this.controller});

  final CreatePostController controller;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            controller.editPost == null ? 'بوست جديد' : 'تعديل البوست',
            style: context.typography.lgBold.copyWith(color: AppColors.textDefault),
          ),
          actions: [
            Obx(() => controller.isSubmitting.value
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: controller.submit,
                    child: Text(
                      controller.editPost == null ? 'نشر' : 'تحديث',
                      style: context.typography.smSemiBold
                          .copyWith(color: AppColors.primary),
                    ),
                  )),
            SizedBox(width: 6.w),
          ],
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text field
                      TextField(
                        controller: controller.textController,
                        maxLines: 5,
                        minLines: 3,
                        textDirection: TextDirection.rtl,
                        style: context.typography.mdRegular
                            .copyWith(color: AppColors.textDefault),
                        decoration: InputDecoration(
                          hintText: 'اكتب شيئاً...',
                          hintTextDirection: TextDirection.rtl,
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                                BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          contentPadding: EdgeInsets.all(12.w),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Category picker
                      const _SectionLabel(label: 'التصنيف'),
                      SizedBox(height: 8.h),
                      Obx(() => Wrap(
                            spacing: 8,
                            children: PostCategory.values
                                .map((cat) => _CategoryToggle(
                                      cat: cat,
                                      selected: controller.category.value == cat,
                                      onTap: () => controller.category.value = cat,
                                    ))
                                .toList(),
                          )),
                      SizedBox(height: 16.h),
                      // Pin toggle
                      Obx(() => _PinRow(
                            value: controller.isPinned.value,
                            onChanged: (v) => controller.isPinned.value = v,
                          )),
                      SizedBox(height: 16.h),
                      // Branches
                      _SectionLabel(label: 'feed_branches_label'.tr),
                      SizedBox(height: 4.h),
                      Text(
                        'feed_branches_hint'.tr,
                        style: context.typography.xsRegular.copyWith(
                            fontSize: 12, color: const Color(0xFF9CA3AF)),
                      ),
                      SizedBox(height: 8.h),
                      _BranchSelector(controller: controller),
                      SizedBox(height: 16.h),
                      // Audience
                      _SectionLabel(label: 'feed_audience_label'.tr),
                      SizedBox(height: 8.h),
                      _AudienceSelector(controller: controller),
                      SizedBox(height: 16.h),
                      // Photos section
                      const _SectionLabel(label: 'الصور'),
                      SizedBox(height: 8.h),
                      Obx(() {
                        final existing = List<String>.from(controller.existingPhotos);
                        final newImgs = List<XFile>.from(controller.newImages);
                        final total = existing.length + newImgs.length;
                        return _PhotosPicker(
                          existing: existing,
                          newImgs: newImgs,
                          total: total,
                          onRemoveExisting: controller.removeExisting,
                          onRemoveNew: controller.removeNew,
                          onPick: controller.pickImages,
                        );
                      }),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.typography.smSemiBold.copyWith(
          fontSize: 13, color: const Color(0xFF6B7280)),
    );
  }
}

class _CategoryToggle extends StatelessWidget {
  const _CategoryToggle({
    required this.cat,
    required this.selected,
    required this.onTap,
  });

  final PostCategory cat;
  final bool selected;
  final VoidCallback onTap;

  Color get _color {
    switch (cat) {
      case PostCategory.announcement:
        return const Color(0xFFDC2626);
      case PostCategory.event:
        return const Color(0xFF2563EB);
      case PostCategory.achievement:
        return const Color(0xFFD97706);
      case PostCategory.reminder:
        return const Color(0xFF0891B2);
      default:
        return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? _color : _color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _color, width: selected ? 0 : 1),
        ),
        child: Text(
          cat.labelKey.tr,
          style: context.typography.smSemiBold.copyWith(
            fontSize: 12,
            color: selected ? Colors.white : _color,
          ),
        ),
      ),
    );
  }
}

class _PinRow extends StatelessWidget {
  const _PinRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: value
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: value ? const Color(0xFFD97706) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.push_pin_rounded,
              size: 18.sp,
              color: value
                  ? const Color(0xFFD97706)
                  : const Color(0xFF9CA3AF)),
          SizedBox(width: 8.w),
          Text('تثبيت البوست',
              style: context.typography.smMedium),
          const Spacer(),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }
}

class _AudienceSelector extends StatelessWidget {
  const _AudienceSelector({required this.controller});

  final CreatePostController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.classroomId.value;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _AudienceChip(
            label: 'feed_audience_all'.tr,
            icon: Icons.groups_rounded,
            selected: selected == null,
            onTap: () => controller.classroomId.value = null,
          ),
          ...controller.classrooms.map((c) => _AudienceChip(
                label: c.name,
                icon: Icons.meeting_room_rounded,
                selected: selected == c.key,
                onTap: () => controller.classroomId.value = c.key,
              )),
        ],
      );
    });
  }
}

class _BranchSelector extends StatelessWidget {
  const _BranchSelector({required this.controller});

  final CreatePostController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingBranches.value) {
        return SizedBox(
          height: 36.h,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              width: 20.w,
              height: 20.h,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }
      final allSelected = controller.selectedBranchIds.isEmpty;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _AudienceChip(
            label: 'feed_all_branches'.tr,
            icon: Icons.account_balance_rounded,
            selected: allSelected,
            onTap: controller.toggleAllBranches,
          ),
          ...controller.branches.map((b) => _AudienceChip(
                label: b.name,
                icon: Icons.account_balance_rounded,
                selected: controller.selectedBranchIds.contains(b.key),
                onTap: () => controller.toggleBranch(b.key ?? ''),
              )),
        ],
      );
    });
  }
}

class _AudienceChip extends StatelessWidget {
  const _AudienceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: selected ? color : color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: selected ? Colors.white : color),
            SizedBox(width: 5.w),
            Text(
              label,
              style: context.typography.xsMedium
                  .copyWith(color: selected ? Colors.white : color),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotosPicker extends StatelessWidget {
  const _PhotosPicker({
    required this.existing,
    required this.newImgs,
    required this.total,
    required this.onRemoveExisting,
    required this.onRemoveNew,
    required this.onPick,
  });

  final List<String> existing;
  final List<XFile> newImgs;
  final int total;
  final void Function(String) onRemoveExisting;
  final void Function(int) onRemoveNew;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (existing.isNotEmpty || newImgs.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 6.h,
              crossAxisSpacing: 6.w,
            ),
            itemCount: existing.length + newImgs.length,
            itemBuilder: (_, i) {
              if (i < existing.length) {
                final url = existing[i];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image(image: appCachedImageProvider(url),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity),
                    ),
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: GestureDetector(
                        onTap: () => onRemoveExisting(url),
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle),
                          padding: EdgeInsets.all(4.w),
                          child: Icon(Icons.close,
                              size: 14.sp, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }
              final j = i - existing.length;
              return LocalImagePreview(
                file: newImgs[j],
                onRemove: () => onRemoveNew(j),
              );
            },
          ),
        if (total < 10) ...[
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: onPick,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: const Color(0xFFE5E7EB), style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Icons.add_photo_alternate_rounded,
                      size: 28.sp, color: const Color(0xFF9CA3AF)),
                  SizedBox(height: 4.h),
                  Text(
                    total == 0
                        ? 'أضف صور (حتى 10)'
                        : 'أضف المزيد ($total/10)',
                    style: context.typography.xsRegular.copyWith(
                        fontSize: 12, color: const Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
