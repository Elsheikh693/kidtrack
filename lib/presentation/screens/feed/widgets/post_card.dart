import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../Data/models/feed/nursery_post_model.dart';
import '../../../../index/index_main.dart';
import '../feed_controller.dart';
import 'create_post_sheet.dart';

class FeedPostCard extends StatelessWidget {
  const FeedPostCard({
    super.key,
    required this.post,
    required this.controller,
  });

  final NurseryPostModel post;
  final FeedController controller;

  Color get _categoryColor {
    switch (post.category) {
      case PostCategory.announcement:
        return AppColors.errorForeground;
      case PostCategory.event:
        return AppColors.blueForeground;
      case PostCategory.achievement:
        return AppColors.yellowForeground;
      case PostCategory.reminder:
        return AppColors.teal;
      default:
        return AppColors.primary;
    }
  }

  Color get _avatarColor {
    final palette = [
      AppColors.primary,
      AppColors.blueForeground,
      AppColors.teal,
      AppColors.successForeground,
    ];
    return palette[post.authorId.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(post: post, avatarColor: _avatarColor, categoryColor: _categoryColor, controller: controller),
          if (post.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
              child: Text(
                post.text,
                style: context.typography.smRegular.copyWith(
                  color: const Color(0xFF1F2937),
                  height: 1.65,
                ),
              ),
            ),
          if (post.photos.isNotEmpty) _PhotosGrid(urls: post.photos),
          _SeenRow(count: post.seenCount),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}

// ─── Seen count (manager insight) ─────────────────────────────────────────────

class _SeenRow extends StatelessWidget {
  const _SeenRow({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 2.h),
      child: Row(
        children: [
          Icon(Icons.visibility_outlined,
              size: 16.sp, color: const Color(0xFF9CA3AF)),
          SizedBox(width: 6.w),
          Text(
            count == 0
                ? 'feed_seen_none'.tr
                : 'feed_seen_count'.trParams({'n': '$count'}),
            style: context.typography.xsMedium
                .copyWith(color: const Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.post,
    required this.avatarColor,
    required this.categoryColor,
    required this.controller,
  });

  final NurseryPostModel post;
  final Color avatarColor;
  final Color categoryColor;
  final FeedController controller;

  String _timeAgo() {
    final diff = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(post.createdAt));
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    final d = DateTime.fromMillisecondsSinceEpoch(post.createdAt);
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 10.w, 10.h),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                post.authorName.isNotEmpty ? post.authorName[0] : '؟',
                style: context.typography.mdBold.copyWith(color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // Name + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      post.authorName,
                      style: context.typography.smSemiBold,
                    ),
                    if (post.isPinned) ...[
                      SizedBox(width: 6.w),
                      Icon(Icons.push_pin_rounded,
                          size: 14.sp, color: const Color(0xFFD97706)),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    _CategoryChip(
                        labelKey: post.category.labelKey,
                        color: categoryColor),
                    SizedBox(width: 6.w),
                    Text(
                      _timeAgo(),
                      style: context.typography.xsMedium.copyWith(color: const Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                color: Color(0xFF9CA3AF)),
            onSelected: (v) async {
              if (v == 'edit') {
                showCreatePostSheet(context, controller: controller, editPost: post);
              } else if (v == 'pin') {
                await controller.togglePin(post);
              } else if (v == 'delete') {
                await controller.deletePost(post);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_rounded, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text('تعديل'),
                ]),
              ),
              PopupMenuItem(
                value: 'pin',
                child: Row(children: [
                  Icon(
                      post.isPinned
                          ? Icons.push_pin_outlined
                          : Icons.push_pin_rounded,
                      size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(post.isPinned ? 'إلغاء التثبيت' : 'تثبيت'),
                ]),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline_rounded,
                      size: 18.sp, color: Colors.red),
                  SizedBox(width: 8.w),
                  Text('حذف', style: context.typography.smRegular.copyWith(color: Colors.red)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.labelKey, required this.color});

  final String labelKey;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        labelKey.tr,
        style: context.typography.xsMedium.copyWith(color: color),
      ),
    );
  }
}

// ─── Photos Grid ──────────────────────────────────────────────────────────────

class _PhotosGrid extends StatelessWidget {
  const _PhotosGrid({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.length == 1) {
      return _NetImage(url: urls[0], height: 220.h, fit: BoxFit.cover);
    }
    if (urls.length == 2) {
      return Row(
        children: urls
            .map((u) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 1.w),
                    child: _NetImage(url: u, height: 180.h, fit: BoxFit.cover),
                  ),
                ))
            .toList(),
      );
    }
    // 3+
    return SizedBox(
      height: 200.h,
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: _NetImage(
                  url: urls[0], height: 200.h, fit: BoxFit.cover)),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              children: [
                Expanded(
                    child: _NetImage(
                        url: urls[1], height: 99.h, fit: BoxFit.cover)),
                SizedBox(height: 2.h),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _NetImage(
                          url: urls[2], height: 99.h, fit: BoxFit.cover),
                      if (urls.length > 3)
                        Container(
                          color: Colors.black54,
                          child: Center(
                            child: Text(
                              '+${urls.length - 3}',
                              style: context.typography.xlBold.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NetImage extends StatelessWidget {
  const _NetImage({required this.url, required this.height, required this.fit});

  final String url;
  final double height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: appCachedImageProvider(url),
      height: height,
      width: double.infinity,
      fit: fit,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          height: height,
          color: const Color(0xFFF3F4F6),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        height: height,
        color: const Color(0xFFF3F4F6),
        child: const Icon(Icons.broken_image_rounded, color: Color(0xFFD1D5DB)),
      ),
    );
  }
}

// ─── Local image preview (for create sheet) ───────────────────────────────────

class LocalImagePreview extends StatelessWidget {
  const LocalImagePreview({
    super.key,
    required this.file,
    required this.onRemove,
  });

  final XFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.file(
            File(file.path),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4.h,
          right: 4.w,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              padding: EdgeInsets.all(4.w),
              child:
                  Icon(Icons.close, size: 14.sp, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
