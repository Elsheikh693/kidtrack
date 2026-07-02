import '../../../../../index/index_main.dart';
import '../add_child/widgets/add_child_fields.dart';

class RcParentAccountView extends StatefulWidget {
  const RcParentAccountView({super.key});

  @override
  State<RcParentAccountView> createState() => _ParentAccountViewState();
}

class _ParentAccountViewState extends State<RcParentAccountView> {
  late final ParentAccountService _service;

  final _searchCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _isLoading = false.obs;
  final _dataLoading = true.obs;
  final _query = ''.obs;
  final _showCreate = false.obs;

  final _allParents = <ParentModel>[].obs;
  final _links = <ParentChildModel>[].obs;
  final _childNames = <String, String>{};

  String? _newChildId;
  String _newChildName = '';

  static final _phoneRegex = RegExp(r'^(010|011|012|015)\d{8}$');

  @override
  void initState() {
    super.initState();
    _service = Get.find<ParentAccountService>();
    final args = Get.arguments as Map?;
    _newChildId = args?['childId'] as String?;
    _newChildName = (args?['childName'] as String?) ?? '';
    _searchCtrl.addListener(() => _query.value = _searchCtrl.text.trim());
    _loadData();
  }

  Future<void> _loadData() async {
    _dataLoading.value = true;
    await Get.find<ChildParentService>().getAll(
      callBack: (list) {
        for (final c in list.whereType<ChildModel>()) {
          _childNames[c.key ?? ''] = c.fullName;
        }
      },
    );
    await Get.find<ParentChildParentService>().getAll(
      callBack: (list) {
        _links.value = list.whereType<ParentChildModel>().toList();
      },
    );
    await Get.find<GuardianParentService>().getAll(
      callBack: (list) {
        _allParents.value = list.whereType<ParentModel>().toList()
          ..sort((a, b) => a.name.compareTo(b.name));
      },
    );
    _dataLoading.value = false;
  }

  List<ParentModel> get _results {
    final q = _query.value;
    if (q.isEmpty) return const [];
    final lower = q.toLowerCase();
    return _allParents
        .where((p) =>
            (p.phone ?? '').contains(q) || p.name.toLowerCase().contains(lower))
        .toList();
  }

  List<String> _childrenOf(String parentId) => _links
      .where((l) => l.parentId == parentId)
      .map((l) => _childNames[l.childId] ?? '')
      .where((n) => n.isNotEmpty)
      .toList();

  Future<void> _linkExisting(ParentModel parent) async {
    if (_newChildId == null || _newChildId!.isEmpty) return;
    _isLoading.value = true;
    Loader.show();
    final ok = await _service.linkChildToExistingParent(
      parentId: parent.uid,
      childId: _newChildId!,
      onError: (msg) {
        _isLoading.value = false;
        Loader.showError(msg);
      },
    );
    if (ok) {
      _isLoading.value = false;
      Loader.showSuccess('rc_parent_assign_link_success'.tr);
      await Future.delayed(const Duration(milliseconds: 800));
      Get.back();
    }
  }

  void _openCreate() {
    final q = _query.value;
    if (_phoneRegex.hasMatch(q)) _phoneCtrl.text = q;
    _showCreate.value = true;
  }

  Future<void> _createAndLink() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      Loader.showError('guardian_create_error_name'.tr);
      return;
    }
    if (!_phoneRegex.hasMatch(phone)) {
      Loader.showError('guardian_create_error_phone'.tr);
      return;
    }

    _isLoading.value = true;
    Loader.show();

    final ok = await _service.createAccount(
      name: name,
      phone: phone,
      password: phone,
      childIds: _newChildId == null ? const [] : [_newChildId!],
      onError: (msg) {
        _isLoading.value = false;
        Loader.showError(msg);
      },
    );

    if (ok) {
      _isLoading.value = false;
      Loader.showSuccess('guardian_create_success'.tr);
      await Future.delayed(const Duration(milliseconds: 800));
      Get.back();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          18.w,
          16.h,
          18.w,
          MediaQuery.of(context).viewInsets.bottom + 24.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_newChildName.isNotEmpty) _LinkingBanner(name: _newChildName),
            SizedBox(height: 16.h),
            Obx(() {
              if (_showCreate.value) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FieldLabel('rc_parent_assign_search_label'.tr),
                  SizedBox(height: 8.h),
                  _SearchInput(controller: _searchCtrl),
                  SizedBox(height: 16.h),
                ],
              );
            }),
            Obx(() {
              if (_dataLoading.value) {
                return Padding(
                  padding: EdgeInsets.only(top: 40.h),
                  child: Center(
                    child: SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              if (_showCreate.value) return _buildCreateForm();
              if (_query.value.isEmpty) {
                return Column(
                  children: [
                    const _SearchHint(),
                    SizedBox(height: 24.h),
                    _CreatePrimaryButton(onTap: _openCreate),
                  ],
                );
              }

              final results = _results;
              if (results.isEmpty) {
                return _NoResult(onCreate: _openCreate);
              }
              return Column(
                children: [
                  for (final p in results)
                    _ParentResultCard(
                      parent: p,
                      children: _childrenOf(p.uid),
                      isLoading: _isLoading,
                      onLink: () => _linkExisting(p),
                    ),
                  SizedBox(height: 8.h),
                  _CreateInlineButton(onTap: _openCreate),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'rc_parent_assign_create_new'.tr,
                style: context.typography.displaySmBold.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            TextButton(
              onPressed: () => _showCreate.value = false,
              child: Text('common_cancel'.tr,
                  style: context.typography.xsRegular.copyWith(
                      fontSize: 13, color: const Color(0xFF8A93A4))),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        FieldLabel('guardian_name_label'.tr),
        SizedBox(height: 8.h),
        _Input(
          controller: _nameCtrl,
          hint: 'guardian_name_hint'.tr,
          keyboardType: TextInputType.name,
        ),
        SizedBox(height: 18.h),
        FieldLabel('guardian_create_phone_label'.tr),
        SizedBox(height: 8.h),
        _Input(
          controller: _phoneCtrl,
          hint: 'guardian_create_phone_hint'.tr,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 26.h),
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: _isLoading.value ? null : _createAndLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: _isLoading.value
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
                      style: context.typography.mdBold.copyWith(
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
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
            Icon(Icons.child_care_rounded,
                size: 20.sp, color: const Color(0xFF16A34A)),
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

class _SearchInput extends StatelessWidget {
  final TextEditingController controller;
  const _SearchInput({required this.controller});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        style: context.typography.smRegular.copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
        decoration: _decoration('rc_parent_assign_search_hint'.tr).copyWith(
          prefixIcon: Icon(Icons.search_rounded,
              color: const Color(0xFF94A3B8), size: 22.sp),
        ),
      );
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: 36.h),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.person_search_rounded,
                  size: 56.sp, color: const Color(0xFFCBD5E1)),
              SizedBox(height: 12.h),
              Text(
                'rc_parent_assign_search_empty'.tr,
                textAlign: TextAlign.center,
                style: context.typography.smRegular.copyWith(
                  fontSize: 14,
                  color: const Color(0xFF8A93A4),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
}

class _NoResult extends StatelessWidget {
  final VoidCallback onCreate;
  const _NoResult({required this.onCreate});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: 24.h),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 52.sp, color: const Color(0xFFCBD5E1)),
            SizedBox(height: 10.h),
            Text(
              'rc_parent_assign_no_result'.tr,
              style: context.typography.displaySmBold.copyWith(
                fontSize: 15,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 18.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: onCreate,
                icon: Icon(Icons.person_add_alt_1_rounded, size: 20.sp),
                label: Text(
                  'rc_parent_assign_create_new'.tr,
                  style: context.typography.displaySmBold.copyWith(
                      fontSize: 15),
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
          ],
        ),
      );
}

class _CreatePrimaryButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CreatePrimaryButton({required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(Icons.person_add_alt_1_rounded, size: 20.sp),
          label: Text(
            'rc_parent_assign_create_new'.tr,
            style: context.typography.displaySmBold.copyWith(fontSize: 15),
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
      );
}

class _CreateInlineButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateInlineButton({required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 50.h,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(Icons.person_add_alt_1_rounded, size: 20.sp),
          label: Text(
            'rc_parent_assign_create_new'.tr,
            style:
                context.typography.displaySmBold.copyWith(fontSize: 14.5),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
        ),
      );
}

class _ParentResultCard extends StatelessWidget {
  final ParentModel parent;
  final List<String> children;
  final RxBool isLoading;
  final VoidCallback onLink;

  const _ParentResultCard({
    required this.parent,
    required this.children,
    required this.isLoading,
    required this.onLink,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    parent.name.isNotEmpty ? parent.name[0] : '?',
                    style: context.typography.mdBold.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parent.name,
                        style: context.typography.mdBold.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        parent.phone ?? '',
                        style: context.typography.xsRegular.copyWith(
                          fontSize: 13.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              'rc_parent_assign_children_label'.tr,
              style: context.typography.displaySmBold.copyWith(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
            ),
            SizedBox(height: 6.h),
            if (children.isEmpty)
              Text(
                'rc_parent_assign_no_children'.tr,
                style: context.typography.xsRegular.copyWith(
                    fontSize: 13, color: const Color(0xFFCBD5E1)),
              )
            else
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: [
                  for (final c in children)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        c,
                        style: context.typography.smSemiBold.copyWith(
                          fontSize: 12.5,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                ],
              ),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: Obx(
                () => ElevatedButton(
                  onPressed: isLoading.value ? null : onLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'rc_parent_assign_link_child'.tr,
                    style: context.typography.displaySmBold.copyWith(
                        fontSize: 14.5),
                  ),
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
        controller: controller,
        keyboardType: keyboardType,
        style: context.typography.smRegular.copyWith(fontSize: 15, color: const Color(0xFF1E293B)),
        decoration: _decoration(hint),
      );
}

InputDecoration _decoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
