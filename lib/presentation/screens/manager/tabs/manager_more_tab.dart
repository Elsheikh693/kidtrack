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
                    const RoleSwitchCard(),
                    ManagerProfileCard(
                      controller: controller,
                      onTap: () => showEditProfileSheet(isStaff: true),
                    ),
                    const SizedBox(height: 24),
                    _nurseryProfileSection(),
                    const SizedBox(height: 20),
                    _operationsSection(),
                    const SizedBox(height: 20),
                    _businessSection(),
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

  /// Nursery public profile, surfaced on its own directly under the header.
  Widget _nurseryProfileSection() {
    return ManagerGridSection(
      titleKey: 'owner_section_nursery',
      tiles: [
        ManagerGridTile(
          icon: Icons.checklist_rounded,
          color: AppColors.primary,
          labelKey: 'owner_item_setup_checklist',
          onTap: () => Get.toNamed(setupChecklistView),
        ),
        ManagerGridTile(
          icon: Icons.ondemand_video_rounded,
          color: const Color(0xFFDC2626),
          labelKey: 'tutorial_menu_entry',
          onTap: () => Get.toNamed(appTutorialView),
        ),
        // "الفروع" now lives inside "خطوات الإعداد"; "الكورسات" temporarily
        // removed — both dropped from this section for manager/owner.
      ],
    );
  }

  /// Day-to-day running of the branch: people, classes and incoming families.
  Widget _operationsSection() {
    return ManagerGridSection(
      titleKey: 'manager_more_section_operations',
      tiles: [
        // "أرقام التواصل" now lives inside "خطوات الإعداد".
        ManagerGridTile(
          icon: Icons.event_busy_rounded,
          color: AppColors.activityOrange,
          labelKey: 'manager_more_link_holidays',
          onTap: () => Get.toNamed(holidaysView),
        ),
        // "الأطفال" moved to the Children tab (ManagerChildrenTab).
        ManagerGridTile(
          icon: Icons.emoji_events_rounded,
          color: const Color(0xFFE0A100),
          labelKey: 'sotw_menu_entry',
          onTap: () => Get.toNamed(starOfWeekView),
        ),
        ManagerGridTile(
          icon: Icons.reviews_rounded,
          color: AppColors.ratingStar,
          labelKey: 'nursery_feedback_view_title',
          onTap: () => Get.toNamed(nurseryFeedbackListView),
        ),
        ManagerGridTile(
          icon: Icons.rate_review_rounded,
          color: const Color(0xFF0891B2),
          labelKey: 'manager_item_photo_approval',
          onTap: () => Get.toNamed(managerPhotoApprovalSettingsView),
        ),
        ManagerGridTile(
          icon: Icons.forum_rounded,
          color: AppColors.activityPurple,
          labelKey: 'parent_notes_tab',
          onTap: () => Get.to(() => const ParentNotesInboxView()),
        ),
        ManagerGridTile(
          icon: Icons.assignment_rounded,
          color: const Color(0xFF4F46E5),
          labelKey: 'assessment_templates_menu_item',
          onTap: () => Get.toNamed(assessmentRunsView),
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
          icon: Icons.event_available_rounded,
          color: const Color(0xFF16A34A),
          labelKey: 'manager_profile_fee_window',
          onTap: () => Get.toNamed(managerFeeWindowView),
        ),
        // "حسابات استلام المدفوعات" now lives inside "خطوات الإعداد".
        // "طلبات الالتحاق" and "ملف التقديم" tiles temporarily removed
        // for manager/owner.
      ],
    );
  }

  // "الإعدادات" section removed — its only remaining item (الإشعارات) is
  // already reachable from the bell icon in the app bar.
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
