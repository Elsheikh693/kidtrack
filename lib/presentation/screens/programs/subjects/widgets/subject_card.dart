import '../../../../../index/index_main.dart';

class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final String branchScope;
  final bool isAllBranches;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SubjectCard({
    super.key,
    required this.subject,
    this.branchScope = '',
    this.isAllBranches = true,
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
            _SubjectAvatar(icon: subject.icon),
            SizedBox(width: 12.w),
            Expanded(
              child: _SubjectInfo(
                subject: subject,
                branchScope: branchScope,
                isAllBranches: isAllBranches,
              ),
            ),
            _SubjectMenu(onEdit: onEdit, onDelete: onDelete),
          ],
        ),
      ),
    );
  }
}

class _SubjectAvatar extends StatelessWidget {
  final String? icon;
  const _SubjectAvatar({this.icon});

  @override
  Widget build(BuildContext context) => Container(
    width: 48.w,
    height: 48.h,
    decoration: BoxDecoration(
      color: const Color(0xFFD97706).withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Center(
      child: Text(
        icon ?? '📚',
        style: context.typography.mdRegular.copyWith(fontSize: 22),
      ),
    ),
  );
}

class _SubjectInfo extends StatelessWidget {
  final SubjectModel subject;
  final String branchScope;
  final bool isAllBranches;
  const _SubjectInfo({
    required this.subject,
    required this.branchScope,
    required this.isAllBranches,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        subject.name,
        style: context.typography.smSemiBold.copyWith(
          fontSize: 15, color: const Color(0xFF1E293B),
        ),
      ),
      if (subject.description != null) ...[
        SizedBox(height: 4.h),
        Text(
          subject.description!,
          style: context.typography.xsRegular.copyWith(fontSize: 12, color: const Color(0xFF64748B)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
      if (branchScope.isNotEmpty) ...[
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(
              isAllBranches ? Icons.public_rounded : Icons.account_balance_rounded,
              size: 13.sp,
              color: const Color(0xFF6366F1),
            ),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                branchScope,
                style: context.typography.smSemiBold.copyWith(
                  fontSize: 12, color: const Color(0xFF6366F1),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    ],
  );
}

class _SubjectMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _SubjectMenu({required this.onEdit, required this.onDelete});

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
        child: _MenuItem(icon: Icons.edit_outlined, label: 'subject_edit_title'.tr),
      ),
      PopupMenuItem(
        value: _Action.delete,
        child: _MenuItem(
          icon: Icons.delete_outline,
          label: 'subject_delete'.tr,
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
