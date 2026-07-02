import 'package:url_launcher/url_launcher.dart';
import '../../../../Data/models/nursery_course/nursery_course_model.dart';
import '../../../../index/index_main.dart';

class LessonViewerArgs {
  final NurseryCourse course;
  final CourseLesson lesson;
  final int lessonIndex;
  final int totalLessons;
  final VoidCallback? onCompleted;

  const LessonViewerArgs({
    required this.course,
    required this.lesson,
    required this.lessonIndex,
    required this.totalLessons,
    this.onCompleted,
  });
}

class LessonViewerView extends StatefulWidget {
  const LessonViewerView({super.key});

  @override
  State<LessonViewerView> createState() => _LessonViewerViewState();
}

class _LessonViewerViewState extends State<LessonViewerView> {
  late final LessonViewerArgs args;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    args = Get.arguments as LessonViewerArgs;
    // Auto-mark as completed after 2 seconds of viewing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _completed = true);
        args.onCompleted?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final course  = args.course;
    final lesson  = args.lesson;
    final catColor = course.category.color;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App bar ───────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: catColor,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: context.typography.xsRegular.copyWith(color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'درس ${args.lessonIndex + 1} من ${args.totalLessons}',
                    style: context.typography.xsRegular.copyWith(color: Colors.white54),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: (args.lessonIndex + 1) / args.totalLessons),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    minHeight: 4,
                  ),
                ),
              ),
            ),

            // ── Lesson header ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: catColor.withOpacity(0.06),
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: lesson.contentType.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            lesson.contentType.icon,
                            color: lesson.contentType.color,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: lesson.contentType.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  lesson.contentType.label,
                                  style: context.typography.xsRegular.copyWith(color: lesson.contentType.color),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_completed)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.elasticOut,
                            builder: (_, v, child) => Transform.scale(scale: v, child: child),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: const Color(0xFF059669).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 12.sp, color: const Color(0xFF059669)),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'مكتمل',
                                    style: context.typography.xsMedium.copyWith(color: Color(0xFF059669)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      lesson.title,
                      style: context.typography.xlBold.copyWith(height: 1.3),
                    ),
                    if (lesson.durationMinutes > 0) ...[
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 13.sp, color: Colors.grey.shade500),
                          SizedBox(width: 4.w),
                          Text(
                            '${lesson.durationMinutes} دقيقة',
                            style: context.typography.xsRegular.copyWith(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                    if (lesson.description != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        lesson.description!,
                        style: context.typography.xsRegular.copyWith(height: 1.6, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
            ),

            // ── Content ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: _LessonContent(lesson: lesson, catColor: catColor),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 40.h)),
          ],
        ),
      ),
    );
  }
}

// ─── Content renderer ─────────────────────────────────────────────────────────

class _LessonContent extends StatelessWidget {
  const _LessonContent({required this.lesson, required this.catColor});

  final CourseLesson lesson;
  final Color catColor;

  @override
  Widget build(BuildContext context) {
    return switch (lesson.contentType) {
      LessonContentType.text  => _TextContent(text: lesson.textContent, catColor: catColor),
      LessonContentType.video => _UrlContent(
          url: lesson.contentUrl,
          icon: Icons.play_circle_rounded,
          label: 'فتح الفيديو',
          color: const Color(0xFFDC2626),
          hint: 'سيتم فتح الفيديو في المتصفح',
        ),
      LessonContentType.pdf   => _UrlContent(
          url: lesson.contentUrl,
          icon: Icons.picture_as_pdf_rounded,
          label: 'فتح الـ PDF',
          color: const Color(0xFFD97706),
          hint: 'سيتم فتح الملف في المتصفح',
        ),
      LessonContentType.image => _ImageContent(url: lesson.contentUrl),
    };
  }
}

// ── Text content ──────────────────────────────────────────────────────────────

class _TextContent extends StatelessWidget {
  const _TextContent({required this.text, required this.catColor});

  final String? text;
  final Color catColor;

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) {
      return Center(
        child: Text(
          'لا يوجد محتوى نصي',
          style: context.typography.smRegular.copyWith(color: Colors.grey.shade400),
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: catColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: catColor.withOpacity(0.12)),
      ),
      child: Text(
        text!,
        style: context.typography.mdRegular.copyWith(height: 2.0, letterSpacing: 0.2, color: Color(0xFF1F2937)),
      ),
    );
  }
}

// ── URL content (video / pdf) ─────────────────────────────────────────────────

class _UrlContent extends StatefulWidget {
  const _UrlContent({
    required this.url,
    required this.icon,
    required this.label,
    required this.color,
    required this.hint,
  });

  final String? url;
  final IconData icon;
  final String label;
  final Color color;
  final String hint;

  @override
  State<_UrlContent> createState() => _UrlContentState();
}

class _UrlContentState extends State<_UrlContent> {
  bool _launched = false;

  Future<void> _launch() async {
    if (widget.url == null || widget.url!.isEmpty) return;
    final uri = Uri.tryParse(widget.url!);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    setState(() => _launched = true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url == null || widget.url!.isEmpty) {
      return Center(
        child: Text(
          'لم يتم إضافة رابط بعد',
          style: context.typography.smRegular.copyWith(color: Colors.grey.shade400),
        ),
      );
    }
    return Column(
      children: [
        GestureDetector(
          onTap: _launch,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.95, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: double.infinity,
              height: 160.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.color, widget.color.withOpacity(0.7)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 20.r,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 52.sp),
                  SizedBox(height: 12.h),
                  Text(
                    widget.label,
                    style: context.typography.mdBold.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    widget.hint,
                    style: context.typography.xsRegular.copyWith(color: Colors.white.withOpacity(0.75)),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_launched) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 16.sp, color: const Color(0xFF059669)),
                SizedBox(width: 8.w),
                Text(
                  'تم فتح المحتوى',
                  style: context.typography.xsMedium.copyWith(color: Color(0xFF059669)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Image content ─────────────────────────────────────────────────────────────

class _ImageContent extends StatelessWidget {
  const _ImageContent({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Center(
        child: Text('لم يتم إضافة صورة', style: context.typography.smRegular.copyWith(color: Colors.grey.shade400)),
      );
    }
    return GestureDetector(
      onTap: () => _showFullScreen(context),
      child: Hero(
        tag: 'lesson_image_$url',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Image(
            image: appCachedImageProvider(url!),
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 200.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Hero(
              tag: 'lesson_image_$url',
              child: InteractiveViewer(
                child: Image(image: appCachedImageProvider(url!), fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
