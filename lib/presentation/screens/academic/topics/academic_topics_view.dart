import '../../../../index/index_main.dart';
import '../../../../Data/models/academic_topic/academic_topic_model.dart';
import 'academic_topics_controller.dart';

class AcademicTopicsView extends StatelessWidget {
  const AcademicTopicsView({super.key});

  static const _amber = Color(0xFFD97706);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AcademicTopicsController());
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'presentati10_curriculum_topics'.tr,
                    style: context.typography.mdBold.copyWith(color: Color(0xFF111827)),
                  ),
                  Text(
                    c.subjectName,
                    style: context.typography.xsRegular.copyWith(color: Color(0xFF6B7280)),
                  ),
                ],
              )),
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded,
                size: 18.sp, color: Color(0xFF374151)),
            onPressed: Get.back,
          ),
          actions: [
            Obx(() => Container(
                  margin: EdgeInsets.only(
                      left: 8.w, right: 16.w, top: 8.h, bottom: 8.h),
                  child: FilledButton.icon(
                    onPressed: c.showAddSheet,
                    icon: Icon(Icons.add_rounded, size: 16.sp),
                    label: Text('presentati10_add'.tr,
                        style: context.typography.xsMedium),
                    style: FilledButton.styleFrom(
                      backgroundColor: _amber,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                    ),
                  ),
                )),
          ],
        ),
        body: Obx(() {
          if (c.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(color: _amber));
          }
          if (c.topics.isEmpty) {
            return _EmptyState(onAdd: c.showAddSheet);
          }
          return RefreshIndicator(
            color: _amber,
            onRefresh: c.refresh,
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
              itemCount: c.topics.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (ctx, i) {
                final topic = c.topics[i];
                return _TopicCard(
                  topic: topic,
                  index: i,
                  onEdit: () => c.showEditSheet(topic),
                  onDelete: () => c.confirmDelete(topic),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

// ── Topic Card ────────────────────────────────────────────────────────────────

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });
  final AcademicTopicModel topic;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        leading: Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: const Color(0xFFD97706).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: context.typography.displaySmBold.copyWith(color: Color(0xFFD97706)),
            ),
          ),
        ),
        title: Text(
          topic.title,
          style: context.typography.displaySmBold.copyWith(color: Color(0xFF111827)),
        ),
        subtitle: topic.description != null && topic.description!.isNotEmpty
            ? Text(
                topic.description!,
                style: context.typography.xsRegular.copyWith(color: Colors.grey.shade500),
              )
            : null,
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_rounded, size: 18.sp, color: Color(0xFF374151)),
                SizedBox(width: 10.w),
                Text('presentati10_edit'.tr),
              ]),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_rounded, size: 18.sp, color: Color(0xFFDC2626)),
                SizedBox(width: 10.w),
                Text('presentati10_delete'.tr,
                    style: context.typography.smRegular
                        .copyWith(color: Color(0xFFDC2626))),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded,
                size: 64.sp, color: Colors.grey.shade200),
            SizedBox(height: 16.h),
            Text(
              'presentati10_no_topics_yet'.tr,
              style: context.typography.mdBold.copyWith(color: Color(0xFF9CA3AF)),
            ),
            SizedBox(height: 8.h),
            Text(
              'presentati10_add_topics_hint'.tr,
              style: context.typography.xsRegular.copyWith(color: Colors.grey.shade400),
            ),
            SizedBox(height: 24.h),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text('presentati10_add_first_topic'.tr),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
