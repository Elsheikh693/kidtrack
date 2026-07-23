import '../../../../index/index_main.dart';
import '../dashboard/widgets/dashboard_item_model.dart';
import '../dashboard/widgets/dashboard_section_widget.dart';

class OwnerEducationTab extends StatelessWidget {
  const OwnerEducationTab({super.key});

  static final _classroomsSection = DashboardSection(
    titleKey: 'owner_section_classrooms',
    titleIcon: Icons.class_rounded,
    titleColor: AppColors.yellowForeground,
    items: [
      DashboardItem(
        labelKey: 'owner_item_classrooms',
        icon: Icons.class_rounded,
        color: AppColors.yellowForeground,
        route: classroomsView,
      ),
    ],
  );

  static final _curriculumSection = DashboardSection(
    titleKey: 'owner_section_attendance',
    titleIcon: Icons.library_books_rounded,
    titleColor: AppColors.secondary60,
    items: [
      DashboardItem(
        labelKey: 'owner_item_programs',
        icon: Icons.library_books_rounded,
        color: AppColors.secondary60,
        route: programsView,
      ),
      DashboardItem(
        labelKey: 'owner_item_subjects',
        icon: Icons.menu_book_rounded,
        color: AppColors.closedText,
        route: subjectsView,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            KidTrackCollapsingHeader(
              title: 'ownertabs20_education'.tr,
              icon: Icons.school_rounded,
              accentColor: const Color(0xFFD97706),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  DashboardSectionWidget(section: _classroomsSection),
                  DashboardSectionWidget(section: _curriculumSection),
                ]),
              ),
            ),
          ],
        );
  }
}

