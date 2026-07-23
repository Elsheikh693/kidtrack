import '../../../../../../index/index_main.dart';

const _ink = Color(0xFF1E293B);
const _label = Color(0xFF475569);
const _hint = Color(0xFFCBD5E1);
const _fill = Color(0xFFF8FAFC);
const _border = Color(0xFFE2E8F0);

class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: context.typography.smSemiBold.copyWith(
          fontSize: 14,
          color: _label,
        ),
      );
}

class AddChildNameField extends StatelessWidget {
  final TextEditingController nameCtrl;
  final FocusNode focus;

  const AddChildNameField({
    super.key,
    required this.nameCtrl,
    required this.focus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel('child_name_label'.tr),
        SizedBox(height: 8.h),
        _Input(
          controller: nameCtrl,
          hint: 'child_name_hint'.tr,
          focusNode: focus,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
        ),
      ],
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String> onSubmitted;

  const _Input({
    required this.controller,
    required this.hint,
    required this.focusNode,
    required this.textInputAction,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: context.typography.smRegular.copyWith(fontSize: 15, color: _ink),
        decoration: _decoration(hint),
      );
}

class AddChildGenderDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const AddChildGenderDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => _DropdownBox(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            style: context.typography.smRegular.copyWith(fontSize: 14, color: _ink),
            items: [
              DropdownMenuItem(
                value: 'male',
                child: Text('child_gender_male'.tr),
              ),
              DropdownMenuItem(
                value: 'female',
                child: Text('child_gender_female'.tr),
              ),
            ],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      );
}

class AddChildBranchDropdown extends StatelessWidget {
  final List<BranchModel> branches;
  final BranchModel? selected;
  final ValueChanged<BranchModel?> onChanged;

  const AddChildBranchDropdown({
    super.key,
    required this.branches,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => _DropdownBox(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<BranchModel?>(
            value: selected,
            isExpanded: true,
            hint: Text(
              'common_no_branch_selected'.tr,
              style: context.typography.smRegular.copyWith(color: _hint, fontSize: 14),
            ),
            style: context.typography.smRegular.copyWith(fontSize: 14, color: _ink),
            items: branches
                .map((b) =>
                    DropdownMenuItem(value: b, child: Text(b.name)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );
}

class AddChildClassroomDropdown extends StatelessWidget {
  final List<ClassroomModel> classrooms;
  final ClassroomModel? selected;
  final ValueChanged<ClassroomModel?> onChanged;

  const AddChildClassroomDropdown({
    super.key,
    required this.classrooms,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => _DropdownBox(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<ClassroomModel?>(
            value: selected,
            isExpanded: true,
            hint: Text(
              'child_classroom_none'.tr,
              style: context.typography.smRegular.copyWith(color: _hint, fontSize: 14),
            ),
            style: context.typography.smRegular.copyWith(fontSize: 14, color: _ink),
            items: [
              DropdownMenuItem<ClassroomModel?>(
                value: null,
                child: Text('child_classroom_none'.tr),
              ),
              ...classrooms.map(
                (c) => DropdownMenuItem(value: c, child: Text(c.name)),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      );
}

class AddChildPackageSelector extends StatelessWidget {
  final List<PackageModel> packages;
  final List<PackageModel> selected;
  final ValueChanged<PackageModel> onToggle;

  const AddChildPackageSelector({
    super.key,
    required this.packages,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) {
      return ReadonlyField('child_package_none'.tr);
    }
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: packages.map((p) {
        final isSelected = selected.any((s) => s.key == p.key);
        return GestureDetector(
          onTap: () => onToggle(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : _fill,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : _border,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: 18.sp,
                  color: isSelected ? Colors.white : _hint,
                ),
                SizedBox(width: 7.w),
                Text(
                  '${p.name} • ${p.monthlyDue.toStringAsFixed(0)} ${'overdue_currency'.tr}',
                  style: context.typography.smSemiBold.copyWith(
                    fontSize: 14,
                    color: isSelected ? Colors.white : _ink,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class AddChildProgramSelector extends StatelessWidget {
  final List<ProgramModel> programs;
  final ProgramModel? selected;
  final ValueChanged<ProgramModel?> onChanged;

  const AddChildProgramSelector({
    super.key,
    required this.programs,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (programs.isEmpty) {
      return ReadonlyField('child_program_none'.tr);
    }
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: programs.map((p) {
        final isSelected = selected?.key == p.key;
        return GestureDetector(
          onTap: () => onChanged(isSelected ? null : p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : _fill,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : _border,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: 18.sp,
                  color: isSelected ? Colors.white : _hint,
                ),
                SizedBox(width: 7.w),
                Text(
                  p.name,
                  style: context.typography.smSemiBold.copyWith(
                    fontSize: 14,
                    color: isSelected ? Colors.white : _ink,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DropdownBox extends StatelessWidget {
  final Widget child;
  const _DropdownBox({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: _fill,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _border),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: child,
      );
}

class ReadonlyField extends StatelessWidget {
  final String text;
  const ReadonlyField(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _border),
        ),
        alignment: AlignmentDirectional.centerStart,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Text(text, style: context.typography.smRegular.copyWith(fontSize: 15, color: _ink)),
      );
}

class LockedField extends StatelessWidget {
  final String text;
  const LockedField(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _border),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Expanded(
              child: Text(text,
                  style: context.typography.smRegular.copyWith(fontSize: 15, color: _ink)),
            ),
            Icon(Icons.lock_outline_rounded,
                size: 18.sp, color: const Color(0xFF94A3B8)),
          ],
        ),
      );
}

class SubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SubmitButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 54.h,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
            elevation: 0,
          ),
          child: Text(
            label,
            style: context.typography.mdBold.copyWith(fontSize: 16),
          ),
        ),
      );
}

InputDecoration _decoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _hint, fontSize: 14),
      filled: true,
      fillColor: _fill,
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
