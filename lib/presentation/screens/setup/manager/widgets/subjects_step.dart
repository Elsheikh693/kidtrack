import '../../../../../index/index_main.dart';
import '../controller.dart';
import 'setup_item_tile.dart';
import 'setup_shared_widgets.dart';

class SubjectsStep extends StatelessWidget {
  final ManagerSetupController controller;
  const SubjectsStep({super.key, required this.controller});

  void _showAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => _AddSubjectSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => SetupStepScaffold(
          icon: Icons.menu_book_rounded,
          iconBg: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          title: 'setup_step_subjects'.tr,
          subtitle: 'setup_subjects_subtitle'.tr,
          onAdd: () => _showAdd(context),
          addLabel: 'setup_add_subject'.tr,
          emptyIcon: Icons.menu_book_outlined,
          emptyLabel: 'setup_subjects_empty'.tr,
          items: controller.subjects
              .map((s) => SetupItemTile(
                    icon: Icons.menu_book_rounded,
                    iconBg: const Color(0xFFFEF3C7),
                    iconColor: const Color(0xFFD97706),
                    title: s.name,
                    onDelete: () => controller.deleteSubject(s.key ?? ''),
                  ))
              .toList(),
        ));
  }
}

class _AddSubjectSheet extends StatefulWidget {
  final ManagerSetupController controller;
  const _AddSubjectSheet({required this.controller});
  @override
  State<_AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<_AddSubjectSheet> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('setup_subject_name_required'.tr);
      return;
    }
    Get.back();
    widget.controller.addSubject(name);
  }

  @override
  Widget build(BuildContext context) {
    return SetupSimpleSheet(
      title: 'setup_add_subject_title'.tr,
      nameCtrl: _nameCtrl,
      nameLabel: 'setup_subject_name_label'.tr,
      nameHint: 'setup_subject_name_hint'.tr,
      onSubmit: _submit,
    );
  }
}
