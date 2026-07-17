import '../../../../index/index_main.dart';
import 'widgets/showcase_roles.dart';

/// SuperAdmin manager for the public website showcase albums: per-role
/// screenshots that feed the "شوف كل تطبيق من جوّه" section. Upload, delete,
/// drag-to-reorder, and show/hide — all persisted to RTDB + Storage.
class SaShowcaseAlbumsController extends GetxController {
  late final ShowcaseShotParentService _service;

  final RxList<ShowcaseShotModel> allShots = <ShowcaseShotModel>[].obs;
  final RxString selectedRole = kShowcaseRoles.first.key.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<ShowcaseShotParentService>();
    loadData();
  }

  /// Shots for the currently-selected role, ordered.
  List<ShowcaseShotModel> get shotsForSelected => allShots
      .where((s) => s.role == selectedRole.value)
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));

  int shotCountFor(String role) =>
      allShots.where((s) => s.role == role).length;

  void selectRole(String role) => selectedRole.value = role;

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        allShots.value = list.whereType<ShowcaseShotModel>().toList();
      },
    );
    isLoading.value = false;
  }

  /// Pick an image from the gallery, upload it, and append it to the current
  /// album at the end of its order.
  Future<void> pickAndAdd() async {
    await PickedImage().pickImage(
      callBack: (file) async {
        if (file == null) return;
        final role = selectedRole.value;
        final key = 'ss_${DateTime.now().millisecondsSinceEpoch}';
        Loader.show();
        try {
          final url = await _service.uploadImage(id: key, file: file);
          final model = ShowcaseShotModel(
            key: key,
            role: role,
            imageUrl: url,
            order: shotCountFor(role),
            isActive: true,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          );
          await _service.add(
            item: model,
            callBack: (status) {
              if (status == ResponseStatus.success) {
                allShots.add(model);
                Loader.showSuccess('showcase_shot_added'.tr);
              } else {
                Loader.showError('showcase_error'.tr);
              }
            },
          );
        } catch (_) {
          Loader.showError('showcase_error'.tr);
        }
      },
    );
  }

  Future<void> delete(ShowcaseShotModel shot) async {
    Loader.show();
    await _service.delete(
      id: shot.key ?? '',
      callBack: (status) async {
        if (status == ResponseStatus.success) {
          await _service.deleteMedia(shot.key ?? '');
          allShots.removeWhere((s) => s.key == shot.key);
          Loader.showSuccess('showcase_shot_deleted'.tr);
        } else {
          Loader.showError('showcase_error'.tr);
        }
      },
    );
  }

  Future<void> toggleActive(ShowcaseShotModel shot) async {
    final updated = shot.copyWith(isActive: !shot.isActive);
    _replace(updated);
    await _service.update(
      item: updated,
      callBack: (status) {
        if (status != ResponseStatus.success) {
          _replace(shot); // revert
          Loader.showError('showcase_error'.tr);
        }
      },
    );
  }

  /// Drag-to-reorder within the current album. Reassigns [order] on every shot
  /// whose position changed and persists just those.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = shotsForSelected;
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;

    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);

    final changed = <ShowcaseShotModel>[];
    for (var i = 0; i < list.length; i++) {
      if (list[i].order != i) {
        final updated = list[i].copyWith(order: i);
        _replace(updated);
        changed.add(updated);
      }
    }

    for (final shot in changed) {
      await _service.update(item: shot, callBack: (_) {});
    }
  }

  void _replace(ShowcaseShotModel updated) {
    final i = allShots.indexWhere((s) => s.key == updated.key);
    if (i != -1) allShots[i] = updated;
  }
}
