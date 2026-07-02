import '../../../../../index/index_main.dart';
import 'staff_avatar.dart';

/// A single staff row in the directory: avatar, name, role, and today's
/// attendance badge.
class StaffDirectoryTile extends StatelessWidget {
  const StaffDirectoryTile({
    super.key,
    required this.staff,
    required this.status,
    required this.onTap,
  });

  final StaffModel staff;

  /// Raw attendance status for today ('present', 'late', 'absent', 'on_leave'),
  /// or empty when there is no record.
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grayLight),
        ),
        child: Row(
          children: [
            StaffAvatar(name: staff.name, imageUrl: staff.profileImage),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    staff.template.labelKey.tr,
                    style: context.typography.xsRegular
                        .copyWith(color: AppColors.textSecondaryParagraph),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (_label != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _label!.tr,
                  style: context.typography.xsMedium.copyWith(color: _color),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.arrow_back_ios_new_rounded,
                size: 13, color: AppColors.grayMedium),
          ],
        ),
      ),
    );
  }

  String? get _label {
    switch (status) {
      case 'present':
        return 'manager_staff_status_present';
      case 'late':
        return 'manager_staff_status_late';
      case 'absent':
        return 'manager_staff_status_absent';
      case 'on_leave':
        return 'manager_staff_status_leave';
      default:
        return null;
    }
  }

  Color get _color {
    switch (status) {
      case 'present':
        return AppColors.activityGreen;
      case 'late':
        return AppColors.activityAmberBrand;
      case 'absent':
        return AppColors.activityRed;
      case 'on_leave':
        return AppColors.activityPurple;
      default:
        return AppColors.grayMedium;
    }
  }
}
