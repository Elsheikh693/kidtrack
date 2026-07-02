import '../../../../../index/index_main.dart';
import '../controller.dart';
import 'setup_item_tile.dart';
import 'setup_shared_widgets.dart';

class ProgramsStep extends StatelessWidget {
  final ManagerSetupController controller;
  const ProgramsStep({super.key, required this.controller});

  void _showAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => _AddProgramSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => SetupStepScaffold(
          icon: Icons.school_rounded,
          iconBg: const Color(0xFFE0F2FE),
          iconColor: const Color(0xFF0284C7),
          title: 'setup_step_programs'.tr,
          subtitle: 'setup_programs_subtitle'.tr,
          onAdd: () => _showAdd(context),
          addLabel: 'setup_add_program'.tr,
          emptyIcon: Icons.school_outlined,
          emptyLabel: 'setup_programs_empty'.tr,
          items: controller.programs
              .map((p) => SetupItemTile(
                    icon: Icons.school_rounded,
                    iconBg: const Color(0xFFE0F2FE),
                    iconColor: const Color(0xFF0284C7),
                    title: p.name,
                    subtitle: p.description,
                    onDelete: () => controller.deleteProgram(p.key ?? ''),
                  ))
              .toList(),
        ));
  }
}

class _AddProgramSheet extends StatefulWidget {
  final ManagerSetupController controller;
  const _AddProgramSheet({required this.controller});
  @override
  State<_AddProgramSheet> createState() => _AddProgramSheetState();
}

class _AddProgramSheetState extends State<_AddProgramSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('setup_program_name_required'.tr);
      return;
    }
    Get.back();
    widget.controller.addProgram(name, description: _descCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return SetupSimpleSheet(
      title: 'setup_add_program_title'.tr,
      nameCtrl: _nameCtrl,
      nameLabel: 'setup_program_name_label'.tr,
      nameHint: 'setup_program_name_hint'.tr,
      extraCtrl: _descCtrl,
      extraLabel: 'setup_program_desc_label'.tr,
      extraHint: 'setup_program_desc_hint'.tr,
      onSubmit: _submit,
    );
  }
}
