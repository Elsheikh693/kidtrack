import 'package:cached_network_image/cached_network_image.dart';
import '../../index/index_main.dart';

class NetworkCachedImage extends StatelessWidget {
  const NetworkCachedImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.boxFit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  final String image;
  final double? width;
  final double? height;
  final BoxFit boxFit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      width: width,
      height: height,
      fit: boxFit,
      errorWidget: (_, _, _) =>
          errorWidget ??
          Container(
            width: width ?? 100,
            height: height ?? 100,
            color: Colors.grey[200],
            child: Icon(Icons.broken_image_outlined,
                color: Colors.grey, size: 24),
          ),
      placeholder: (_, _) =>
          placeholder ??
          SizedBox(
            width: width,
            height: height,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          ),
    );
  }
}
