import '../../../../../index/index_main.dart';
import 'staff_avatar.dart';

/// Read-only profile shown when a staff row is tapped: identity, contact, HR
/// details, and salary. Pure display — no editing here.
class StaffProfileSheet extends StatelessWidget {
  const StaffProfileSheet({super.key, required this.staff});

  final StaffModel staff;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grayLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          StaffAvatar(
            name: staff.name,
            imageUrl: staff.profileImage,
            size: 72,
          ),
          const SizedBox(height: 12),
          Text(
            staff.name,
            style: context.typography.lgBold
                .copyWith(color: AppColors.textDefault),
          ),
          const SizedBox(height: 4),
          Text(
            staff.template.labelKey.tr,
            style: context.typography.smMedium
                .copyWith(color: AppColors.activityBlue),
          ),
          const SizedBox(height: 20),
          if ((staff.phone ?? '').isNotEmpty)
            _InfoRow(
              icon: Icons.phone_rounded,
              label: 'manager_staff_info_phone'.tr,
              value: staff.phone!,
            ),
          if ((staff.emergencyPhone ?? '').isNotEmpty)
            _InfoRow(
              icon: Icons.emergency_rounded,
              label: 'manager_staff_info_emergency'.tr,
              value: staff.emergencyPhone!,
            ),
          if ((staff.email ?? '').isNotEmpty)
            _InfoRow(
              icon: Icons.email_rounded,
              label: 'manager_staff_info_email'.tr,
              value: staff.email!,
            ),
          if ((staff.nationalId ?? '').isNotEmpty)
            _InfoRow(
              icon: Icons.badge_rounded,
              label: 'manager_staff_info_national_id'.tr,
              value: staff.nationalId!,
            ),
          if ((staff.address ?? '').isNotEmpty)
            _InfoRow(
              icon: Icons.home_rounded,
              label: 'manager_staff_info_address'.tr,
              value: staff.address!,
            ),
          if (staff.hireDate != null)
            _InfoRow(
              icon: Icons.event_rounded,
              label: 'manager_staff_info_hired'.tr,
              value: _formatDate(staff.hireDate!),
            ),
          if (staff.salary != null && staff.salary! > 0)
            _InfoRow(
              icon: Icons.payments_rounded,
              label: 'manager_staff_info_salary'.tr,
              value:
                  '${staff.salary!.toStringAsFixed(0)} ${'manager_staff_currency'.tr}',
            ),
        ],
      ),
    );
  }

  static String _formatDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.activityBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Icon(icon, size: 18, color: AppColors.activityBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.typography.xsRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
