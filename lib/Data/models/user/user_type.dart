enum UserType {
  superAdmin,
  owner,
  branchManager,
  teacher,
  nanny,
  receptionist,
  parent,
  busChaperone,
}

extension UserTypeExtension on UserType {
  static UserType fromString(String? value) {
    return UserType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserType.parent,
    );
  }

  bool get isStaffRole       => this != UserType.parent && this != UserType.superAdmin;
  /// True only for roles that own a record under `platform/{n}/staff`.
  /// The owner lives in `users/{uid}` + the nursery's `ownerIds`, NOT the staff
  /// node — so writing under staff for an owner creates a phantom staff record.
  bool get hasStaffRecord    => isStaffRole && this != UserType.owner;
  bool get canManageBranch   => this == UserType.owner || this == UserType.branchManager;
  bool get canCheckIn        => this == UserType.receptionist || this == UserType.owner || this == UserType.branchManager;
  bool get isClassroomRole   => this == UserType.teacher || this == UserType.nanny;
  bool get isBusChaperone    => this == UserType.busChaperone;
  bool get isBranchManager   => this == UserType.branchManager;
}
