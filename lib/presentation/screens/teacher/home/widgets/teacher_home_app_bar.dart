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

  String get _initial {
    final name = controller.teacherName.trim();
    return name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
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
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Get.to(() => const StaffAccountView()),
            child: _Avatar(initial: _initial),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.lgBold.copyWith(
                    color: AppColors.activitySlate,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                _DatePill(label: _dateLabel),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _BellButton(onTap: () => Get.toNamed(notificationsView)),
        const SizedBox(width: 10),
        _SettingsButton(onTap: () => Get.to(() => const StaffAccountView())),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.activityGreenAccent, AppColors.activityGreen],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.activityGreen.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: context.typography.lgBold.copyWith(color: AppColors.white),
      ),
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
        color: AppColors.activityGreenLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 11,
            color: AppColors.activityGreen,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: context.typography.xsMedium.copyWith(
              color: AppColors.activityGreenDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.activityGreenLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.activityGreen.withValues(alpha: 0.12),
          ),
        ),
        child: const Icon(
          Icons.notifications_outlined,
          size: 21,
          color: AppColors.activityGreen,
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.activityGreenLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.activityGreen.withValues(alpha: 0.12),
          ),
        ),
        child: const Icon(
          Icons.settings_outlined,
          size: 21,
          color: AppColors.activityGreen,
        ),
      ),
    );
  }
}
