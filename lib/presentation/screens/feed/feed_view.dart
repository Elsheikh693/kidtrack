import '../../../Data/models/feed/nursery_post_model.dart';
import '../../../index/index_main.dart';
import 'feed_controller.dart';
import 'widgets/create_post_sheet.dart';
import 'widgets/post_card.dart';

class OwnerFeedTab extends StatefulWidget {
  const OwnerFeedTab({super.key, this.showHeader = true});

  /// When false, the built-in collapsing header is omitted so a parent tab
  /// (e.g. the manager social tab) can supply its own header.
  final bool showHeader;

  @override
  State<OwnerFeedTab> createState() => _OwnerFeedTabState();
}

class _OwnerFeedTabState extends State<OwnerFeedTab> {
  late final FeedController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => FeedController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar:
            widget.showHeader ? OwnerAppBar(title: 'owner_tab_feed'.tr) : null,
        body: Obx(() {
          final loading = controller.isLoading.value;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _CategoryFilterBar(controller: controller),
              ),
              if (loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.filteredPosts.isEmpty)
                const SliverFillRemaining(
                  child: _EmptyState(),
                )
              else ...[
                if (controller.pinnedPosts.isNotEmpty)
                  _PostsSection(
                    label: 'المثبتة',
                    icon: Icons.push_pin_rounded,
                    color: const Color(0xFFD97706),
                    posts: controller.pinnedPosts,
                    controller: controller,
                  ),
                if (controller.regularPosts.isNotEmpty)
                  _PostsSection(
                    label: 'الأحدث',
                    icon: Icons.article_rounded,
                    color: AppColors.primary,
                    posts: controller.regularPosts,
                    controller: controller,
                  ),
              ],
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          );
        }),
        // Lifted above the floating bottom nav bar (68.h pill + 12.h gap)
        // owned by the outer shell Scaffold, so the FAB clears it.
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 80.h),
          child: FloatingActionButton.extended(
            onPressed: () =>
                showCreatePostSheet(context, controller: controller),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text('بوست جديد', style: context.typography.smSemiBold.copyWith(color: Colors.white)),
          ),
        ),
      );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

// ─── Category filter bar ──────────────────────────────────────────────────────

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({required this.controller});

  final FeedController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
      child: Obx(() {
        final selected = controller.selectedCategory.value;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'الكل',
                selected: selected == null,
                color: AppColors.primary,
                onTap: () => controller.filterBy(null),
              ),
              SizedBox(width: 6.w),
              ...PostCategory.values.map((cat) {
                final color = _catColor(cat);
                return Padding(
                  padding: EdgeInsets.only(left: 6.w),
                  child: _FilterChip(
                    label: cat.labelKey.tr,
                    selected: selected == cat,
                    color: color,
                    onTap: () => controller.filterBy(cat),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Color _catColor(PostCategory cat) {
    switch (cat) {
      case PostCategory.announcement:
        return const Color(0xFFDC2626);
      case PostCategory.event:
        return const Color(0xFF2563EB);
      case PostCategory.achievement:
        return const Color(0xFFD97706);
      case PostCategory.reminder:
        return const Color(0xFF0891B2);
      case PostCategory.starOfWeek:
        return const Color(0xFFE0A100);
      case PostCategory.gallery:
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF7C3AED);
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
              color: selected ? color : color.withOpacity(0.3), width: 1),
        ),
        child: Text(
          label,
          style: context.typography.xsMedium.copyWith(
            color: selected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

// ─── Posts section ────────────────────────────────────────────────────────────

class _PostsSection extends StatelessWidget {
  const _PostsSection({
    required this.label,
    required this.icon,
    required this.color,
    required this.posts,
    required this.controller,
  });

  final String label;
  final IconData icon;
  final Color color;
  final List<NurseryPostModel> posts;
  final FeedController controller;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Row(
              children: [
                Icon(icon, size: 16.sp, color: color),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: context.typography.xsMedium.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => FeedPostCard(
              key: ValueKey(posts[i].id),
              post: posts[i],
              controller: controller,
            ),
            childCount: posts.length,
          ),
        ),
      ],
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dynamic_feed_outlined,
              size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(
            'لا يوجد منشورات بعد',
            style: context.typography.mdMedium.copyWith(color: Colors.grey.shade500),
          ),
          SizedBox(height: 6.h),
          Text(
            'ابدأ بنشر أول بوست للحضانة',
            style: context.typography.xsRegular.copyWith(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
