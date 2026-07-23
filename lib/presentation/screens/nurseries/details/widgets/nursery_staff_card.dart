import '../../../../../index/index_main.dart';

/// One employee row in the SuperAdmin nursery-details roster: name, role and
/// their durable activation (login) code, plus show-code + WhatsApp actions.
class NurseryStaffCard extends StatelessWidget {
  final StaffModel staff;
  final ActivationCodeModel? code;
  final VoidCallback onShowCode;
  final VoidCallback onSendWhatsApp;

  const NurseryStaffCard({
    super.key,
    required this.staff,
    required this.code,
    required this.onShowCode,
    required this.onSendWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final phone = staff.phone ?? '';
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.badge_outlined, color: Color(0xFF6366F1)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        staff.name,
                        style: context.typography.smSemiBold.copyWith(
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    _RolePill(label: staff.template.labelKey.tr),
                  ],
                ),
                if (phone.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    phone,
                    style: context.typography.xsRegular.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.vpn_key_rounded,
                        size: 13.sp, color: const Color(0xFF94A3B8)),
                    SizedBox(width: 4.w),
                    Text(
                      code?.code ?? 'nursery_staff_code_pending'.tr,
                      style: context.typography.xsMedium.copyWith(
                        color: code != null
                            ? AppColors.primary
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _TileAction(
            icon: Icons.chat_rounded,
            color: const Color(0xFF25D366),
            onTap: onSendWhatsApp,
          ),
          _TileAction(
            icon: Icons.qr_code_rounded,
            color: AppColors.primary,
            onTap: onShowCode,
          ),
        ],
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final String label;
  const _RolePill({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: context.typography.xsMedium.copyWith(
            color: const Color(0xFF475569),
          ),
        ),
      );
}

class _TileAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _TileAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: BoxConstraints(minWidth: 34.w, minHeight: 34.h),
        icon: Icon(icon, size: 19.sp, color: color),
      );
}
