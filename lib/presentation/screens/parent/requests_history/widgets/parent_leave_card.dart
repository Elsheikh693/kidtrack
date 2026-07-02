import '../../../../../index/index_main.dart';

class ParentLeaveCard extends StatelessWidget {
  final ChildLeaveRequestModel item;
  final String childName;
  final VoidCallback onDelete;

  const ParentLeaveCard({
    super.key,
    required this.item,
    required this.childName,
    required this.onDelete,
  });

  Color get _statusColor {
    switch (item.status) {
      case 'approved': return AppColors.successForeground;
      case 'rejected': return AppColors.errorForeground;
      default:         return AppColors.yellowForeground;
    }
  }

  Color get _statusBg {
    switch (item.status) {
      case 'approved': return AppColors.successBackground;
      case 'rejected': return AppColors.errorBackground;
      default:         return AppColors.yellowBackground;
    }
  }

  String get _statusKey {
    switch (item.status) {
      case 'approved': return 'parent_req_status_approved';
      case 'rejected': return 'parent_req_status_rejected';
      default:         return 'parent_req_status_pending';
    }
  }

  String _formatDate(int ts) {
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    return '${d.day}/${d.month}/${d.year}';
  }

  int get _days {
    final start = DateTime.fromMillisecondsSinceEpoch(item.startDate);
    final end   = DateTime.fromMillisecondsSinceEpoch(item.endDate);
    return end.difference(start).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayLight.withValues(alpha: 0.5),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.child_care_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  childName,
                  style: context.typography.mdBold.copyWith(
                      color: AppColors.textDefault, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusKey.tr,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'parent_req_from'.tr,
            value: '${_formatDate(item.startDate)}  →  ${_formatDate(item.endDate)}',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: '$_days ${'parent_req_days'.tr}',
            value: '',
          ),
          if (item.reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            _InfoRow(
              icon: Icons.notes_rounded,
              label: item.reason,
              value: '',
            ),
          ],
          if (item.status == 'pending') ...[
            const Divider(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded,
                    size: 16, color: AppColors.errorForeground),
                label: Text(
                  'common_delete'.tr,
                  style: TextStyle(
                      color: AppColors.errorForeground, fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.grayMedium),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF475569)),
              children: [
                TextSpan(text: label),
                if (value.isNotEmpty)
                  TextSpan(
                    text: '  $value',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
