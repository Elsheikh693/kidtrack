import '../../../../../index/index_main.dart';
import 'eval_filter_row.dart';

class EvalFilterBarDelegate extends SliverPersistentHeaderDelegate {
  const EvalFilterBarDelegate({
    required this.searchCtrl,
    required this.ctrl,
  });

  final TextEditingController searchCtrl;
  final TeacherActivityController ctrl;

  @override
  double get maxExtent => 104;
  @override
  double get minExtent => 104;
  @override
  bool shouldRebuild(covariant EvalFilterBarDelegate old) => false;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: AppColors.backgroundNeutral100,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          children: [
            TextField(
              controller: searchCtrl,
              textDirection: appTextDirection,
              decoration: InputDecoration(
                hintText: 'teacher_activity_search_hint'.tr,
                hintStyle: context.typography.smRegular
                    .copyWith(color: Colors.grey.shade400),
                prefixIcon:
                    Icon(Icons.search_rounded, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.activityGreen, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              ctrl.evalFilter.value;
              ctrl.activeActivity.value;
              return EvalFilterRow(ctrl: ctrl);
            }),
          ],
        ),
      ),
    );
  }
}
