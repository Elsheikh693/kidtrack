import '../../../../../../index/index_main.dart';

/// Filter chips for the teacher's day: one scrollable row to narrow by class,
/// another by subject. Each row only appears when there is something to choose
/// between (more than one option), so a single-class day stays uncluttered.
class TtFilterBar extends StatelessWidget {
  const TtFilterBar({super.key, required this.controller});

  final TeacherTodayController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final classes = controller.classOptions;
      final subjects = controller.subjectOptions;
      final rows = <Widget>[];

      if (classes.length > 1) {
        rows.add(_row(
          context,
          label: 'live_teaching_filter_class'.tr,
          chips: [
            _Chip(
              label: 'live_teaching_filter_all'.tr,
              selected: controller.classFilter.value == null,
              onTap: () => controller.selectClass(null),
            ),
            for (final c in classes)
              _Chip(
                label: c.value,
                selected: controller.classFilter.value == c.key,
                onTap: () => controller.selectClass(c.key),
              ),
          ],
        ));
      }

      if (subjects.length > 1) {
        if (rows.isNotEmpty) rows.add(SizedBox(height: 10.h));
        rows.add(_row(
          context,
          label: 'live_teaching_filter_subject'.tr,
          chips: [
            _Chip(
              label: 'live_teaching_filter_all'.tr,
              selected: controller.subjectFilter.value == null,
              onTap: () => controller.selectSubject(null),
            ),
            for (final s in subjects)
              _Chip(
                label: s,
                selected: controller.subjectFilter.value == s,
                onTap: () => controller.selectSubject(s),
              ),
          ],
        ));
      }

      if (rows.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        ),
      );
    });
  }

  Widget _row(
    BuildContext context, {
    required String label,
    required List<Widget> chips,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.typography.xsMedium
              .copyWith(color: AppColors.textSecondaryParagraph),
        ),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: chips),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(left: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.textDefault : AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.textDefault : AppColors.chartTrack,
          ),
        ),
        child: Text(
          label,
          style: context.typography.xsMedium.copyWith(
            color: selected ? AppColors.white : AppColors.textDefault,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
