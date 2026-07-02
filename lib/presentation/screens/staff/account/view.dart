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
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 32.h),
          physics: const BouncingScrollPhysics(),
          children: [
            _StaffHeader(controller: controller),
            SizedBox(height: 20.h),
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

// ─── Header ───────────────────────────────────────────────────────────────────

class _StaffHeader extends StatelessWidget {
  final StaffAccountController controller;

  const _StaffHeader({required this.controller});

  static const _grad1 = Color(0xFF6D5BF5);
  static const _grad2 = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_grad1, _grad2],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: _grad2.withValues(alpha: 0.32),
            blurRadius: 22.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circles for depth
          Positioned(
            top: -38,
            left: -28,
            child: _Bubble(size: 96, opacity: 0.10),
          ),
          Positioned(
            bottom: -34,
            left: 40,
            child: _Bubble(size: 64, opacity: 0.08),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.staffName,
                      style: context.typography.lgBold.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Text(
                        controller.roleLabel,
                        style: context.typography.displaySmBold.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (controller.staffPhone.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 15.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            controller.staffPhone,
                            style: context.typography.smMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 14.w),
              Container(
                width: 72.w,
                height: 72.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 2,
                  ),
                ),
                child: Icon(controller.roleIcon, color: Colors.white, size: 34.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
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
