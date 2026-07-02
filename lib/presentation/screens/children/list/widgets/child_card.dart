import '../../../../../index/index_main.dart';

class ChildCard extends StatelessWidget {
  final ChildModel child;
  final String branchName;
  final String classroomName;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ChildCard({
    super.key,
    required this.child,
    required this.branchName,
    required this.classroomName,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            _ChildAvatar(child: child),
            SizedBox(width: 12.w),
            Expanded(
              child: _ChildInfo(
                child: child,
                branchName: branchName,
                classroomName: classroomName,
              ),
            ),
            _ChildMenu(onEdit: onEdit, onDelete: onDelete),
          ],
        ),
      ),
    ),
    );
  }
}

class _ChildAvatar extends StatelessWidget {
  final ChildModel child;
  const _ChildAvatar({required this.child});

  @override
  Widget build(BuildContext context) {
    final initials = child.firstName.isNotEmpty
        ? child.firstName[0].toUpperCase()
        : '؟';
    final fallback = Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFF059669).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          initials,
          style: context.typography.lgBold.copyWith(
            color: const Color(0xFF059669),
            fontSize: 20,
          ),
        ),
      ),
    );
    if (!child.hasImage) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: AppNetworkImage(
        url: child.profileImage,
        width: 48.w,
        height: 48.h,
        errorWidget: fallback,
      ),
    );
  }
}

class _ChildInfo extends StatelessWidget {
  final ChildModel child;
  final String branchName;
  final String classroomName;
  const _ChildInfo({
    required this.child,
    required this.branchName,
    required this.classroomName,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              child.fullName,
              style: context.typography.smSemiBold.copyWith(
                fontSize: 15, color: const Color(0xFF1E293B),
              ),
            ),
          ),
          _StatusBadge(status: child.status),
        ],
      ),
      SizedBox(height: 4.h),
      _InfoRow(icon: Icons.location_on_outlined, text: branchName),
      SizedBox(height: 2.h),
      _InfoRow(icon: Icons.class_outlined, text: classroomName),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case 'active': return const Color(0xFF16A34A);
      case 'withdrawn': return const Color(0xFFD97706);
      default: return const Color(0xFFDC2626);
    }
  }

  Color get _bg {
    switch (status) {
      case 'active': return const Color(0xFFDCFCE7);
      case 'withdrawn': return const Color(0xFFFEF3C7);
      default: return const Color(0xFFFEE2E2);
    }
  }

  String _label() {
    switch (status) {
      case 'active': return 'child_status_active'.tr;
      case 'withdrawn': return 'child_status_withdrawn'.tr;
      default: return 'child_status_inactive'.tr;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: _bg,
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Text(
      _label(),
      style: context.typography.smSemiBold.copyWith(fontSize: 11, color: _color),
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
          style: context.typography.xsRegular.copyWith(fontSize: 12, color: const Color(0xFF64748B)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

class _ChildMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ChildMenu({required this.onEdit, required this.onDelete});

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
        child: _MenuItem(icon: Icons.edit_outlined, label: 'child_edit_title'.tr),
      ),
      PopupMenuItem(
        value: _Action.delete,
        child: _MenuItem(
          icon: Icons.delete_outline,
          label: 'child_delete'.tr,
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
      Text(label, style: context.typography.smRegular.copyWith(color: color ?? const Color(0xFF1E293B), fontSize: 14)),
    ],
  );
}

enum _Action { edit, delete }
