import '../../../../../index/index_main.dart';

/// Edge-to-edge horizontal gallery. The list scrolls from screen edge to edge
/// while the first/last items stay inset by [sidePadding] so they line up with
/// the rest of the content.
class ProfileGallery extends StatelessWidget {
  final List<String> photos;
  final double sidePadding;
  const ProfileGallery({
    super.key,
    required this.photos,
    this.sidePadding = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: sidePadding.w),
        physics: const BouncingScrollPhysics(),
        itemCount: photos.length,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: AppNetworkImage(
            url: photos[i],
            width: 230.w,
            height: 168.h,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }
}
