import '../../../../index/index_main.dart';

class ParentRequestsController extends GetxController {
  late final ChildLeaveRequestParentService _leaveService;
  late final ParentChildParentService _parentChildService;
  late final ChildParentService _childService;

  final RxList<ChildLeaveRequestModel> items = <ChildLeaveRequestModel>[].obs;
  final RxList<ChildLeaveRequestModel> _all = <ChildLeaveRequestModel>[].obs;
  final RxMap<String, String> childNames = <String, String>{}.obs;
  final RxBool isLoading = true.obs;
  final RxString selectedStatus = ''.obs;

  final _session = SessionService();

  @override
  void onInit() {
    super.onInit();
    _leaveService      = Get.find<ChildLeaveRequestParentService>();
    _parentChildService = Get.find<ParentChildParentService>();
    _childService      = Get.find<ChildParentService>();
    ever(selectedStatus, (_) => _filter());
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;

    final myChildIds = <String>{};

    await _parentChildService.getAll(callBack: (list) {
      for (final pc in list.whereType<ParentChildModel>()) {
        if (pc.parentId == _session.userId) myChildIds.add(pc.childId);
      }
    });

    await _childService.getAll(callBack: (list) {
      final map = <String, String>{};
      for (final c in list.whereType<ChildModel>()) {
        if (c.key != null && myChildIds.contains(c.key)) {
          map[c.key!] = c.fullName;
        }
      }
      childNames.value = map;
    });

    await _leaveService.getAll(callBack: (list) {
      _all.value = list
          .whereType<ChildLeaveRequestModel>()
          .where((r) => myChildIds.contains(r.childId))
          .toList()
        ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
      _filter();
    });

    isLoading.value = false;
  }

  void _filter() {
    final s = selectedStatus.value;
    items.value = s.isEmpty
        ? List.from(_all)
        : _all.where((r) => r.status == s).toList();
  }

  void setStatus(String s) =>
      selectedStatus.value = (selectedStatus.value == s) ? '' : s;

  String childName(String id) => childNames[id] ?? '';

  void openAdd() => _openSheet(null);

  void _openSheet(ChildLeaveRequestModel? item) {
    if (childNames.isEmpty) {
      Loader.showError('parent_req_no_children'.tr);
      return;
    }
    Get.bottomSheet(
      _ParentLeaveSheet(initial: item, childNames: childNames),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ).then((_) => _load());
  }

  Future<void> delete(ChildLeaveRequestModel item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('parent_req_delete_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'common_delete'.tr,
              style: TextStyle(color: AppColors.errorForeground),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    Loader.show();
    await _leaveService.delete(
      id: item.key ?? '',
      callBack: (s) {
        Loader.dismiss();
        if (s == ResponseStatus.success) {
          Loader.showSuccess('parent_req_delete_success'.tr);
          _load();
        } else {
          Loader.showError('parent_req_error'.tr);
        }
      },
    );
  }
}

// ─── Add / Edit Sheet ─────────────────────────────────────────────────────────

class _ParentLeaveSheet extends StatefulWidget {
  final ChildLeaveRequestModel? initial;
  final RxMap<String, String> childNames;

  const _ParentLeaveSheet({this.initial, required this.childNames});

  @override
  State<_ParentLeaveSheet> createState() => _ParentLeaveSheetState();
}

class _ParentLeaveSheetState extends State<_ParentLeaveSheet> {
  late final ChildLeaveRequestParentService _service;
  String? _childId;
  int? _startDate;
  int? _endDate;
  final _reasonCtrl = TextEditingController();
  bool _loading = false;
  final _session = SessionService();

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _service = Get.find<ChildLeaveRequestParentService>();
    if (_isEdit) {
      final i = widget.initial!;
      _childId    = i.childId;
      _startDate  = i.startDate;
      _endDate    = i.endDate;
      _reasonCtrl.text = i.reason;
    }
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  String _fmt(int? ts) {
    if (ts == null) return 'child_leave_pick_date'.tr;
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    return '${d.day}/${d.month}/${d.year}';
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showAppDatePicker(
      context,
      initialDate: DateTime.now(),
      minimumDate: DateTime(2020),
      maximumDate: DateTime(2030),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) _startDate = picked.millisecondsSinceEpoch;
      else          _endDate   = picked.millisecondsSinceEpoch;
    });
  }

  Future<void> _save() async {
    if (_childId == null) { Loader.showError('child_leave_error_child'.tr); return; }
    if (_startDate == null) { Loader.showError('child_leave_error_start'.tr); return; }
    if (_endDate == null) { Loader.showError('child_leave_error_end'.tr); return; }
    if (_reasonCtrl.text.trim().isEmpty) {
      Loader.showError('child_leave_error_reason'.tr); return;
    }

    setState(() => _loading = true);
    Loader.show();

    final model = ChildLeaveRequestModel(
      key: widget.initial?.key ?? const Uuid().v4(),
      nurseryId:   _session.nurseryId ?? '',
      childId:     _childId!,
      requestedBy: _session.userId ?? '',
      startDate:   _startDate!,
      endDate:     _endDate!,
      reason:      _reasonCtrl.text.trim(),
      status:      widget.initial?.status ?? 'pending',
      createdAt:   widget.initial?.createdAt,
    );

    void cb(ResponseStatus s) {
      Loader.dismiss();
      if (mounted) setState(() => _loading = false);
      if (s == ResponseStatus.success) {
        Loader.showSuccess('parent_req_submit_success'.tr);
        Get.back();
      } else {
        Loader.showError('parent_req_error'.tr);
      }
    }

    if (_isEdit) {
      await _service.update(item: model, callBack: cb);
    } else {
      await _service.add(item: model, callBack: cb);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isEdit
                    ? 'child_leave_edit_title'.tr
                    : 'parent_req_add'.tr,
                style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'parent_req_child_label'.tr,
                style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String>(
                value: _childId,
                hint: Text('child_leave_child_hint'.tr),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                items: widget.childNames.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) => setState(() => _childId = v),
              )),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _DatePick(
                  label: 'child_leave_start_date'.tr,
                  value: _fmt(_startDate),
                  onTap: () => _pickDate(true),
                )),
                const SizedBox(width: 12),
                Expanded(child: _DatePick(
                  label: 'child_leave_end_date'.tr,
                  value: _fmt(_endDate),
                  onTap: () => _pickDate(false),
                )),
              ]),
              const SizedBox(height: 16),
              Text(
                'parent_req_reason_label'.tr,
                style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reasonCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'parent_req_reason_hint'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'parent_req_submit'.tr,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePick extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DatePick(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: Color(0xFF475569))),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF1E293B))),
            ),
          ]),
        ),
      ),
    ],
  );
}
