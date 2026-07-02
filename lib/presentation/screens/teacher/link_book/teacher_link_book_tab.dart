import '../../../../index/index_main.dart';

const _kBlue = Color(0xFF2563EB);

class TeacherLinkBookTab extends StatelessWidget {
  const TeacherLinkBookTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LinkBookController>(
      init: LinkBookController(),
      builder: (_) => RefreshIndicator(
        onRefresh: Get.find<LinkBookController>().reload,
        child: ColoredBox(
          color: const Color(0xFFF8F9FA),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              TeacherClassicAppBar(title: 'teacher_tab_link_book'.tr),
              const LbFilterBar(),
              _LbBody(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Body switches between classroom report and child summary ──────────────────

class _LbBody extends GetView<LinkBookController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingClassrooms.value) {
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: List.generate(
                3,
                (i) => Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  height: 118,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(width: 5, color: Colors.grey.shade200),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 13,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 10,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      if (!controller.hasClassroom) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: _kBlue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.class_rounded,
                    size: 40,
                    color: _kBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد فصول مسجلة',
                  style: context.typography.smSemiBold.copyWith(
                    color: const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return controller.isChildMode
          ? const LbChildSummary()
          : const LbClassroomReport();
    });
  }
}
