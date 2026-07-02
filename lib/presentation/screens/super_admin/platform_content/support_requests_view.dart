import '../../../../index/index_main.dart';

class SupportRequestsAdminView extends StatefulWidget {
  const SupportRequestsAdminView({super.key});

  @override
  State<SupportRequestsAdminView> createState() =>
      _SupportRequestsAdminViewState();
}

class _SupportRequestsAdminViewState extends State<SupportRequestsAdminView> {
  late final SupportRequestsAdminController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => SupportRequestsAdminController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: Get.back,
          child: Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textDefault, size: 20.sp),
        ),
        title: Text(
          'pcontent_support'.tr,
          style:
              context.typography.mdBold.copyWith(color: AppColors.textDefault),
        ),
      ),
      body: Column(
        children: [
          _FilterBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const _ShimmerList();
              }
              if (controller.items.isEmpty) {
                return _Empty();
              }
              return RefreshIndicator(
                onRefresh: controller.loadData,
                color: AppColors.primary,
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  itemCount: controller.items.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (_, i) => _RequestCard(
                    item: controller.items[i],
                    onReply: () => controller.openReply(controller.items[i]),
                    onDelete: () =>
                        controller.confirmDelete(controller.items[i]),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'open':
      return const Color(0xFFF59E0B);
    case 'in_progress':
      return const Color(0xFF6366F1);
    case 'resolved':
      return const Color(0xFF10B981);
    case 'closed':
      return AppColors.grayMedium;
    default:
      return AppColors.grayMedium;
  }
}

class _FilterBar extends StatelessWidget {
  final SupportRequestsAdminController controller;
  const _FilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Obx(
          () => Row(
            children: SupportRequestsAdminController.statuses.map((s) {
              final selected = controller.selectedStatus.value == s;
              final color = _statusColor(s);
              return Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: GestureDetector(
                  onTap: () => controller.setStatus(s),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: 0.14)
                          : AppColors.backgroundNeutral100,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: selected ? color : AppColors.grayLight,
                      ),
                    ),
                    child: Text(
                      '${'srq_status_$s'.tr} (${controller.countOf(s)})',
                      style: context.typography.xsMedium.copyWith(
                        color:
                            selected ? color : AppColors.textSecondaryParagraph,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final SupportRequestModel item;
  final VoidCallback onReply;
  final VoidCallback onDelete;

  const _RequestCard({
    required this.item,
    required this.onReply,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayLight.withValues(alpha: 0.6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.subject,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'srq_status_${item.status}'.tr,
                  style: context.typography.xsMedium.copyWith(color: color),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            item.message,
            style: context.typography.xsRegular
                .copyWith(color: AppColors.textSecondaryParagraph, height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.person_outline_rounded,
                  size: 15.sp, color: AppColors.grayMedium),
              SizedBox(width: 4.w),
              Text(
                item.name,
                style: context.typography.xsRegular
                    .copyWith(color: AppColors.textDefault),
              ),
              SizedBox(width: 12.w),
              Icon(Icons.phone_outlined,
                  size: 15.sp, color: AppColors.grayMedium),
              SizedBox(width: 4.w),
              Text(
                item.phone,
                style: context.typography.xsRegular
                    .copyWith(color: AppColors.textDefault),
              ),
            ],
          ),
          if (item.hasReply) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '${'srq_reply_label'.tr}: ${item.adminReply}',
                style: context.typography.xsRegular
                    .copyWith(color: AppColors.primary, height: 1.5),
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onReply,
                  child: Container(
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        'srq_reply'.tr,
                        style: context.typography.xsMedium
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 38.h,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: AppColors.errorBackground,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 18.sp, color: AppColors.errorForeground),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 56.sp, color: AppColors.grayMedium),
          SizedBox(height: 14.h),
          Text(
            'srq_empty'.tr,
            style: context.typography.smRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (_, _) => Shimmer.fromColors(
        baseColor: AppColors.grayLight,
        highlightColor: AppColors.white,
        child: Container(
          height: 140.h,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}
