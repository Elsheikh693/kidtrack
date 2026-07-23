import '../../../../../index/index_main.dart';
import '../../../feed/widgets/post_photo_carousel.dart';
import 'post_detail_sheet.dart';

const _kInk = Color(0xFF0F172A);
const _kMuted = Color(0xFF64748B);

class ParentPostCard extends StatelessWidget {
  const ParentPostCard({super.key, required this.post});

  final NurseryPostModel post;

  Color get _catColor => switch (post.category) {
    PostCategory.announcement => AppColors.errorForeground,
    PostCategory.event => AppColors.blueForeground,
    PostCategory.achievement => AppColors.yellowForeground,
    PostCategory.reminder => AppColors.teal,
    PostCategory.gallery => const Color(0xFF6366F1),
    _ => AppColors.primary,
  };

  Color get _avatarColor {
    final palette = [
      AppColors.primary,
      const Color(0xFF2563EB),
      AppColors.teal,
      const Color(0xFF059669),
      const Color(0xFF7C3AED),
    ];
    return palette[post.authorId.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPostDetail(context, post),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: post.isPinned
              ? Border.all(
                  color: const Color(0xFFD97706).withValues(alpha: 0.30),
                  width: 1.2,
                )
              : Border.all(color: const Color(0xFFEEF0F4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.isPinned) _PinnedRibbon(),
            _Header(post: post, avatarColor: _avatarColor, catColor: _catColor),
            if (post.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Text(
                  post.text,
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontFamilyFallback: kEmojiFontFallback,
                    fontSize: 14.5,
                    color: Color(0xFF334155),
                    height: 1.7,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (post.photos.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: post.isGallery
                      ? PostPhotoCarousel(urls: post.photos)
                      : _PhotosGrid(urls: post.photos),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Pinned ribbon ────────────────────────────────────────────────────────────

class _PinnedRibbon extends StatelessWidget {
  static const _amber = Color(0xFFD97706);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _amber.withValues(alpha: 0.12),
            _amber.withValues(alpha: 0.03),
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.push_pin_rounded, size: 13, color: _amber),
          const SizedBox(width: 6),
          Text(
            'parent_posts_pinned_section'.tr,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _amber,
              letterSpacing: 0.2,
            ),
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
    required this.catColor,
  });

  final NurseryPostModel post;
  final Color avatarColor;
  final Color catColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
      child: Row(
        children: [
          _AuthorAvatar(
            name: post.authorName,
            photoUrl: post.authorPhotoUrl,
            color: avatarColor,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.authorName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _CategoryBadge(
                      label: post.category.labelKey.tr,
                      color: catColor,
                    ),
                    const SizedBox(width: 7),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: _kMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        ParentFeedController.timeAgo(post.createdAt) +
                            (post.updatedAt != null ? ' · معدّل' : ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _kMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: _kMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Author avatar ────────────────────────────────────────────────────────────

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({required this.name, required this.color, this.photoUrl});

  final String name;
  final String? photoUrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: photoUrl == null
            ? LinearGradient(
                colors: [
                  color.withValues(alpha: 0.22),
                  color.withValues(alpha: 0.10),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              )
            : null,
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1.4),
      ),
      child: photoUrl != null
          ? ClipOval(
              child: AppNetworkImage(url: photoUrl!, fit: BoxFit.cover),
            )
          : Center(
              child: Text(
                name.isNotEmpty ? name[0] : '؟',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }
}

// ─── Category badge ───────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Photos grid ──────────────────────────────────────────────────────────────

class _PhotosGrid extends StatelessWidget {
  const _PhotosGrid({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.length == 1) {
      return _NetImg(url: urls[0], height: 220);
    }
    if (urls.length == 2) {
      return Row(
        children: urls
            .map(
              (u) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: _NetImg(url: u, height: 180),
                ),
              ),
            )
            .toList(),
      );
    }
    // 3+: large left + 2 stacked right
    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(flex: 2, child: _NetImg(url: urls[0], height: 220)),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _NetImg(url: urls[1], height: 109)),
                const SizedBox(height: 2),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _NetImg(url: urls[2], height: 109),
                      if (urls.length > 3)
                        Container(
                          color: Colors.black.withValues(alpha: 0.45),
                          child: Center(
                            child: Text(
                              '+${urls.length - 3}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
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

class _NetImg extends StatelessWidget {
  const _NetImg({required this.url, required this.height});

  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: appCachedImageProvider(url),
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, prog) {
        if (prog == null) return child;
        return Container(
          height: height,
          color: const Color(0xFFF3F4F6),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stack) => Container(
        height: height,
        color: const Color(0xFFF3F4F6),
        child: const Icon(Icons.broken_image_rounded, color: Color(0xFFD1D5DB)),
      ),
    );
  }
}
