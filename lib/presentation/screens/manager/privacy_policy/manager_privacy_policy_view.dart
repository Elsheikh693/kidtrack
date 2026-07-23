import '../../../../index/index_main.dart';
import '../profile/widgets/profile_terms_editor.dart';
import 'manager_privacy_policy_controller.dart';

/// Dedicated editor for the nursery privacy policy — a numbered, add-one-at-a-
/// time list (reusing [ProfileTermsEditor]) shown to guardians on first open.
/// Opened as an (optional) card from the setup checklist hub.
class ManagerPrivacyPolicyView extends StatefulWidget {
  const ManagerPrivacyPolicyView({super.key});

  @override
  State<ManagerPrivacyPolicyView> createState() =>
      _ManagerPrivacyPolicyViewState();
}

class _ManagerPrivacyPolicyViewState extends State<ManagerPrivacyPolicyView> {
  late final ManagerPrivacyPolicyController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ManagerPrivacyPolicyController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: HomeAppBar(
          title: 'manager_privacy_policy_section'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PrivacyIntro(),
                SizedBox(height: 16.h),
                ProfileTermsEditor(
                  hint: 'manager_privacy_policy_hint'.tr,
                  items: controller.privacyPolicy,
                  onAdd: controller.addClause,
                  onRemove: controller.removeClause,
                ),
                SizedBox(height: 24.h),
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
          );
        }),
      ),
    );
  }
}

class _PrivacyIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.privacy_tip_outlined,
              size: 20.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: AppText(
              text: 'manager_privacy_policy_note'.tr,
              textStyle: context.typography.xsRegular.copyWith(
                color: AppColors.textPrimaryParagraph,
                height: 1.6,
              ),
              maxLines: 4,
            ),
          ),
        ],
      ),
    );
  }
}
