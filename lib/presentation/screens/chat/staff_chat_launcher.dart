import '../../../index/index_main.dart';

/// Opens the nursery ↔ guardian conversation for [child] from a staff context
/// (branch manager or receptionist).
///
/// There is a single conversation per child, keyed by `childId`. The nursery
/// side is always `senderRole: 'manager'`, so the manager and the receptionist
/// share the SAME thread with the parent — reception does not get a separate
/// conversation.
Future<void> openStaffChat({
  required ChildModel child,
  required String parentId,
  required String parentName,
}) async {
  final childId = child.key ?? '';
  if (childId.isEmpty) return;

  final meta = ChatConversationModel(
    childId: childId,
    childName: child.fullName,
    childImage: child.profileImage,
    classroomId: child.classroomId,
    branchId: child.branchId,
    parentId: parentId,
    parentName: parentName,
  );

  await ChatService().markRead(childId, 'manager');
  Get.toNamed(
    chatThreadView,
    arguments: {
      'meta': meta,
      'senderRole': 'manager',
      'title': child.fullName,
      'subtitle': parentName,
      'image': child.profileImage,
    },
  );
}
