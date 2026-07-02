import '../../../../index/index_main.dart';

class ManagerMoreController extends GetxController {
  final branchName = ''.obs;
  final pendingApplications = 0.obs;

  late final BranchParentService _branchSvc;
  late final OnlineApplicationParentService _applicationSvc;
  final _session = SessionService();

  String get userName => _session.currentUser?.displayName ?? '';
  String get userPhone => _session.currentUser?.phone ?? '';
  String get userImage => _session.currentUser?.profileImage ?? '';
  String get branchId => _session.branchId ?? '';

  @override
  void onInit() {
    super.onInit();
    _branchSvc = Get.find<BranchParentService>();
    _applicationSvc = Get.find<OnlineApplicationParentService>();
    _loadBranch();
    loadPendingApplications();
  }

  Future<void> loadPendingApplications() async {
    await _applicationSvc.getAll(callBack: (list) {
      pendingApplications.value = list
          .whereType<OnlineApplicationModel>()
          .where((a) => a.isPending)
          .length;
    });
  }

  Future<void> _loadBranch() async {
    if (branchId.isEmpty) return;
    await _branchSvc.getAll(callBack: (list) {
      for (final b in list.whereType<BranchModel>()) {
        if (b.key == branchId) {
          branchName.value = b.name;
          break;
        }
      }
    });
  }
}
