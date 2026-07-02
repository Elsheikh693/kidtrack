import '../../../../../index/index_main.dart';

class MedicalCard extends StatelessWidget {
  final MedicalProfileModel medical;
  final String childName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MedicalCard({super.key, required this.medical, required this.childName, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8.r, offset: Offset(0, 2.h))],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44.w, height: 44.h,
                  decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
                  child: Icon(Icons.medical_services_outlined, color: const Color(0xFFEF4444), size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(childName, style: context.typography.mdBold.copyWith(fontSize: 16, color: const Color(0xFF1E293B))),
                      if (medical.bloodType != null)
                        Text('${'medical_blood_type'.tr}: ${medical.bloodType}', style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),
            if (medical.allergies.isNotEmpty) ...[
              SizedBox(height: 12.h),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              SizedBox(height: 10.h),
              Text('medical_allergies'.tr, style: context.typography.xsMedium.copyWith(fontSize: 12, color: const Color(0xFF94A3B8))),
              SizedBox(height: 4.h),
              Wrap(
                spacing: 6.w, runSpacing: 4.h,
                children: medical.allergies.map((a) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20.r)),
                  child: Text(a, style: context.typography.xsMedium.copyWith(fontSize: 12, color: const Color(0xFFEF4444))),
                )).toList(),
              ),
            ],
            if (medical.emergencyContact != null) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  Icon(Icons.emergency_outlined, size: 14.sp, color: const Color(0xFF94A3B8)),
                  SizedBox(width: 4.w),
                  Text(medical.emergencyContact!, style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFF64748B))),
                  if (medical.emergencyPhone != null) ...[
                    SizedBox(width: 8.w),
                    Text(medical.emergencyPhone!, style: context.typography.xsRegular.copyWith(fontSize: 13, color: const Color(0xFF6366F1))),
                  ],
                ],
              ),
            ],
            SizedBox(height: 8.h),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionBtn(icon: Icons.edit_outlined, color: const Color(0xFF6366F1), onTap: onEdit),
                SizedBox(width: 4.w),
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
