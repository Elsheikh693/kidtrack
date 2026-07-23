import '../../../../index/index_main.dart';

/// A swipeable photo carousel used by "gallery" feed posts (e.g. event-photo
/// albums) instead of the collage grid — a PageView with a counter chip and
/// animated dot indicators. Shared by the manager and parent post cards.
class PostPhotoCarousel extends StatefulWidget {
  const PostPhotoCarousel({super.key, required this.urls, this.height = 240});

  final List<String> urls;
  final double height;

  @override
  State<PostPhotoCarousel> createState() => _PostPhotoCarouselState();
}

class _PostPhotoCarouselState extends State<PostPhotoCarousel> {
  final _ctrl = PageController();
  int _index = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final many = widget.urls.length > 1;
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => Image(
              image: appCachedImageProvider(widget.urls[i]),
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, prog) => prog == null
                  ? child
                  : Container(color: const Color(0xFFF3F4F6)),
              errorBuilder: (_, e, s) => Container(
                color: const Color(0xFFF3F4F6),
                child: const Center(
                  child: Icon(Icons.broken_image_rounded,
                      color: Color(0xFFD1D5DB)),
                ),
              ),
            ),
          ),
          if (many)
            PositionedDirectional(
              top: 10,
              end: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_index + 1}/${widget.urls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          if (many)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.urls.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
