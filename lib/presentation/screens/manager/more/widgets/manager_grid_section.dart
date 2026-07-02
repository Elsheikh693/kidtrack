import '../../../../../index/index_main.dart';
import 'manager_grid_tile.dart';

/// A titled white card that arranges its [tiles] in a fixed three-column grid,
/// keeping every group compact and scannable instead of a long row list.
class ManagerGridSection extends StatelessWidget {
  const ManagerGridSection({
    super.key,
    required this.titleKey,
    required this.tiles,
  });

  final String titleKey;
  final List<ManagerGridTile> tiles;

  static const _columns = 3;

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
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = constraints.maxWidth / _columns;
              return Wrap(
                children: [
                  for (final tile in tiles)
                    SizedBox(width: cellWidth, child: tile),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
