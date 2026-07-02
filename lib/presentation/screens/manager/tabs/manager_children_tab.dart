import '../../../../index/index_main.dart';
import '../widgets/manager_tab_header.dart';
import '../children/widgets/children_overview_section.dart';
import '../children/widgets/classroom_health_section.dart';
import '../children/widgets/child_directory_tile.dart';
import '../children/widgets/children_shimmer.dart';

class ManagerChildrenTab extends StatefulWidget {
  const ManagerChildrenTab({super.key});

  @override
  State<ManagerChildrenTab> createState() => _ManagerChildrenTabState();
}

class _ManagerChildrenTabState extends State<ManagerChildrenTab> {
  static const _accent = AppColors.activityGreen;

  late final ManagerChildrenController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ManagerChildrenController>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => ManagerTabHeader(
            title: 'manager_tab_children'.tr,
            accent: _accent,
            searchEnabled: true,
            searchActive: controller.searchActive.value,
            searchHint: 'manager_children_search_hint'.tr,
            onSearchToggle: controller.toggleSearch,
            onSearchChanged: controller.onSearch,
          ),
        ),
        Expanded(
          child: Obx(() {
            // Distinct keys per branch: swapping these subtrees without keys
            // lets Flutter try to reuse render objects across very different
            // trees, which leaves semantics parent-data dirty and trips the
            // framework's `!semantics.parentDataDirty` assertion.
            if (controller.isLoading.value) {
              return const ChildrenShimmer(key: ValueKey('children-loading'));
            }
            if (controller.searchActive.value) {
              return KeyedSubtree(
                key: const ValueKey('children-search'),
                child: _buildSearchResults(),
              );
            }
            return KeyedSubtree(
              key: const ValueKey('children-dashboard'),
              child: _buildDashboard(),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: controller.loadData,
      color: _accent,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ChildrenOverviewSection(controller: controller),
                const SizedBox(height: 24),
                ClassroomHealthSection(controller: controller),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      final items = controller.filteredDirectory;
      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded,
                  size: 40, color: AppColors.grayMedium),
              const SizedBox(height: 12),
              Text(
                'manager_children_directory_empty'.tr,
                style: context.typography.smRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final c = items[i];
          return ChildDirectoryTile(
            child: c,
            classroomName: controller.classroomName(c.classroomId),
            onTap: () => controller.openChild(c.key ?? ''),
          );
        },
      );
    });
  }
}
