import '../../../../../index/index_main.dart';

class BranchCard extends StatelessWidget {
  final BranchModel branch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BranchCard({
    super.key,
    required this.branch,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            _BranchAvatar(name: branch.name),
            SizedBox(width: 12.w),
            Expanded(child: _BranchInfo(branch: branch)),
            _BranchMenu(onEdit: onEdit, onDelete: onDelete),
          ],
        ),
      ),
    );
  }
}

class _BranchAvatar extends StatelessWidget {
  final String name;
  const _BranchAvatar({required this.name});

  @override
  Widget build(BuildContext context) => Container(
    width: 48.w,
    height: 48.h,
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Center(
      child: Icon(Icons.location_city, color: AppColors.primary, size: 22.sp),
    ),
  );
}

class _BranchInfo extends StatelessWidget {
  final BranchModel branch;
  const _BranchInfo({required this.branch});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              branch.name,
              style: context.typography.smSemiBold.copyWith(
                fontSize: 15, color: const Color(0xFF1E293B),
              ),
            ),
          ),
          _StatusBadge(isActive: branch.isActive),
        ],
      ),
      if (branch.address != null) ...[
        SizedBox(height: 4.h),
        _InfoRow(icon: Icons.location_on_outlined, text: branch.address!),
      ],
      if (branch.phone != null) ...[
        SizedBox(height: 2.h),
        _InfoRow(icon: Icons.phone_outlined, text: branch.phone!),
      ],
      if (branch.capacity != null) ...[
        SizedBox(height: 2.h),
        _InfoRow(
          icon: Icons.people_outline,
          text: '${branch.capacity} ${'branch_capacity_label'.tr}',
        ),
      ],
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Text(
      isActive ? 'branch_active'.tr : 'branch_inactive'.tr,
      style: context.typography.smSemiBold.copyWith(
        fontSize: 11,
        color: isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 13.sp, color: const Color(0xFF94A3B8)),
      SizedBox(width: 4.w),
      Expanded(
        child: Text(
          text,
          style: context.typography.xsRegular.copyWith(
            fontSize: 12, color: const Color(0xFF64748B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

class _BranchMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _BranchMenu({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => PopupMenuButton<_Action>(
    icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
    onSelected: (a) {
      if (a == _Action.edit) onEdit();
      if (a == _Action.delete) onDelete();
    },
    itemBuilder: (_) => [
      PopupMenuItem(
        value: _Action.edit,
        child: _MenuItem(icon: Icons.edit_outlined, label: 'branch_edit'.tr),
      ),
      PopupMenuItem(
        value: _Action.delete,
        child: _MenuItem(
          icon: Icons.delete_outline,
          label: 'branch_delete'.tr,
          color: const Color(0xFFDC2626),
        ),
      ),
    ],
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _MenuItem({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18.sp, color: color ?? const Color(0xFF475569)),
      SizedBox(width: 10.w),
      Text(
        label,
        style: context.typography.smRegular.copyWith(
          color: color ?? const Color(0xFF1E293B), fontSize: 14,
        ),
      ),
    ],
  );
}

enum _Action { edit, delete }
