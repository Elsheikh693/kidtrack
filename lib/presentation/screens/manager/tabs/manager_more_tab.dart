import '../../../../index/index_main.dart';
import '../widgets/manager_tab_header.dart';
import '../more/widgets/manager_profile_card.dart';
import '../more/widgets/manager_grid_section.dart';
import '../more/widgets/manager_grid_tile.dart';
import '../more/widgets/manager_logout_button.dart';

class ManagerMoreTab extends StatefulWidget {
  const ManagerMoreTab({super.key});

  @override
  State<ManagerMoreTab> createState() => _ManagerMoreTabState();
}

class _ManagerMoreTabState extends State<ManagerMoreTab> {
  static const _accent = AppColors.activityPurple;

  late final ManagerMoreController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ManagerMoreController>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ManagerTabHeader(title: 'manager_tab_more'.tr, accent: _accent),
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (SessionService().canSwitchRole &&
                        SessionService().isViewingAsManager) ...[
                      const _BackToOwnerCard(),
                      const SizedBox(height: 16),
                    ],
                    ManagerProfileCard(
                      controller: controller,
                      onTap: () => showEditProfileSheet(isStaff: true),
                    ),
                    const SizedBox(height: 24),
                    _operationsSection(),
                    const SizedBox(height: 20),
                    Obx(() => _businessSection()),
                    const SizedBox(height: 20),
                    _settingsSection(),
                    const SizedBox(height: 24),
                    const ManagerLogoutButton(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Day-to-day running of the branch: people, classes and incoming families.
  Widget _operationsSection() {
    return ManagerGridSection(
      titleKey: 'manager_more_section_operations',
      tiles: [
        ManagerGridTile(
          icon: Icons.child_care_rounded,
          color: AppColors.activityGreen,
          labelKey: 'manager_more_link_children',
          onTap: () => Get.toNamed(childrenView),
        ),
        ManagerGridTile(
          icon: Icons.badge_rounded,
          color: AppColors.activityBlue,
          labelKey: 'manager_more_link_staff',
          onTap: () => Get.toNamed(staffView),
        ),
        ManagerGridTile(
          icon: Icons.meeting_room_rounded,
          color: AppColors.activityOrange,
          labelKey: 'manager_more_link_classrooms',
          onTap: () => Get.toNamed(classroomsView),
        ),
        ManagerGridTile(
          icon: Icons.contact_phone_rounded,
          color: const Color(0xFF25D366),
          labelKey: 'owner_item_contact_numbers',
          onTap: () => Get.toNamed(nurseryContactsView),
        ),
        ManagerGridTile(
          icon: Icons.play_lesson_rounded,
          color: AppColors.activityPurple,
          labelKey: 'manager_more_link_courses',
          onTap: () => Get.toNamed(coursesView),
        ),
        ManagerGridTile(
          icon: Icons.library_books_rounded,
          color: AppColors.activityAmberBrand,
          labelKey: 'owner_item_programs',
          onTap: () => Get.toNamed(programsView),
        ),
        ManagerGridTile(
          icon: Icons.menu_book_rounded,
          color: AppColors.teal,
          labelKey: 'owner_item_subjects',
          onTap: () => Get.toNamed(subjectsView),
        ),
        ManagerGridTile(
          icon: Icons.account_balance_rounded,
          color: AppColors.activityPurple,
          labelKey: 'owner_item_branches',
          onTap: () => Get.toNamed(branchesView),
        ),
        ManagerGridTile(
          icon: Icons.card_membership_rounded,
          color: AppColors.primary,
          labelKey: 'owner_item_packages',
          onTap: () => Get.toNamed(nurseryPackagesView),
        ),
      ],
    );
  }

  /// Nursery-level setup: the public profile, branches and pricing packages.
  Widget _businessSection() {
    return ManagerGridSection(
      titleKey: 'owner_more_business',
      tiles: [
        ManagerGridTile(
          icon: Icons.payments_rounded,
          color: AppColors.activityGreen,
          labelKey: 'billing_my_subscription',
          onTap: () => Get.toNamed(mySubscriptionView),
        ),
        ManagerGridTile(
          icon: Icons.app_registration_rounded,
          color: AppColors.secondary80,
          labelKey: 'apply_manage_title',
          badgeCount: controller.pendingApplications.value,
          onTap: () => Get.toNamed(managerApplicationsView)
              ?.then((_) => controller.loadPendingApplications()),
        ),
        ManagerGridTile(
          icon: Icons.storefront_rounded,
          color: AppColors.secondary80,
          labelKey: 'manager_more_link_nursery_profile',
          onTap: () => Get.toNamed(managerNurseryProfileView),
        ),
        ManagerGridTile(
          icon: Icons.reviews_rounded,
          color: AppColors.ratingStar,
          labelKey: 'nursery_feedback_view_title',
          onTap: () => Get.toNamed(nurseryFeedbackListView),
        ),
        ManagerGridTile(
          icon: Icons.assignment_rounded,
          color: AppColors.teal,
          labelKey: 'manager_more_link_application_file',
          onTap: () => Get.toNamed(managerApplicationFileView),
        ),
      ],
    );
  }

  Widget _settingsSection() {
    return ManagerGridSection(
      titleKey: 'manager_more_section_settings',
      tiles: [
        ManagerGridTile(
          icon: Icons.notifications_none_rounded,
          color: AppColors.primary,
          labelKey: 'manager_more_link_notifications',
          onTap: () => Get.toNamed(notificationsView),
        ),
        ManagerGridTile(
          icon: Icons.event_busy_rounded,
          color: AppColors.activityOrange,
          labelKey: 'الإجازات',
          onTap: () => Get.toNamed(holidaysView),
        ),
        ManagerGridTile(
          icon: Icons.support_agent_rounded,
          color: AppColors.blueForeground,
          labelKey: 'staff_account_contact_support',
          onTap: () => showContactSheet(ContactType.support),
        ),
      ],
    );
  }
}

/// Shown only when a real owner is currently acting as a branch manager.
/// Tapping returns to the owner dashboard (network scope).
class _BackToOwnerCard extends StatelessWidget {
  const _BackToOwnerCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: backToOwnerMode,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'owner_back_to_owner'.tr,
                    style: context.typography.smSemiBold.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'owner_acting_as_manager'.tr,
                    style: context.typography.xsRegular.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.swap_horiz_rounded,
                color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
