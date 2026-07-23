import '../../../../../index/index_main.dart';
import 'nursery_staff_card.dart';

/// SuperAdmin roster block: the nursery's children count + the full employee
/// list (each with role + activation code). Assembled here so the view stays a
/// thin composition layer.
class NurseryRosterSection extends StatelessWidget {
  final NurseryDetailsController controller;
  const NurseryRosterSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _childrenStat(context),
        SizedBox(height: 20.h),
        Text(
          'nursery_staff_section'.tr,
          style: context.typography.displaySmBold.copyWith(
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 10.h),
        _staffList(context),
      ],
    );
  }

  Widget _childrenStat(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14.r),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.child_care_rounded,
                color: Color(0xFF3B82F6)),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              'nursery_children_count_label'.tr,
              style: context.typography.smMedium.copyWith(
                color: const Color(0xFF475569),
              ),
            ),
          ),
          Obx(
            () => controller.loadingChildren.value
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    '${controller.childrenCount.value}',
                    style: context.typography.xxlBold.copyWith(
                      color: const Color(0xFF1E293B),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _staffList(BuildContext context) {
    return Obx(() {
      if (controller.loadingStaff.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.staff.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 28.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            'nursery_staff_empty'.tr,
            style: context.typography.smRegular.copyWith(
              color: const Color(0xFF94A3B8),
            ),
          ),
        );
      }
      return Column(
        children: controller.staff
            .map(
              (s) => NurseryStaffCard(
                staff: s,
                code: controller.codeFor(s),
                onShowCode: () => controller.showStaffActivation(s),
                onSendWhatsApp: () => controller.sendStaffActivationWhatsApp(s),
              ),
            )
            .toList(),
      );
    });
  }
}
