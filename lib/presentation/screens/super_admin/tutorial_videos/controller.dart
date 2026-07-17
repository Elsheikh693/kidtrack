import 'dart:io';

import '../../../../index/index_main.dart';
import 'widgets/tutorial_video_sheet.dart';

/// SuperAdmin manager for the platform tutorial-video catalogue: list, add,
/// edit, delete, and upload the raw video/thumbnail files to Firebase Storage.
class SaTutorialVideosController extends GetxController {
  late final TutorialVideoParentService _service;

  final RxList<TutorialVideoModel> items = <TutorialVideoModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<TutorialVideoParentService>();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        items.value = list.whereType<TutorialVideoModel>().toList()
          ..sort((a, b) => a.order.compareTo(b.order));
      },
    );
    isLoading.value = false;
  }

  void openAdd() => _openSheet(null);
  void openEdit(TutorialVideoModel item) => _openSheet(item);

  void _openSheet(TutorialVideoModel? item) {
    Get.bottomSheet(
      TutorialVideoSheet(existing: item),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> delete(TutorialVideoModel item) async {
    Loader.show();
    await _service.delete(
      id: item.key ?? '',
      callBack: (status) async {
        if (status == ResponseStatus.success) {
          await _service.deleteMedia(item.key ?? '');
          Loader.showSuccess('tutorial_admin_deleted'.tr);
          loadData();
        } else {
          Loader.showError('tutorial_admin_error'.tr);
        }
      },
    );
  }

  /// Uploads any newly-picked media then persists the model. Called by the
  /// add/edit sheet with its collected inputs.
  Future<void> saveVideo({
    TutorialVideoModel? existing,
    required String title,
    String? description,
    required int order,
    required List<String> audience,
    required bool isActive,
    File? videoFile,
    File? thumbFile,
  }) async {
    final isNew = existing == null;
    final key = existing?.key ?? 'tv_${DateTime.now().millisecondsSinceEpoch}';

    if (isNew && videoFile == null) {
      Loader.showError('tutorial_video_required'.tr);
      return;
    }
    if (audience.isEmpty) {
      Loader.showError('tutorial_audience_required'.tr);
      return;
    }

    try {
      String videoUrl = existing?.videoUrl ?? '';
      String? thumbUrl = existing?.thumbnailUrl;

      if (videoFile != null) {
        Loader.showUploadProgress();
        videoUrl = await _service.uploadVideo(
          id: key,
          file: videoFile,
          onProgress: Loader.updateUploadProgress,
        );
        Loader.hideUploadProgress();
      }
      if (thumbFile != null) {
        thumbUrl = await _service.uploadThumbnail(id: key, file: thumbFile);
      }

      final model = TutorialVideoModel(
        key: key,
        title: title,
        description: (description?.trim().isEmpty ?? true)
            ? null
            : description!.trim(),
        videoUrl: videoUrl,
        thumbnailUrl: thumbUrl,
        audience: audience,
        order: order,
        isActive: isActive,
        createdAt:
            existing?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
      );

      void done(ResponseStatus status) {
        if (status == ResponseStatus.success) {
          Loader.showSuccess(
              isNew ? 'tutorial_admin_saved'.tr : 'tutorial_admin_updated'.tr);
          Get.back();
        } else {
          Loader.showError('tutorial_admin_error'.tr);
        }
      }

      if (isNew) {
        await _service.add(item: model, callBack: done);
      } else {
        await _service.update(item: model, callBack: done);
      }
    } catch (_) {
      Loader.hideUploadProgress();
      Loader.showError('tutorial_admin_error'.tr);
    }
  }
}
