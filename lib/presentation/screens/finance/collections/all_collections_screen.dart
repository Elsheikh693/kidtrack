import '../../../../index/index_main.dart';

/// Full "عرض الكل" list for the dashboard's current scope + month. Reads the
/// SAME controller (by [tag]) so it hits the already-downloaded cache — no
/// extra Firebase call — and rebuilds via the controller's [revision] counter.
class AllCollectionsScreen extends StatelessWidget {
  final String tag;
  const AllCollectionsScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FinanceDashboardController>(tag: tag);
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
          title: Text(
            '${'finance_all_collections_title'.tr} · ${controller.monthLabel}',
            style: context.typography.smSemiBold
                .copyWith(color: const Color(0xFF1E293B), fontSize: 15),
          ),
        ),
        body: Obx(() {
          controller.revision.value; // rebuild trigger
          final items = controller.allCollectionsForPeriod();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CategoryFilterBar(
                options: controller.categories.toList(),
                selectedId: controller.collectionCategoryFilter.value,
                accent: const Color(0xFF7C3AED),
                onChanged: controller.setCollectionCategoryFilter,
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'finance_dash_no_collections'.tr,
                          style: context.typography.smRegular
                              .copyWith(color: const Color(0xFF94A3B8)),
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => SizedBox(height: 10.h),
                        itemBuilder: (_, i) => CollectionTile(item: items[i]),
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
