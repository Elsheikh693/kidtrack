import '../index/index_main.dart';

// ─── Route Names ──────────────────────────────────────────────────────────────

// Entry
const String forceUpdateView = "/ForceUpdateView";
const String onBoardView = "/OnBoardView";
const String activationLandingView = "/ActivationLandingView";
const String activationCodeView = "/ActivationCodeView";
// Nursery Discovery (pre-login)
const String nurseryDiscoveryView = "/NurseryDiscoveryView";
const String nurseryProfileView = "/NurseryProfileView";
const String onlineApplicationView = "/OnlineApplicationView";
// Main shell
const String mainView = "/MainView";
// Subscription renewal (owner, nursery suspended)
const String renewalView = "/RenewalView";

// Nurseries (Super Admin)
const String nurseriesView = "/NurseriesView";
const String nurseryDetailsView = "/NurseryDetailsView";
const String nurseryPackagesView = "/NurseryPackagesView";
const String auditLogView = "/AuditLogView";
const String supportTicketsView = "/SupportTicketsView";

// Platform Subscription Billing
const String platformBillingView = "/PlatformBillingView";
const String platformBillingDetailView = "/PlatformBillingDetailView";
const String mySubscriptionView = "/MySubscriptionView";
const String ownerPhotoReviewSettingsView = "/OwnerPhotoReviewSettingsView";

// Branches
const String branchesView = "/BranchesView";

// Staff
const String staffView = "/StaffView";
const String staffPermissionsView = "/StaffPermissionsView";
const String staffFormView = "/StaffFormView";

// Children
const String childLeaveRequestsView = "/ChildLeaveRequestsView";
const String childrenView = "/ChildrenView";
const String childProfileView = "/ChildProfileView";
const String childRegistrationView = "/ChildRegistrationView";
const String addChildView = "/AddChildView";
const String parentAccountView = "/ParentAccountView";
const String bulkInvitationsView = "/BulkInvitationsView";
const String childMedicalView = "/ChildMedicalView";
const String childDocumentsView = "/ChildDocumentsView";
const String authorizedPickupView = "/AuthorizedPickupView";
const String waitingListView = "/WaitingListView";
const String enrollmentsView = "/EnrollmentsView";

// Classrooms
const String classroomsView = "/ClassroomsView";
const String classroomDetailView = "/ClassroomDetailView";

// Programs
const String programsView = "/ProgramsView";
const String subjectsView = "/SubjectsView";

// Attendance
const String checkInView = "/CheckInView";
const String attendanceDailyView = "/AttendanceDailyView";

// Guardian list (admin)
const String guardianListView = "/GuardianListView";

// Parent
const String parentRequestsHistoryView = "/ParentRequestsHistoryView";
const String staffAccountView = "/StaffAccountView";
const String parentHomeView = "/ParentHomeView";
const String parentOnboardingView = "/ParentOnboardingView";
const String parentTodayScheduleView = "/ParentTodayScheduleView";
const String parentPickupHistoryView = "/ParentPickupHistoryView";
const String reportsHubView = "/ReportsHubView";
const String weeklyAttendanceReportView = "/WeeklyAttendanceReportView";
const String weeklyEvaluationReportView = "/WeeklyEvaluationReportView";
const String weeklyLearningReportView = "/WeeklyLearningReportView";
const String financialReportView = "/FinancialReportView";
const String monthlyReportView = "/MonthlyReportView";
// ─── Owner Analytics Center ───────────────────────────────────────────────
const String ownerAnalyticsCenterView = "/OwnerAnalyticsCenterView";
const String ownerFinanceTrendReportView = "/OwnerFinanceTrendReportView";
const String ownerCollectionsReportView = "/OwnerCollectionsReportView";
const String ownerReceivablesReportView = "/OwnerReceivablesReportView";
const String ownerBranchPnlReportView = "/OwnerBranchPnlReportView";
const String ownerBranchHealthReportView = "/OwnerBranchHealthReportView";
const String ownerOccupancyReportView = "/OwnerOccupancyReportView";
const String ownerInsightsReportView = "/OwnerInsightsReportView";
const String ownerChurnReportView = "/OwnerChurnReportView";
const String ownerEngagementReportView = "/OwnerEngagementReportView";
const String ownerTeacherPerfReportView = "/OwnerTeacherPerfReportView";
const String ownerEvaluationsReportView = "/OwnerEvaluationsReportView";
const String ownerAttendanceReportView = "/OwnerAttendanceReportView";
const String ownerCollectionRateReportView = "/OwnerCollectionRateReportView";
const String ownerRevenueMethodReportView = "/OwnerRevenueMethodReportView";
const String ownerRevenueCategoryReportView = "/OwnerRevenueCategoryReportView";
const String ownerPaymentBehaviorReportView = "/OwnerPaymentBehaviorReportView";
const String ownerRevenueForecastReportView = "/OwnerRevenueForecastReportView";
const String parentHomeworkView = "/ParentHomeworkView";
const String parentSubjectsAllView = "/ParentSubjectsAllView";
const String parentClassPhotosView = "/ParentClassPhotosView";
const String parentHomeLocationView = "/ParentHomeLocationView";

// Finance
const String invoicesView = "/InvoicesView";
const String paymentsView = "/PaymentsView";
const String paymentCategoriesView = "/PaymentCategoriesView";
const String shiftsView = "/ShiftsView";
const String nurseryContactsView = "/NurseryContactsView";
const String nurseryFeedbackListView = "/NurseryFeedbackListView";
const String parentInvoicesView = "/ParentInvoicesView";
const String overdueView = "/OverdueView";

// Receptionist
const String pickupRequestsView = "/PickupRequestsView";
const String pickupVerificationView = "/PickupVerificationView";
const String receptionistEventsView = "/ReceptionistEventsView";
const String latePayersView = "/LatePayersView";
const String holidaysView = "/HolidaysView";

// Parent Events
const String parentEventsView = "/ParentEventsView";

// Feed
const String nurseryFeedView = "/NurseryFeedView";

// Chat (manager ↔ parent, per child)
const String chatThreadView = "/ChatThreadView";

// Bus / Transport
const String busAssignmentView = "/BusAssignmentView";

// Courses
const String courseLessonsView = "/CourseLessonsView";
const String coursesView = "/CoursesView";

// Notifications
const String notificationsView = "/NotificationsView";

// Settings
const String settingsView = "/SettingsView";
const String dashboardView = "/DashboardView";

// Pre-login platform content (no guard)
const String appSettingsView = "/AppSettingsView";
const String contactUsView = "/ContactUsView";
const String aboutUsView = "/AboutUsView";
const String supportRequestView = "/SupportRequestView";
const String joinUsView = "/JoinUsView";
const String appReviewView = "/AppReviewView";

// Platform content management (Super Admin)
const String platformContentView = "/PlatformContentView";
const String contactInfoFormView = "/ContactInfoFormView";
const String aboutUsFormView = "/AboutUsFormView";
const String supportRequestsAdminView = "/SupportRequestsAdminView";
const String appReviewsAdminView = "/AppReviewsAdminView";
const String citiesView = "/CitiesView";
const String kidtrackCampaignsView = "/KidtrackCampaignsView";
const String kidtrackFeedbackResponsesView = "/KidtrackFeedbackResponsesView";
const String platformPaymentAccountsView = "/PlatformPaymentAccountsView";
const String saTutorialVideosView = "/SaTutorialVideosView";
const String saShowcaseAlbumsView = "/SaShowcaseAlbumsView";

// App Tutorial ("Learn the App") — shared across roles
const String appTutorialView = "/AppTutorialView";
const String tutorialPlayerView = "/TutorialPlayerView";

// Manager
const String managerNurseryProfileView = "/ManagerNurseryProfileView";
const String nurseryPaymentAccountsView = "/NurseryPaymentAccountsView";
const String managerApplicationFileView = "/ManagerApplicationFileView";
const String managerTeacherReportsView = "/ManagerTeacherReportsView";
const String managerApplicationsView = "/ManagerApplicationsView";
const String managerPresenceView = "/ManagerPresenceView";

// First-Login Setup
const String ownerSetupView = "/OwnerSetupView";
const String managerSetupView = "/ManagerSetupView";
const String setupChecklistView = "/SetupChecklistView";
const String teacherOnboardingView = "/TeacherOnboardingView";
const String teacherAcademicSettingsView = "/TeacherAcademicSettingsView";

// Academic (Teacher)
const String academicTopicsView = "/AcademicTopicsView";

// Evaluation Reasons
const String evaluationReasonsView = "/EvaluationReasonsView";

// Child State Templates (Settings)
const String childStatesView = "/ChildStatesView";

// Activity Eval Levels (Settings)
const String evalLevelsView = "/EvalLevelsView";

// Teacher Weekly Schedule
const String teacherWeeklyScheduleView = "/TeacherWeeklyScheduleView";

class Routes {
  static List<GetPage<dynamic>> handleRoutes() {
    final guard = [AppMiddleware(priority: 1)];

    return [
      // ── Entry (no guard) ───────────────────────────────────────────────────
      GetPage(
        name: forceUpdateView,
        page: () => const ForceUpdateView(),
        transition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: onBoardView,
        page: () => const OnboardView(),
        binding: BindingsBuilder(() => Get.lazyPut(() => OnboardController())),
        transition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 400),
      ),
      GetPage(
        name: activationLandingView,
        page: () => const ActivationLandingView(),
        binding: Binding(),
        transition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 350),
      ),
      GetPage(
        name: activationCodeView,
        page: () => const ActivationCodeView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 400),
      ),

      // ── Nursery Discovery (no guard — pre-login) ───────────────────────────
      GetPage(
        name: nurseryDiscoveryView,
        page: () => const DiscoveryView(),
        binding: Binding(),
        transition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 350),
      ),
      GetPage(
        name: nurseryProfileView,
        page: () => const NurseryProfileView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 350),
      ),
      GetPage(
        name: onlineApplicationView,
        page: () => const OnlineApplicationView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 350),
      ),

      // ── Pre-login Platform Content (no guard) ──────────────────────────────
      GetPage(
        name: appSettingsView,
        page: () => const AppSettingsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: contactUsView,
        page: () => const ContactUsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: aboutUsView,
        page: () => const AboutUsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: supportRequestView,
        page: () => const SupportRequestView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: joinUsView,
        page: () => const JoinUsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
      ),
      GetPage(
        name: appReviewView,
        page: () => const AppReviewView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
      ),

      // ── Main Shell ─────────────────────────────────────────────────────────
      GetPage(
        name: mainView,
        page: () => const MainPage(),
        binding: Binding(),
        transition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Subscription Renewal (no guard — owner is routed here mid-session) ──
      GetPage(
        name: renewalView,
        page: () => const RenewalView(),
        transition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 300),
      ),

      // ── Notifications ──────────────────────────────────────────────────────
      GetPage(
        name: notificationsView,
        page: () => const NotificationsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Staff ──────────────────────────────────────────────────────────────
      GetPage(
        name: staffView,
        page: () => const StaffListView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: staffPermissionsView,
        page: () => const StaffPermissionsView(),
        binding: BindingsBuilder(
          () => Get.lazyPut(() => StaffPermissionsController()),
        ),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: staffFormView,
        page: () => const StaffFormView(),
        binding: BindingsBuilder(
          () => Get.lazyPut(
            () =>
                StaffFormController(initialStaff: Get.arguments as StaffModel?),
          ),
        ),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Nurseries ──────────────────────────────────────────────────────────
      GetPage(
        name: nurseriesView,
        page: () => const NurseryListView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: nurseryDetailsView,
        page: () => const NurseryDetailsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: nurseryPackagesView,
        page: () => const PackageListView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Branches ───────────────────────────────────────────────────────────
      GetPage(
        name: branchesView,
        page: () => const BranchListView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Classrooms ─────────────────────────────────────────────────────────
      GetPage(
        name: classroomsView,
        page: () => const ClassroomListView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: classroomDetailView,
        page: () => const ClassroomDetailView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Children ───────────────────────────────────────────────────────────
      GetPage(
        name: childrenView,
        page: () => const ChildListView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: childProfileView,
        page: () => const ChildProfileView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: addChildView,
        page: () => const AddChildView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: parentAccountView,
        page: () => const RcParentAccountView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: bulkInvitationsView,
        page: () => const BulkInvitationsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: childMedicalView,
        page: () => const MedicalListView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: childDocumentsView,
        page: () => const DocumentListView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: authorizedPickupView,
        page: () => const AuthorizedPickupView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: waitingListView,
        page: () => const WaitingListView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: enrollmentsView,
        page: () => const EnrollmentListView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Guardian ───────────────────────────────────────────────────────────
      GetPage(
        name: guardianListView,
        page: () => const GuardianListView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Programs ───────────────────────────────────────────────────────────
      GetPage(
        name: programsView,
        page: () => const ProgramListView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Subjects ───────────────────────────────────────────────────────────
      GetPage(
        name: subjectsView,
        page: () => const SubjectListView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Receptionist Check-In ─────────────────────────────────────────────
      GetPage(
        name: checkInView,
        page: () => const ReceptionistCheckInView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Daily Care ─────────────────────────────────────────────────────────
      GetPage(
        name: attendanceDailyView,
        page: () => const DailyCareView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Child Leave Requests ───────────────────────────────────────────────
      GetPage(
        name: childLeaveRequestsView,
        page: () => const ChildLeaveRequestView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Invoices ───────────────────────────────────────────────────────────
      GetPage(
        name: invoicesView,
        page: () => const InvoiceView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Payments ───────────────────────────────────────────────────────────
      GetPage(
        name: paymentsView,
        page: () => const PaymentView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Payment Categories ────────────────────────────────────────────────
      GetPage(
        name: paymentCategoriesView,
        page: () => const PaymentCategoriesView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Nursery Shifts ────────────────────────────────────────────────────
      GetPage(
        name: shiftsView,
        page: () => const ShiftsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Parent Reports ────────────────────────────────────────────────────
      GetPage(
        name: reportsHubView,
        page: () => const ReportsHubView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: weeklyAttendanceReportView,
        page: () => const WeeklyAttendanceView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: weeklyEvaluationReportView,
        page: () => const WeeklyEvaluationView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: weeklyLearningReportView,
        page: () => const WeeklyLearningView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: financialReportView,
        page: () => const FinancialReportView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: monthlyReportView,
        page: () => const MonthlyReportView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      // ─── Owner Analytics Center ─────────────────────────────────────────
      GetPage(
        name: ownerAnalyticsCenterView,
        page: () => const AnalyticsCenterView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerFinanceTrendReportView,
        page: () => const OwnerFinanceTrendView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerCollectionsReportView,
        page: () => const OwnerCollectionsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerReceivablesReportView,
        page: () => const OwnerReceivablesView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerBranchPnlReportView,
        page: () => const OwnerBranchPnlView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerBranchHealthReportView,
        page: () => const OwnerBranchHealthView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerOccupancyReportView,
        page: () => const OwnerOccupancyView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerInsightsReportView,
        page: () => const OwnerInsightsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerChurnReportView,
        page: () => const OwnerChurnView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerCollectionRateReportView,
        page: () => const OwnerCollectionRateView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerRevenueMethodReportView,
        page: () => const OwnerRevenueMethodView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerRevenueCategoryReportView,
        page: () => const OwnerRevenueCategoryView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerPaymentBehaviorReportView,
        page: () => const OwnerPaymentBehaviorView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerRevenueForecastReportView,
        page: () => const OwnerRevenueForecastView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerEngagementReportView,
        page: () => const OwnerEngagementView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerTeacherPerfReportView,
        page: () => const OwnerTeacherPerfView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerEvaluationsReportView,
        page: () => const OwnerEvaluationsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerAttendanceReportView,
        page: () => const OwnerAttendanceView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Nursery Contact Numbers ───────────────────────────────────────────
      GetPage(
        name: nurseryContactsView,
        page: () => const NurseryContactsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Nursery Feedback (owner/manager view of parent ratings) ───────────
      GetPage(
        name: nurseryFeedbackListView,
        page: () => const NurseryFeedbackListView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Parent Invoices ───────────────────────────────────────────────────
      GetPage(
        name: parentInvoicesView,
        page: () => const ParentInvoicesView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Overdue / Obligations ─────────────────────────────────────────────
      GetPage(
        name: overdueView,
        page: () => const OverdueView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Parent Home Location ──────────────────────────────────────────────
      GetPage(
        name: parentHomeLocationView,
        page: () => const ParentHomeLocationView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Bus Assignment ────────────────────────────────────────────────────
      GetPage(
        name: busAssignmentView,
        page: () => const BusAssignmentView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Audit Log ──────────────────────────────────────────────────────────
      GetPage(
        name: auditLogView,
        page: () => const AuditLogView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Support Tickets ────────────────────────────────────────────────────
      GetPage(
        name: supportTicketsView,
        page: () => const SupportTicketsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Platform Subscription Billing ──────────────────────────────────────
      GetPage(
        name: platformBillingView,
        page: () => const SaBillingView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: platformBillingDetailView,
        page: () => const SaBillingDetailView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: mySubscriptionView,
        page: () => const MySubscriptionView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: ownerPhotoReviewSettingsView,
        page: () => const OwnerPhotoReviewSettingsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Platform Content Management (Super Admin) ──────────────────────────
      GetPage(
        name: platformContentView,
        page: () => const PlatformContentView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: platformPaymentAccountsView,
        page: () => const PlatformPaymentAccountsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: nurseryPaymentAccountsView,
        page: () => const NurseryPaymentAccountsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: contactInfoFormView,
        page: () => const ContactInfoFormView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: aboutUsFormView,
        page: () => const AboutUsFormView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: supportRequestsAdminView,
        page: () => const SupportRequestsAdminView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: appReviewsAdminView,
        page: () => const AppReviewsAdminView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: citiesView,
        page: () => const CitiesView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: saTutorialVideosView,
        page: () => const SaTutorialVideosView(),
        binding: BindingsBuilder(
          () => Get.lazyPut(() => SaTutorialVideosController(), fenix: true),
        ),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: saShowcaseAlbumsView,
        page: () => const SaShowcaseAlbumsView(),
        binding: BindingsBuilder(
          () => Get.lazyPut(() => SaShowcaseAlbumsController(), fenix: true),
        ),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: appTutorialView,
        page: () => const AppTutorialView(),
        binding: BindingsBuilder(
          () => Get.lazyPut(() => AppTutorialController(), fenix: true),
        ),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: tutorialPlayerView,
        page: () => const TutorialPlayerView(),
        binding: BindingsBuilder(
          () => Get.lazyPut(() => TutorialPlayerController(), fenix: true),
        ),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: kidtrackCampaignsView,
        page: () => const KidtrackCampaignsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
      GetPage(
        name: kidtrackFeedbackResponsesView,
        page: () => const KidtrackFeedbackResponsesView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Parent Requests History ────────────────────────────────────────────
      GetPage(
        name: parentRequestsHistoryView,
        page: () => const ParentRequestsHistoryView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Staff Account ──────────────────────────────────────────────────────
      GetPage(
        name: staffAccountView,
        page: () => const StaffAccountView(),
        binding: BindingsBuilder(
          () => Get.lazyPut(() => StaffAccountController()),
        ),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Settings (staff account) ───────────────────────────────────────────
      GetPage(
        name: settingsView,
        page: () => const StaffAccountView(),
        binding: BindingsBuilder(
          () => Get.lazyPut(() => StaffAccountController()),
        ),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Parent Today Schedule ──────────────────────────────────────────────
      GetPage(
        name: parentTodayScheduleView,
        page: () => const ParentTodayScheduleView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Parent Pickup History ──────────────────────────────────────────────
      GetPage(
        name: parentPickupHistoryView,
        page: () => const PickupHistoryView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Parent Homework All ────────────────────────────────────────────────
      GetPage(
        name: parentHomeworkView,
        page: () => const HomeworkAllView(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Parent Subjects All ────────────────────────────────────────────────
      GetPage(
        name: parentSubjectsAllView,
        page: () => const SubjectsAllView(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Parent Class Photos ────────────────────────────────────────────────
      GetPage(
        name: parentClassPhotosView,
        page: () => const ParentClassPhotosView(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Manager Nursery Profile (Discovery data) ───────────────────────────
      GetPage(
        name: managerNurseryProfileView,
        page: () => const ManagerNurseryProfileView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Manager Application File (fee, terms, apply-form config) ────────────
      GetPage(
        name: managerApplicationFileView,
        page: () => const ManagerApplicationFileView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Manager Online Admission Applications ──────────────────────────────
      GetPage(
        name: managerApplicationsView,
        page: () => const ManagerApplicationsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Manager Teacher Performance Reports ────────────────────────────────
      GetPage(
        name: managerTeacherReportsView,
        page: () => const ManagerTeacherReportsView(),
        binding: BindingsBuilder(
          () => Get.lazyPut(() => ManagerTeacherReportsController()),
        ),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Manager Presence / Attendance Movement ─────────────────────────────
      GetPage(
        name: managerPresenceView,
        page: () => const ManagerPresenceView(),
        binding: BindingsBuilder(
          () => Get.lazyPut(() => ManagerPresenceController()),
        ),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Owner First-Login Setup ────────────────────────────────────────────
      GetPage(
        name: ownerSetupView,
        page: () => const OwnerSetupView(),
        binding: BindingsBuilder(
          () => Get.lazyPut(() => OwnerSetupController()),
        ),
        transition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 400),
        middlewares: guard,
      ),

      // ── Manager First-Login Setup ──────────────────────────────────────────
      GetPage(
        name: managerSetupView,
        page: () => const ManagerSetupView(),
        binding: BindingsBuilder(
          () => Get.lazyPut(() => ManagerSetupController()),
        ),
        transition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 400),
        middlewares: guard,
      ),

      // ── First-Login Setup Checklist (owner + manager) ──────────────────────
      GetPage(
        name: setupChecklistView,
        page: () => const SetupChecklistView(),
        binding: BindingsBuilder(
          () => Get.lazyPut(() => SetupChecklistController()),
        ),
        transition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 400),
        middlewares: guard,
      ),

      // ── Nursery Feed ───────────────────────────────────────────────────────
      GetPage(
        name: nurseryFeedView,
        page: () => const OwnerFeedTab(),
        binding: BindingsBuilder(() => Get.lazyPut(() => FeedController())),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Chat Thread (manager ↔ parent) ─────────────────────────────────────
      GetPage(
        name: chatThreadView,
        page: () => const ChatThreadView(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Pickup Requests ────────────────────────────────────────────────────
      GetPage(
        name: pickupRequestsView,
        page: () => const PickupRequestsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Pickup Verification ────────────────────────────────────────────────
      GetPage(
        name: pickupVerificationView,
        page: () => const PickupVerificationView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Course Lessons (Owner) ─────────────────────────────────────────────
      GetPage(
        name: courseLessonsView,
        page: () => const CourseLessonsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Courses (Owner) ────────────────────────────────────────────────────
      GetPage(
        name: coursesView,
        page: () => const OwnerCoursesTab(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Receptionist Events ────────────────────────────────────────────────
      GetPage(
        name: receptionistEventsView,
        page: () => const ReceptionistEventsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Holidays (manager + receptionist) ──────────────────────────────────
      GetPage(
        name: holidaysView,
        page: () => const HolidaysView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Receptionist Late Payers ───────────────────────────────────────────
      GetPage(
        name: latePayersView,
        page: () => const LatePayersView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Parent Events ──────────────────────────────────────────────────────
      GetPage(
        name: parentEventsView,
        page: () => const ParentEventsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Teacher Onboarding ─────────────────────────────────────────────────
      GetPage(
        name: teacherOnboardingView,
        page: () => const TeacherOnboardingView(),
        binding: Binding(),
        transition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 350),
      ),

      // ── Teacher Academic Settings (Edit) ───────────────────────────────────
      GetPage(
        name: teacherAcademicSettingsView,
        page: () => const TeacherOnboardingView(editMode: true),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Academic Topics (Admin) ────────────────────────────────────────────
      GetPage(
        name: academicTopicsView,
        page: () => const AcademicTopicsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Evaluation Reasons ────────────────────────────────────────────────
      GetPage(
        name: evaluationReasonsView,
        page: () => const EvaluationReasonsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Child State Templates ─────────────────────────────────────────────
      GetPage(
        name: childStatesView,
        page: () => const ChildStatesView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Activity Eval Levels ──────────────────────────────────────────────
      GetPage(
        name: evalLevelsView,
        page: () => const EvalLevelsView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),

      // ── Teacher Weekly Schedule ───────────────────────────────────────────
      GetPage(
        name: teacherWeeklyScheduleView,
        page: () => const TeacherWeeklyScheduleView(),
        binding: Binding(),
        transition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        middlewares: guard,
      ),
    ];
  }
}
