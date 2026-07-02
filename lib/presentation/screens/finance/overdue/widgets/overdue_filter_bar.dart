import '../../../../../index/index_main.dart';

class OverdueFilterBar extends StatelessWidget {
  final OverdueController controller;

  const OverdueFilterBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const filters = <ObligationStatus?>[
      null,
      ObligationStatus.overdue,
      ObligationStatus.upcoming,
      ObligationStatus.paid,
    ];

    return SizedBox(
      height: 48.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final f = filters[i];
          return Obx(() {
            final active = controller.selectedFilter.value == f;
            return GestureDetector(
              onTap: () => controller.setFilter(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(left: 8.w),
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: active ? AppColors.primary : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  _label(f),
                  style: context.typography.xsMedium.copyWith(
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

  String _label(ObligationStatus? f) {
    switch (f) {
      case ObligationStatus.overdue:
        return 'overdue_filter_overdue'.tr;
      case ObligationStatus.upcoming:
        return 'overdue_filter_upcoming'.tr;
      case ObligationStatus.paid:
        return 'overdue_filter_paid'.tr;
      case null:
        return 'overdue_filter_all'.tr;
    }
  }
}
