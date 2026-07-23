import '../../../../index/index_main.dart';
import 'widgets/profile_age_fee_editor.dart';
import 'widgets/profile_cover_picker.dart';
import 'widgets/profile_gallery_editor.dart';
import 'widgets/profile_branches_editor.dart';
import 'widgets/profile_city_selector.dart';
import 'widgets/profile_tag_editor.dart';
import 'widgets/profile_visibility_toggle.dart';
import 'widgets/profile_working_days_editor.dart';

class ManagerNurseryProfileView extends StatefulWidget {
  const ManagerNurseryProfileView({super.key});

  @override
  State<ManagerNurseryProfileView> createState() =>
      _ManagerNurseryProfileViewState();
}

class _ManagerNurseryProfileViewState extends State<ManagerNurseryProfileView>
    with KeyboardSheetMixin {
  late final ManagerNurseryProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ManagerNurseryProfileController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: HomeAppBar(
          title: 'manager_profile_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return wrapWithKeyboard(
            context: context,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
              child: Column(
                children: [
              ProfileCoverPicker(controller: controller),
              SizedBox(height: 20.h),
              _section(
                context,
                'manager_profile_basic'.tr,
                AppTextField(
                  controller: controller.nameCtrl,
                  labelText: 'manager_profile_name'.tr,
                ),
              ),
              _section(
                context,
                'manager_profile_about'.tr,
                AppTextField(
                  controller: controller.descriptionCtrl,
                  hintText: 'manager_profile_about_hint'.tr,
                  maxLines: 4,
                ),
              ),
              _section(
                context,
                'manager_profile_age_section'.tr,
                ProfileAgeEditor(controller: controller),
              ),
              _section(
                context,
                'manager_profile_gallery'.tr,
                ProfileGalleryEditor(controller: controller),
              ),
              _section(
                context,
                'manager_profile_city'.tr,
                ProfileCitySelector(controller: controller),
              ),
              _section(
                context,
                'manager_profile_branches'.tr,
                ProfileBranchesEditor(controller: controller),
              ),
              _section(
                context,
                'managerass17_working_days'.tr,
                ProfileWorkingDaysEditor(controller: controller),
              ),
              _section(
                context,
                'manager_profile_programs'.tr,
                ProfileTagEditor(
                  hint: 'manager_profile_programs_hint'.tr,
                  items: controller.programs,
                  onAdd: controller.addProgram,
                  onRemove: controller.removeProgram,
                  color: AppColors.primary,
                ),
              ),
              _section(
                context,
                'manager_profile_activities'.tr,
                ProfileTagEditor(
                  hint: 'manager_profile_activities_hint'.tr,
                  items: controller.activities,
                  onAdd: controller.addActivity,
                  onRemove: controller.removeActivity,
                  color: AppColors.activityGreen,
                ),
              ),
              _section(
                context,
                'manager_profile_visibility'.tr,
                ProfileVisibilityToggle(controller: controller),
              ),
              SizedBox(height: 12.h),
              Obx(
                () => PrimaryTextButton(
                  label: AppText(
                    text: 'manager_profile_save'.tr,
                    textStyle: context.typography.smSemiBold
                        .copyWith(color: AppColors.white),
                  ),
                  appButtonSize: AppButtonSize.large,
                  onTap: controller.isSaving.value ? null : controller.save,
                ),
              ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: title,
            textStyle: context.typography.smSemiBold
                .copyWith(color: AppColors.textPrimaryParagraph),
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}
