import '../../../../index/index_main.dart';

enum ApplicationFilter { pending, approved, rejected }

class ManagerApplicationsController extends GetxController {
  late final OnlineApplicationParentService _service;
  late final ChildParentService _childService;
  late final ParentAccountService _accountService;
  final _session = SessionService();

  final RxList<OnlineApplicationModel> _all = <OnlineApplicationModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isProcessing = false.obs;
  final Rx<ApplicationFilter> filter = ApplicationFilter.pending.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<OnlineApplicationParentService>();
    _childService = Get.find<ChildParentService>();
    _accountService = Get.find<ParentAccountService>();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        _all.value = list.whereType<OnlineApplicationModel>().toList()
          ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
      },
    );
    isLoading.value = false;
  }

  int get pendingCount => _all.where((a) => a.isPending).length;

  List<OnlineApplicationModel> get filtered {
    switch (filter.value) {
      case ApplicationFilter.pending:
        return _all.where((a) => a.isPending).toList();
      case ApplicationFilter.approved:
        return _all.where((a) => a.isApproved).toList();
      case ApplicationFilter.rejected:
        return _all.where((a) => a.isRejected).toList();
    }
  }

  void setFilter(ApplicationFilter value) => filter.value = value;

  // ─── Approve ────────────────────────────────────────────────────────────--

  Future<void> approve(
    OnlineApplicationModel app, {
    required DateTime appointment,
  }) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    final childKey = const Uuid().v4();
    final child = ChildModel(
      key: childKey,
      nurseryId: _session.nurseryId ?? '',
      branchId: (app.branchId ?? '').isNotEmpty
          ? app.branchId!
          : (_session.branchId ?? ''),
      firstName: app.childFirstName,
      lastName: app.childLastName,
      profileImage: app.childPhoto,
      gender: app.childGender,
      dateOfBirth: app.childDateOfBirth,
      nationality: app.childNationality,
      bloodType: app.childBloodType,
      homeAddress: app.childAddress,
      status: 'active',
    );

    final childDone = Completer<ResponseStatus>();
    await _childService.add(item: child, callBack: childDone.complete);
    if (await childDone.future != ResponseStatus.success) {
      isProcessing.value = false;
      Loader.showError('apply_manage_error'.tr);
      return;
    }

    final fatherOk = await _accountService.createAccount(
      name: app.fatherName,
      phone: app.fatherPhone,
      password: app.fatherPhone,
      childIds: [childKey],
      relationship: 'father',
      onError: Loader.showError,
    );
    if (!fatherOk) {
      isProcessing.value = false;
      return; // account service already surfaced the error
    }

    // Second guardian account (mother). Skipped when she has no distinct phone,
    // since the phone doubles as the unique login identifier.
    if (app.motherPhone.isNotEmpty && app.motherPhone != app.fatherPhone) {
      await _accountService.createAccount(
        name: app.motherName,
        phone: app.motherPhone,
        password: app.motherPhone,
        childIds: [childKey],
        relationship: 'mother',
        onError: Loader.showError,
      );
    }

    final approved = app.copyWith(
      status: 'approved',
      createdChildId: childKey,
      appointmentAt: appointment.millisecondsSinceEpoch,
    );
    final updateDone = Completer<ResponseStatus>();
    await _service.update(
      item: approved,
      callBack: updateDone.complete,
    );
    await updateDone.future;

    isProcessing.value = false;
    await load();
    Loader.showSuccess('apply_manage_approved'.tr);
    sendWhatsApp(approved);
  }

  /// Opens WhatsApp to the primary guardian with a prepared acceptance message
  /// that includes the scheduled visit date/time.
  void sendWhatsApp(OnlineApplicationModel app) {
    final message = 'apply_whatsapp_message'.trParams({
      'parent': app.primaryName,
      'child': app.childFullName,
      'nursery': app.nurseryName ?? 'apply_whatsapp_our_nursery'.tr,
      'date': appointmentDate(app.appointmentAt),
      'time': appointmentTime(app.appointmentAt),
    });
    launchWhatsApp(app.primaryPhone, message: message);
  }

  static String appointmentDate(int? ms) {
    if (ms == null) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  }

  static String appointmentTime(int? ms) {
    if (ms == null) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final period = d.hour < 12 ? 'apply_time_am'.tr : 'apply_time_pm'.tr;
    return '$h:${d.minute.toString().padLeft(2, '0')} $period';
  }

  // ─── Reject ─────────────────────────────────────────────────────────────--

  Future<void> reject(OnlineApplicationModel app, String reason) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    final done = Completer<ResponseStatus>();
    await _service.update(
      item: app.copyWith(status: 'rejected', rejectionReason: reason),
      callBack: done.complete,
    );
    final status = await done.future;

    isProcessing.value = false;
    if (status == ResponseStatus.success) {
      await load();
      Loader.showSuccess('apply_manage_rejected'.tr);
    } else {
      Loader.showError('apply_manage_error'.tr);
    }
  }
}
