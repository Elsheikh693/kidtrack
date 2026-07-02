import '../../../../../index/index_main.dart';
import '../controller.dart';
import 'section_header.dart';

class DashboardQuickActionsSection extends StatelessWidget {
  final ReceptionistDashboardController controller;
  const DashboardQuickActionsSection({super.key, required this.controller});

  static const _actions = [
    _Action(Icons.login_rounded,          'reception_action_checkin',  Color(0xFF0891B2), checkInView),
    _Action(Icons.child_care_rounded,     'reception_action_children', Color(0xFF16A34A), childrenView),
    _Action(Icons.family_restroom_rounded,'reception_action_parents',  Color(0xFFDC2626), guardianListView),
    _Action(Icons.directions_car_rounded, 'reception_action_pickup',   Color(0xFF7C3AED), pickupRequestsView),
    _Action(Icons.receipt_long_rounded,   'reception_action_finance',  Color(0xFFD97706), invoicesView),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: 'reception_quick_actions'.tr,
          accentColor: const Color(0xFF7C3AED),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _actions
              .map((a) => _ActionButton(action: a))
              .toList(),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final _Action action;
  const _ActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(action.route),
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 52.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  action.color,
                  action.color.withValues(alpha: 0.72),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: action.color.withValues(alpha: 0.32),
                  blurRadius: 10.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Icon(action.icon, color: Colors.white, size: 24.sp),
          ),
          SizedBox(height: 7.h),
          Text(
            action.labelKey.tr,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.typography.xsMedium.copyWith(
              color: const Color(0xFF334155),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Action {
  final IconData icon;
  final String labelKey;
  final Color color;
  final String route;
  const _Action(this.icon, this.labelKey, this.color, this.route);
}
