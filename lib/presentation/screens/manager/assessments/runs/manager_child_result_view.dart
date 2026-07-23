import '../../../../../index/index_main.dart';
import '../../../shared/assessment/assessment_result_breakdown.dart';
import 'widgets/unlock_reason_sheet.dart';
import 'widgets/retake_schedule_sheet.dart';
import 'widgets/attempt_switcher.dart';

/// Read-only view of one child's attempt(s), with the manager's workflow actions
/// (publish / lock / unlock / schedule-retake) and — after a retake — an attempt
/// switcher to view each try and mark which one is official.
class ManagerChildResultView extends StatefulWidget {
  final String childId;
  const ManagerChildResultView({super.key, required this.childId});

  @override
  State<ManagerChildResultView> createState() => _ManagerChildResultViewState();
}

class _ManagerChildResultViewState extends State<ManagerChildResultView> {
  late final ManagerRunDetailController controller;

  /// Attempt number currently displayed; null → follow the official attempt.
  int? _viewedNo;

  static const _accent = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    controller = Get.find<ManagerRunDetailController>();
  }

  ChildAssessmentModel? get _row =>
      controller.rows.firstWhereOrNull((r) => r.childId == widget.childId);

  AssessmentAttempt? _viewedAttempt(ChildAssessmentModel row) {
    if (_viewedNo == null) return row.officialAttempt;
    return row.attempts.firstWhereOrNull((a) => a.attemptNo == _viewedNo) ??
        row.officialAttempt;
  }

  void _scheduleRetake(ChildAssessmentModel row) {
    final run = controller.run.value;
    if (run == null) return;
    Get.bottomSheet(
      RetakeScheduleSheet(
        items: run.items,
        teachers: controller.teachers.toList(),
        onConfirm: ({
          required int date,
          required List<String> itemIds,
          String? teacherId,
          required bool notifyParent,
        }) {
          Get.back();
          controller.scheduleRetake(
            row,
            date: date,
            itemIds: itemIds,
            teacherId: teacherId,
            notifyParent: notifyParent,
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _unlock(ChildAssessmentModel row) {
    Get.bottomSheet(
      UnlockReasonSheet(
        onConfirm: (reason) {
          Get.back();
          controller.unlockChild(row, reason);
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = controller.childName(widget.childId);
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: name.isEmpty ? 'assessment_grade_title'.tr : name,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Obx(() {
          final row = _row;
          final run = controller.run.value;
          if (row == null || run == null) return const SizedBox.shrink();
          final attempt = _viewedAttempt(row);
          if (attempt == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_note_rounded,
                        size: 40, color: _accent),
                  ),
                  const SizedBox(height: 14),
                  Text('assessment_child_in_progress'.tr,
                      style: context.typography.mdRegular
                          .copyWith(color: const Color(0xFF94A3B8))),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              if (row.attempts.length > 1) ...[
                AttemptSwitcher(
                  attempts: row.attempts,
                  viewedNo: _viewedNo ?? row.officialAttemptNo,
                  officialNo: row.officialAttemptNo,
                  onSelect: (no) => setState(() => _viewedNo = no),
                  onMakeOfficial: (no) =>
                      controller.setOfficialAttempt(row, no),
                ),
                const SizedBox(height: 16),
              ],
              AssessmentResultBreakdown(
                attempt: attempt,
                scale: run.scale,
                items: run.items,
                accent: _accent,
              ),
            ],
          );
        }),
        bottomNavigationBar: Obx(() {
          final row = _row;
          if (row == null) return const SizedBox.shrink();
          // Not graded yet → offer the manager a direct "grade" action.
          if (row.officialAttempt == null) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: _button(
                      context,
                      'assessment_action_grade'.tr,
                      Icons.edit_rounded,
                      _accent,
                      () => controller.openGradeChild(widget.childId)),
                ),
              ),
            );
          }
          return _actionBar(context, row);
        }),
      ),
    );
  }

  Widget _actionBar(BuildContext context, ChildAssessmentModel row) {
    final buttons = <Widget>[];

    switch (row.status) {
      case kChildStatusPublished:
        buttons.add(_button(context, 'assessment_action_lock'.tr,
            Icons.lock_outline_rounded, const Color(0xFF6366F1),
            () => controller.lockChild(row)));
        break;
      case kChildStatusLocked:
        buttons.add(_button(context, 'assessment_action_unlock'.tr,
            Icons.lock_open_rounded, const Color(0xFF64748B),
            () => _unlock(row)));
        break;
      default:
        buttons.add(_button(context, 'assessment_action_publish'.tr,
            Icons.publish_rounded, const Color(0xFF16A34A),
            () => controller.publishChild(row)));
        // Before publishing, the manager can still fix the grades.
        buttons.add(const SizedBox(height: 10));
        buttons.add(_outlined(context, 'assessment_action_edit_grades'.tr,
            Icons.edit_rounded, _accent,
            () => controller.openGradeChild(row.childId)));
    }

    // Retake can be scheduled once a result exists and is parent-visible.
    if (row.isVisibleToParent && !row.hasPendingRetake) {
      buttons.add(const SizedBox(height: 10));
      buttons.add(_outlined(context, 'assessment_retake_action'.tr,
          Icons.event_repeat_rounded, _accent, () => _scheduleRetake(row)));
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final b in buttons)
            SizedBox(width: double.infinity, child: b),
        ]),
      ),
    );
  }

  Widget _button(BuildContext context, String label, IconData icon, Color color,
      VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: context.typography.smSemiBold),
    );
  }

  Widget _outlined(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label,
          style: context.typography.smSemiBold.copyWith(color: color)),
    );
  }
}
