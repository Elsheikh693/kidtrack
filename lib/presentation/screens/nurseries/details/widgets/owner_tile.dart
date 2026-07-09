import '../../../../../index/index_main.dart';

class OwnerTile extends StatelessWidget {
  final UserModel owner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShowCode;
  final VoidCallback onSendWhatsApp;

  const OwnerTile({
    super.key,
    required this.owner,
    required this.onEdit,
    required this.onDelete,
    required this.onShowCode,
    required this.onSendWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final name = (owner.name?.trim().isNotEmpty == true)
        ? owner.name!.trim()
        : 'nursery_owner_unknown'.tr;
    final phone = owner.phone ?? '';

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
            child: const Icon(Icons.person, color: Color(0xFF6366F1)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: context.typography.smSemiBold.copyWith(
                    color: const Color(0xFF1E293B),
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    phone,
                    style: context.typography.xsRegular.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
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
          _TileAction(
            icon: Icons.edit_outlined,
            color: const Color(0xFF6366F1),
            onTap: onEdit,
          ),
          _TileAction(
            icon: Icons.delete_outline,
            color: AppColors.errorForeground,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

/// Compact icon button so several actions fit on one owner row without wrapping.
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
