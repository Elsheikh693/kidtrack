import '../../../../../index/index_main.dart';

/// One row on the bulk-invitations screen: a guardian plus the names of every
/// child linked to them, so the receptionist can send a single WhatsApp
/// invitation that covers all of that parent's children.
class ParentInviteRow {
  final ParentModel parent;
  final List<String> childNames;

  const ParentInviteRow({required this.parent, required this.childNames});

  ParentOnboardingStatus get status => parent.onboardingStatus;

  bool get hasPhone => (parent.phone ?? '').trim().isNotEmpty;

  ParentInviteRow copyWith({ParentModel? parent}) => ParentInviteRow(
    parent: parent ?? this.parent,
    childNames: childNames,
  );
}
