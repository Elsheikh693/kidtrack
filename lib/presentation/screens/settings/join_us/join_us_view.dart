import '../../../../index/index_main.dart';

class JoinUsView extends StatefulWidget {
  const JoinUsView({super.key});

  @override
  State<JoinUsView> createState() => _JoinUsViewState();
}

class _JoinUsViewState extends State<JoinUsView> {
  late final JoinUsController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => JoinUsController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    surfaceTintColor: Colors.transparent,
                    automaticallyImplyLeading: false,
                    leadingWidth: 60.w,
                    leading: Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: GestureDetector(
                        onTap: Get.back,
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(Icons.arrow_back_rounded,
                              size: 20.sp, color: AppColors.white),
                        ),
                      ),
                    ),
                    centerTitle: false,
                    title: AppText(
                      text: 'join_hero_title'.tr,
                      textDirection: appTextDirection,
                      textAlign: TextAlign.right,
                      textStyle: context.typography.mdBold.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FreeBadge(),
                          SizedBox(height: 18.h),
                          _SectionTitle(text: 'join_about_title'.tr),
                          SizedBox(height: 8.h),
                          AppText(
                            text: 'join_about_body'.tr,
                            maxLines: 1000,
                            textStyle: context.typography.smRegular.copyWith(
                              color: AppColors.textSecondaryParagraph,
                              height: 1.7,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          _SectionTitle(text: 'join_system_title'.tr),
                          SizedBox(height: 6.h),
                          AppText(
                            text: 'join_system_sub'.tr,
                            maxLines: 1000,
                            textStyle: context.typography.xsRegular.copyWith(
                              color: AppColors.textSecondaryParagraph,
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          _RoleCard(
                            icon: Icons.workspace_premium_rounded,
                            color: const Color(0xFF6366F1),
                            title: 'join_role_owner'.tr,
                            desc: 'join_role_owner_desc'.tr,
                          ),
                          _RoleCard(
                            icon: Icons.admin_panel_settings_rounded,
                            color: const Color(0xFF0EA5E9),
                            title: 'join_role_manager'.tr,
                            desc: 'join_role_manager_desc'.tr,
                          ),
                          _RoleCard(
                            icon: Icons.support_agent_rounded,
                            color: const Color(0xFFF59E0B),
                            title: 'join_role_reception'.tr,
                            desc: 'join_role_reception_desc'.tr,
                          ),
                          _RoleCard(
                            icon: Icons.menu_book_rounded,
                            color: const Color(0xFF10B981),
                            title: 'join_role_teacher'.tr,
                            desc: 'join_role_teacher_desc'.tr,
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _CtaBar(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _FreeBadge extends StatelessWidget {
  const _FreeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(Icons.verified_rounded, size: 24.sp, color: AppColors.white),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'join_free_title'.tr,
                  textStyle: context.typography.mdBold
                      .copyWith(color: const Color(0xFF047857)),
                ),
                SizedBox(height: 3.h),
                AppText(
                  text: 'join_free_sub'.tr,
                  textStyle: context.typography.xsRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 8.w),
        AppText(
          text: text,
          textStyle: context.typography.mdBold
              .copyWith(color: AppColors.textDefault),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const _RoleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 22.sp, color: color),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
                SizedBox(height: 4.h),
                AppText(
                  text: desc,
                  textStyle: context.typography.xsRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                    height: 1.5,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaBar extends StatelessWidget {
  final JoinUsController controller;
  const _CtaBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _CtaButton(
              icon: Icons.chat_rounded,
              label: 'join_cta_whatsapp'.tr,
              background: const Color(0xFF25D366),
              onTap: controller.whatsapp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _CtaButton(
              icon: Icons.call_rounded,
              label: 'join_cta_call'.tr,
              background: AppColors.primary,
              onTap: controller.call,
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final VoidCallback onTap;

  const _CtaButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.sp, color: AppColors.white),
            SizedBox(width: 8.w),
            AppText(
              text: label,
              textStyle: context.typography.smSemiBold
                  .copyWith(color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
