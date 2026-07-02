import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../presentation/design_systems/design_constants/colors/app_colors.dart';
import '../activity_end_controller.dart';
import 'end_subject_row.dart';
import 'end_labeled_field.dart';
import 'end_due_date_picker.dart';

class EndHomeworkSection extends StatelessWidget {
  const EndHomeworkSection({super.key, required this.endCtrl});
  final ActivityEndController endCtrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () =>
                  endCtrl.showHomework.value = !endCtrl.showHomework.value,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: endCtrl.showHomework.value
                      ? AppColors.activityPurple.withValues(alpha: 0.05)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: endCtrl.showHomework.value
                        ? AppColors.activityPurple.withValues(alpha: 0.2)
                        : Colors.grey.shade100,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.activityPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.assignment_rounded,
                        color: AppColors.activityPurple,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'teacher_end_hw_toggle'.tr,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: endCtrl.showHomework.value
                              ? AppColors.activityPurple
                              : AppColors.textDisplay,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: endCtrl.showHomework.value,
                      onChanged: (v) => endCtrl.showHomework.value = v,
                      activeColor: AppColors.activityPurple,
                    ),
                  ],
                ),
              ),
            ),
            if (endCtrl.showHomework.value) ...[
              const SizedBox(height: 14),
              EndSubjectRow(endCtrl: endCtrl),
              const SizedBox(height: 12),
              EndLabeledField(
                labelKey: 'teacher_end_hw_title',
                hintKey: 'teacher_end_hw_title_hint',
                controller: endCtrl.hwTitleCtrl,
                maxLines: 1,
                accentColor: AppColors.activityPurple,
              ),
              const SizedBox(height: 10),
              EndDueDatePicker(endCtrl: endCtrl),
              const SizedBox(height: 10),
              EndLabeledField(
                labelKey: 'teacher_end_hw_desc',
                hintKey: 'teacher_end_hw_desc_hint',
                controller: endCtrl.hwDescCtrl,
                maxLines: 3,
                accentColor: AppColors.activityPurple,
              ),
            ],
          ],
        ));
  }
}
