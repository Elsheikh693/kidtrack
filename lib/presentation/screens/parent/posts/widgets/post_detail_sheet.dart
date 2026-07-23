import '../../../../../index/index_main.dart';

void showPostDetail(BuildContext context, NurseryPostModel post) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PostDetailSheet(post: post),
  );
}

class PostDetailSheet extends StatefulWidget {
  const PostDetailSheet({super.key, required this.post});
  final NurseryPostModel post;

  @override
  State<PostDetailSheet> createState() => _PostDetailSheetState();
}

class _PostDetailSheetState extends State<PostDetailSheet> {
  int _photoIndex = 0;
  late final PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Color get _catColor => switch (widget.post.category) {
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
    return palette[widget.post.authorId.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (context, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              // ── Drag handle ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // ── Title bar ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                child: Row(
                  children: [
                    _CategoryBadge(label: post.category.labelKey.tr, color: _catColor),
                    if (post.isPinned) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.push_pin_rounded, size: 14, color: Color(0xFFD97706)),
                      const SizedBox(width: 3),
                      const Text(
                        'مثبت',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      padding: EdgeInsets.zero,
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5)),
              // ── Scrollable content ────────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    // Author row
                    _AuthorRow(post: post, avatarColor: _avatarColor),
                    const SizedBox(height: 16),

                    // Photos gallery
                    if (post.photos.isNotEmpty) ...[
                      _PhotoGallery(
                        photos: post.photos,
                        controller: _pageCtrl,
                        index: _photoIndex,
                        onPageChanged: (i) => setState(() => _photoIndex = i),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Text
                    if (post.text.isNotEmpty)
                      Text(
                        post.text,
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontFamilyFallback: kEmojiFontFallback,
                          fontSize: 15,
                          color: Color(0xFF1F2937),
                          height: 1.7,
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Date footer
                    Text(
                      _formatDate(post.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                    if (post.updatedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'آخر تعديل: ${_formatDate(post.updatedAt!)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    final h = dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = h < 12 ? 'ص' : 'م';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}، $h12:$min $ampm';
  }
}

// ─── Author row ───────────────────────────────────────────────────────────────

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.post, required this.avatarColor});
  final NurseryPostModel post;
  final Color avatarColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: avatarColor.withValues(alpha: 0.13),
            shape: BoxShape.circle,
            border: Border.all(color: avatarColor.withValues(alpha: 0.25), width: 1),
          ),
          child: post.authorPhotoUrl != null
              ? ClipOval(child: AppNetworkImage(url: post.authorPhotoUrl!, fit: BoxFit.cover))
              : Center(
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0] : '؟',
                    style: TextStyle(
                      color: avatarColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                ParentFeedController.timeAgo(post.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Photos gallery with PageView ─────────────────────────────────────────────

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({
    required this.photos,
    required this.controller,
    required this.index,
    required this.onPageChanged,
  });
  final List<String> photos;
  final PageController controller;
  final int index;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          SizedBox(
            height: 260,
            child: PageView.builder(
              controller: controller,
              itemCount: photos.length,
              onPageChanged: onPageChanged,
              itemBuilder: (_, i) => Image(
                image: appCachedImageProvider(photos[i]),
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (_, child, prog) {
                  if (prog == null) return child;
                  return Container(
                    color: const Color(0xFFF3F4F6),
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (context, error, stack) => Container(
                  color: const Color(0xFFF3F4F6),
                  child: const Icon(Icons.broken_image_rounded, color: Color(0xFFD1D5DB), size: 40),
                ),
              ),
            ),
          ),
          if (photos.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                photos.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == index ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  decoration: BoxDecoration(
                    color: i == index
                        ? AppColors.primary
                        : AppColors.borderNeutralPrimary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
