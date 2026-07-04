import '../../../../../index/index_main.dart';
import '../add_child/widgets/add_child_fields.dart';
import 'parent_status_chip.dart';

class RcParentAccountView extends StatefulWidget {
  const RcParentAccountView({super.key});

  @override
  State<RcParentAccountView> createState() => _ParentAccountViewState();
}

class _ParentAccountViewState extends State<RcParentAccountView> {
  late final ParentAccountService _service;

  final _dataLoading = true.obs;
  final _allParents = <ParentModel>[].obs;
  final _links = <ParentChildModel>[].obs;

  String _childId = '';
  String _childName = '';

  static final _phoneRegex = RegExp(r'^(010|011|012|015)\d{8}$');

  @override
  void initState() {
    super.initState();
    _service = Get.find<ParentAccountService>();
    final args = Get.arguments as Map?;
    _childId = (args?['childId'] as String?) ?? '';
    _childName = (args?['childName'] as String?) ?? '';
    _loadData();
  }

  Future<void> _loadData() async {
    _dataLoading.value = true;
    await Get.find<ParentChildParentService>().getAll(
      callBack: (list) =>
          _links.value = list.whereType<ParentChildModel>().toList(),
    );
    await Get.find<GuardianParentService>().getAll(
      callBack: (list) =>
          _allParents.value = list.whereType<ParentModel>().toList(),
    );
    _dataLoading.value = false;
  }

  ParentModel? _guardianOf(String relationship) {
    for (final l in _links) {
      if (l.childId != _childId || l.relationship != relationship) continue;
      for (final p in _allParents) {
        if (p.uid == l.parentId) return p;
      }
    }
    return null;
  }

  Set<String> get _linkedUids => _links
      .where((l) => l.childId == _childId)
      .map((l) => l.parentId)
      .toSet();

  Future<bool> _createGuardian(
    String relationship,
    String name,
    String phone,
  ) async {
    if (name.trim().isEmpty) {
      Loader.showError('guardian_create_error_name'.tr);
      return false;
    }
    if (!_phoneRegex.hasMatch(phone.trim())) {
      Loader.showError('guardian_create_error_phone'.tr);
      return false;
    }
    Loader.show();
    final ok = await _service.createAccount(
      name: name.trim(),
      phone: phone.trim(),
      password: phone.trim(),
      childIds: [_childId],
      relationship: relationship,
      onError: (msg) {
        Loader.dismiss();
        Loader.showError(msg);
      },
    );
    if (ok) {
      Loader.showSuccess('guardian_create_success'.tr);
      await _loadData();
    }
    return ok;
  }

  Future<bool> _linkGuardian(String relationship, ParentModel parent) async {
    Loader.show();
    final ok = await _service.linkChildToExistingParent(
      parentId: parent.uid,
      childId: _childId,
      relationship: relationship,
      onError: (msg) {
        Loader.dismiss();
        Loader.showError(msg);
      },
    );
    if (ok) {
      Loader.showSuccess('rc_parent_assign_link_success'.tr);
      await _loadData();
    }
    return ok;
  }

  Future<void> _removeGuardian(ParentModel parent) async {
    final confirm = await Get.dialog<bool>(
      _ConfirmRemoveDialog(name: parent.name),
    );
    if (confirm != true) return;
    Loader.show();
    final done = Completer<ResponseStatus>();
    await Get.find<ParentChildParentService>().delete(
      id: '${parent.uid}_$_childId',
      callBack: done.complete,
    );
    Loader.dismiss();
    if (await done.future == ResponseStatus.success) {
      await _loadData();
    } else {
      Loader.showError('guardian_create_error_general'.tr);
    }
  }

  void _openAdd(String relationship, String label) {
    Get.bottomSheet(
      _AddGuardianSheet(
        relationshipLabel: label,
        allParents: _allParents,
        linkedUids: _linkedUids,
        onLink: (p) => _linkGuardian(relationship, p),
        onCreate: (name, phone) =>
            _createGuardian(relationship, name, phone),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'rc_parent_assign_title'.tr,
          style: context.typography.mdBold.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'parent_account_skip'.tr,
              style: context.typography.displaySmBold.copyWith(
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_childName.isNotEmpty)
                      _LinkingBanner(name: _childName),
                    SizedBox(height: 18.h),
                    _sectionLabel(context, 'rc_parent_guardians_label'.tr),
                    SizedBox(height: 10.h),
                    Obx(() {
                      if (_dataLoading.value) {
                        return Padding(
                          padding: EdgeInsets.only(top: 40.h),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          _GuardianSlot(
                            label: 'guardian_create_relationship_father'.tr,
                            icon: Icons.man_rounded,
                            color: const Color(0xFF2563EB),
                            parent: _guardianOf('father'),
                            onAdd: () => _openAdd(
                              'father',
                              'guardian_create_relationship_father'.tr,
                            ),
                            onRemove: _removeGuardian,
                          ),
                          SizedBox(height: 12.h),
                          _GuardianSlot(
                            label: 'guardian_create_relationship_mother'.tr,
                            icon: Icons.woman_rounded,
                            color: const Color(0xFFDB2777),
                            parent: _guardianOf('mother'),
                            onAdd: () => _openAdd(
                              'mother',
                              'guardian_create_relationship_mother'.tr,
                            ),
                            onRemove: _removeGuardian,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            _bottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 14.h),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Color(0xFFEDF0F3))),
    ),
    child: SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton.icon(
        onPressed: () => Get.back(),
        icon: Icon(Icons.check_rounded, size: 20.sp),
        label: Text(
          'rc_parent_done'.tr,
          style: context.typography.mdBold.copyWith(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 0,
        ),
      ),
    ),
  );

  Widget _sectionLabel(BuildContext context, String text) => Text(
    text,
    style: context.typography.displaySmBold.copyWith(
      fontSize: 13,
      color: const Color(0xFF94A3B8),
    ),
  );
}

// ─── Guardian slot (father / mother) ─────────────────────────────────────────

class _GuardianSlot extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final ParentModel? parent;
  final VoidCallback onAdd;
  final Future<void> Function(ParentModel) onRemove;

  const _GuardianSlot({
    required this.label,
    required this.icon,
    required this.color,
    required this.parent,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final p = parent;
    if (p == null) return _empty(context);
    return _filled(context, p);
  }

  Widget _empty(BuildContext context) => InkWell(
    onTap: onAdd,
    borderRadius: BorderRadius.circular(16.r),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.2,
        ),
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
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.typography.mdBold.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF334155),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'rc_parent_slot_add_hint'.tr,
                  style: context.typography.xsRegular.copyWith(
                    fontSize: 12.5,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.add_circle_rounded, color: color, size: 26.sp),
        ],
      ),
    ),
  );

  Widget _filled(BuildContext context, ParentModel p) => Container(
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: const Color(0xFFE2E8F0)),
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
          child: Icon(icon, color: color, size: 24.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      label,
                      style: context.typography.smSemiBold.copyWith(
                        fontSize: 11,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                p.name,
                style: context.typography.mdBold.copyWith(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                p.phone ?? '',
                textDirection: TextDirection.ltr,
                style: context.typography.xsRegular.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 8.h),
              ParentStatusChip(status: p.onboardingStatus),
            ],
          ),
        ),
        IconButton(
          onPressed: () => onRemove(p),
          icon: Icon(
            Icons.close_rounded,
            size: 20.sp,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    ),
  );
}

// ─── Add guardian bottom sheet (search existing / create new) ────────────────

class _AddGuardianSheet extends StatefulWidget {
  final String relationshipLabel;
  final List<ParentModel> allParents;
  final Set<String> linkedUids;
  final Future<bool> Function(ParentModel) onLink;
  final Future<bool> Function(String name, String phone) onCreate;

  const _AddGuardianSheet({
    required this.relationshipLabel,
    required this.allParents,
    required this.linkedUids,
    required this.onLink,
    required this.onCreate,
  });

  @override
  State<_AddGuardianSheet> createState() => _AddGuardianSheetState();
}

class _AddGuardianSheetState extends State<_AddGuardianSheet> {
  final _searchCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _query = ''.obs;
  final _showCreate = false.obs;
  final _busy = false.obs;

  static final _phoneRegex = RegExp(r'^(010|011|012|015)\d{8}$');

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => _query.value = _searchCtrl.text.trim());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  List<ParentModel> get _results {
    final q = _query.value;
    if (q.isEmpty) return const [];
    final lower = q.toLowerCase();
    return widget.allParents
        .where((p) => !widget.linkedUids.contains(p.uid))
        .where(
          (p) =>
              (p.phone ?? '').contains(q) ||
              p.name.toLowerCase().contains(lower),
        )
        .toList();
  }

  void _openCreate() {
    final q = _query.value;
    if (_phoneRegex.hasMatch(q)) _phoneCtrl.text = q;
    _showCreate.value = true;
  }

  Future<void> _link(ParentModel p) async {
    _busy.value = true;
    final ok = await widget.onLink(p);
    _busy.value = false;
    if (ok) Get.back();
  }

  Future<void> _create() async {
    _busy.value = true;
    final ok = await widget.onCreate(_nameCtrl.text, _phoneCtrl.text);
    _busy.value = false;
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 14.h),
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'rc_parent_add_sheet_title'.trParams({
                  'role': widget.relationshipLabel,
                }),
                style: context.typography.mdBold.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  0,
                  20.w,
                  MediaQuery.of(context).viewInsets.bottom + 20.h,
                ),
                child: Obx(
                  () => _showCreate.value
                      ? _buildCreateForm(context)
                      : _buildSearch(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel('rc_parent_assign_search_label'.tr),
        SizedBox(height: 8.h),
        TextField(
          inputFormatters: const [EnglishDigitsFormatter()],
          controller: _searchCtrl,
          style: context.typography.smRegular.copyWith(
            fontSize: 15,
            color: const Color(0xFF1E293B),
          ),
          decoration: _decoration('rc_parent_assign_search_hint'.tr).copyWith(
            prefixIcon: Icon(
              Icons.search_rounded,
              color: const Color(0xFF94A3B8),
              size: 22.sp,
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Obx(() {
          final results = _results;
          if (_query.value.isEmpty) {
            return _CreateButton(onTap: _openCreate);
          }
          if (results.isEmpty) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    'rc_parent_assign_no_result'.tr,
                    style: context.typography.smRegular.copyWith(
                      fontSize: 13.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                _CreateButton(onTap: _openCreate),
              ],
            );
          }
          return Column(
            children: [
              for (final p in results) ...[
                _ExistingParentRow(
                  parent: p,
                  busy: _busy,
                  onLink: () => _link(p),
                ),
                SizedBox(height: 10.h),
              ],
              SizedBox(height: 2.h),
              _CreateButton(onTap: _openCreate, outlined: true),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCreateForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel('guardian_name_label'.tr),
        SizedBox(height: 8.h),
        _Input(
          controller: _nameCtrl,
          hint: 'guardian_name_hint'.tr,
          keyboardType: TextInputType.name,
        ),
        SizedBox(height: 16.h),
        FieldLabel('guardian_create_phone_label'.tr),
        SizedBox(height: 8.h),
        _Input(
          controller: _phoneCtrl,
          hint: 'guardian_create_phone_hint'.tr,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 20.h),
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _busy.value ? null : _create,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: _busy.value
                  ? SizedBox(
                      width: 22.w,
                      height: 22.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'rc_parent_assign_create_submit'.tr,
                      style: context.typography.mdBold.copyWith(fontSize: 15.5),
                    ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Center(
          child: TextButton(
            onPressed: () => _showCreate.value = false,
            child: Text(
              'rc_parent_back_to_search'.tr,
              style: context.typography.smSemiBold.copyWith(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExistingParentRow extends StatelessWidget {
  final ParentModel parent;
  final RxBool busy;
  final VoidCallback onLink;

  const _ExistingParentRow({
    required this.parent,
    required this.busy,
    required this.onLink,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            parent.name.isNotEmpty ? parent.name[0] : '?',
            style: context.typography.mdBold.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parent.name,
                style: context.typography.displaySmBold.copyWith(
                  fontSize: 14.5,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                parent.phone ?? '',
                textDirection: TextDirection.ltr,
                style: context.typography.xsRegular.copyWith(
                  fontSize: 12.5,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 38.h,
          child: Obx(
            () => ElevatedButton(
              onPressed: busy.value ? null : onLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              child: Text(
                'rc_parent_assign_link_child'.tr,
                style: context.typography.smSemiBold.copyWith(fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool outlined;
  const _CreateButton({required this.onTap, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_add_alt_1_rounded, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          'rc_parent_assign_create_new'.tr,
          style: context.typography.displaySmBold.copyWith(fontSize: 14.5),
        ),
      ],
    );
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: outlined
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: child,
            ),
    );
  }
}

class _ConfirmRemoveDialog extends StatelessWidget {
  final String name;
  const _ConfirmRemoveDialog({required this.name});

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
    child: Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'rc_parent_remove_confirm'.trParams({'name': name}),
            textAlign: TextAlign.center,
            style: context.typography.mdBold.copyWith(
              fontSize: 15.5,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(result: false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text('common_cancel'.tr),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text('rc_parent_remove_confirm_yes'.tr),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _LinkingBanner extends StatelessWidget {
  final String name;
  const _LinkingBanner({required this.name});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF7EE),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: const Color(0xFFBFE6C9)),
    ),
    child: Row(
      children: [
        Icon(
          Icons.child_care_rounded,
          size: 20.sp,
          color: const Color(0xFF16A34A),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            'rc_parent_assign_linking_child'.trParams({'name': name}),
            style: context.typography.displaySmBold.copyWith(
              fontSize: 14,
              color: const Color(0xFF166534),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _Input({
    required this.controller,
    required this.hint,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => TextField(
    inputFormatters: const [EnglishDigitsFormatter()],
    controller: controller,
    keyboardType: keyboardType,
    style: context.typography.smRegular.copyWith(
      fontSize: 15,
      color: const Color(0xFF1E293B),
    ),
    decoration: _decoration(hint),
  );
}

InputDecoration _decoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
  filled: true,
  fillColor: const Color(0xFFF8FAFC),
  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
  ),
);
