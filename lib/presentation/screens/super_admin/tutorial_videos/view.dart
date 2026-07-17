import '../../../../index/index_main.dart';
import 'widgets/tutorial_admin_card.dart';

class SaTutorialVideosView extends StatefulWidget {
  const SaTutorialVideosView({super.key});

  @override
  State<SaTutorialVideosView> createState() => _SaTutorialVideosViewState();
}

class _SaTutorialVideosViewState extends State<SaTutorialVideosView> {
  late final SaTutorialVideosController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SaTutorialVideosController>();
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
            text: 'tutorial_admin_title'.tr,
            textStyle: context.typography.mdBold
                .copyWith(color: AppColors.textDefault),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          onPressed: controller.openAdd,
          icon: Icon(Icons.add_rounded, color: AppColors.white),
          label: AppText(
            text: 'tutorial_admin_add'.tr,
            textStyle:
                context.typography.smSemiBold.copyWith(color: AppColors.white),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (controller.items.isEmpty) {
            return Center(
              child: AppText(
                text: 'tutorial_admin_empty'.tr,
                textStyle: context.typography.smRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 90.h),
            itemCount: controller.items.length,
            separatorBuilder: (_, _) => SizedBox(height: 14.h),
            itemBuilder: (_, i) => TutorialAdminCard(
              video: controller.items[i],
              onEdit: () => controller.openEdit(controller.items[i]),
              onDelete: () => controller.delete(controller.items[i]),
            ),
          );
        }),
      ),
    );
  }
}
