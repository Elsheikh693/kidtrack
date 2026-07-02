import '../../../../../index/index_main.dart';

class PackageCard extends StatelessWidget {
  final PackageModel pkg;
  final String branchName;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const PackageCard({
    super.key,
    required this.pkg,
    this.branchName = '',
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  String get _durationLabel {
    switch (pkg.duration) {
      case 'monthly': return 'package_duration_monthly'.tr;
      case 'term': return 'package_duration_term'.tr;
      case 'yearly': return 'package_duration_yearly'.tr;
      case 'oneTime': return 'package_duration_oneTime'.tr;
      default: return pkg.duration;
    }
  }

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
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
                  child: Icon(Icons.inventory_2_outlined, color: const Color(0xFF10B981), size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pkg.name, style: context.typography.mdBold.copyWith(fontSize: 16, color: const Color(0xFF1E293B))),
                      if (branchName.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Row(
                            children: [
                              Icon(Icons.account_balance_rounded, size: 13.sp, color: const Color(0xFF6366F1)),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(branchName, style: context.typography.smSemiBold.copyWith(fontSize: 12, color: const Color(0xFF6366F1)), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                      if (pkg.description != null)
                        Text(pkg.description!, style: context.typography.xsRegular.copyWith(color: const Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                _StatusChip(isActive: pkg.isActive),
              ],
            ),
            SizedBox(height: 12.h),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: 10.h),
            Row(
              children: [
                _InfoItem(label: 'package_price_label'.tr, value: '${pkg.price.toStringAsFixed(0)} ${' package_currency'.tr}'),
                SizedBox(width: 16.w),
                _InfoItem(label: 'package_duration_label'.tr, value: _durationLabel),
              ],
            ),
            SizedBox(height: 8.h),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionBtn(icon: pkg.isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded, color: pkg.isActive ? Colors.green : Colors.grey, onTap: onToggleActive),
                SizedBox(width: 4.w),
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

class _StatusChip extends StatelessWidget {
  final bool isActive;
  const _StatusChip({required this.isActive});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
    decoration: BoxDecoration(color: (isActive ? Colors.green : Colors.grey).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20.r)),
    child: Text(isActive ? 'common_active'.tr : 'common_inactive'.tr, style: context.typography.smSemiBold.copyWith(fontSize: 12, color: isActive ? Colors.green : Colors.grey)),
  );
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: context.typography.xsRegular.copyWith(fontSize: 11, color: const Color(0xFF94A3B8))),
      Text(value, style: context.typography.smSemiBold.copyWith(fontSize: 14, color: const Color(0xFF1E293B))),
    ],
  );
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
