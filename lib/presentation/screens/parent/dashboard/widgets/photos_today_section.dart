import 'dart:async';
import '../../../../../index/index_main.dart';
import 'image_viewer.dart';

class PhotosTodaySection extends StatefulWidget {
  const PhotosTodaySection({super.key, required this.controller});
  final ParentDashboardController controller;

  @override
  State<PhotosTodaySection> createState() => _PhotosTodaySectionState();
}

class _PhotosTodaySectionState extends State<PhotosTodaySection> {
  late final PageController _pageCtrl;
  Timer? _timer;
  StreamSubscription<dynamic>? _photosSub;
  int _current = 0;

  List<String> get _photos => widget.controller.todayPhotos.toList();

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    if (_photos.length > 1) _startAutoScroll();
    _photosSub = widget.controller.todayPhotos.listen((_) {
      if (!mounted) return;
      setState(() {});
      if (_photos.length > 1 && _timer == null) _startAutoScroll();
      if (_photos.length <= 1) { _timer?.cancel(); _timer = null; }
    });
  }

  @override
  void dispose() {
    _photosSub?.cancel();
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_current + 1) % _photos.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _openViewer(int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) =>
            DailyPhotoViewer(urls: _photos, initialIndex: index),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_photos.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayLight.withValues(alpha: 0.5),
            blurRadius: 10.r,
            offset: Offset(0.w, 3.h)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.photo_camera_rounded,
                    color: Color(0xFF2563EB),
                    size: 18.sp)),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'صور ${widget.controller.classroomName} اليوم',
                        style: context.typography.displaySmBold.copyWith(color: Color(0xFF1E293B), fontSize: 13),
                      ),
                      Text(
                        '${_photos.length} صورة',
                        style: context.typography.xsRegular.copyWith(color: AppColors.textSecondaryParagraph, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(
                    parentClassPhotosView,
                    arguments: {
                      'urls': _photos,
                      'classroomName': widget.controller.classroomName,
                    },
                  ),
                  child: Text(
                    'عرض الكل',
                    style: context.typography.smSemiBold.copyWith(color: AppColors.primary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          // Carousel
          ClipRRect(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
            child: SizedBox(
              height: 200.h,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageCtrl,
                    itemCount: _photos.length,
                    onPageChanged: (i) => setState(() => _current = i),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _openViewer(i),
                      child: AppNetworkImage(
                        url: _photos[i],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Gradient + dots
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 10.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_photos.length, (i) {
                          final active = i == _current;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: EdgeInsets.symmetric(horizontal: 3.w),
                            width: active ? 18 : 6,
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(3.r),
                            ));
                        }),
                      )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
