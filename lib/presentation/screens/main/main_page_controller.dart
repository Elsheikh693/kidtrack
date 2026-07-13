import '../../../index/index_main.dart';

class MainPageViewModel extends GetxController {
  MainPageViewModel({int initialIndex = 0}) {
    currentIndex = initialIndex.obs;
  }

  late final RxInt currentIndex;

  /// Becomes true only after the access gate clears the restored session.
  /// The shell renders blank under the native splash until then.
  final gateReady = false.obs;

  final _session = SessionService();

  @override
  void onInit() {
    super.onInit();
    _runGate();
  }

  /// One-shot access check on app open. The native splash is held by main()
  /// for the gating path and removed here once the decision is made.
  Future<void> _runGate() async {
    // The native splash is removed in main() after the first frame, so the
    // gate no longer touches it. While this runs, MainPage renders its own
    // neutral surface (gateReady == false).
    final outcome = await AccessControlService().validateOnce();

    switch (outcome.action) {
      case AccessAction.toRenewal:
        Get.offAllNamed(renewalView);
        return;
      case AccessAction.toLogin:
        await _session.clear();
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
        Get.offAllNamed(activationLandingView);
        if (outcome.reasonKey != null) {
          await Future.delayed(const Duration(milliseconds: 400));
          Get.snackbar(
            '',
            outcome.reasonKey!.tr,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
        }
        return;
      case AccessAction.allowed:
        // Start the live access guard now that the one-shot check passed.
        AccessWatcherService.to.start();
        gateReady.value = true;
        if (_session.userType == UserType.teacher) {
          _checkTeacherOnboarding();
        }
    }
  }

  Future<void> _checkTeacherOnboarding() async {
    final uid = _session.userId ?? '';
    // Reliable per-device gate: skip the remote read once setup is recorded.
    if (SetupLocalCheck.isDone(uid)) return;

    final done = await TeacherAcademicService().isSetupDone();
    if (done) {
      await SetupLocalCheck.markDone(uid);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    Get.toNamed(teacherOnboardingView);
  }

  void changePage(int index) => currentIndex.value = index;

  UserType get role => _session.effectiveRole;

  bool get isParent => role == UserType.parent;

  bool get isOwner => role == UserType.owner;

  bool get isBranchManager => role == UserType.branchManager;

  bool get isReceptionist => role == UserType.receptionist;

  bool get isBusChaperone => role == UserType.busChaperone;

  List<Widget> get pages {
    switch (role) {
      case UserType.superAdmin:
        return _superAdminPages;
      case UserType.owner:
        return _ownerPages;
      case UserType.branchManager:
        return _managerPages;
      case UserType.teacher:
        return _teacherPages;
      case UserType.receptionist:
        return _receptionistPages;
      case UserType.parent:
        return _parentPages;
      case UserType.busChaperone:
        return _busChaperonPages;
      default:
        return _parentPages;
    }
  }

  static final _superAdminPages = <Widget>[const SuperAdminDashboardView()];
  static final _ownerPages = <Widget>[
    const OwnerExecutiveDashboard(),
    const OwnerFinanceTab(),
    const OwnerFeedTab(),
    const OwnerMoreTab(),
  ];
  static final _managerPages = <Widget>[
    const ManagerDashboardTab(),
    const ManagerChildrenTab(),
    const ManagerTeacherReportsView(asTab: true),
    const ManagerChatTab(),
    const ManagerFinanceTab(),
    const ManagerSocialTab(),
    const ManagerMoreTab(),
  ];
  static final _receptionistPages = <Widget>[
    const ReceptionistDashboardTab(),
    const ReceptionistCheckInView(),
    const ReceptionistChildrenTab(),
    const ReceptionistCoursesTab(),
    const ReceptionistEventsView(),
    const ReceptionistFinanceTab(),
    // index 6: shared staff↔guardian chat inbox (same threads the manager uses).
    const ManagerChatTab(),
  ];
  static final _teacherPages = <Widget>[
    const TeacherHomeTab(),
    const TeacherActivityTab(),
    const TeacherReportsTab(),
    // مخفي مؤقتاً: دفتر التواصل
    // const TeacherLinkBookTab(),
    // مخفي مؤقتاً: صفحة الواجبات
    // const TeacherHomeworkTab(),
  ];
  static final _busChaperonPages = <Widget>[
    const ChaperoneHomeView(),
    const ChaperoneHistoryView(),
    const StaffAccountView(),
  ];
  static final _parentPages = <Widget>[
    const ParentDashboardView(),
    const ParentEducationView(),
    const ParentPostsView(),
    // مخفي مؤقتاً: تاب الكورسات
    // const ParentCoursesView(),
    const ReportsHubView(),
  ];
}
