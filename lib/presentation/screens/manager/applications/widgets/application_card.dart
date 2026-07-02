import '../../../../../index/index_main.dart';

class ApplicationCard extends StatelessWidget {
  final OnlineApplicationModel application;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback? onTap;
  const ApplicationCard({
    super.key,
    required this.application,
    required this.onApprove,
    required this.onReject,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayLight.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if ((application.childPhoto ?? '').isNotEmpty) ...[
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: appCachedImageProvider(application.childPhoto!),
                ),
                SizedBox(width: 10.w),
              ],
              Expanded(
                child: AppText(
                  text: application.childFullName,
                  textStyle: context.typography.mdBold
                      .copyWith(color: AppColors.textDefault),
                  maxLines: 1,
                ),
              ),
              _statusBadge(context),
            ],
          ),
          SizedBox(height: 10.h),
          _info(context, Icons.man_rounded,
              '${application.fatherName} • ${application.fatherPhone}'),
          SizedBox(height: 4.h),
          _info(context, Icons.woman_rounded,
              '${application.motherName} • ${application.motherPhone}'),
          if ((application.branchName ?? '').isNotEmpty) ...[
            SizedBox(height: 4.h),
            _info(context, Icons.account_tree_rounded, application.branchName!),
          ],
          if (application.selectedPackages.isNotEmpty) ...[
            SizedBox(height: 10.h),
            _packagesBox(context),
          ],
          if ((application.notes ?? '').isNotEmpty) ...[
            SizedBox(height: 4.h),
            _info(context, Icons.notes_rounded, application.notes!),
          ],
          if (application.isRejected &&
              (application.rejectionReason ?? '').isNotEmpty) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.activityRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: AppText(
                text: '${'apply_reject_reason'.tr}: ${application.rejectionReason!}',
                textStyle: context.typography.xsRegular
                    .copyWith(color: AppColors.activityRed, height: 1.5),
                maxLines: 4,
              ),
            ),
          ],
          if (application.isApproved && application.appointmentAt != null) ...[
            SizedBox(height: 6.h),
            _info(
              context,
              Icons.event_available_rounded,
              '${ManagerApplicationsController.appointmentDate(application.appointmentAt)} • ${ManagerApplicationsController.appointmentTime(application.appointmentAt)}',
            ),
          ],
          if (application.isPending) ...[
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onReject,
                    child: _actionBox(context, 'apply_reject_btn',
                        AppColors.activityRed, false),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: onApprove,
                    child: _actionBox(context, 'apply_approve_btn',
                        AppColors.activityGreen, true),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      ),
    );
  }

  Widget _packagesBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...application.selectedPackages.map(
            (p) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppText(
                      text: p.name,
                      textStyle: context.typography.xsRegular
                          .copyWith(color: AppColors.textDefault),
                      maxLines: 1,
                    ),
                  ),
                  AppText(
                    text: '${_money(p.price)} ${'currency'.tr}',
                    textStyle: context.typography.xsMedium
                        .copyWith(color: AppColors.textSecondaryParagraph),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 12.h, color: AppColors.grayLight),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: 'apply_total_label'.tr,
                textStyle: context.typography.xsMedium
                    .copyWith(color: AppColors.textDefault),
              ),
              AppText(
                text: '${_money(application.totalFees)} ${'currency'.tr}',
                textStyle: context.typography.smSemiBold
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _money(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  Widget _info(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15.sp, color: AppColors.grayMedium),
        SizedBox(width: 6.w),
        Expanded(
          child: AppText(
            text: text,
            textStyle: context.typography.xsRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _actionBox(
      BuildContext context, String labelKey, Color color, bool filled) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(
        text: labelKey.tr,
        textStyle: context.typography.smSemiBold
            .copyWith(color: filled ? AppColors.white : color),
      ),
    );
  }

  Widget _statusBadge(BuildContext context) {
    late final Color color;
    late final String key;
    if (application.isApproved) {
      color = AppColors.activityGreen;
      key = 'apply_status_approved';
    } else if (application.isRejected) {
      color = AppColors.activityRed;
      key = 'apply_status_rejected';
    } else {
      color = AppColors.activityAmberBrand;
      key = 'apply_status_pending';
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText(
        text: key.tr,
        textStyle: context.typography.xsMedium.copyWith(color: color),
      ),
    );
  }
}
