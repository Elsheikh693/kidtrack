import '../../../../../index/index_main.dart';

class StaffCard extends StatelessWidget {
  final StaffModel staff;
  final List<String> shiftLabels;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onPermissions;
  final VoidCallback onGenerateCode;
  final VoidCallback onSendWhatsApp;
  final VoidCallback onDelete;
  final bool canDelete;

  const StaffCard({
    super.key,
    required this.staff,
    this.shiftLabels = const [],
    required this.onEdit,
    required this.onToggleActive,
    required this.onPermissions,
    required this.onGenerateCode,
    required this.onSendWhatsApp,
    required this.onDelete,
    this.canDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = _color(staff.template);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Info(staff: staff, color: color, shiftLabels: shiftLabels),
            SizedBox(height: 12.h),
            Row(
              children: [
                _CardAction(
                  icon: Icons.chat_rounded,
                  color: const Color(0xFF25D366),
                  onTap: onSendWhatsApp,
                ),
                SizedBox(width: 8.w),
                _CardAction(
                  icon: Icons.qr_code_rounded,
                  color: AppColors.primary,
                  onTap: onGenerateCode,
                ),
                const Spacer(),
                _Menu(
                  staff: staff,
                  onEdit: onEdit,
                  onToggleActive: onToggleActive,
                  onPermissions: onPermissions,
                  onDelete: onDelete,
                  canDelete: canDelete,
                ),
              ],
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

class _Info extends StatelessWidget {
  final StaffModel staff;
  final Color color;
  final List<String> shiftLabels;
  const _Info({
    required this.staff,
    required this.color,
    this.shiftLabels = const [],
  });

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
      if (shiftLabels.isNotEmpty)
        _InfoRow(
          icon: Icons.schedule_rounded,
          text: shiftLabels.join(' • '),
        ),
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

class _CardAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CardAction({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, size: 20.sp, color: color),
    ),
  );
}

class _Menu extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onPermissions;
  final VoidCallback onDelete;
  final bool canDelete;
  const _Menu({
    required this.staff,
    required this.onEdit,
    required this.onToggleActive,
    required this.onPermissions,
    required this.onDelete,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context) => PopupMenuButton<_MenuAction>(
    icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
    onSelected: (action) {
      switch (action) {
        case _MenuAction.edit:        onEdit();
        case _MenuAction.permissions: onPermissions();
        case _MenuAction.toggle:      onToggleActive();
        case _MenuAction.delete:      onDelete();
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
      if (canDelete)
        PopupMenuItem(
          value: _MenuAction.delete,
          child: _MenuItem(
            icon: Icons.delete_outline_rounded,
            label: 'staff_menu_delete'.tr,
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

enum _MenuAction { edit, permissions, toggle, delete }
