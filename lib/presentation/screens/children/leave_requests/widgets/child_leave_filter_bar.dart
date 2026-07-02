import '../../../../../index/index_main.dart';

class ChildLeaveFilterBar extends StatelessWidget {
  final ChildLeaveRequestController controller;
  const ChildLeaveFilterBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const statuses = ['pending', 'approved', 'rejected'];
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: statuses.length,
        itemBuilder: (_, i) {
          final s = statuses[i];
          return Obx(() {
            final active = controller.selectedStatus.value == s;
            return GestureDetector(
              onTap: () => controller.setStatus(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? AppColors.primary : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  'child_leave_status_$s'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: active ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
