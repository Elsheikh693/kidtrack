import '../../../../../index/index_main.dart';

class GuardianCard extends StatelessWidget {
  final ParentModel guardian;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  const GuardianCard({super.key, required this.guardian, required this.onEdit, required this.onToggleActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8.r, offset: Offset(0, 2.h))],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
              backgroundImage: guardian.hasImage ? appCachedImageProvider(guardian.profileImage!) : null,
              child: guardian.hasImage ? null : Text(
                guardian.name.isNotEmpty ? guardian.name[0].toUpperCase() : '?',
                style: context.typography.mdBold.copyWith(fontSize: 18, color: const Color(0xFF6366F1)),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(guardian.name, style: context.typography.displaySmBold.copyWith(fontSize: 15, color: const Color(0xFF1E293B))),
                  if (guardian.phone != null)
                    Text(guardian.phone!, style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFF64748B))),
                  if (guardian.email != null)
                    Text(guardian.email!, style: context.typography.xsRegular.copyWith(fontSize: 12, color: const Color(0xFF94A3B8)), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              children: [
                InkWell(
                  onTap: onToggleActive,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      guardian.isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                      size: 24.sp, color: guardian.isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(padding: EdgeInsets.all(6.w), child: Icon(Icons.edit_outlined, size: 20.sp, color: const Color(0xFF6366F1))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
