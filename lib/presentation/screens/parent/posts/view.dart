import '../../../../index/index_main.dart';
import 'widgets/post_card.dart';

class ParentPostsView extends StatefulWidget {
  const ParentPostsView({super.key});

  @override
  State<ParentPostsView> createState() => _ParentPostsViewState();
}

class _ParentPostsViewState extends State<ParentPostsView> {
  late final ParentFeedController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ParentFeedController());
  }

  @override
  Widget build(BuildContext context) {
    return ParentTabScaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppColors.primary,
        displacement: 60,
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _FeedBody(controller: controller)),
          ],
        ),
      ),
    );
  }
}

// ─── Feed body ────────────────────────────────────────────────────────────────

class _FeedBody extends StatelessWidget {
  const _FeedBody({required this.controller});
  final ParentFeedController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const _FeedShimmer();

      final pinned = controller.pinnedPosts;
      final regular = controller.regularPosts;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breathing room between the top bar and the first post.
          const SizedBox(height: 12),

          // ── Pinned section ────────────────────────────────────────────────
          if (pinned.isNotEmpty) ...[
            _SectionHeader(
              icon: Icons.push_pin_rounded,
              label: 'parent_posts_pinned_section'.tr,
              color: AppColors.yellowForeground,
            ),
            ...pinned.map(
              (p) => ParentPostCard(key: ValueKey('pin_${p.id}'), post: p),
            ),
          ],

          // ── Regular section ───────────────────────────────────────────────
          // Header ("الأنشطة والأخبار") intentionally removed — the posts speak
          // for themselves and the top bar already frames the feed.
          if (regular.isNotEmpty)
            ...regular.map(
              (p) => ParentPostCard(key: ValueKey('reg_${p.id}'), post: p),
            ),

          // ── Empty state ───────────────────────────────────────────────────
          if (controller.isEmpty) const _EmptyState(),

          // ── Load more spinner ─────────────────────────────────────────────
          if (controller.isLoadingMore.value)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),

          // ── End of feed label ─────────────────────────────────────────────
          if (!controller.hasMore.value &&
              regular.isNotEmpty &&
              !controller.isLoadingMore.value)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 1,
                      color: AppColors.borderNeutralPrimary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'parent_feed_no_more'.tr,
                      style: const TextStyle(
                        color: AppColors.textSecondaryParagraph,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 1,
                      color: AppColors.borderNeutralPrimary,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 100),
        ],
      );
    });
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 9),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.article_outlined,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'parent_feed_empty_title'.tr,
            style: context.typography.mdBold.copyWith(
              color: AppColors.textDefault,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'parent_feed_empty_subtitle'.tr,
            style: const TextStyle(
              color: AppColors.textSecondaryParagraph,
              fontSize: 13,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer skeleton ─────────────────────────────────────────────────────────

class _FeedShimmer extends StatelessWidget {
  const _FeedShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(children: List.generate(3, (_) => const _PostSkeleton()));
  }
}

class _PostSkeleton extends StatelessWidget {
  const _PostSkeleton();

  Widget _box(double w, double h) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: const Color(0xFFE5E7EB),
      borderRadius: BorderRadius.circular(6),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE5E7EB),
        highlightColor: const Color(0xFFF8FAFC),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(130, 11),
                    const SizedBox(height: 6),
                    _box(90, 9),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            _box(double.infinity, 10),
            const SizedBox(height: 8),
            _box(220, 10),
            const SizedBox(height: 8),
            _box(170, 10),
            const SizedBox(height: 14),
            _box(double.infinity, 160),
          ],
        ),
      ),
    );
  }
}
