import '../../../../../index/index_main.dart';
import '../teacher_activity_controller.dart';
import 'eval_filter_chip.dart';

class EvalFilterRow extends StatelessWidget {
  const EvalFilterRow({super.key, required this.ctrl});
  final TeacherActivityController ctrl;

  int _countFor(EvalFilter f) {
    final activity = ctrl.activeActivity.value;
    if (activity == null) return 0;
    switch (f) {
      case EvalFilter.unevaluated:
        return ctrl.children
            .where((c) => activity.evalFor(c.key ?? '') == null)
            .length;
      case EvalFilter.excellent:
        return activity.evaluations.values
            .where((v) => v == 'excellent')
            .length;
      case EvalFilter.needsFollow:
        return activity.evaluations.values
            .where((v) => v == 'needs_follow')
            .length;
      case EvalFilter.needsAttention:
        return activity.evaluations.values
            .where((v) => v == 'needs_attention')
            .length;
      case EvalFilter.all:
        return ctrl.children.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = ctrl.evalFilter.value;
    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        children: [
          EvalFilterChip(
            label: 'teacher_eval_all'.tr,
            count: _countFor(EvalFilter.all),
            color: Colors.grey.shade600,
            isSelected: current == EvalFilter.all,
            onTap: () => ctrl.evalFilter.value = EvalFilter.all,
          ),
          const SizedBox(width: 6),
          EvalFilterChip(
            label: 'teacher_eval_unevaluated'.tr,
            count: _countFor(EvalFilter.unevaluated),
            color: Colors.grey.shade600,
            isSelected: current == EvalFilter.unevaluated,
            onTap: () => ctrl.evalFilter.value = EvalFilter.unevaluated,
          ),
          const SizedBox(width: 6),
          EvalFilterChip(
            label: 'teacher_eval_excellent'.tr,
            count: _countFor(EvalFilter.excellent),
            color: AppColors.activityGreen,
            isSelected: current == EvalFilter.excellent,
            onTap: () => ctrl.evalFilter.value = EvalFilter.excellent,
          ),
          const SizedBox(width: 6),
          EvalFilterChip(
            label: 'teacher_eval_follow_short'.tr,
            count: _countFor(EvalFilter.needsFollow),
            color: AppColors.activityAmber,
            isSelected: current == EvalFilter.needsFollow,
            onTap: () => ctrl.evalFilter.value = EvalFilter.needsFollow,
          ),
          const SizedBox(width: 6),
          EvalFilterChip(
            label: 'teacher_eval_attention_short'.tr,
            count: _countFor(EvalFilter.needsAttention),
            color: AppColors.activityRed,
            isSelected: current == EvalFilter.needsAttention,
            onTap: () => ctrl.evalFilter.value = EvalFilter.needsAttention,
          ),
        ],
      ),
    );
  }
}
