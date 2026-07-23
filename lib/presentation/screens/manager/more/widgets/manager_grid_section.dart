import '../../../../../index/index_main.dart';
import 'manager_grid_tile.dart';

/// A titled white card that stacks its [tiles] as full-width list rows with
/// hairline dividers between them — clean and filled even when a group only has
/// one or two items.
class ManagerGridSection extends StatelessWidget {
  const ManagerGridSection({
    super.key,
    required this.titleKey,
    required this.tiles,
  });

  final String titleKey;
  final List<ManagerGridTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 10.h),
          child: Text(
            titleKey.tr,
            style: context.typography.xsMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.grayLight.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                tiles[i],
                if (i != tiles.length - 1)
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 66.w),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.grayLight.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
