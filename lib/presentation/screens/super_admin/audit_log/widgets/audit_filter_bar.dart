import '../../../../../index/index_main.dart';

class AuditFilterBar extends StatelessWidget {
  final AuditLogController controller;
  const AuditFilterBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const actions = ['create', 'update', 'delete'];
    return SizedBox(
      height: 48.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: actions.length,
        itemBuilder: (_, i) {
          final a = actions[i];
          return Obx(() {
            final active = controller.selectedAction.value == a;
            return GestureDetector(
              onTap: () => controller.setAction(a),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(left: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: active ? AppColors.primary : const Color(0xFFE2E8F0)),
                ),
                child: Text('audit_action_$a'.tr, style: context.typography.xsMedium.copyWith(fontSize: 13, color: active ? Colors.white : const Color(0xFF475569))),
              ),
            );
          });
        },
      ),
    );
  }
}
