import '../../../../../index/index_main.dart';
import '../teacher_home_controller.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.controller});

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
    final months = [
      'teacherhom35_month_1'.tr, 'teacherhom35_month_2'.tr,
      'teacherhom35_month_3'.tr, 'teacherhom35_month_4'.tr,
      'teacherhom35_month_5'.tr, 'teacherhom35_month_6'.tr,
      'teacherhom35_month_7'.tr, 'teacherhom35_month_8'.tr,
      'teacherhom35_month_9'.tr, 'teacherhom35_month_10'.tr,
      'teacherhom35_month_11'.tr, 'teacherhom35_month_12'.tr,
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _greeting,
              style: context.typography.lgBold
                  .copyWith(color: AppColors.activitySlate),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.activityGreen.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.activityGreen.withValues(alpha: 0.20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.activityGreen,
                  size: 13,
                ),
                const SizedBox(width: 5),
                Text(
                  _dateLabel,
                  style: context.typography.xsMedium
                      .copyWith(color: AppColors.activityGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
