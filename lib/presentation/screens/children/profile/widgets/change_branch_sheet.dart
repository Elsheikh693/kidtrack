import '../../../../../index/index_main.dart';
import '../../../receptionist/children/add_child/widgets/add_child_fields.dart';
import 'manage_sheet_scaffold.dart';

/// Two-step sheet to move the child to another branch. Step 1 picks the target
/// branch; step 2 re-configures the child FOR that branch — level (optional),
/// classroom (required) and fee package(s) (at least one required, since the
/// new branch is often priced differently). Filtering mirrors the add-child
/// screen so the options stay consistent with registration.
class ChangeBranchSheet extends StatefulWidget {
  const ChangeBranchSheet({super.key, required this.controller});

  final ChildProfileController controller;

  @override
  State<ChangeBranchSheet> createState() => _ChangeBranchSheetState();
}

class _ChangeBranchSheetState extends State<ChangeBranchSheet> {
  BranchModel? _branch;
  ProgramModel? _program;
  ClassroomModel? _classroom;
  final _packages = <PackageModel>[];

  void _pickBranch(BranchModel b) => setState(() {
    _branch = b;
    _program = null;
    _classroom = null;
    _packages.clear();
  });

  bool get _canSave => _classroom != null && _packages.isNotEmpty;

  void _save() {
    widget.controller.changeBranch(
      branch: _branch!,
      program: _program,
      classroom: _classroom!,
      packageIds: _packages.map((p) => p.key).whereType<String>().toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onForm = _branch != null;
    return ManageSheetScaffold(
      icon: Icons.apartment_rounded,
      title: onForm
          ? 'child_change_branch_configure'.tr
          : 'child_change_branch_pick_branch'.tr,
      subtitle: onForm ? _branch!.name : null,
      child: Obx(() {
        if (widget.controller.isManageLoading.value) {
          return const ManageSheetLoader();
        }
        final child = widget.controller.child.value;
        if (child == null) return const SizedBox.shrink();
        return onForm ? _form() : _branchStep(child);
      }),
    );
  }

  Widget _branchStep(ChildModel child) {
    final branches = widget.controller.manageBranches;
    if (branches.isEmpty) {
      return ManageSheetEmpty(text: 'child_change_no_branches'.tr);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: branches
          .map(
            (b) => ManageSheetTile(
              label: b.name,
              selected: b.key == child.branchId,
              onTap: () => _pickBranch(b),
            ),
          )
          .toList(),
    );
  }

  Widget _form() {
    final branchId = _branch!.key ?? '';
    final programs = widget.controller.programsFor(branchId);
    final classrooms = widget.controller.classroomsFor(
      branchId,
      programId: _program?.key,
    );
    final packages = widget.controller.packagesFor(branchId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _backToBranches(),
        FieldLabel('child_program_label'.tr),
        SizedBox(height: 8.h),
        AddChildProgramSelector(
          programs: programs,
          selected: _program,
          onChanged: (p) => setState(() {
            _program = p;
            _classroom = null; // classroom list depends on the level
          }),
        ),
        SizedBox(height: 18.h),
        FieldLabel('child_classroom_label'.tr),
        SizedBox(height: 8.h),
        AddChildClassroomDropdown(
          classrooms: classrooms,
          selected: _classroom,
          onChanged: (c) => setState(() => _classroom = c),
        ),
        SizedBox(height: 18.h),
        FieldLabel('child_package_label'.tr),
        SizedBox(height: 8.h),
        AddChildPackageSelector(
          packages: packages,
          selected: _packages,
          onToggle: (p) => setState(() {
            final i = _packages.indexWhere((s) => s.key == p.key);
            if (i >= 0) {
              _packages.removeAt(i);
            } else {
              _packages.add(p);
            }
          }),
        ),
        SizedBox(height: 22.h),
        PrimaryTextButton(
          label: AppText(
            text: 'child_change_branch_confirm'.tr,
            textStyle: context.typography.smSemiBold.copyWith(
              color: AppColors.white,
            ),
          ),
          appButtonSize: AppButtonSize.large,
          onTap: _canSave ? _save : null,
        ),
      ],
    );
  }

  Widget _backToBranches() => GestureDetector(
    onTap: () => setState(() => _branch = null),
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Icon(
            Icons.arrow_forward_rounded,
            size: 18.sp,
            color: AppColors.primary,
          ),
          SizedBox(width: 6.w),
          Text(
            'child_change_branch_back'.tr,
            style: context.typography.smMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Loads the lookup options, then opens the change-branch sheet.
Future<void> showChangeBranchSheet(ChildProfileController controller) {
  controller.loadManageLookups();
  return showManageSheet(ChangeBranchSheet(controller: controller));
}
