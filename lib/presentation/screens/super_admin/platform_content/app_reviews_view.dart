import '../../../../index/index_main.dart';

class AppReviewsAdminView extends StatefulWidget {
  const AppReviewsAdminView({super.key});

  @override
  State<AppReviewsAdminView> createState() => _AppReviewsAdminViewState();
}

class _AppReviewsAdminViewState extends State<AppReviewsAdminView> {
  late final AppReviewsAdminController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => AppReviewsAdminController());
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
          'pcontent_reviews'.tr,
          style:
              context.typography.mdBold.copyWith(color: AppColors.textDefault),
        ),
      ),
      body: Column(
        children: [
          Obx(() => controller.total == 0
              ? const SizedBox.shrink()
              : _SummaryBar(controller: controller)),
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
                  itemBuilder: (_, i) => _ReviewCard(
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
    case 'new':
      return const Color(0xFFF59E0B);
    case 'read':
      return const Color(0xFF6366F1);
    case 'replied':
      return const Color(0xFF10B981);
    default:
      return AppColors.grayMedium;
  }
}

class _SummaryBar extends StatelessWidget {
  final AppReviewsAdminController controller;
  const _SummaryBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 14.h),
      child: Row(
        children: [
          Icon(Icons.star_rounded, color: AppColors.ratingStar, size: 26.sp),
          SizedBox(width: 8.w),
          Text(
            controller.averageRating.toStringAsFixed(1),
            style: context.typography.lgBold
                .copyWith(color: AppColors.textDefault),
          ),
          SizedBox(width: 6.w),
          Text(
            'arv_avg_of'.trParams({'n': controller.total.toString()}),
            style: context.typography.xsRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final AppReviewsAdminController controller;
  const _FilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.only(bottom: 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Obx(
          () => Row(
            children: AppReviewsAdminController.statuses.map((s) {
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
                      '${'arv_status_$s'.tr} (${controller.countOf(s)})',
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

class _ReviewCard extends StatelessWidget {
  final AppReviewModel item;
  final VoidCallback onReply;
  final VoidCallback onDelete;

  const _ReviewCard({
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
              ...List.generate(
                5,
                (i) => Icon(
                  i < item.rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: AppColors.ratingStar,
                  size: 18.sp,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'arv_status_${item.status}'.tr,
                  style: context.typography.xsMedium.copyWith(color: color),
                ),
              ),
            ],
          ),
          if (item.tags.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: item.tags
                  .map((t) => Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          t.tr,
                          style: context.typography.xsMedium
                              .copyWith(color: AppColors.primary),
                        ),
                      ))
                  .toList(),
            ),
          ],
          if ((item.comment ?? '').isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              item.comment!,
              style: context.typography.xsRegular.copyWith(
                  color: AppColors.textSecondaryParagraph, height: 1.5),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.person_outline_rounded,
                  size: 15.sp, color: AppColors.grayMedium),
              SizedBox(width: 4.w),
              Text(
                (item.name ?? '').isEmpty ? 'arv_anonymous'.tr : item.name!,
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
                '${'arv_reply_label'.tr}: ${item.adminReply}',
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
                        'arv_reply'.tr,
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
          Icon(Icons.reviews_outlined, size: 56.sp, color: AppColors.grayMedium),
          SizedBox(height: 14.h),
          Text(
            'arv_empty'.tr,
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
          height: 130.h,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}
