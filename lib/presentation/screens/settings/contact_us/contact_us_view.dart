import '../../../../index/index_main.dart';

class ContactUsView extends StatefulWidget {
  const ContactUsView({super.key});

  @override
  State<ContactUsView> createState() => _ContactUsViewState();
}

class _ContactUsViewState extends State<ContactUsView> {
  late final ContactUsController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ContactUsController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
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
            text: 'settings_contact_us'.tr,
            textStyle:
                context.typography.mdBold.copyWith(color: AppColors.textDefault),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const _ContactShimmer();
          }
          final info = controller.info.value;
          if (info == null) {
            return _Empty(message: 'contact_empty'.tr);
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
            children: [
              _Header(info: info),
              SizedBox(height: 20.h),
              if (info.hasPhone)
                _ActionCard(
                  icon: Icons.call_rounded,
                  color: const Color(0xFF10B981),
                  title: 'contact_phone'.tr,
                  value: info.phone!,
                  onTap: () => controller.call(info.phone!),
                ),
              if (info.hasWhatsapp)
                _ActionCard(
                  icon: Icons.chat_rounded,
                  color: const Color(0xFF25D366),
                  title: 'contact_whatsapp'.tr,
                  value: info.whatsapp!,
                  onTap: () => controller.whatsapp(info.whatsapp!),
                ),
              if (info.hasEmail)
                _ActionCard(
                  icon: Icons.email_rounded,
                  color: const Color(0xFFEF4444),
                  title: 'contact_email'.tr,
                  value: info.email!,
                  onTap: () => controller.email(info.email!),
                ),
              if (info.hasAddress)
                _ActionCard(
                  icon: Icons.location_on_rounded,
                  color: const Color(0xFF6366F1),
                  title: 'contact_address'.tr,
                  value: info.address!,
                  onTap: info.hasLocation
                      ? () => controller.openMap(info.lat!, info.lng!)
                      : null,
                  trailing: info.hasLocation ? 'contact_open_map'.tr : null,
                ),
              if (info.hasWorkingHours)
                _ActionCard(
                  icon: Icons.access_time_rounded,
                  color: const Color(0xFFF59E0B),
                  title: 'contact_working_hours'.tr,
                  value: info.workingHours!,
                ),
              if (info.hasAnySocial) ...[
                SizedBox(height: 14.h),
                AppText(
                  text: 'contact_social'.tr,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: [
                    if (info.hasFacebook)
                      _SocialChip(
                        icon: Icons.facebook_rounded,
                        color: const Color(0xFF1877F2),
                        onTap: () => controller.openLink(info.facebook!),
                      ),
                    if (info.hasInstagram)
                      _SocialChip(
                        icon: Icons.camera_alt_rounded,
                        color: const Color(0xFFE4405F),
                        onTap: () => controller.openLink(info.instagram!),
                      ),
                    if (info.hasTiktok)
                      _SocialChip(
                        icon: Icons.music_note_rounded,
                        color: AppColors.textDefault,
                        onTap: () => controller.openLink(info.tiktok!),
                      ),
                    if (info.hasYoutube)
                      _SocialChip(
                        icon: Icons.play_circle_fill_rounded,
                        color: const Color(0xFFFF0000),
                        onTap: () => controller.openLink(info.youtube!),
                      ),
                    if (info.hasWebsite)
                      _SocialChip(
                        icon: Icons.language_rounded,
                        color: AppColors.primary,
                        onTap: () => controller.openLink(info.website!),
                      ),
                  ],
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ContactInfoModel info;
  const _Header({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 22.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primary, AppColors.primary80],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Icon(Icons.support_agent_rounded,
                size: 32.sp, color: AppColors.white),
          ),
          SizedBox(height: 12.h),
          AppText(
            text: 'contact_header_title'.tr,
            textStyle:
                context.typography.mdBold.copyWith(color: AppColors.white),
          ),
          SizedBox(height: 6.h),
          AppText(
            text: 'contact_header_sub'.tr,
            textStyle: context.typography.xsRegular.copyWith(
              color: AppColors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final VoidCallback? onTap;
  final String? trailing;

  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.grayLight),
          ),
          child: Row(
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
                      textStyle: context.typography.xsRegular
                          .copyWith(color: AppColors.textSecondaryParagraph),
                    ),
                    SizedBox(height: 3.h),
                    AppText(
                      text: value,
                      textStyle: context.typography.smSemiBold
                          .copyWith(color: AppColors.textDefault),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: AppText(
                    text: trailing!,
                    textStyle:
                        context.typography.xsBold.copyWith(color: color),
                  ),
                )
              else if (onTap != null)
                Icon(Icons.chevron_right_rounded,
                    size: 22.sp, color: AppColors.grayMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialChip(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Icon(icon, size: 26.sp, color: color),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String message;
  const _Empty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent_outlined,
              size: 56.sp, color: AppColors.grayMedium),
          SizedBox(height: 14.h),
          AppText(
            text: message,
            textStyle: context.typography.smRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}

class _ContactShimmer extends StatelessWidget {
  const _ContactShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Shimmer.fromColors(
          baseColor: AppColors.grayLight,
          highlightColor: AppColors.white,
          child: Container(
            height: 150.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22.r),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        ...List.generate(
          4,
          (_) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Shimmer.fromColors(
              baseColor: AppColors.grayLight,
              highlightColor: AppColors.white,
              child: Container(
                height: 72.h,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
