import 'setup_step.dart';

/// A titled cluster of related [SetupStep]s, rendered as one section on the hub.
class SetupGroup {
  final String titleKey;
  final List<SetupStep> steps;

  const SetupGroup({required this.titleKey, required this.steps});
}
