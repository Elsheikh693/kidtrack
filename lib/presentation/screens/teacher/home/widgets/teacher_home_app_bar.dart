import '../../../../../index/index_main.dart';

class TeacherHomeAppBar extends StatelessWidget {
  const TeacherHomeAppBar({super.key, required this.controller});

  final TeacherHomeController controller;

  String get _greeting {
    final h = DateTime.now().hour;
    final name = controller.teacherName.isNotEmpty
        ? controller.teacherName.split(' ').first
        : '';
    final prefix = h < 12
        ? 'home_greeting_morning'.tr
        : h < 17
            ? 'home_greeting_afternoon'.tr
            : 'home_greeting_evening'.tr;
    return name.isNotEmpty ? '$prefix، $name' : prefix;
  }

  String get _dateLabel {
    final now = DateTime.now();
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    const days = [
      'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس',
      'الجمعة', 'السبت', 'الأحد',
    ];
    final dayName = days[now.weekday - 1];
    return '$dayName، ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 72,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _greeting,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.smSemiBold.copyWith(
              color: AppColors.activitySlate,
            ),
          ),
          const SizedBox(height: 5),
          _DatePill(label: _dateLabel),
        ],
      ),
      actions: [
        Obx(
          () => _CircleButton(
            icon: Icons.notifications_outlined,
            showDot: controller.hasUnreadNotifications,
            onTap: () => Get.toNamed(notificationsView),
          ),
        ),
        const SizedBox(width: 10),
        _CircleButton(
          icon: Icons.settings_outlined,
          onTap: () => Get.to(() => const StaffAccountView()),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.activityPurpleLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 11,
            color: AppColors.activityPurple,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: context.typography.xsMedium.copyWith(
              color: AppColors.activityPurple,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 46,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.activityPurpleLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.activityPurple),
            ),
            if (showDot)
              Positioned(
                right: 1,
                top: 1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: AppColors.activityRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
