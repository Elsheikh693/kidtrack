import 'package:flutter/material.dart';

/// The five website album keys shown in the public "شوف كل تطبيق من جوّه"
/// section. [key] must match the album keys hard-coded in `public/index.html`
/// so the website can group shots by role directly.
class ShowcaseRole {
  final String key;
  final String labelKey;
  final Color color;

  const ShowcaseRole(this.key, this.labelKey, this.color);
}

const List<ShowcaseRole> kShowcaseRoles = [
  ShowcaseRole('owner', 'showcase_role_owner', Color(0xFF6D4AFF)),
  ShowcaseRole('manager', 'showcase_role_manager', Color(0xFF0EA5E9)),
  ShowcaseRole('teacher', 'showcase_role_teacher', Color(0xFF16C47F)),
  ShowcaseRole('reception', 'showcase_role_reception', Color(0xFFF97362)),
  ShowcaseRole('parent', 'showcase_role_parent', Color(0xFFF5A623)),
];
