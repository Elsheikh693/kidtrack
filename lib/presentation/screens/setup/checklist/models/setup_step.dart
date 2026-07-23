import 'package:flutter/material.dart';

/// A single first-login setup task on the checklist hub.
///
/// Tapping a step opens [route] — an existing management screen — and returns
/// to the hub. Whether the step is "done" is inferred by the controller from
/// live data (e.g. at least one branch exists), never stored on the step.
class SetupStep {
  final String id;
  final String titleKey;
  final String subtitleKey;
  final IconData icon;
  final String route;

  /// Optional steps still show their own done state, but never count toward the
  /// progress total or gate the "finish setup" button.
  final bool optional;

  const SetupStep({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    required this.route,
    this.optional = false,
  });
}
