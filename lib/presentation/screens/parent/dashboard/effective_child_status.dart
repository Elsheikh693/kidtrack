import '../../../../index/index_main.dart';
import '../../../../Data/models/child_current_status/child_current_status_model.dart';

class EffectiveChildStatus {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final String? activityTitle;
  final String? subjectName;

  const EffectiveChildStatus({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    this.activityTitle,
    this.subjectName,
  });

  bool get isActivity => key == 'in_activity';
  bool get isOnBus => key == ChildStatus.onBus;
  bool get isActive =>
      key != ChildStatus.checkedOut && key != ChildStatus.notArrived;
}
