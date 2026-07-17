import '../../../../index/index_main.dart';
import 'widgets/showcase_role_tabs.dart';
import 'widgets/showcase_shot_card.dart';

class SaShowcaseAlbumsView extends StatefulWidget {
  const SaShowcaseAlbumsView({super.key});

  @override
  State<SaShowcaseAlbumsView> createState() => _SaShowcaseAlbumsViewState();
}

class _SaShowcaseAlbumsViewState extends State<SaShowcaseAlbumsView> {
  late final SaShowcaseAlbumsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SaShowcaseAlbumsController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          leading: GestureDetector(
            onTap: Get.back,
            child: Icon(Icons.arrow_back_rounded,
                color: AppColors.textDefault, size: 22.sp),
          ),
          title: AppText(
            text: 'showcase_admin_title'.tr,
            textStyle: context.typography.mdBold
                .copyWith(color: AppColors.textDefault),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          onPressed: controller.pickAndAdd,
          icon: Icon(Icons.add_photo_alternate_rounded, color: AppColors.white),
          label: AppText(
            text: 'showcase_admin_add'.tr,
            textStyle:
                context.typography.smSemiBold.copyWith(color: AppColors.white),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 14.h),
            ShowcaseRoleTabs(controller: controller),
            SizedBox(height: 8.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                final shots = controller.shotsForSelected;
                if (shots.isEmpty) {
                  return Center(
                    child: AppText(
                      text: 'showcase_admin_empty'.tr,
                      textStyle: context.typography.smRegular
                          .copyWith(color: AppColors.textSecondaryParagraph),
                    ),
                  );
                }
                return ReorderableListView.builder(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 90.h),
                  itemCount: shots.length,
                  onReorder: controller.reorder,
                  itemBuilder: (_, i) => Padding(
                    key: ValueKey(shots[i].key),
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: ShowcaseShotCard(
                      shot: shots[i],
                      position: i,
                      onDelete: () => controller.delete(shots[i]),
                      onToggleActive: () => controller.toggleActive(shots[i]),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
