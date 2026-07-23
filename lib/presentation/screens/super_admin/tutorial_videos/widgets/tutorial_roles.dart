import '../../../../../index/index_main.dart';

/// The roles a tutorial video can be targeted at. Stored on the model as the
/// [UserType] name; labelled via these translation keys in the admin UI.
class TutorialRole {
  final UserType type;
  final String labelKey;

  const TutorialRole(this.type, this.labelKey);

  String get name => type.name;
}

const List<TutorialRole> kTutorialRoles = [
  TutorialRole(UserType.owner, 'tutorial_role_owner'),
  TutorialRole(UserType.branchManager, 'tutorial_role_manager'),
  TutorialRole(UserType.teacher, 'tutorial_role_teacher'),
  TutorialRole(UserType.receptionist, 'tutorial_role_reception'),
  TutorialRole(UserType.parent, 'tutorial_role_parent'),
];

/// Translated label for a stored role name (falls back to the raw name).
String tutorialRoleLabel(String roleName) {
  for (final r in kTutorialRoles) {
    if (r.name == roleName) return r.labelKey.tr;
  }
  return roleName;
}
