import '../../../../index/index_main.dart';
import '../../../screens/shared/edit_profile_sheet.dart';
import 'controller.dart';

class StaffAccountView extends StatefulWidget {
  const StaffAccountView({super.key});

  @override
  State<StaffAccountView> createState() => _StaffAccountViewState();
}

class _StaffAccountViewState extends State<StaffAccountView> {
  late final StaffAccountController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => StaffAccountController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundNeutral100,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 76.h,
          titleSpacing: 0,
          title: _ProfileTitle(controller: controller),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
          physics: const BouncingScrollPhysics(),
          children: [
            _Section(
              titleKey: 'staff_account_section_profile',
              items: [
                _MenuItem(
                  labelKey: 'staff_account_edit_profile',
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.primary,
                  onTap: () => showEditProfileSheet(isStaff: true),
                ),
              ],
            ),
            if (controller.isTeacher)
              _Section(
                titleKey: 'teacher_account_classroom_section',
                items: [
                  _MenuItem(
                    labelKey: 'teacher_academic_settings_menu_item',
                    icon: Icons.school_rounded,
                    iconColor: const Color(0xFF16A34A),
                    onTap: () => Get.toNamed(teacherAcademicSettingsView),
                  ),
                ],
              ),
            // Evaluation reasons & child-state templates are teacher-only
            // classroom tools — managers/receptionists don't need them.
            if (controller.isTeacher)
              _Section(
                titleKey: 'staff_account_section_settings',
                items: [
                  _MenuItem(
                    labelKey: 'eval_reasons_screen_title',
                    icon: Icons.fact_check_rounded,
                    iconColor: AppColors.activityPurple,
                    onTap: () => Get.toNamed(evaluationReasonsView),
                  ),
                  _MenuItem(
                    labelKey: 'child_state_templates_menu_item',
                    icon: Icons.emoji_emotions_rounded,
                    iconColor: const Color(0xFF0891B2),
                    onTap: () => Get.toNamed(childStatesView),
                  ),
                ],
              ),
            if (!controller.isOwner)
              _Section(
                titleKey: 'staff_account_section_support',
                items: [
                  _MenuItem(
                    labelKey: 'staff_account_contact_support',
                    icon: Icons.support_agent_rounded,
                    iconColor: AppColors.blueForeground,
                    onTap: () => showContactSheet(ContactType.support),
                  ),
                ],
              ),
            _Section(
              titleKey: 'staff_account_title',
              items: [
                _MenuItem(
                  labelKey: 'staff_account_logout',
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.errorForeground,
                  onTap: controller.logout,
                  isDestructive: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App bar title (name · role · phone) ───────────────────────────────────────

class _ProfileTitle extends StatelessWidget {
  const _ProfileTitle({required this.controller});

  final StaffAccountController controller;

  @override
  Widget build(BuildContext context) {
    final phone = controller.staffPhone;
    return Row(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(controller.roleIcon, color: AppColors.primary, size: 22.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.staffName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.mdBold
                    .copyWith(color: AppColors.textDefault),
              ),
              SizedBox(height: 2.h),
              Text(
                phone.isNotEmpty
                    ? '${controller.roleLabel} · $phone'
                    : controller.roleLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.xsRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Section ──────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String titleKey;
  final List<_MenuItem> items;

  const _Section({required this.titleKey, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 10.h),
            child: Text(
              titleKey.tr,
              style: context.typography.lgBold.copyWith(
                color: AppColors.textSecondaryParagraph,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grayLight.withValues(alpha: 0.45),
                  blurRadius: 10.r,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  items[i],
                  if (i != items.length - 1)
                    Padding(
                      padding: EdgeInsets.only(right: 60.w),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.borderNeutralPrimary.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Menu item ────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final String labelKey;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.labelKey,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isDestructive
        ? AppColors.errorForeground
        : AppColors.textDefault;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.errorBackground
                      : iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? AppColors.errorForeground : iconColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  labelKey.tr,
                  style: context.typography.smSemiBold.copyWith(color: fg),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22.sp,
                color: isDestructive
                    ? AppColors.errorForeground.withValues(alpha: 0.6)
                    : AppColors.grayMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
