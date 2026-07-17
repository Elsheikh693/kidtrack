import '../../../../../index/index_main.dart';
import '../../more/widgets/manager_grid_tile.dart';

/// Entry point to the full children directory (ChildListView), surfaced on the
/// Children tab. A single tappable row inside the standard white section card —
/// same look the tile had on the More tab, before it was moved here.
class ChildrenDirectoryEntry extends StatelessWidget {
  const ChildrenDirectoryEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ManagerGridTile(
        icon: Icons.child_care_rounded,
        color: AppColors.activityGreen,
        labelKey: 'manager_children_directory_title',
        onTap: () => Get.toNamed(childrenView),
      ),
    );
  }
}
