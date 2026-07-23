import '../../../../../../index/index_main.dart';

/// A celebratory, branded, shareable image of the Star of the Week — nursery
/// logo on top, the child's photo in a gold ring, their name and the caption,
/// and the KidTrack wordmark in the footer. Rendered off-screen and captured.
class StarShareCard extends StatelessWidget {
  final String childName;
  final String? childPhotoUrl;
  final String caption;
  final String nurseryName;
  final String? nurseryLogo;

  const StarShareCard({
    super.key,
    required this.childName,
    required this.childPhotoUrl,
    required this.caption,
    required this.nurseryName,
    required this.nurseryLogo,
  });

  static const _gold = Color(0xFFF5C542);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4C2A85), Color(0xFF2A1657)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _nurseryHeader(context),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, color: _gold, size: 22),
                    const SizedBox(width: 6),
                    Text('star_share_title'.tr,
                        style: context.typography.mdBold
                            .copyWith(color: const Color(0xFF7C3AED))),
                    const SizedBox(width: 6),
                    const Icon(Icons.star_rounded, color: _gold, size: 22),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [_gold, Color(0xFFFFE9A8)],
                    ),
                  ),
                  child: ChildAvatar(
                    name: childName,
                    imageUrl: childPhotoUrl,
                    size: 116,
                    color: const Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(height: 16),
                Text(childName,
                    textAlign: TextAlign.center,
                    style: context.typography.xlBold
                        .copyWith(color: const Color(0xFF1E293B))),
                if (caption.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(caption.trim(),
                      textAlign: TextAlign.center,
                      style: context.typography.smRegular.copyWith(
                          color: const Color(0xFF64748B), height: 1.5)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _appFooter(context),
        ],
      ),
    );
  }

  Widget _nurseryHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: (nurseryLogo != null && nurseryLogo!.isNotEmpty)
              ? AppNetworkImage(
                  url: nurseryLogo,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorWidget: const Icon(Icons.child_care_rounded,
                      color: Color(0xFF7C3AED)),
                )
              : const Icon(Icons.child_care_rounded, color: Color(0xFF7C3AED)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            nurseryName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _appFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset('assets/images/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.child_care_rounded,
                  size: 15, color: Color(0xFF7C3AED))),
        ),
        const SizedBox(width: 8),
        Text('assessment_share_via_app'.tr,
            style: context.typography.xsMedium.copyWith(color: Colors.white)),
      ],
    );
  }
}
