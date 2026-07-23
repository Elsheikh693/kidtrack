import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../education/widgets/journal_meta.dart';
import '../../education/controller.dart' show DayTimelineItem;
import '../guardian_note_controller.dart';
import '../../../../../Global/Localization/app_direction.dart';

/// Bottom sheet where the guardian writes / edits / deletes their note on a
/// single session. Opened from [GuardianNoteSection].
class GuardianNoteSheet extends StatefulWidget {
  const GuardianNoteSheet({
    super.key,
    required this.item,
  });

  final DayTimelineItem item;

  @override
  State<GuardianNoteSheet> createState() => _GuardianNoteSheetState();
}

class _GuardianNoteSheetState extends State<GuardianNoteSheet> {
  late final GuardianNoteController controller;
  late final TextEditingController _text;

  static const _accent = Color(0xFF6C4DDB);

  bool get _hasExisting =>
      controller.noteFor(widget.item.activityId) != null;

  @override
  void initState() {
    super.initState();
    controller = Get.find<GuardianNoteController>();
    final existing = controller.noteFor(widget.item.activityId);
    _text = TextEditingController(text: existing?.content ?? '');
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await controller.saveNote(
      item: widget.item,
      content: _text.text,
    );
    if (mounted) Get.back();
  }

  Future<void> _delete() async {
    await controller.deleteNote(widget.item.activityId ?? '');
    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.item.title.trim().isNotEmpty
        ? widget.item.title
        : widget.item.subjectName;
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.edit_note_rounded,
                        color: _accent, size: 21),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'guardian_note_sheet_title'.tr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: kJInk,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: kJMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _text,
                autofocus: true,
                maxLines: 5,
                minLines: 3,
                maxLength: 500,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                    fontSize: 14, height: 1.5, color: kJInk),
                decoration: InputDecoration(
                  hintText: 'guardian_note_hint'.tr,
                  hintStyle: const TextStyle(
                      fontSize: 13.5, color: kJMuted, height: 1.5),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: kJBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: kJBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _accent, width: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _save,
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'guardian_note_save'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_hasExisting) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _delete,
                      child: Container(
                        height: 50,
                        width: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: Color(0xFFDC2626), size: 22),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
