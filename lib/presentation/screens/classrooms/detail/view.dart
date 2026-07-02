import '../../../../index/index_main.dart';
import 'widgets/cd_header.dart';
import 'widgets/cd_child_card.dart';
import 'widgets/cd_teacher_card.dart';

class ClassroomDetailView extends StatefulWidget {
  const ClassroomDetailView({super.key});

  @override
  State<ClassroomDetailView> createState() => _ClassroomDetailViewState();
}

class _ClassroomDetailViewState extends State<ClassroomDetailView> {
  late final ClassroomDetailController controller;

  @override
  void initState() {
    super.initState();
    final classroom = Get.arguments as ClassroomModel;
    // Force-delete any cached controller so each classroom gets a fresh instance
    if (Get.isRegistered<ClassroomDetailController>()) {
      Get.delete<ClassroomDetailController>(force: true);
    }
    controller = Get.put(ClassroomDetailController(classroom: classroom));
  }

  @override
  void dispose() {
    Get.delete<ClassroomDetailController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: controller.classroom.name,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Obx(() => Stack(
          children: [
            RefreshIndicator(
              onRefresh: controller.loadAll,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Obx(() => CdHeader(
                      classroom: controller.classroom,
                      childCount: controller.children.length,
                      teacherCount: controller.teachers.length,
                    )),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                  _childrenSection(),
                  SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                  _teachersSection(),
                  SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                ],
              ),
            ),
            if (controller.selectMode.value) _BulkBar(controller: controller),
          ],
        )),
      ),
    );
  }

  Widget _childrenSection() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverToBoxAdapter(
        child: Obx(() {
          final isLoading = controller.isChildrenLoading.value;
          final children = controller.children;
          final selectMode = controller.selectMode.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.child_care_rounded,
                    size: 18.sp,
                    color: const Color(0xFF059669),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'cd_children_section'.tr,
                    style: context.typography.displaySmBold.copyWith(
                      fontSize: 15,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  if (!isLoading && children.isNotEmpty && !selectMode)
                    TextButton.icon(
                      onPressed: controller.toggleSelectMode,
                      icon: Icon(
                        Icons.checklist_rounded,
                        size: 16.sp,
                        color: const Color(0xFF7C3AED),
                      ),
                      label: Text(
                        'cd_select'.tr,
                        style: context.typography.smSemiBold.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF7C3AED),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                      ),
                    ),
                  if (selectMode) ...[
                    TextButton(
                      onPressed: controller.toggleSelectAll,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 4.h,
                        ),
                      ),
                      child: Text(
                        controller.allSelected
                            ? 'cd_deselect_all'.tr
                            : 'cd_select_all'.tr,
                        style: context.typography.smSemiBold.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: controller.toggleSelectMode,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 4.h,
                        ),
                      ),
                      child: Text(
                        'cd_cancel'.tr,
                        style: context.typography.smSemiBold.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12.h),
              if (isLoading)
                _SectionShimmer()
              else if (children.isEmpty)
                _ChildrenEmpty()
              else
                ...children.map((child) => Obx(() => CdChildCard(
                  child: child,
                  selectMode: controller.selectMode.value,
                  isSelected: controller.selected.contains(child.key),
                  onTransfer: () => controller.openTransfer(child),
                  onToggle: () => controller.toggleChild(child.key ?? ''),
                ))),
            ],
          );
        }),
      ),
    );
  }

  Widget _teachersSection() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverToBoxAdapter(
        child: Obx(() {
          final isLoading = controller.isTeachersLoading.value;
          final teachers = controller.teachers;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.school_rounded,
                    size: 18.sp,
                    color: const Color(0xFF7C3AED),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'cd_teachers_section'.tr,
                    style: context.typography.displaySmBold.copyWith(
                      fontSize: 15,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: controller.openAssignTeacher,
                    icon: Icon(
                      Icons.add_rounded,
                      color: const Color(0xFF7C3AED),
                      size: 22.sp,
                    ),
                    tooltip: 'cd_assign_teacher_title'.tr,
                    splashRadius: 20,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (isLoading)
                _SectionShimmer()
              else if (teachers.isEmpty)
                _TeachersEmpty()
              else
                ...teachers.map((s) => CdTeacherCard(
                  staff: s,
                  onRemove: () => controller.removeTeacher(s),
                )),
            ],
          );
        }),
      ),
    );
  }
}

// ── Bulk transfer bottom bar ───────────────────────────────────────────────────

class _BulkBar extends StatelessWidget {
  final ClassroomDetailController controller;
  const _BulkBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Obx(() {
        final count = controller.selected.length;
        return AnimatedSlide(
          offset: count > 0 ? Offset.zero : const Offset(0, 1),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              16.w,
              16.h,
              16.w,
              16.h + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1A000000),
                  blurRadius: 20.r,
                  offset: Offset(0, -4.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '$count ${'cd_selected'.tr}',
                    style: context.typography.smSemiBold.copyWith(
                      color: const Color(0xFF7C3AED),
                      fontSize: 13,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: count > 0 ? controller.openBulkTransfer : null,
                    icon: Icon(Icons.swap_horiz_rounded, size: 18.sp),
                    label: Text('cd_bulk_transfer'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Empty states ──────────────────────────────────────────────────────────────

class _ChildrenEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 32.h),
    child: Center(
      child: Column(
        children: [
          Icon(
            Icons.child_care_outlined,
            size: 48.sp,
            color: const Color(0xFFCBD5E1),
          ),
          SizedBox(height: 12.h),
          Text(
            'cd_children_empty'.tr,
            style: context.typography.smMedium.copyWith(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    ),
  );
}

class _TeachersEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 32.h),
    child: Center(
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 48.sp,
            color: const Color(0xFFCBD5E1),
          ),
          SizedBox(height: 12.h),
          Text(
            'cd_teachers_empty'.tr,
            style: context.typography.smMedium.copyWith(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SectionShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    children: List.generate(
      3,
      (_) => Container(
        margin: EdgeInsets.only(bottom: 10.h),
        height: 64.h,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
    ),
  );
}
