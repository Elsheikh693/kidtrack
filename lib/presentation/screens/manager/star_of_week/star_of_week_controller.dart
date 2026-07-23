import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../index/index_main.dart';

/// Drives the "Star of the Week" picker: loads the branch's active children,
/// lets the manager choose one + write a caption, then publishes the pick (feed
/// post + stored record) and surfaces the current week's star.
class StarOfWeekController extends GetxController {
  final children = <ChildModel>[].obs;
  final filteredChildren = <ChildModel>[].obs;
  final searchQuery = ''.obs;
  final selectedChild = Rxn<ChildModel>();
  final currentStar = Rxn<StarOfWeekModel>();

  /// Optional manager-supplied photo for the post. When set it replaces the
  /// child's avatar in both the post and the reveal; when null the child's
  /// profile photo is used.
  final customPhoto = Rxn<File>();

  final isLoading = false.obs;
  final isPublishing = false.obs;

  final searchController = TextEditingController();
  final captionController = TextEditingController();

  late final ChildParentService _childSvc;
  late final StarOfWeekParentService _starSvc;
  late final SessionService _session;
  late Worker _searchWorker;

  /// Only a branch manager (or an owner acting as one) may pick.
  bool get canPick =>
      _session.isOwner || _session.effectiveRole == UserType.branchManager;

  String get _branchId => _session.branchId ?? '';

  @override
  void onInit() {
    super.onInit();
    _childSvc = Get.find<ChildParentService>();
    _starSvc = Get.find<StarOfWeekParentService>();
    _session = SessionService();

    loadData();

    _searchWorker = debounce(
      searchQuery,
      (_) => _filter(),
      time: const Duration(milliseconds: 300),
    );
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.wait([_loadChildren(), _loadCurrentStar()]);
    isLoading.value = false;
  }

  Future<void> _loadChildren() async {
    await _childSvc.getAll(callBack: (list) {
      final branch = _branchId;
      final result = list
          .whereType<ChildModel>()
          .where((c) => branch.isEmpty || c.branchId == branch)
          .where((c) => c.status == 'active')
          .toList()
        ..sort((a, b) => a.fullName.compareTo(b.fullName));
      children.assignAll(result);
      _filter();
    });
  }

  Future<void> _loadCurrentStar() async {
    await _starSvc.getAll(callBack: (list) {
      final week = StarOfWeekModel.currentWeekKey();
      final branch = _branchId;
      final match = list.whereType<StarOfWeekModel>().where((s) =>
          s.weekKey == week && (branch.isEmpty || s.branchId == branch));
      currentStar.value = match.isEmpty ? null : match.first;
    });
  }

  void _filter() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      filteredChildren.assignAll(children);
      return;
    }
    filteredChildren.assignAll(
      children.where((c) => c.fullName.toLowerCase().contains(q)),
    );
  }

  void onSearchChanged(String v) => searchQuery.value = v;

  void select(ChildModel child) {
    if (selectedChild.value?.key == child.key) {
      selectedChild.value = null;
    } else {
      selectedChild.value = child;
    }
    // The custom photo belongs to a specific pick — drop it when the target
    // child changes so it never leaks onto the wrong celebration.
    customPhoto.value = null;
  }

  void clearSelection() {
    selectedChild.value = null;
    customPhoto.value = null;
  }

  bool isSelected(ChildModel child) => selectedChild.value?.key == child.key;

  /// Take/pick a photo to use as the post image (overrides the child's avatar).
  Future<void> pickPhoto() async {
    final source = await showImageSourceSheet();
    if (source == null) return;
    await PickedImage().pickImage(
      source: source,
      callBack: (file) async {
        if (file != null) customPhoto.value = file;
      },
    );
  }

  void removePhoto() => customPhoto.value = null;

  /// Publishes the current selection. Returns the saved star on success (so the
  /// view can play the reveal), or null on validation failure / error.
  Future<StarOfWeekModel?> publish() async {
    final child = selectedChild.value;
    final caption = captionController.text.trim();

    if (child == null) {
      Loader.showError('sotw_no_selection'.tr);
      return null;
    }
    if (caption.isEmpty) {
      Loader.showError('sotw_caption_required'.tr);
      return null;
    }

    final week = StarOfWeekModel.currentWeekKey();
    final star = StarOfWeekModel(
      key: StarOfWeekModel.idFor(_branchId, week),
      nurseryId: _session.nurseryId ?? '',
      branchId: _branchId,
      weekKey: week,
      childId: child.key ?? '',
      childName: child.fullName,
      childPhotoUrl: child.profileImage,
      caption: caption,
      pickedById: _session.userId ?? '',
      pickedByName: _session.currentUser?.displayName ?? 'المدير',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    isPublishing.value = true;
    Loader.show();
    // Replacing this week's pick? Remove the previous pick's now-orphaned post.
    final previousPostId = currentStar.value?.postId;
    final published = await _starSvc.publish(
      star: star,
      previousPostId: previousPostId,
      customImage: customPhoto.value,
    );
    isPublishing.value = false;
    Loader.dismiss();

    if (published != null) {
      currentStar.value = published;
      selectedChild.value = null;
      customPhoto.value = null;
      captionController.clear();
      searchController.clear();
      searchQuery.value = '';
      Loader.showSuccess('sotw_publish_success'.tr);
    } else {
      Loader.showError('sotw_publish_error'.tr);
    }
    return published;
  }

  @override
  void onClose() {
    _searchWorker.dispose();
    searchController.dispose();
    captionController.dispose();
    super.onClose();
  }
}
