import '../../../../../../index/index_main.dart';
import '../../parent_account/parent_status_chip.dart';
import '../parent_invite_row.dart';

class BulkInviteParentCard extends StatelessWidget {
  final ParentInviteRow row;
  final VoidCallback onSend;

  const BulkInviteParentCard({
    super.key,
    required this.row,
    required this.onSend,
  });

  static const _whatsappGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context) {
    final sent = row.status != ParentOnboardingStatus.notSent;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  row.parent.name.isNotEmpty ? row.parent.name[0] : '?',
                  style: context.typography.mdBold.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.parent.name,
                      style: context.typography.mdBold.copyWith(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      row.parent.phone ?? '',
                      textDirection: TextDirection.ltr,
                      style: context.typography.xsRegular.copyWith(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              ParentStatusChip(status: row.status),
            ],
          ),
          SizedBox(height: 12.h),
          _childrenLine(context),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton.icon(
              onPressed: row.hasPhone ? onSend : null,
              icon: Icon(
                sent ? Icons.done_all_rounded : Icons.chat_rounded,
                size: 19.sp,
              ),
              label: Text(
                sent ? 'rc_invite_resend'.tr : 'rc_invite_send'.tr,
                style: context.typography.displaySmBold.copyWith(fontSize: 14.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    sent ? const Color(0xFF16A34A) : _whatsappGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _childrenLine(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Row(
      children: [
        Icon(Icons.child_care_rounded,
            size: 16.sp, color: const Color(0xFF94A3B8)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            row.childNames.join('، '),
            style: context.typography.smMedium.copyWith(
              fontSize: 13,
              color: const Color(0xFF475569),
            ),
          ),
        ),
      ],
    ),
  );
}
