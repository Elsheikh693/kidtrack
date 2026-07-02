enum StaffTemplate {
  owner,
  branchManager,
  receptionist,
  teacher,
  nanny,
  busChaperone,
}

extension StaffTemplateExtension on StaffTemplate {
  static StaffTemplate fromString(String? value) {
    return StaffTemplate.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StaffTemplate.teacher,
    );
  }

  /// Translation key — call `.tr` in the UI layer.
  String get labelKey {
    switch (this) {
      case StaffTemplate.owner:         return 'template_owner';
      case StaffTemplate.branchManager: return 'template_branch_manager';
      case StaffTemplate.receptionist:  return 'template_receptionist';
      case StaffTemplate.teacher:       return 'template_teacher';
      case StaffTemplate.nanny:         return 'template_nanny';
      case StaffTemplate.busChaperone:  return 'template_bus_chaperone';
    }
  }
}
