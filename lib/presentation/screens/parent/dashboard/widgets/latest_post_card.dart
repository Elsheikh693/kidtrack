import '../../../../../index/index_main.dart';
import '../../../../../Data/models/feed/nursery_post_model.dart';
import '../controller.dart';

/// Home peek at the nursery's newest social post. Only rendered while the
/// controller has a `latestPost` (today-only, audience-matched) — the card
/// disappears on its own at midnight when yesterday's post stops matching.
class LatestPostCard extends StatelessWidget {
  const LatestPostCard({super.key, required this.controller});
  final ParentDashboardController controller;

  static const _radius = 20.0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final post = controller.latestPost.value;
      if (post == null) return const SizedBox.shrink();

      return Container(
        margin: EdgeInsets.only(bottom: 18.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_radius.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14.r,
              offset: Offset(0.w, 5.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(post: post),
              if (post.text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                  child: Text(
                    post.text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.smRegular.copyWith(
                      color: const Color(0xFF374151),
                      height: 1.6,
                    ),
                  ),
                ),
              if (post.photos.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: AppNetworkImage(
                      url: post.photos.first,
                      width: double.infinity,
                      height: 160.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const _Divider(),
              _ViewAllButton(),
            ],
          ),
        ),
      );
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.post});
  final NurseryPostModel post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 12.w, 10.h),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.campaign_rounded,
                color: AppColors.primary, size: 22.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'parent_latest_post_label'.tr,
                  style: context.typography.xsMedium.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  post.authorName,
                  style: context.typography.smSemiBold,
                ),
              ],
            ),
          ),
          if (post.isPinned)
            Padding(
              padding: EdgeInsets.only(right: 4.w),
              child: Icon(Icons.push_pin_rounded,
                  size: 16.sp, color: const Color(0xFFD97706)),
            ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, thickness: 1, color: const Color(0xFFF1F5F9));
}

class _ViewAllButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.find<MainPageViewModel>().changePage(2),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 13.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'common_view_all'.tr,
              style: context.typography.smSemiBold
                  .copyWith(color: AppColors.primary),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.chevron_right_rounded,
                size: 20.sp, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
