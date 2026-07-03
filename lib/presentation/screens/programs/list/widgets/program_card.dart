import '../../../../../index/index_main.dart';

class ProgramCard extends StatelessWidget {
  final ProgramModel program;
  final String branchScope;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProgramCard({
    super.key,
    required this.program,
    required this.branchScope,
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
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            _ProgramAvatar(),
            SizedBox(width: 12.w),
            Expanded(child: _ProgramInfo(program: program, branchScope: branchScope)),
            _ProgramMenu(
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramAvatar extends StatelessWidget {
  const _ProgramAvatar();

  @override
  Widget build(BuildContext context) => Container(
    width: 48.w,
    height: 48.h,
    decoration: BoxDecoration(
      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Center(
      child: Icon(Icons.school_outlined, color: const Color(0xFF2563EB), size: 22.sp),
    ),
  );
}

class _ProgramInfo extends StatelessWidget {
  final ProgramModel program;
  final String branchScope;
  const _ProgramInfo({required this.program, required this.branchScope});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              program.name,
              style: context.typography.smSemiBold.copyWith(
                fontSize: 15, color: const Color(0xFF1E293B),
              ),
            ),
          ),
          _StatusBadge(isActive: program.isActive),
        ],
      ),
      if (program.description != null) ...[
        SizedBox(height: 4.h),
        Text(
          program.description!,
          style: context.typography.xsRegular.copyWith(fontSize: 12, color: const Color(0xFF64748B)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
      SizedBox(height: 2.h),
      Row(
        children: [
          Icon(Icons.location_on_outlined, size: 13.sp, color: const Color(0xFF94A3B8)),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              branchScope,
              style: context.typography.xsRegular.copyWith(fontSize: 12, color: const Color(0xFF64748B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      if (program.ageGroup != null) ...[
        SizedBox(height: 2.h),
        Row(
          children: [
            Icon(Icons.cake_outlined, size: 13.sp, color: const Color(0xFF94A3B8)),
            SizedBox(width: 4.w),
            Text(
              program.ageGroup!,
              style: context.typography.xsRegular.copyWith(fontSize: 12, color: const Color(0xFF64748B)),
            ),
          ],
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
      isActive ? 'program_active'.tr : 'program_inactive'.tr,
      style: context.typography.smSemiBold.copyWith(
        fontSize: 11,
        color: isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
      ),
    ),
  );
}

class _ProgramMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ProgramMenu({
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => PopupMenuButton<_Action>(
    icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
    onSelected: (a) {
      switch (a) {
        case _Action.edit: onEdit();
        case _Action.delete: onDelete();
      }
    },
    itemBuilder: (_) => [
      PopupMenuItem(
        value: _Action.edit,
        child: _MenuItem(icon: Icons.edit_outlined, label: 'program_edit_title'.tr),
      ),
      PopupMenuItem(
        value: _Action.delete,
        child: _MenuItem(
          icon: Icons.delete_outline,
          label: 'program_delete'.tr,
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
      Text(label, style: context.typography.xsRegular.copyWith(color: color ?? const Color(0xFF1E293B), fontSize: 14)),
    ],
  );
}

enum _Action { edit, delete }
