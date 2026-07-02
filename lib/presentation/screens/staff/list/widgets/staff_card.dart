import '../../../../../index/index_main.dart';

class StaffCard extends StatelessWidget {
  final StaffModel staff;
  final String branchName;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onPermissions;

  const StaffCard({
    super.key,
    required this.staff,
    required this.branchName,
    required this.onEdit,
    required this.onToggleActive,
    required this.onPermissions,
  });

  @override
  Widget build(BuildContext context) {
    final color = _color(staff.template);
    final initials = staff.name.trim().isNotEmpty
        ? staff.name.trim().split(' ').take(2).map((w) => w[0]).join()
        : '؟';

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
            _Avatar(initials: initials, color: color),
            SizedBox(width: 12.w),
            Expanded(
              child: _Info(staff: staff, branchName: branchName, color: color),
            ),
            _Menu(
              staff: staff,
              onEdit: onEdit,
              onToggleActive: onToggleActive,
              onPermissions: onPermissions,
            ),
          ],
        ),
      ),
    );
  }

  static Color _color(StaffTemplate t) {
    switch (t) {
      case StaffTemplate.owner:         return const Color(0xFF7C3AED);
      case StaffTemplate.branchManager: return const Color(0xFF5E35B1);
      case StaffTemplate.receptionist:  return const Color(0xFF2563EB);
      case StaffTemplate.teacher:       return const Color(0xFF059669);
      case StaffTemplate.nanny:         return const Color(0xFFD97706);
      case StaffTemplate.busChaperone:  return const Color(0xFF0891B2);
    }
  }
}

// ── Internal pieces — private to this file ────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  final Color color;
  const _Avatar({required this.initials, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 52.w,
    height: 52.h,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14.r),
    ),
    child: Center(
      child: Text(
        initials,
        style: context.typography.lgBold.copyWith(
          color: color, fontSize: 18,
        ),
      ),
    ),
  );
}

class _Info extends StatelessWidget {
  final StaffModel staff;
  final String branchName;
  final Color color;
  const _Info({required this.staff, required this.branchName, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              staff.name,
              style: context.typography.smSemiBold.copyWith(
                fontSize: 15, color: const Color(0xFF1E293B),
              ),
            ),
          ),
          _StatusBadge(isActive: staff.isActive),
        ],
      ),
      SizedBox(height: 4.h),
      _TemplateBadge(template: staff.template, color: color),
      SizedBox(height: 6.h),
      if (staff.phone != null) ...[
        _InfoRow(icon: Icons.phone_outlined, text: staff.phone!),
        SizedBox(height: 2.h),
      ],
      _InfoRow(icon: Icons.location_on_outlined, text: branchName),
      if (staff.shift != null) ...[
        SizedBox(height: 2.h),
        _InfoRow(
          icon: ShiftScope.fromName(staff.shift)?.icon ?? Icons.schedule,
          text: (ShiftScope.fromName(staff.shift)?.labelKey ?? 'shift_morning').tr,
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
      isActive ? 'staff_active'.tr : 'staff_inactive'.tr,
      style: context.typography.smSemiBold.copyWith(
        fontSize: 11,
        color: isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
      ),
    ),
  );
}

class _TemplateBadge extends StatelessWidget {
  final StaffTemplate template;
  final Color color;
  const _TemplateBadge({required this.template, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(6.r),
    ),
    child: Text(
      template.labelKey.tr,
      style: context.typography.xsMedium.copyWith(fontSize: 11, color: color),
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
      Text(text, style: context.typography.smRegular.copyWith(fontSize: 12, color: const Color(0xFF64748B))),
    ],
  );
}

class _Menu extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onPermissions;
  const _Menu({
    required this.staff,
    required this.onEdit,
    required this.onToggleActive,
    required this.onPermissions,
  });

  @override
  Widget build(BuildContext context) => PopupMenuButton<_MenuAction>(
    icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
    onSelected: (action) {
      switch (action) {
        case _MenuAction.edit:        onEdit();
        case _MenuAction.permissions: onPermissions();
        case _MenuAction.toggle:      onToggleActive();
      }
    },
    itemBuilder: (_) => [
      PopupMenuItem(
        value: _MenuAction.edit,
        child: _MenuItem(icon: Icons.edit_outlined, label: 'staff_menu_edit'.tr),
      ),
      PopupMenuItem(
        value: _MenuAction.permissions,
        child: _MenuItem(icon: Icons.shield_outlined, label: 'staff_menu_permissions'.tr),
      ),
      PopupMenuItem(
        value: _MenuAction.toggle,
        child: _MenuItem(
          icon: staff.isActive ? Icons.block : Icons.check_circle_outline,
          label: staff.isActive ? 'staff_menu_deactivate'.tr : 'staff_menu_activate'.tr,
          color: staff.isActive ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
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

enum _MenuAction { edit, permissions, toggle }
