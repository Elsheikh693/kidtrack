import '../../../../../index/index_main.dart';
import '../teacher_activity_controller.dart';
import '../activity_end_controller.dart';
import 'activity_end_sheet_handle.dart';
import 'activity_end_sheet_header.dart';
import 'activity_end_confirm_button.dart';
import 'end_eval_section.dart';
import 'end_homework_section.dart';

Future<void> showActivityEndSheet(
  BuildContext context,
  TeacherActivityController mainCtrl,
) async {
  if (mainCtrl.activeActivity.value == null) return;
  // Recompute who is present right now so the evaluation list reflects any
  // check-ins/outs that happened after the activity screen first loaded.
  await mainCtrl.refreshPresentChildren();
  if (!context.mounted) return;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ActivityEndSheet(mainCtrl: mainCtrl),
  );
}

class ActivityEndSheet extends StatefulWidget {
  const ActivityEndSheet({super.key, required this.mainCtrl});
  final TeacherActivityController mainCtrl;

  @override
  State<ActivityEndSheet> createState() => _ActivityEndSheetState();
}

class _ActivityEndSheetState extends State<ActivityEndSheet> {
  late final ActivityEndController endCtrl;

  @override
  void initState() {
    super.initState();
    endCtrl = Get.find<ActivityEndController>();
    endCtrl.initFromActivity();
  }

  Future<void> _confirm() async {
    HapticFeedback.heavyImpact();
    await widget.mainCtrl.endWithData(
      finalEvals: Map<String, String>.from(endCtrl.childEvals),
      finalNotes: Map<String, String>.from(endCtrl.childNotes),
      finalReasons: Map<String, List<String>>.from(endCtrl.childReasons),
      groupNote: '',
      homework: endCtrl.buildHomework(),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const ActivityEndSheetHandle(),
              ActivityEndSheetHeader(
                activityTitle:
                    widget.mainCtrl.activeActivity.value?.title ?? '',
                classroomName: endCtrl.classroomName,
                childrenCount: endCtrl.totalCount,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  // DraggableScrollableSheet doesn't resize for the keyboard,
                  // so add the keyboard inset as bottom padding — this gives the
                  // scroll enough extra extent for the focused homework field to
                  // lift above the keyboard instead of hiding behind it.
                  padding: EdgeInsets.fromLTRB(
                      20, 0, 20, 16 + MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EndEvalSection(endCtrl: endCtrl),
                      const SizedBox(height: 20),
                      EndHomeworkSection(endCtrl: endCtrl),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              // Sticky submit button
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  child: ActivityEndConfirmButton(
                    onTap: _confirm,
                    mainCtrl: widget.mainCtrl,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
