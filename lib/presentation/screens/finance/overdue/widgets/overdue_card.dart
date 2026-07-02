import '../../../../../index/index_main.dart';

class OverdueCard extends StatelessWidget {
  final Obligation item;

  const OverdueCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final s = _StatusStyle.of(item.status);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFEEF1F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Leading avatar
              Container(
                width: 46.w,
                height: 46.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: s.bg,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  item.party.characters.first,
                  style: context.typography.mdBold.copyWith(color: s.fg),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.party,
                      style: context.typography.displaySmBold
                          .copyWith(color: const Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            item.categoryName,
                            style: context.typography.xsRegular
                                .copyWith(color: const Color(0xFF64748B)),
                          ),
                        ),
                        if (item.item != null) ...[
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              item.item!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.typography.xsRegular
                                  .copyWith(color: const Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '${item.amount.toStringAsFixed(0)} ${'overdue_currency'.tr}',
                style: context.typography.mdBold
                    .copyWith(color: const Color(0xFF1E293B)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1, color: Color(0xFFEEF1F5)),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14.sp, color: s.fg),
              SizedBox(width: 6.w),
              Text(
                _dueLabel(),
                style: context.typography.xsMedium.copyWith(color: s.fg),
              ),
              const Spacer(),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: s.bg,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  s.label,
                  style: context.typography.xsMedium.copyWith(color: s.fg),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _dueLabel() {
    switch (item.status) {
      case ObligationStatus.paid:
        return 'overdue_due_paid'.tr;
      case ObligationStatus.overdue:
        return 'overdue_due_since'.trParams({'n': '${item.daysUntilDue.abs()}'});
      case ObligationStatus.upcoming:
        return 'overdue_due_in'.trParams({'n': '${item.daysUntilDue}'});
    }
  }
}

class _StatusStyle {
  final Color bg;
  final Color fg;
  final String label;

  const _StatusStyle({required this.bg, required this.fg, required this.label});

  factory _StatusStyle.of(ObligationStatus status) {
    switch (status) {
      case ObligationStatus.overdue:
        return _StatusStyle(
          bg: AppColors.errorBackground,
          fg: AppColors.errorForeground,
          label: 'overdue_filter_overdue'.tr,
        );
      case ObligationStatus.upcoming:
        return _StatusStyle(
          bg: AppColors.yellowBackground,
          fg: AppColors.yellowForeground,
          label: 'overdue_filter_upcoming'.tr,
        );
      case ObligationStatus.paid:
        return _StatusStyle(
          bg: AppColors.successBackground,
          fg: AppColors.successForeground,
          label: 'overdue_filter_paid'.tr,
        );
    }
  }
}
