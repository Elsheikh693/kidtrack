import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Data/models/branch/branch_model.dart';
import '../../../Data/models/classroom/classroom_model.dart';
import '../../../Data/models/feed/nursery_post_model.dart';
import '../../../Global/services/feed_service.dart';
import '../../../Global/services/session_service.dart';
import '../../parentControllers/services/branch_parent_service.dart';
import '../../parentControllers/services/classroom_parent_service.dart';
import '../../../Global/Localization/app_direction.dart';

class FeedController extends GetxController {
  final _service = FeedService();

  final RxList<NurseryPostModel> posts = <NurseryPostModel>[].obs;
  final Rx<PostCategory?> selectedCategory = Rx<PostCategory?>(null);
  final RxBool isLoading = true.obs;

  StreamSubscription<List<NurseryPostModel>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = _service.watchFeed().listen((data) {
      posts.value = data;
      isLoading.value = false;
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  List<NurseryPostModel> get filteredPosts {
    final cat = selectedCategory.value;
    if (cat == null) return posts;
    return posts.where((p) => p.category == cat).toList();
  }

  List<NurseryPostModel> get pinnedPosts =>
      filteredPosts.where((p) => p.isPinned).toList();

  List<NurseryPostModel> get regularPosts =>
      filteredPosts.where((p) => !p.isPinned).toList();

  void filterBy(PostCategory? cat) => selectedCategory.value = cat;

  Future<void> togglePin(NurseryPostModel post) async {
    await _service.togglePin(post.id, post.isPinned);
  }

  Future<void> deletePost(NurseryPostModel post) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('feed14_delete_post_title'.tr, textDirection: appTextDirection),
        content: Text('feed14_delete_post_confirm'.tr,
            textDirection: appTextDirection),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('feed14_cancel'.tr)),
          TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('feed14_delete'.tr,
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.deletePost(post);
    }
  }
}

// ─── Create/Edit Post Controller ──────────────────────────────────────────────

class CreatePostController extends GetxController {
  CreatePostController({this.editPost});

  final NurseryPostModel? editPost;
  final _service = FeedService();
  final _classroomService = ClassroomParentService();
  final _branchService = BranchParentService();

  final textController = TextEditingController();
  final RxList<String> existingPhotos = <String>[].obs;
  final RxList<XFile> newImages = <XFile>[].obs;
  final Rx<PostCategory> category = PostCategory.general.obs;
  final RxBool isPinned = false.obs;
  final RxBool isSubmitting = false.obs;

  // Audience: null classroomId == everyone, otherwise a specific classroom.
  final RxList<ClassroomModel> classrooms = <ClassroomModel>[].obs;
  final Rxn<String> classroomId = Rxn<String>();

  // Branch scope: empty set == all branches, otherwise restricted to these ids.
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final RxSet<String> selectedBranchIds = <String>{}.obs;
  final RxBool isLoadingBranches = true.obs;

  @override
  void onInit() {
    super.onInit();
    if (editPost != null) {
      textController.text = editPost!.text;
      existingPhotos.value = List.from(editPost!.photos);
      category.value = editPost!.category;
      isPinned.value = editPost!.isPinned;
      classroomId.value = editPost!.classroomId;
      selectedBranchIds.addAll(editPost!.branchIds);
    }
    _loadClassrooms();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    await _branchService.getAll(callBack: (list) {
      branches.value = list.whereType<BranchModel>().toList();
    });
    isLoadingBranches.value = false;
  }

  void toggleAllBranches() => selectedBranchIds.clear();

  void toggleBranch(String id) {
    if (selectedBranchIds.contains(id)) {
      selectedBranchIds.remove(id);
    } else {
      selectedBranchIds.add(id);
    }
  }

  Future<void> _loadClassrooms() async {
    final branchId = SessionService().branchId;
    await _classroomService.getAll(callBack: (list) {
      final items = list
          .whereType<ClassroomModel>()
          .where((c) => c.isActive)
          .where((c) => branchId == null || branchId.isEmpty || c.isAllBranches || c.branchIds.contains(branchId))
          .toList();
      classrooms.value = items;
    });
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  int get totalPhotos => existingPhotos.length + newImages.length;

  Future<void> pickImages() async {
    if (totalPhotos >= 10) return;
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85);
    final remaining = 10 - totalPhotos;
    newImages.addAll(picked.take(remaining));
  }

  void removeExisting(String url) => existingPhotos.remove(url);
  void removeNew(int i) => newImages.removeAt(i);

  Future<void> submit() async {
    final text = textController.text.trim();
    if (text.isEmpty && totalPhotos == 0) return;
    isSubmitting.value = true;
    bool ok;
    if (editPost == null) {
      ok = await _service.createPost(
        text: text,
        images: List.from(newImages),
        category: category.value,
        isPinned: isPinned.value,
        branchIds: selectedBranchIds.toList(),
        classroomId: classroomId.value,
      );
    } else {
      ok = await _service.updatePost(
        post: editPost!,
        text: text,
        existingPhotos: List.from(existingPhotos),
        newImages: List.from(newImages),
        category: category.value,
        isPinned: isPinned.value,
        branchIds: selectedBranchIds.toList(),
        classroomId: classroomId.value,
      );
    }
    isSubmitting.value = false;
    if (ok) Get.back(result: true);
  }
}
