import '../../../../../index/index_main.dart';

class DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final String childName;
  final String typeLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DocumentCard({super.key, required this.document, required this.childName, required this.typeLabel, required this.onEdit, required this.onDelete});

  IconData get _typeIcon {
    switch (document.type) {
      case 'birth_certificate': return Icons.badge_outlined;
      case 'vaccination': return Icons.vaccines_outlined;
      case 'medical': return Icons.medical_information_outlined;
      default: return Icons.insert_drive_file_outlined;
    }
  }

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
            Container(
              width: 44.w, height: 44.h,
              decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(_typeIcon, color: const Color(0xFF0EA5E9), size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(document.title ?? typeLabel, style: context.typography.displaySmBold.copyWith(fontSize: 15, color: const Color(0xFF1E293B))),
                  SizedBox(height: 2.h),
                  Text(childName, style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFF64748B))),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20.r)),
                    child: Text(typeLabel, style: context.typography.xsMedium.copyWith(fontSize: 11, color: const Color(0xFF0EA5E9))),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _ActionBtn(icon: Icons.edit_outlined, color: const Color(0xFF6366F1), onTap: onEdit),
                SizedBox(height: 4.h),
                _ActionBtn(icon: Icons.delete_outline_rounded, color: Colors.red, onTap: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8.r),
    child: Padding(padding: EdgeInsets.all(6.w), child: Icon(icon, size: 20.sp, color: color)),
  );
}
