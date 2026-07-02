import '../../../../index/index_main.dart';
import 'widgets/dashboard_item_model.dart';

class OwnerDashboardController extends GetxController {
  late final SessionService _session;

  @override
  void onInit() {
    super.onInit();
    _session = SessionService();
  }

  String get ownerName => _session.currentUser?.displayName ?? 'owner_default_name'.tr;

  List<DashboardSection> get sections => [
    // ── Nursery ──────────────────────────────────────────────────────────────
    DashboardSection(
      titleKey: 'owner_section_nursery',
      titleIcon: Icons.business_rounded,
      titleColor: AppColors.primary,
      items: [
        DashboardItem(
          labelKey: 'owner_item_branches',
          icon: Icons.account_balance_rounded,
          color: AppColors.primary,
          route: branchesView,
        ),
        DashboardItem(
          labelKey: 'owner_item_packages',
          icon: Icons.card_membership_rounded,
          color: AppColors.primary60,
          route: nurseryPackagesView,
        ),
      ],
    ),

    // ── Staff ─────────────────────────────────────────────────────────────────
    DashboardSection(
      titleKey: 'owner_section_staff',
      titleIcon: Icons.badge_rounded,
      titleColor: AppColors.blueForeground,
      items: [
        DashboardItem(
          labelKey: 'owner_item_staff_list',
          icon: Icons.people_alt_rounded,
          color: AppColors.blueForeground,
          route: staffView,
        ),
        DashboardItem(
          labelKey: 'owner_item_staff_permissions',
          icon: Icons.shield_rounded,
          color: const Color(0xFF6366F1),
          route: staffView,
        ),
      ],
    ),

    // ── Children ──────────────────────────────────────────────────────────────
    DashboardSection(
      titleKey: 'owner_section_children',
      titleIcon: Icons.child_care_rounded,
      titleColor: AppColors.successForeground,
      items: [
        DashboardItem(
          labelKey: 'owner_item_children',
          icon: Icons.child_care_rounded,
          color: AppColors.successForeground,
          route: childrenView,
        ),
        DashboardItem(
          labelKey: 'owner_item_enrollments',
          icon: Icons.app_registration_rounded,
          color: const Color(0xFF059669),
          route: enrollmentsView,
        ),
        DashboardItem(
          labelKey: 'owner_item_waiting_list',
          icon: Icons.pending_actions_rounded,
          color: AppColors.primary40,
          route: waitingListView,
        ),
        DashboardItem(
          labelKey: 'owner_item_leave_requests',
          icon: Icons.event_busy_rounded,
          color: const Color(0xFFF97316),
          route: childLeaveRequestsView,
        ),
        DashboardItem(
          labelKey: 'owner_item_medical',
          icon: Icons.medical_services_rounded,
          color: AppColors.errorForeground,
          route: childMedicalView,
        ),
        DashboardItem(
          labelKey: 'owner_item_documents',
          icon: Icons.folder_copy_rounded,
          color: AppColors.yellowForeground,
          route: childDocumentsView,
        ),
        DashboardItem(
          labelKey: 'owner_item_pickup',
          icon: Icons.directions_car_rounded,
          color: AppColors.primary60,
          route: authorizedPickupView,
        ),
      ],
    ),

    // ── Classrooms ────────────────────────────────────────────────────────────
    DashboardSection(
      titleKey: 'owner_section_classrooms',
      titleIcon: Icons.school_rounded,
      titleColor: AppColors.yellowForeground,
      items: [
        DashboardItem(
          labelKey: 'owner_item_classrooms',
          icon: Icons.class_rounded,
          color: AppColors.yellowForeground,
          route: classroomsView,
        ),
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
    ),

    // ── Attendance & Care ─────────────────────────────────────────────────────
    DashboardSection(
      titleKey: 'owner_section_attendance',
      titleIcon: Icons.fingerprint_rounded,
      titleColor: AppColors.teal,
      items: [
        DashboardItem(
          labelKey: 'owner_item_checkin',
          icon: Icons.login_rounded,
          color: AppColors.teal,
          route: checkInView,
        ),
        DashboardItem(
          labelKey: 'owner_item_daily_care',
          icon: Icons.baby_changing_station_rounded,
          color: const Color(0xFF0891B2),
          route: attendanceDailyView,
        ),
      ],
    ),

    // ── Finance ───────────────────────────────────────────────────────────────
    DashboardSection(
      titleKey: 'owner_section_finance',
      titleIcon: Icons.account_balance_wallet_rounded,
      titleColor: const Color(0xFFD97706),
      items: [
        DashboardItem(
          labelKey: 'owner_item_invoices',
          icon: Icons.receipt_long_rounded,
          color: const Color(0xFFD97706),
          route: invoicesView,
        ),
        DashboardItem(
          labelKey: 'owner_item_payments',
          icon: Icons.payments_rounded,
          color: const Color(0xFFB45309),
          route: paymentsView,
        ),
      ],
    ),

    // ── Communication ─────────────────────────────────────────────────────────
    DashboardSection(
      titleKey: 'owner_section_communication',
      titleIcon: Icons.family_restroom_rounded,
      titleColor: AppColors.errorForeground,
      items: [
        DashboardItem(
          labelKey: 'owner_item_guardians',
          icon: Icons.family_restroom_rounded,
          color: AppColors.errorForeground,
          route: guardianListView,
        ),
        DashboardItem(
          labelKey: 'owner_item_notifications',
          icon: Icons.notifications_active_rounded,
          color: AppColors.tagTextError,
          route: notificationsView,
        ),
      ],
    ),
  ];

  void logout() => showLogoutConfirm();
}
