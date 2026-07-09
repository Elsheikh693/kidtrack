import '../../../../../index/index_main.dart';

class KidtrackCampaignCard extends StatelessWidget {
  final KidtrackFeedbackCampaignModel item;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const KidtrackCampaignCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFF59E0B);
    final desc = item.description?.trim() ?? '';
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 8.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.feedback_rounded, color: color, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: context.typography.smSemiBold
                      .copyWith(color: const Color(0xFF1E293B)),
                ),
                if (desc.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.xsRegular
                        .copyWith(color: const Color(0xFF94A3B8)),
                  ),
                ],
                SizedBox(height: 8.h),
                _statusBadge(context),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'toggle') onToggle();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined,
                      size: 16.sp, color: const Color(0xFF475569)),
                  SizedBox(width: 8.w),
                  Text('sa_feedback_edit'.tr),
                ]),
              ),
              PopupMenuItem(
                value: 'toggle',
                child: Row(children: [
                  Icon(
                      item.enabled
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      size: 16.sp,
                      color: const Color(0xFF475569)),
                  SizedBox(width: 8.w),
                  Text(item.enabled
                      ? 'sa_feedback_disable'.tr
                      : 'sa_feedback_enable'.tr),
                ]),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline,
                      size: 16.sp, color: const Color(0xFFDC2626)),
                  SizedBox(width: 8.w),
                  Text('sa_feedback_delete'.tr,
                      style: context.typography.smRegular
                          .copyWith(color: const Color(0xFFDC2626))),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(BuildContext context) {
    final on = item.enabled;
    final color = on ? const Color(0xFF16A34A) : const Color(0xFF94A3B8);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        on ? 'sa_feedback_status_enabled'.tr : 'sa_feedback_status_disabled'.tr,
        style: context.typography.xsMedium.copyWith(color: color),
      ),
    );
  }
}
