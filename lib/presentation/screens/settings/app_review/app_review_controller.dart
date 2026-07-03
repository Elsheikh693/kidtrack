import '../../../../index/index_main.dart';

/// Pre-login capture of a KidTrack app rating ("قولنا كلمة حلوة").
class AppReviewController extends GetxController {
  late final AppReviewParentService _service;

  final commentCtrl = TextEditingController();

  final RxInt rating = 0.obs;
  final RxBool isSubmitting = false.obs;
  final RxSet<String> selectedTags = <String>{}.obs;

  static const List<String> ratingKeys = [
    '',
    'nursery_feedback_rating_1',
    'nursery_feedback_rating_2',
    'nursery_feedback_rating_3',
    'nursery_feedback_rating_4',
    'nursery_feedback_rating_5',
  ];

  /// Stable keys stored in Firebase; labels are `.tr` so admin sees them in
  /// their own language regardless of the reviewer's locale.
  static const List<String> tagKeys = [
    'app_review_tag_tracking',
    'app_review_tag_linkbook',
    'app_review_tag_courses',
    'app_review_tag_reports',
    'app_review_tag_communication',
    'app_review_tag_reassure',
  ];

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<AppReviewParentService>();
  }

  @override
  void onClose() {
    commentCtrl.dispose();
    super.onClose();
  }

  void setRating(int value) => rating.value = value;

  void toggleTag(String tagKey) {
    if (selectedTags.contains(tagKey)) {
      selectedTags.remove(tagKey);
    } else {
      selectedTags.add(tagKey);
    }
  }

  Future<void> submit() async {
    if (rating.value == 0) {
      Loader.showError('app_review_pick_rating'.tr);
      return;
    }
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    Loader.show();

    final comment = commentCtrl.text.trim();
    final name = SessionService().currentUser?.name?.trim();

    final model = AppReviewModel(
      key: const Uuid().v4(),
      name: (name == null || name.isEmpty) ? null : name,
      rating: rating.value,
      comment: comment.isEmpty ? null : comment,
      tags: selectedTags.toList(),
    );

    await _service.add(
      item: model,
      callBack: (status) {
        isSubmitting.value = false;
        if (status == ResponseStatus.success) {
          Loader.showSuccess('app_review_success'.tr);
          Get.back();
        } else {
          Loader.showError('app_review_error'.tr);
        }
      },
    );
  }
}
