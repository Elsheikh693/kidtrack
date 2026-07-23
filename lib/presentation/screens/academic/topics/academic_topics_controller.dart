import 'package:flutter/material.dart';
import '../../../../index/index_main.dart';

class AcademicTopicsController extends GetxController {
  final _service = TeacherAcademicService();
  final _session = SessionService();

  // Passed via Get.arguments: {'subjectId': '...', 'subjectName': '...'}
  late final String subjectId;
  late final String subjectName;

  final RxBool isLoading = true.obs;
  final RxList<AcademicTopicModel> topics = <AcademicTopicModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    subjectId = args['subjectId']?.toString() ?? '';
    subjectName = args['subjectName']?.toString() ?? 'presentati10_subject'.tr;
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    topics.value = await _service.loadTopics(subjectId: subjectId);
    isLoading.value = false;
  }

  void showAddSheet() {
    _showTopicSheet(null);
  }

  void showEditSheet(AcademicTopicModel topic) {
    _showTopicSheet(topic);
  }

  void _showTopicSheet(AcademicTopicModel? topic) {
    Get.bottomSheet(
      _TopicSheet(
        topic: topic,
        subjectId: subjectId,
        nurseryId: _session.nurseryId ?? '',
        order: topics.length,
        onSave: (t) async {
          Get.back();
          if (topic == null) {
            await _service.createTopic(t);
          } else {
            await _service.updateTopic(t);
          }
          await _load();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void confirmDelete(AcademicTopicModel topic) {
    Get.dialog(
      Directionality(
        textDirection: appTextDirection,
        child: AlertDialog(
          title: Text('presentati10_delete_topic_title'.tr),
          content: Text(
              '${'presentati10_delete_topic_confirm'.tr} "${topic.title}"؟'),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text('presentati10_cancel'.tr),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                await _service.deleteTopic(topic.key ?? '');
                await _load();
              },
              child: Text('presentati10_delete'.tr,
                  style: const TextStyle(color: Color(0xFFDC2626))),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> refresh() => _load();
}

// ── Topic Sheet ───────────────────────────────────────────────────────────────

class _TopicSheet extends StatefulWidget {
  const _TopicSheet({
    required this.topic,
    required this.subjectId,
    required this.nurseryId,
    required this.order,
    required this.onSave,
  });
  final AcademicTopicModel? topic;
  final String subjectId;
  final String nurseryId;
  final int order;
  final Future<void> Function(AcademicTopicModel) onSave;

  @override
  State<_TopicSheet> createState() => _TopicSheetState();
}

class _TopicSheetState extends State<_TopicSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.topic?.title ?? '');
    _descCtrl = TextEditingController(text: widget.topic?.description ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      Get.snackbar('presentati10_alert'.tr, 'presentati10_enter_topic_name'.tr);
      return;
    }
    setState(() => _saving = true);
    try {
      final topic = (widget.topic ?? AcademicTopicModel(
        nurseryId: widget.nurseryId,
        subjectId: widget.subjectId,
        title: title,
        order: widget.order,
      )).copyWith(
        title: title,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
      await widget.onSave(topic);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.topic != null;
    return Directionality(
      textDirection: appTextDirection,
      child: Container(
        margin: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        padding: EdgeInsets.fromLTRB(
            20.w, 20.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.menu_book_rounded,
                      color: Color(0xFFD97706), size: 20.sp),
                ),
                SizedBox(width: 10.w),
                Text(
                  isEdit
                      ? 'presentati10_edit_topic'.tr
                      : 'presentati10_add_topic'.tr,
                  style: context.typography.mdBold.copyWith(
                      fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'presentati10_topic_name_label'.tr,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                prefixIcon: const Icon(Icons.title_rounded),
              ),
              autofocus: true,
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'presentati10_description_optional'.tr,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                prefixIcon: const Icon(Icons.description_rounded),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: _saving
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        isEdit
                            ? 'presentati10_save_changes'.tr
                            : 'presentati10_add_topic_btn'.tr,
                        style: context.typography.displaySmBold.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
