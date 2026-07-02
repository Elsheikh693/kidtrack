import '../../../../../index/index_main.dart';

class SetupBranchTile extends StatelessWidget {
  final BranchModel branch;
  final String? managerName;
  final String? phone;
  final VoidCallback onDelete;
  final VoidCallback onSetMain;
  const SetupBranchTile({
    super.key,
    required this.branch,
    this.managerName,
    this.phone,
    required this.onDelete,
    required this.onSetMain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: branch.isMain
              ? const Color(0xFF5E35B1)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE7FF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.location_city_rounded,
                color: const Color(0xFF5E35B1), size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(branch.name,
                          style: context.typography.smSemiBold.copyWith(
                              fontSize: 15, color: const Color(0xFF1F2937))),
                    ),
                    if (branch.isMain) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE7FF),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text('setup_branch_main_badge'.tr,
                            style: context.typography.displaySmBold.copyWith(
                                fontSize: 11,
                                color: const Color(0xFF5E35B1))),
                      ),
                    ],
                  ],
                ),
                if ((managerName ?? '').isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline_rounded,
                            size: 13.sp, color: const Color(0xFF6B7280)),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            (phone ?? '').isNotEmpty
                                ? '$managerName · $phone'
                                : managerName!,
                            style: context.typography.xsRegular.copyWith(
                                fontSize: 12, color: const Color(0xFF6B7280)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (!branch.isMain)
            IconButton(
              tooltip: 'setup_branch_set_main'.tr,
              icon: Icon(Icons.star_outline_rounded,
                  color: const Color(0xFF5E35B1), size: 20.sp),
              onPressed: onSetMain,
            ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: const Color(0xFFEF4444), size: 20.sp),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
