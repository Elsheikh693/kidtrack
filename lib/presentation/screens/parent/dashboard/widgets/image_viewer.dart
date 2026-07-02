import '../../../../../index/index_main.dart';

class DailyPhotoViewer extends StatefulWidget {
  const DailyPhotoViewer({
    super.key,
    required this.urls,
    this.initialIndex = 0,
  });

  final List<String> urls;
  final int initialIndex;

  @override
  State<DailyPhotoViewer> createState() => _DailyPhotoViewerState();
}

class _DailyPhotoViewerState extends State<DailyPhotoViewer> {
  late final PageController _ctrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Swipeable photos
          PageView.builder(
            controller: _ctrl,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Center(
                child: AppNetworkImage(
                  url: widget.urls[i],
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Counter chip
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${_current + 1} / ${widget.urls.length}',
                        style: context.typography.smSemiBold.copyWith(color: Colors.white, fontSize: 13),
                      )),
                    // Close button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20.sp)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
