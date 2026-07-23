import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Global/widgets/kidtrack_tab_header.dart';
import 'teacher_students_controller.dart';
import 'widgets/teacher_student_card.dart';
import '../../../../Global/Localization/app_direction.dart';

class TeacherStudentsTab extends StatefulWidget {
  const TeacherStudentsTab({super.key});

  @override
  State<TeacherStudentsTab> createState() => _TeacherStudentsTabState();
}

class _TeacherStudentsTabState extends State<TeacherStudentsTab> {
  late final TeacherStudentsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TeacherStudentsController(), permanent: false);
  }

  static const _blue = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
          onRefresh: controller.refresh,
          color: _blue,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              KidTrackCollapsingHeader(
                title: 'teacherrep38_students_title'.tr,
                icon: Icons.groups_rounded,
                accentColor: _blue,
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: _SearchBar(onChanged: controller.search),
                ),
              ),

              // Classroom filter chips (only if multiple classrooms)
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.myClassrooms.length <= 1) {
                    return const SizedBox.shrink();
                  }
                  return _ClassroomFilterBar(
                    classrooms: controller.myClassrooms
                        .map((c) => (id: c.key ?? '', name: c.name))
                        .toList(),
                    selected: controller.selectedClassroomId.value,
                    onSelect: controller.selectClassroom,
                  );
                }),
              ),

              // Student list
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                sliver: Obx(() {
                  if (controller.isLoading.value) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final list = controller.filtered;
                  if (list.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.groups_outlined,
                                size: 56, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'teacherrep38_students_empty'.tr,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => TeacherStudentCard(
                        child: list[i],
                        attendanceStatus:
                            controller.attendanceStatus(list[i].key ?? ''),
                        classroomName: controller.myClassrooms.length > 1
                            ? controller.classroomName(list[i].classroomId)
                            : null,
                        index: i,
                      ),
                      childCount: list.length,
                    ),
                  );
                }),
              ),
            ],
          ),
        );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textDirection: appTextDirection,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'teacherrep38_students_search_hint'.tr,
        hintTextDirection: TextDirection.rtl,
        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

// ── Classroom Filter Bar ──────────────────────────────────────────────────────

class _ClassroomFilterBar extends StatelessWidget {
  const _ClassroomFilterBar({
    required this.classrooms,
    required this.selected,
    required this.onSelect,
  });

  final List<({String id, String name})> classrooms;
  final String selected;
  final ValueChanged<String> onSelect;

  static const _blue = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // "All" chip
          _FilterChip(
            label: 'teacherrep38_filter_all'.tr,
            isSelected: selected.isEmpty,
            onTap: () => onSelect(''),
            color: _blue,
          ),
          ...classrooms.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: c.name,
                  isSelected: selected == c.id,
                  onTap: () => onSelect(c.id),
                  color: _blue,
                ),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
