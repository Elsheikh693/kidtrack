import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../Data/models/nursery_course/nursery_course_model.dart';
import '../../../../index/index_main.dart';
import 'owner_courses_controller.dart';

Future<void> showCreateCourseSheet(
  BuildContext context, {
  required OwnerCoursesController controller,
  NurseryCourse? editing,
}) async {
  await Get.to(
    () => _CreateCourseScreen(controller: controller, editing: editing),
    fullscreenDialog: true,
  );
}

class _CreateCourseScreen extends StatefulWidget {
  const _CreateCourseScreen({required this.controller, this.editing});

  final OwnerCoursesController controller;
  final NurseryCourse? editing;

  @override
  State<_CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<_CreateCourseScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  CourseCategory _category = CourseCategory.language;
  XFile? _pickedImage;
  bool _removeCover = false;
  bool _saving = false;
  bool _isOpen = true;

  List<BranchModel> _branches = [];
  final Set<String> _selectedBranchIds = {}; // empty = all branches
  bool _loadingBranches = true;

  bool get isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _descCtrl.text = e.description;
      _priceCtrl.text = e.price == 0 ? '' : e.price.toInt().toString();
      _ageCtrl.text = e.ageGroup;
      _category = e.category;
      _isOpen = e.isActive;
      _selectedBranchIds.addAll(e.branchIds);
    }
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    await Get.find<BranchParentService>().getAll(
      callBack: (list) {
        _branches = list.whereType<BranchModel>().toList();
      },
    );
    if (mounted) setState(() => _loadingBranches = false);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
        _removeCover = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;

    bool ok;
    if (isEditing) {
      ok = await widget.controller.updateCourse(
        course: widget.editing!,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: price,
        category: _category,
        ageGroup: _ageCtrl.text.trim(),
        isActive: _isOpen,
        branchIds: _selectedBranchIds.toList(),
        newCoverImage: _pickedImage,
        removeCover: _removeCover,
      );
    } else {
      ok = await widget.controller.createCourse(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: price,
        category: _category,
        ageGroup: _ageCtrl.text.trim(),
        isActive: _isOpen,
        branchIds: _selectedBranchIds.toList(),
        coverImage: _pickedImage,
      );
    }

    setState(() => _saving = false);
    if (ok && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            isEditing ? 'تعديل الكورس' : 'كورس جديد',
            style: context.typography.lgBold.copyWith(color: AppColors.textDefault),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cover image picker ───────────────────────────────────
                Center(
                  child: SizedBox(
                    width: 220.w,
                    child: _CoverPicker(
                      existingUrl:
                          _removeCover ? null : widget.editing?.coverUrl,
                      pickedFile: _pickedImage,
                      onPick: _pickImage,
                      onRemove: () => setState(() {
                        _pickedImage = null;
                        _removeCover = true;
                      }),
                      catColor: accent,
                    ),
                  ),
                ),
                SizedBox(height: 22.h),

                // ── Course details card ──────────────────────────────────
                _SectionLabel(label: 'تفاصيل الكورس', icon: Icons.edit_note_rounded),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _Field(
                        controller: _titleCtrl,
                        label: 'اسم الكورس',
                        hint: 'مثال: اللغة العربية للمبتدئين',
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 14.h),
                      _Field(
                        controller: _descCtrl,
                        label: 'الوصف',
                        hint: 'اكتب وصفاً موجزاً عن الكورس...',
                        maxLines: 3,
                        textInputAction: TextInputAction.newline,
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _Field(
                              controller: _priceCtrl,
                              label: 'السعر (جنيه)',
                              hint: '0 = مجاني',
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _Field(
                              controller: _ageCtrl,
                              label: 'الفئة العمرية',
                              hint: 'مثال: 3-6',
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 22.h),

                // ── Branch availability ──────────────────────────────────
                _SectionLabel(
                    label: 'الفروع المتاحة', icon: Icons.account_balance_rounded),
                SizedBox(height: 4.h),
                Text(
                  'اختر الفروع المتاح بها الكورس، أو اتركها لكل الفروع',
                  style: context.typography.xsRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
                SizedBox(height: 10.h),
                _BranchPicker(
                  loading: _loadingBranches,
                  branches: _branches,
                  selectedIds: _selectedBranchIds,
                  accent: accent,
                  onAllTap: () => setState(_selectedBranchIds.clear),
                  onToggle: (id) => setState(() {
                    if (_selectedBranchIds.contains(id)) {
                      _selectedBranchIds.remove(id);
                    } else {
                      _selectedBranchIds.add(id);
                    }
                  }),
                ),
                SizedBox(height: 22.h),

                // ── Availability for parents ─────────────────────────────
                _SectionLabel(
                    label: 'إتاحة الكورس', icon: Icons.visibility_rounded),
                SizedBox(height: 10.h),
                _AvailabilityToggle(
                  isOpen: _isOpen,
                  onChanged: (v) => setState(() => _isOpen = v),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          child: SizedBox(
            width: double.infinity,
            height: 54.h,
            child: FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r)),
              ),
              child: _saving
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      isEditing ? 'حفظ التعديلات' : 'إضافة الكورس',
                      style: context.typography.mdBold
                          .copyWith(color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.textSecondaryParagraph),
        SizedBox(width: 6.w),
        Text(
          label,
          style: context.typography.smSemiBold
              .copyWith(color: AppColors.textDefault),
        ),
      ],
    );
  }
}

// ─── Availability toggle (open / closed for parents) ──────────────────────────

class _AvailabilityToggle extends StatelessWidget {
  const _AvailabilityToggle({required this.isOpen, required this.onChanged});

  final bool isOpen;
  final ValueChanged<bool> onChanged;

  static const _open = Color(0xFF059669);
  static const _closed = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? _open : _closed;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isOpen ? Icons.lock_open_rounded : Icons.lock_rounded,
              color: color,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? 'متاح لأولياء الأمور' : 'مقفول (لن يظهر للأهالي)',
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
                SizedBox(height: 2.h),
                Text(
                  isOpen
                      ? 'الكورس ظاهر ومتاح للتسجيل'
                      : 'الكورس مخفي تماماً عن تطبيق ولي الأمر',
                  style: context.typography.xsRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isOpen,
            activeColor: _open,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ─── Cover picker ─────────────────────────────────────────────────────────────

class _CoverPicker extends StatelessWidget {
  const _CoverPicker({
    required this.existingUrl,
    required this.pickedFile,
    required this.onPick,
    required this.onRemove,
    required this.catColor,
  });

  final String? existingUrl;
  final XFile? pickedFile;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final Color catColor;

  bool get hasImage => pickedFile != null || existingUrl != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: catColor.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: catColor.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(19.r),
                    child: pickedFile != null
                        ? Image.file(File(pickedFile!.path), fit: BoxFit.cover)
                        : Image(image: appCachedImageProvider(existingUrl!), fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: EdgeInsets.all(5.w),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close,
                            color: Colors.white, size: 16.sp),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72.w,
                    height: 72.h,
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_photo_alternate_rounded,
                        color: catColor, size: 36.sp),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'إضافة صورة غلاف',
                    style: context.typography.smSemiBold.copyWith(color: catColor),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'اختياري',
                    style: context.typography.xsRegular
                        .copyWith(color: catColor.withValues(alpha: 0.7)),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Branch picker (multi-select) ─────────────────────────────────────────────

class _BranchPicker extends StatelessWidget {
  const _BranchPicker({
    required this.loading,
    required this.branches,
    required this.selectedIds,
    required this.accent,
    required this.onAllTap,
    required this.onToggle,
  });

  final bool loading;
  final List<BranchModel> branches;
  final Set<String> selectedIds;
  final Color accent;
  final VoidCallback onAllTap;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox(
        height: 36.h,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(
            width: 20.w, height: 20.h,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    final allSelected = selectedIds.isEmpty;
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _BranchChip(
          label: 'كل الفروع',
          selected: allSelected,
          accent: accent,
          onTap: onAllTap,
        ),
        ...branches.map((b) => _BranchChip(
              label: b.name,
              selected: selectedIds.contains(b.key),
              accent: accent,
              onTap: () => onToggle(b.key ?? ''),
            )),
      ],
    );
  }
}

class _BranchChip extends StatelessWidget {
  const _BranchChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.12) : AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? accent : AppColors.grayLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 15.sp,
              color: selected ? accent : AppColors.grayMedium,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: context.typography.xsMedium.copyWith(
                color: selected ? accent : AppColors.textSecondaryParagraph,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Text field ───────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: context.typography.xsMedium
                .copyWith(color: AppColors.textSecondaryParagraph)),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          textInputAction: textInputAction,
          style: context.typography.smRegular
              .copyWith(color: AppColors.textDefault),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.typography.smRegular
                .copyWith(color: AppColors.grayMedium),
            filled: true,
            fillColor: AppColors.backgroundNeutral100,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.grayLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.grayLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
