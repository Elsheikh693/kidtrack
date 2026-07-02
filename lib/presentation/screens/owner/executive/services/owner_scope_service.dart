import '../../../../../index/index_main.dart';

/// Holds the owner's current viewing scope (network vs a single branch) and the
/// list of branches the switcher offers. Permanent + reactive: the executive
/// controller listens to [scope] and reloads its metrics whenever it changes.
///
/// Single-branch owners never need a switch, so [isMultiBranch] is false and the
/// AppBar switcher hides itself — the experience stays clean and dynamic.
class OwnerScopeService extends GetxService {
  /// Active branches the owner can scope into (sorted by name).
  final RxList<BranchModel> branches = <BranchModel>[].obs;

  /// The current scope. Defaults to the whole network.
  final Rx<OwnerScope> scope = const OwnerScope.network().obs;

  final RxBool isLoadingBranches = false.obs;

  /// Only worth showing the switcher when there's more than one branch.
  bool get isMultiBranch => branches.length > 1;

  /// Label for the AppBar pill — branch name, or the "all branches" key.
  String get currentLabel =>
      scope.value.isNetwork ? 'owner_scope_all_branches'.tr : scope.value.branchName ?? '';

  Future<void> loadBranches() async {
    isLoadingBranches.value = true;
    try {
      final list = await _fetchBranches();
      list.sort((a, b) => a.name.compareTo(b.name));
      branches.assignAll(list);

      // If the pinned branch vanished (deactivated/deleted), fall back to network.
      final pinned = scope.value.branchId;
      if (pinned != null && !list.any((b) => b.key == pinned)) {
        scope.value = const OwnerScope.network();
      }
    } finally {
      isLoadingBranches.value = false;
    }
  }

  void selectNetwork() => scope.value = const OwnerScope.network();

  void selectBranch(BranchModel branch) =>
      scope.value = OwnerScope.branch(branch.key ?? '', branch.name);

  Future<List<BranchModel>> _fetchBranches() {
    final completer = Completer<List<BranchModel>>();
    Get.find<BaseService<BranchModel>>(tag: 'branches').getData(
      data: {},
      voidCallBack: (list) {
        if (!completer.isCompleted) {
          completer.complete(
            list.whereType<BranchModel>().where((b) => b.isActive).toList(),
          );
        }
      },
    );
    return completer.future;
  }
}
