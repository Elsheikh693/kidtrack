import '../../../../index/index_main.dart';
import 'widgets/permission_section.dart';

class StaffPermissionsView extends StatefulWidget {
  const StaffPermissionsView({super.key});

  @override
  State<StaffPermissionsView> createState() => _StaffPermissionsViewState();
}

class _StaffPermissionsViewState extends State<StaffPermissionsView> {
  late final StaffPermissionsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<StaffPermissionsController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textDefault),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: 'perm_title'.tr,
                textStyle: context.typography.lgBold.copyWith(
                  color: AppColors.textDefault,
                ),
              ),
              AppText(
                text: controller.staff.name,
                textStyle: context.typography.xsRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: TextButton(
                onPressed: controller.save,
                child: AppText(
                  text: 'perm_save'.tr,
                  textStyle: context.typography.smSemiBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final grouped = PermissionLabels.grouped(PermissionKeys.all);
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 40.h),
            itemCount: grouped.length,
            itemBuilder: (_, i) => PermissionSection(
              keys: grouped.values.elementAt(i),
              permissions: controller.permissions,
              onToggle: controller.toggle,
            ),
          );
        }),
      ),
    );
  }
}
