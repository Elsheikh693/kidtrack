import '../../../../../index/index_main.dart';
import '../../../manager/star_of_week/reveal/star_reveal_view.dart';
import '../controller.dart';

/// Headlines the parent feed with this week's Star of the Week. Tapping it
/// replays the same celebratory reveal the manager saw when picking.
class StarOfWeekHighlight extends StatelessWidget {
  const StarOfWeekHighlight({super.key, required this.controller});

  final ParentFeedController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final star = controller.starOfWeek.value;
      if (star == null) return const SizedBox.shrink();
      return GestureDetector(
        onTap: () => showStarReveal(star),
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 4, 14, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4527A0), Color(0xFF7E5BEF)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4527A0).withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5C542),
                      shape: BoxShape.circle,
                    ),
                    child: ChildAvatar(
                      name: star.childName,
                      imageUrl: star.childPhotoUrl,
                      size: 58,
                    ),
                  ),
                  const Positioned(
                    top: -9,
                    child: Icon(Icons.emoji_events_rounded,
                        color: Color(0xFFF5C542), size: 19),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Color(0xFFF5C542), size: 15),
                        const SizedBox(width: 5),
                        AppText(
                          text: 'sotw_title'.tr,
                          textStyle: context.typography.xsMedium
                              .copyWith(color: const Color(0xFFF5C542)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    AppText(
                      text: star.childName,
                      textStyle: context.typography.mdBold
                          .copyWith(color: AppColors.white),
                    ),
                    if (star.caption.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      AppText(
                        text: star.caption,
                        maxLines: 2,
                        textStyle: context.typography.xsRegular.copyWith(
                          color: AppColors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.play_circle_fill_rounded,
                  color: AppColors.white.withValues(alpha: 0.9), size: 30),
            ],
          ),
        ),
      );
    });
  }
}
