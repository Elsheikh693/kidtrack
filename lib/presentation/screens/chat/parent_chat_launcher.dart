import '../../../index/index_main.dart';

/// Opens the manager↔parent conversation for the parent's currently-active
/// child. Shared by the parent home card and the account menu item so both
/// build the conversation meta the same way.
Future<void> openParentChat() async {
  final active = Get.find<ActiveChildService>();
  final session = SessionService();

  final childId = active.childId.value;
  if (childId.isEmpty) {
    Get.snackbar(
      '',
      'chat_no_active_child'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.white,
      colorText: AppColors.textDefault,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
    return;
  }

  final childOption = active.children.firstWhereOrNull((c) => c.id == childId);
  final meta = ChatConversationModel(
    childId: childId,
    childName: active.childName.value,
    childImage: childOption?.image,
    classroomId: active.classroomId.value,
    branchId: active.branchId.value,
    parentId: session.userId ?? '',
    parentName: session.currentUser?.displayName ?? '',
  );

  await ChatService().markRead(childId, 'parent');
  Get.toNamed(chatThreadView, arguments: {
    'meta': meta,
    'senderRole': 'parent',
    'title': 'chat_with_nursery'.tr,
    'subtitle': active.childName.value,
    'image': childOption?.image,
  });
}
