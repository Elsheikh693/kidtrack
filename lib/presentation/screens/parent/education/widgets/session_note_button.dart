import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller.dart' show DayTimelineItem;
import '../../link_book/guardian_note_controller.dart';
import '../../link_book/widgets/guardian_note_sheet.dart';

/// Inline "share your note with the nursery" affordance shown at the bottom of
/// every activity card: the guardian's own note on that session, with an
/// add/edit action. Reads live state from [GuardianNoteController].
class SessionNoteButton extends StatefulWidget {
  const SessionNoteButton({super.key, required this.item});

  final DayTimelineItem item;

  @override
  State<SessionNoteButton> createState() => _SessionNoteButtonState();
}

class _SessionNoteButtonState extends State<SessionNoteButton> {
  late final GuardianNoteController controller;

  static const _accent = Color(0xFF6C4DDB);

  @override
  void initState() {
    super.initState();
    controller = Get.find<GuardianNoteController>();
  }

  void _open() {
    Get.bottomSheet(
      GuardianNoteSheet(item: widget.item),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    // No resolvable session id → can't attach a note.
    if ((widget.item.activityId ?? '').isEmpty) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final note = controller.noteFor(widget.item.activityId)?.content;
      final hasNote = note != null && note.trim().isNotEmpty;

      if (!hasNote) {
        return Padding(
          padding: const EdgeInsets.only(top: 11),
          child: GestureDetector(
            onTap: _open,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accent.withValues(alpha: 0.30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_comment_rounded,
                      size: 15, color: _accent),
                  const SizedBox(width: 7),
                  Text(
                    'guardian_note_add_full'.tr,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: _accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(top: 11),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _accent.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.forum_rounded, size: 13, color: _accent),
                  const SizedBox(width: 6),
                  Text(
                    'guardian_note_your_note'.tr,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: _accent,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _open,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_rounded,
                            size: 13, color: _accent),
                        const SizedBox(width: 3),
                        Text(
                          'guardian_note_edit'.tr,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: _accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                note.trim(),
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
