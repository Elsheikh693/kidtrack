import '../../../../index/index_main.dart';

class PickupVerificationController extends GetxController {
  final authorizedPersons = <AuthorizedPickupModel>[].obs;
  final child = Rx<ChildModel?>(null);
  final isLoading = false.obs;

  late final AuthorizedPickupParentService _pickupSvc;
  late final ChildParentService _childSvc;
  late final ChildAttendanceParentService _attendanceSvc;

  final _session = SessionService();

  String get childId =>
      Get.arguments is Map ? (Get.arguments as Map)['childId'] ?? '' : '';

  @override
  void onInit() {
    super.onInit();
    _pickupSvc = Get.find<AuthorizedPickupParentService>();
    _childSvc = Get.find<ChildParentService>();
    _attendanceSvc = Get.find<ChildAttendanceParentService>();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    await _loadChild();
    await _loadAuthorizedPersons();
    isLoading.value = false;
  }

  Future<void> _loadChild() async {
    await _childSvc.getAll(callBack: (list) {
      child.value = list
          .whereType<ChildModel>()
          .where((c) => c.key == childId)
          .firstOrNull;
    });
  }

  Future<void> _loadAuthorizedPersons() async {
    await _pickupSvc.getAll(callBack: (list) {
      authorizedPersons.value = list
          .whereType<AuthorizedPickupModel>()
          .where((p) => p.childId == childId && p.isCurrentlyValid)
          .toList();
    });
  }

  Future<void> confirmPickup(AuthorizedPickupModel person) async {
    Loader.show();
    final today = _todayString();

    ChildAttendanceModel? todayRecord;
    await _attendanceSvc.getAll(callBack: (list) {
      todayRecord = list
          .whereType<ChildAttendanceModel>()
          .where((a) => a.childId == childId && a.date == today)
          .firstOrNull;
    });

    if (todayRecord == null) {
      Loader.showError('pickup_no_attendance_record'.tr);
      return;
    }

    final updated = todayRecord!.copyWith(
      checkOutTime: DateTime.now().millisecondsSinceEpoch,
      checkOutBy: _session.userId,
      pickedUpByName: person.name,
      pickedUpByRelationship: person.relationship,
    );

    await _attendanceSvc.update(
      item: updated,
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('pickup_confirmed'.tr);
          Get.back();
        } else {
          Loader.showError('common_error'.tr);
        }
      },
    );
  }

  void reportUnauthorized(BuildContext context) {
    Get.bottomSheet(
      _UnauthorizedSheet(childId: childId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

class _UnauthorizedSheet extends StatelessWidget {
  final String childId;
  const _UnauthorizedSheet({required this.childId});

  @override
  Widget build(BuildContext context) {
    final notesCtrl = TextEditingController();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'pickup_unauthorized_title'.tr,
              style: context.typography.mdBold
                  .copyWith(color: AppColors.errorForeground),
            ),
            const SizedBox(height: 6),
            Text(
              'pickup_unauthorized_subtitle'.tr,
              style: context.typography.smRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: notesCtrl,
              labelText: 'pickup_unauthorized_notes_label'.tr,
              hintText: 'pickup_unauthorized_notes_hint'.tr,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Loader.showError('pickup_child_not_released'.tr);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'pickup_unauthorized_record'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
