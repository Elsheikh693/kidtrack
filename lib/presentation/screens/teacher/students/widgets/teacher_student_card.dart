import 'package:flutter/material.dart';
import '../../../../../Data/models/child/child_model.dart';
import '../../../../../Global/widgets/app_network_image.dart';

class TeacherStudentCard extends StatelessWidget {
  const TeacherStudentCard({
    super.key,
    required this.child,
    required this.attendanceStatus,
    required this.index,
    this.classroomName,
  });

  final ChildModel child;
  final String attendanceStatus;
  final int index;
  final String? classroomName;

  static const _avatarColors = [
    Color(0xFF7C3AED), Color(0xFF0891B2), Color(0xFF16A34A),
    Color(0xFFDC2626), Color(0xFFD97706), Color(0xFF0D9488),
    Color(0xFF9333EA), Color(0xFF2563EB),
  ];

  Color get _avatarColor => _avatarColors[index % _avatarColors.length];

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(attendanceStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: _avatarColor.withValues(alpha: 0.15),
            backgroundImage:
                child.hasImage ? appCachedImageProvider(child.profileImage) : null,
            child: child.hasImage
                ? null
                : Text(
                    child.firstName.isNotEmpty ? child.firstName[0] : '?',
                    style: TextStyle(
                      color: _avatarColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // Name + gender
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.fullName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    child.gender == 'male' ? 'ذكر' : (child.gender == 'female' ? 'أنثى' : null),
                    if (classroomName != null && classroomName!.isNotEmpty) classroomName,
                  ].whereType<String>().join(' • '),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          // Attendance badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusInfo.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusInfo.icon, color: statusInfo.color, size: 13),
                const SizedBox(width: 4),
                Text(
                  statusInfo.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusInfo.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'present':
        return _StatusInfo(
            Icons.check_circle_rounded, const Color(0xFF16A34A), 'حاضر');
      case 'late':
        return _StatusInfo(
            Icons.access_time_rounded, const Color(0xFFD97706), 'متأخر');
      case 'absent':
        return _StatusInfo(
            Icons.cancel_rounded, const Color(0xFFDC2626), 'غائب');
      default:
        return _StatusInfo(
            Icons.help_outline_rounded, const Color(0xFF9CA3AF), 'غير محدد');
    }
  }
}

class _StatusInfo {
  const _StatusInfo(this.icon, this.color, this.label);
  final IconData icon;
  final Color color;
  final String label;
}
