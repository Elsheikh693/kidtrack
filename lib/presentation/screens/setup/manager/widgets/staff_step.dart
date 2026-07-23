import '../../../../../index/index_main.dart';
import '../controller.dart';
import 'setup_item_tile.dart';

class StaffStep extends StatelessWidget {
  final ManagerSetupController controller;
  const StaffStep({super.key, required this.controller});

  void _showAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => AddStaffSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.staffList;
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4E6),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(Icons.people_rounded,
                            color: const Color(0xFFE11D48), size: 24.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('setup_step_staff'.tr,
                                style: context.typography.mdBold.copyWith(
                                    fontSize: 17,
                                    color: const Color(0xFF1F2937))),
                            Text('setup_staff_subtitle'.tr,
                                style: context.typography.xsRegular.copyWith(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAdd(context),
                        icon: Icon(Icons.person_add_rounded, size: 16.sp),
                        label: Text('setup_add_staff'.tr,
                            style: context.typography.xsRegular
                                .copyWith(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E35B1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDFB),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFF99F6E4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: const Color(0xFF14B8A6), size: 18.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text('setup_staff_note'.tr,
                              style: context.typography.xsRegular.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF0D9488))),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  if (list.isEmpty)
                    _EmptyStaff()
                  else
                    ...list.map((s) => SetupItemTile(
                          icon: _roleIcon(s.role),
                          iconBg: _roleBg(s.role),
                          iconColor: _roleColor(s.role),
                          title: s.name,
                          subtitle: s.role.name.tr,
                          onDelete: () {},
                        )),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  IconData _roleIcon(UserType role) {
    switch (role) {
      case UserType.teacher:      return Icons.school_rounded;
      case UserType.nanny:        return Icons.child_care_rounded;
      case UserType.receptionist: return Icons.badge_rounded;
      case UserType.busChaperone: return Icons.directions_bus_rounded;
      default:                    return Icons.person_rounded;
    }
  }

  Color _roleBg(UserType role) {
    switch (role) {
      case UserType.teacher:      return const Color(0xFFE0F2FE);
      case UserType.nanny:        return const Color(0xFFFCE7F3);
      case UserType.receptionist: return const Color(0xFFD1FAE5);
      case UserType.busChaperone: return const Color(0xFFFFF7ED);
      default:                    return const Color(0xFFEDE7FF);
    }
  }

  Color _roleColor(UserType role) {
    switch (role) {
      case UserType.teacher:      return const Color(0xFF0284C7);
      case UserType.nanny:        return const Color(0xFFDB2777);
      case UserType.receptionist: return const Color(0xFF059669);
      case UserType.busChaperone: return const Color(0xFFEA580C);
      default:                    return const Color(0xFF5E35B1);
    }
  }
}

class _EmptyStaff extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            children: [
              Icon(Icons.people_outline_rounded,
                  size: 52.sp, color: const Color(0xFFD1D5DB)),
              SizedBox(height: 12.h),
              Text('setup_staff_empty'.tr,
                  style: context.typography.smSemiBold.copyWith(
                      fontSize: 14, color: const Color(0xFF9CA3AF))),
              SizedBox(height: 4.h),
              Text('setup_staff_empty_hint'.tr,
                  style: context.typography.xsRegular.copyWith(
                      fontSize: 12, color: const Color(0xFFD1D5DB))),
            ],
          ),
        ),
      );
}

// ── Add Staff Sheet ───────────────────────────────────────────────────────────

class AddStaffSheet extends StatefulWidget {
  final ManagerSetupController controller;
  const AddStaffSheet({super.key, required this.controller});
  @override
  State<AddStaffSheet> createState() => _AddStaffSheetState();
}

class _AddStaffSheetState extends State<AddStaffSheet> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  StaffTemplate _template = StaffTemplate.receptionist;
  ClassroomModel? _classroom;
  final Set<String> _selectedSubjectIds = {};

  static const _staffTemplates = [
    StaffTemplate.receptionist,
    StaffTemplate.teacher,
    StaffTemplate.busChaperone,
  ];

  bool get _needsClassroom =>
      _template == StaffTemplate.teacher || _template == StaffTemplate.nanny;
  bool get _needsSubjects => _template == StaffTemplate.teacher;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('setup_staff_name_required'.tr);
      return;
    }
    if (phone.isEmpty) {
      Loader.showError('setup_manager_phone_required'.tr);
      return;
    }
    Get.back();
    widget.controller.addStaff(
      name: name,
      phone: phone,
      // The phone number doubles as the staff member's password.
      password: phone,
      template: _template,
      classroomId: _needsClassroom ? _classroom?.key : null,
      subjectIds: _needsSubjects ? _selectedSubjectIds.toList() : [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text('setup_add_staff_title'.tr,
                  style: context.typography.mdBold
                      .copyWith(fontSize: 18, color: const Color(0xFF1E293B))),
              SizedBox(height: 24.h),

              _Label('staff_form_name_label'.tr),
              SizedBox(height: 6.h),
              _Field(controller: _nameCtrl, hint: 'staff_form_name_hint'.tr),
              SizedBox(height: 16.h),

              _Label('staff_form_phone_label'.tr),
              SizedBox(height: 6.h),
              _Field(
                  controller: _phoneCtrl,
                  hint: 'staff_form_phone_hint'.tr,
                  keyboardType: TextInputType.phone),
              SizedBox(height: 16.h),

              _Label('staff_form_template_label'.tr),
              SizedBox(height: 6.h),
              StatefulBuilder(builder: (_, ss) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<StaffTemplate>(
                    value: _template,
                    isExpanded: true,
                    style: context.typography.smRegular.copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
                    items: _staffTemplates.map((t) => DropdownMenuItem(value: t, child: Text(t.labelKey.tr))).toList(),
                    onChanged: (t) { if (t != null) ss(() { _template = t; _classroom = null; _selectedSubjectIds.clear(); }); },
                  ),
                ),
              )),

              // Classroom (nanny or teacher)
              StatefulBuilder(builder: (_, ss) {
                if (!_needsClassroom) return const SizedBox.shrink();
                final rooms = widget.controller.classrooms;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _Label('setup_classroom_assign'.tr),
                    SizedBox(height: 6.h),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ClassroomModel?>(
                          value: _classroom,
                          isExpanded: true,
                          hint: Text('setup_select_classroom'.tr, style: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14)),
                          items: rooms.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
                          onChanged: (r) => ss(() => _classroom = r),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              // Subjects (teacher only)
              StatefulBuilder(builder: (_, ss) {
                if (!_needsSubjects) return const SizedBox.shrink();
                final subjectList = widget.controller.subjects;
                if (subjectList.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _Label('setup_subjects_assign'.tr),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: subjectList.map((s) {
                        final selected = _selectedSubjectIds.contains(s.key ?? '');
                        return GestureDetector(
                          onTap: () => ss(() {
                            if (selected) _selectedSubjectIds.remove(s.key ?? '');
                            else _selectedSubjectIds.add(s.key ?? '');
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF5E35B1) : const Color(0xFFEDE7FF),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(s.name, style: context.typography.smSemiBold.copyWith(fontSize: 12, color: selected ? Colors.white : const Color(0xFF5E35B1))),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              }),

              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E35B1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                  child: Text('setup_add_btn'.tr, style: context.typography.smSemiBold.copyWith(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: context.typography.smMedium.copyWith(fontSize: 14, color: const Color(0xFF475569)));
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  const _Field({required this.controller, required this.hint, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: const [EnglishDigitsFormatter()],
        style: context.typography.smRegular.copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: context.typography.smRegular.copyWith(color: const Color(0xFFCBD5E1), fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFF5E35B1), width: 1.5)),
        ),
      );
}
