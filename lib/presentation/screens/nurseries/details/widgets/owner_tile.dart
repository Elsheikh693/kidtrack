import '../../../../../index/index_main.dart';

class OwnerTile extends StatelessWidget {
  final UserModel owner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const OwnerTile({
    super.key,
    required this.owner,
    required this.onEdit,
    required this.onDelete,
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
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined,
                size: 20.sp, color: const Color(0xFF6366F1)),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline,
                size: 20.sp, color: AppColors.errorForeground),
          ),
        ],
      ),
    );
  }
}
