import 'package:firebase_database/firebase_database.dart';
import 'package:kidtrack/Data/models/care_event/care_event_model.dart';
import '../index/index_main.dart';
import '../Global/services/pickup_realtime_service.dart';
import '../presentation/screens/teacher/activity/activity_end_controller.dart';
import '../presentation/screens/teacher/homework/homework_tab_controller.dart';
import '../presentation/screens/teacher/reports/teacher_reports_controller.dart';
import '../presentation/screens/manager/media_approval/media_approval_controller.dart';

class Binding implements Bindings {
  @override
  void dependencies() {
    // ─── Core ─────────────────────────────────────────────────────────────
    Get.lazyPut<ClientSourceRepo>(() => ClientSourceRepo(), fenix: true);
    Get.lazyPut<FirebaseClient>(() => FirebaseClient(), fenix: true);

    // ─── Firebase Data Source ─────────────────────────────────────────────
    Get.lazyPut<FirebaseDataSource>(
      () => FirebaseDataSourceImpl(Get.find<FirebaseClient>()),
      fenix: true,
    );

    // ─── Authentication ───────────────────────────────────────────────────
    Get.lazyPut<AuthenticationRemoteDataSource>(
      () => AuthenticationRemoteDataSourceImpl(
        FirebaseDatabase.instance,
        Get.find<ClientSourceRepo>(),
      ),
      fenix: true,
    );

    Get.lazyPut<AuthenticationRepository>(
      () => AuthenticationRepositoryImpl(
        Get.find<AuthenticationRemoteDataSource>(),
      ),
      fenix: true,
    );

    // ─── Firebase Repository ──────────────────────────────────────────────
    Get.lazyPut<FirebaseRepository>(
      () => FirebaseRepositoryImpl(Get.find<FirebaseDataSource>()),
      fenix: true,
    );

    // ─── Firebase Credentials ─────────────────────────────────────────────
    Get.lazyPut<FirebaseSignInUseCase>(
      () => FirebaseSignInUseCase(Get.find<FirebaseRepository>()),
      fenix: true,
    );
    Get.lazyPut<FirebaseSignUpUseCase>(
      () => FirebaseSignUpUseCase(Get.find<FirebaseRepository>()),
      fenix: true,
    );
    Get.lazyPut<FirebaseUploadImageUseCase>(
      () => FirebaseUploadImageUseCase(Get.find<FirebaseRepository>()),
      fenix: true,
    );
    Get.lazyPut<FirebaseCredentialsService>(
      () => FirebaseCredentialsService(
        signIn: Get.find<FirebaseSignInUseCase>(),
        signUp: Get.find<FirebaseSignUpUseCase>(),
        uploadImage: Get.find<FirebaseUploadImageUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut<AuthBootstrapService>(
      () => AuthBootstrapService(),
      fenix: true,
    );
    Get.lazyPut<ActivationLoginService>(
      () => ActivationLoginService(),
      fenix: true,
    );

    // ─── Session ──────────────────────────────────────────────────────────
    Get.put<SessionService>(SessionService(), permanent: true);

    // ─── Notification Stream ──────────────────────────────────────────────
    Get.put<NotificationStreamService>(
      NotificationStreamService(),
      permanent: true,
    );

    // ─── Access Watcher (all roles + nursery subscription) ────────────────
    Get.put<AccessWatcherService>(AccessWatcherService(), permanent: true);

    // ─── Active Child (Parent role) ───────────────────────────────────────
    Get.put<ActiveChildService>(ActiveChildService(), permanent: true);

    // ─── Owner Scope (network vs branch level switch) ─────────────────────
    Get.put<OwnerScopeService>(OwnerScopeService(), permanent: true);

    // ─── Owner cross-branch photo-review flag (settings-gated) ────────────
    Get.put<OwnerPhotoReviewService>(
      OwnerPhotoReviewService(),
      permanent: true,
    );

    // ─── Owner Analytics (shared BI data layer — loads the bundle once) ───
    Get.put<OwnerAnalyticsService>(OwnerAnalyticsService(), permanent: true);

    // ─── Owner finance-detail reports (raw invoices/txns/children/packages) ──
    Get.put<OwnerFinanceDataService>(
      OwnerFinanceDataService(),
      permanent: true,
    );

    // ─── Deep links (QR scan → open app → auto-login) ─────────────────────
    Get.put<DeepLinkService>(DeepLinkService(), permanent: true);

    // ─── Parent notification preferences (attendance/activities toggles) ──
    Get.put<NotificationPrefsService>(
      NotificationPrefsService(),
      permanent: true,
    );

    // ═════════════════════════════════════════════════════════════════════
    // CRUD Bindings — 33 Models
    // ═════════════════════════════════════════════════════════════════════

    // 1. Nursery Info
    BaseBinding.bindCrud<NurseryModel>(
      tag: "nurseryInfo",
      baseUrl: () => ApiPaths.globalNurseries,
      fromJson: (json) => NurseryModel.fromJson(json),
    );

    // 2. Packages
    BaseBinding.bindCrud<PackageModel>(
      tag: "packages",
      baseUrl: () => ApiConstants.packages,
      fromJson: (json) => PackageModel.fromJson(json),
    );

    // 3. Branches
    BaseBinding.bindCrud<BranchModel>(
      tag: "branches",
      baseUrl: () => ApiConstants.branches,
      fromJson: (json) => BranchModel.fromJson(json),
    );

    // 3b. Branch Targets (owner — per-branch goals + health weights)
    BaseBinding.bindCrud<BranchTargetModel>(
      tag: "branchTargets",
      baseUrl: () => ApiConstants.branchTargets,
      fromJson: (json) => BranchTargetModel.fromJson(json),
    );

    // 4. Staff
    BaseBinding.bindCrud<StaffModel>(
      tag: "staff",
      baseUrl: () => ApiConstants.staff,
      fromJson: (json) => StaffModel.fromJson(json),
    );

    // 5. Permission Sets
    BaseBinding.bindCrud<PermissionSetModel>(
      tag: "permissionSets",
      baseUrl: () => ApiConstants.permissionSets,
      fromJson: (json) => PermissionSetModel.fromJson(json),
    );

    // 6. Classrooms
    BaseBinding.bindCrud<ClassroomModel>(
      tag: "classrooms",
      baseUrl: () => ApiConstants.classrooms,
      fromJson: (json) => ClassroomModel.fromJson(json),
    );

    // 7. Programs
    BaseBinding.bindCrud<ProgramModel>(
      tag: "programs",
      baseUrl: () => ApiConstants.programs,
      fromJson: (json) => ProgramModel.fromJson(json),
    );

    // 8. Subjects
    BaseBinding.bindCrud<SubjectModel>(
      tag: "subjects",
      baseUrl: () => ApiConstants.subjects,
      fromJson: (json) => SubjectModel.fromJson(json),
    );

    // 9. Children
    BaseBinding.bindCrud<ChildModel>(
      tag: "children",
      baseUrl: () => ApiConstants.children,
      fromJson: (json) => ChildModel.fromJson(json),
    );

    // 10. Enrollments
    BaseBinding.bindCrud<EnrollmentModel>(
      tag: "enrollments",
      baseUrl: () => ApiConstants.enrollments,
      fromJson: (json) => EnrollmentModel.fromJson(json),
    );

    // 11. Medical Profiles
    BaseBinding.bindCrud<MedicalProfileModel>(
      tag: "medicalProfiles",
      baseUrl: () => ApiConstants.medicalProfiles,
      fromJson: (json) => MedicalProfileModel.fromJson(json),
    );

    // 12. Documents
    BaseBinding.bindCrud<DocumentModel>(
      tag: "documents",
      baseUrl: () => ApiConstants.documents,
      fromJson: (json) => DocumentModel.fromJson(json),
    );

    // 13. Authorized Pickups
    BaseBinding.bindCrud<AuthorizedPickupModel>(
      tag: "authorizedPickups",
      baseUrl: () => ApiConstants.authorizedPickups,
      fromJson: (json) => AuthorizedPickupModel.fromJson(json),
    );

    // 14. Waiting List
    BaseBinding.bindCrud<WaitingListModel>(
      tag: "waitingList",
      baseUrl: () => ApiConstants.waitingList,
      fromJson: (json) => WaitingListModel.fromJson(json),
    );

    // 15. Parents
    BaseBinding.bindCrud<ParentModel>(
      tag: "parents",
      baseUrl: () => ApiConstants.parents,
      fromJson: (json) => ParentModel.fromJson(json),
    );

    // 16. Parent-Child links
    BaseBinding.bindCrud<ParentChildModel>(
      tag: "parentChildren",
      baseUrl: () => ApiConstants.parentChildren,
      fromJson: (json) => ParentChildModel.fromJson(json),
    );

    // 16b. Activation Codes (role-agnostic, global — code is the key)
    BaseBinding.bindCrud<ActivationCodeModel>(
      tag: "activationCodes",
      baseUrl: () => ApiConstants.activationCodes,
      fromJson: (json) => ActivationCodeModel.fromJson(json),
    );

    // 17. Child Attendance
    BaseBinding.bindCrud<ChildAttendanceModel>(
      tag: "childAttendance",
      baseUrl: () => ApiConstants.childAttendance,
      fromJson: (json) => ChildAttendanceModel.fromJson(json),
    );

    // 18. Staff Attendance
    BaseBinding.bindCrud<StaffAttendanceModel>(
      tag: "staffAttendance",
      baseUrl: () => ApiConstants.staffAttendance,
      fromJson: (json) => StaffAttendanceModel.fromJson(json),
    );

    // 19. Staff Leaves
    BaseBinding.bindCrud<StaffLeaveModel>(
      tag: "staffLeaves",
      baseUrl: () => ApiConstants.staffLeaves,
      fromJson: (json) => StaffLeaveModel.fromJson(json),
    );

    // 20. Child Leave Requests
    BaseBinding.bindCrud<ChildLeaveRequestModel>(
      tag: "childLeaveRequests",
      baseUrl: () => ApiConstants.childLeaveRequests,
      fromJson: (json) => ChildLeaveRequestModel.fromJson(json),
    );

    // 21. Child Reports
    BaseBinding.bindCrud<ChildReportModel>(
      tag: "childReports",
      baseUrl: () => ApiConstants.childReports,
      fromJson: (json) => ChildReportModel.fromJson(json),
    );

    // 22. Assessments
    BaseBinding.bindCrud<AssessmentModel>(
      tag: "assessments",
      baseUrl: () => ApiConstants.assessments,
      fromJson: (json) => AssessmentModel.fromJson(json),
    );

    // 23. Incidents
    BaseBinding.bindCrud<IncidentModel>(
      tag: "incidents",
      baseUrl: () => ApiConstants.incidents,
      fromJson: (json) => IncidentModel.fromJson(json),
    );

    // 24. Notes
    BaseBinding.bindCrud<NoteModel>(
      tag: "notes",
      baseUrl: () => ApiConstants.notes,
      fromJson: (json) => NoteModel.fromJson(json),
    );

    // 24b. Guardian notes (parent → nursery, per session)
    BaseBinding.bindCrud<GuardianNoteModel>(
      tag: "guardianNotes",
      baseUrl: () => ApiConstants.guardianNotes,
      fromJson: (json) => GuardianNoteModel.fromJson(json),
    );

    // 25. Lesson Plans
    BaseBinding.bindCrud<LessonPlanModel>(
      tag: "lessonPlans",
      baseUrl: () => ApiConstants.lessonPlans,
      fromJson: (json) => LessonPlanModel.fromJson(json),
    );

    BaseBinding.bindCrud<HomeworkModel>(
      tag: "homework",
      baseUrl: () => ApiConstants.homework,
      fromJson: (json) => HomeworkModel.fromJson(json),
    );

    // 26. Classroom Posts
    BaseBinding.bindCrud<ClassroomPostModel>(
      tag: "classroomPosts",
      baseUrl: () => ApiConstants.classroomPosts,
      fromJson: (json) => ClassroomPostModel.fromJson(json),
    );

    // 27. Announcements
    BaseBinding.bindCrud<AnnouncementModel>(
      tag: "announcements",
      baseUrl: () => ApiConstants.announcements,
      fromJson: (json) => AnnouncementModel.fromJson(json),
    );

    // 28. Schedules
    BaseBinding.bindCrud<ScheduleModel>(
      tag: "schedules",
      baseUrl: () => ApiConstants.schedules,
      fromJson: (json) => ScheduleModel.fromJson(json),
    );

    // 29. Daily Care Logs (Nanny)
    BaseBinding.bindCrud<DailyCareLogModel>(
      tag: "dailyCareLogs",
      baseUrl: () => ApiConstants.dailyCareLogs,
      fromJson: (json) => DailyCareLogModel.fromJson(json),
    );

    // 30. Invoices
    BaseBinding.bindCrud<InvoiceModel>(
      tag: "invoices",
      baseUrl: () => ApiConstants.invoices,
      fromJson: (json) => InvoiceModel.fromJson(json),
    );

    // 30. Payments
    BaseBinding.bindCrud<PaymentModel>(
      tag: "payments",
      baseUrl: () => ApiConstants.payments,
      fromJson: (json) => PaymentModel.fromJson(json),
    );

    // Payment Categories
    BaseBinding.bindCrud<PaymentCategoryModel>(
      tag: "paymentCategories",
      baseUrl: () => ApiConstants.paymentCategories,
      fromJson: (json) => PaymentCategoryModel.fromJson(json),
    );

    // Payment Accounts (nursery's own collection accounts — InstaPay / wallets)
    BaseBinding.bindCrud<PaymentAccountModel>(
      tag: "paymentAccounts",
      baseUrl: () => ApiConstants.paymentAccounts,
      fromJson: (json) => PaymentAccountModel.fromJson(json),
    );

    // Cities (global, SuperAdmin managed)
    BaseBinding.bindCrud<CityModel>(
      tag: "cities",
      baseUrl: () => ApiConstants.cities,
      fromJson: (json) => CityModel.fromJson(json),
    );

    // Expenses (accounts payable / vendor obligations)
    BaseBinding.bindCrud<ExpenseModel>(
      tag: "expenses",
      baseUrl: () => ApiConstants.expenses,
      fromJson: (json) => ExpenseModel.fromJson(json),
    );

    // Fee Categories (new finance module — revenue types)
    BaseBinding.bindCrud<FeeCategoryModel>(
      tag: "feeCategories",
      baseUrl: () => ApiConstants.feeCategories,
      fromJson: (json) => FeeCategoryModel.fromJson(json),
    );

    // Attendance shifts (dynamic — drives auto-late computation)
    BaseBinding.bindCrud<ShiftModel>(
      tag: "shifts",
      baseUrl: () => ApiConstants.shifts,
      fromJson: (json) => ShiftModel.fromJson(json),
    );

    // Financial Transactions (new finance module — cash collection log)
    BaseBinding.bindCrud<FinancialTransactionModel>(
      tag: "financialTransactions",
      baseUrl: () => ApiConstants.financialTransactions,
      fromJson: (json) => FinancialTransactionModel.fromJson(json),
    );

    // 31. Notifications (scoped per user)
    BaseBinding.bindCrud<NotificationModel>(
      tag: "notifications",
      baseUrl: () => ApiConstants.notifications(''),
      fromJson: (json) => NotificationModel.fromJson(json),
    );

    // 32. Users
    BaseBinding.bindCrud<UserModel>(
      tag: "users",
      baseUrl: () => ApiConstants.users,
      fromJson: (json) => UserModel.fromJson(json),
    );

    // 33. Support Tickets
    BaseBinding.bindCrud<SupportTicketModel>(
      tag: "supportTickets",
      baseUrl: () => ApiConstants.supportTickets,
      fromJson: (json) => SupportTicketModel.fromJson(json),
    );

    // 34. Pickup Requests
    BaseBinding.bindCrud<PickupRequestModel>(
      tag: "pickupRequests",
      baseUrl: () => ApiConstants.pickupRequests,
      fromJson: (json) => PickupRequestModel.fromJson(json),
    );

    // 35. Care Events (Nanny)
    BaseBinding.bindCrud<CareEventModel>(
      tag: "careEvents",
      baseUrl: () => ApiConstants.careEvents,
      fromJson: (json) => CareEventModel.fromJson(json),
    );

    // 36. Academic Topics
    BaseBinding.bindCrud<AcademicTopicModel>(
      tag: "academicTopics",
      baseUrl: () => ApiConstants.academicTopics,
      fromJson: (json) => AcademicTopicModel.fromJson(json),
    );

    // 37. Topic Progress
    BaseBinding.bindCrud<TopicProgressModel>(
      tag: "topicProgress",
      baseUrl: () => ApiConstants.topicProgress,
      fromJson: (json) => TopicProgressModel.fromJson(json),
    );

    // 38. Daily Assessments
    BaseBinding.bindCrud<DailyAssessmentModel>(
      tag: "dailyAssessments",
      baseUrl: () => ApiConstants.dailyAssessments,
      fromJson: (json) => DailyAssessmentModel.fromJson(json),
    );

    // 39. Child State Templates
    BaseBinding.bindCrud<ChildStateTemplateModel>(
      tag: "childStateTemplates",
      baseUrl: () => ApiConstants.childStateTemplates,
      fromJson: (json) => ChildStateTemplateModel.fromJson(json),
    );

    // 39b. Activity Eval Level Templates (ممتاز / يحتاج متابعة / يحتاج دعم …)
    BaseBinding.bindCrud<EvalLevelTemplateModel>(
      tag: "evalLevelTemplates",
      baseUrl: () => ApiConstants.evalLevelTemplates,
      fromJson: (json) => EvalLevelTemplateModel.fromJson(json),
    );

    // 40. Nursery Contacts (direct WhatsApp/call numbers shown to parents)
    BaseBinding.bindCrud<NurseryContactModel>(
      tag: "nurseryContacts",
      baseUrl: () => ApiConstants.nurseryContacts,
      fromJson: (json) => NurseryContactModel.fromJson(json),
    );

    // 41. Contact Info (platform-level, super admin managed)
    BaseBinding.bindCrud<ContactInfoModel>(
      tag: "contactInfo",
      baseUrl: () => ApiConstants.contactInfo,
      fromJson: (json) => ContactInfoModel.fromJson(json),
    );

    // 42. About Us (platform-level, super admin managed)
    BaseBinding.bindCrud<AboutUsModel>(
      tag: "aboutUs",
      baseUrl: () => ApiConstants.aboutUs,
      fromJson: (json) => AboutUsModel.fromJson(json),
    );

    // 42b. Tutorial Videos (SuperAdmin-managed, role-targeted "Learn the App")
    BaseBinding.bindCrud<TutorialVideoModel>(
      tag: "tutorialVideos",
      baseUrl: () => ApiConstants.tutorialVideos,
      fromJson: (json) => TutorialVideoModel.fromJson(json),
    );

    // 42c. Showcase Shots (SuperAdmin-managed website album screenshots)
    BaseBinding.bindCrud<ShowcaseShotModel>(
      tag: "showcaseShots",
      baseUrl: () => ApiConstants.showcaseShots,
      fromJson: (json) => ShowcaseShotModel.fromJson(json),
    );

    // 43. Support Requests (pre-login guest tickets)
    BaseBinding.bindCrud<SupportRequestModel>(
      tag: "supportRequests",
      baseUrl: () => ApiConstants.supportRequests,
      fromJson: (json) => SupportRequestModel.fromJson(json),
    );

    // 43b. App Reviews (pre-login KidTrack app ratings)
    BaseBinding.bindCrud<AppReviewModel>(
      tag: "appReviews",
      baseUrl: () => ApiConstants.appReviews,
      fromJson: (json) => AppReviewModel.fromJson(json),
    );

    // 44. Online admission applications (manager-side CRUD)
    BaseBinding.bindCrud<OnlineApplicationModel>(
      tag: "onlineApplications",
      baseUrl: () => ApiConstants.onlineApplications,
      fromJson: (json) => OnlineApplicationModel.fromJson(json),
    );

    // 45. Nursery Feedback (parent → nursery rating, keyed by parentId)
    BaseBinding.bindCrud<NurseryFeedbackModel>(
      tag: "nurseryFeedback",
      baseUrl: () => ApiConstants.nurseryFeedback,
      fromJson: (json) => NurseryFeedbackModel.fromJson(json),
    );

    BaseBinding.bindCrud<WithdrawalLogModel>(
      tag: "withdrawals",
      baseUrl: () => ApiConstants.withdrawals,
      fromJson: (json) => WithdrawalLogModel.fromJson(json),
    );

    // ─── Parent Services ──────────────────────────────────────────────────
    Get.lazyPut<WithdrawalParentService>(
      () => WithdrawalParentService(),
      fenix: true,
    );
    Get.lazyPut<NotificationParentService>(
      () => NotificationParentService(),
      fenix: true,
    );
    Get.lazyPut<StaffParentService>(() => StaffParentService(), fenix: true);
    Get.lazyPut<BranchParentService>(() => BranchParentService(), fenix: true);
    Get.lazyPut<PermissionParentService>(
      () => PermissionParentService(),
      fenix: true,
    );
    Get.lazyPut<NurseryParentService>(
      () => NurseryParentService(),
      fenix: true,
    );
    Get.lazyPut<NurseryContactParentService>(
      () => NurseryContactParentService(),
      fenix: true,
    );
    Get.lazyPut<PackageParentService>(
      () => PackageParentService(),
      fenix: true,
    );
    Get.lazyPut<ClassroomParentService>(
      () => ClassroomParentService(),
      fenix: true,
    );
    Get.lazyPut<ProgramParentService>(
      () => ProgramParentService(),
      fenix: true,
    );
    Get.lazyPut<SubjectParentService>(
      () => SubjectParentService(),
      fenix: true,
    );
    Get.lazyPut<ChildParentService>(() => ChildParentService(), fenix: true);
    Get.lazyPut<EnrollmentParentService>(
      () => EnrollmentParentService(),
      fenix: true,
    );
    Get.lazyPut<MedicalProfileParentService>(
      () => MedicalProfileParentService(),
      fenix: true,
    );
    Get.lazyPut<DocumentParentService>(
      () => DocumentParentService(),
      fenix: true,
    );
    Get.lazyPut<AuthorizedPickupParentService>(
      () => AuthorizedPickupParentService(),
      fenix: true,
    );
    Get.lazyPut<WaitingListParentService>(
      () => WaitingListParentService(),
      fenix: true,
    );
    Get.lazyPut<GuardianParentService>(
      () => GuardianParentService(),
      fenix: true,
    );
    Get.lazyPut<ParentAccountService>(
      () => ParentAccountService(),
      fenix: true,
    );
    Get.lazyPut<ChildWithdrawalService>(
      () => ChildWithdrawalService(),
      fenix: true,
    );
    Get.lazyPut<ParentChildParentService>(
      () => ParentChildParentService(),
      fenix: true,
    );
    Get.lazyPut<ActivationParentService>(
      () => ActivationParentService(),
      fenix: true,
    );
    Get.lazyPut<BulkInvitationsController>(
      () => BulkInvitationsController(),
      fenix: true,
    );
    Get.lazyPut<ChildAttendanceParentService>(
      () => ChildAttendanceParentService(),
      fenix: true,
    );
    Get.lazyPut<StaffAttendanceParentService>(
      () => StaffAttendanceParentService(),
      fenix: true,
    );
    Get.lazyPut<StaffLeaveParentService>(
      () => StaffLeaveParentService(),
      fenix: true,
    );
    Get.lazyPut<ChildLeaveRequestParentService>(
      () => ChildLeaveRequestParentService(),
      fenix: true,
    );
    Get.lazyPut<ChildReportParentService>(
      () => ChildReportParentService(),
      fenix: true,
    );
    Get.lazyPut<AssessmentParentService>(
      () => AssessmentParentService(),
      fenix: true,
    );
    Get.lazyPut<IncidentParentService>(
      () => IncidentParentService(),
      fenix: true,
    );
    Get.lazyPut<NoteParentService>(() => NoteParentService(), fenix: true);
    Get.lazyPut<LessonPlanParentService>(
      () => LessonPlanParentService(),
      fenix: true,
    );
    Get.lazyPut<ClassroomPostParentService>(
      () => ClassroomPostParentService(),
      fenix: true,
    );
    Get.lazyPut<AnnouncementParentService>(
      () => AnnouncementParentService(),
      fenix: true,
    );
    Get.lazyPut<ScheduleParentService>(
      () => ScheduleParentService(),
      fenix: true,
    );
    Get.lazyPut<DailyCareLogParentService>(
      () => DailyCareLogParentService(),
      fenix: true,
    );
    Get.lazyPut<ExpenseParentService>(
      () => ExpenseParentService(),
      fenix: true,
    );
    Get.lazyPut<InvoiceParentService>(
      () => InvoiceParentService(),
      fenix: true,
    );
    Get.lazyPut<PaymentAccountParentService>(
      () => PaymentAccountParentService(),
      fenix: true,
    );
    Get.lazyPut<FeeCategoryParentService>(
      () => FeeCategoryParentService(),
      fenix: true,
    );
    Get.lazyPut<ShiftParentService>(() => ShiftParentService(), fenix: true);
    Get.lazyPut<DailyAssessmentParentService>(
      () => DailyAssessmentParentService(),
      fenix: true,
    );
    Get.lazyPut<TopicProgressParentService>(
      () => TopicProgressParentService(),
      fenix: true,
    );
    Get.lazyPut<AcademicTopicParentService>(
      () => AcademicTopicParentService(),
      fenix: true,
    );
    Get.lazyPut<FinancialTransactionParentService>(
      () => FinancialTransactionParentService(),
      fenix: true,
    );
    // Shared, stateless finance analytics (single source of truth for the
    // owner + manager dashboards). No state, no fetch — controllers cache.
    Get.lazyPut<FinanceAnalyticsService>(
      () => FinanceAnalyticsService(),
      fenix: true,
    );
    // Role-agnostic "unpaid monthly subscription" tracker — one shared instance
    // behind the owner, manager AND reception dashboard cards. Scopes itself.
    Get.lazyPut<UnpaidSubscriptionController>(
      () => UnpaidSubscriptionController(),
      fenix: true,
    );
    // Shared "absent today" list behind the reception home + children-tab
    // sections. One instance, resolved by both AbsentTodaySection mounts.
    Get.lazyPut<AbsentTodayController>(
      () => AbsentTodayController(),
      fenix: true,
    );
    Get.lazyPut<PaymentParentService>(
      () => PaymentParentService(),
      fenix: true,
    );
    Get.lazyPut<AuditLogParentService>(
      () => AuditLogParentService(),
      fenix: true,
    );
    Get.lazyPut<SupportTicketParentService>(
      () => SupportTicketParentService(),
      fenix: true,
    );
    Get.lazyPut<ContactInfoParentService>(
      () => ContactInfoParentService(),
      fenix: true,
    );
    Get.lazyPut<CityParentService>(() => CityParentService(), fenix: true);
    Get.lazyPut<AboutUsParentService>(
      () => AboutUsParentService(),
      fenix: true,
    );
    Get.lazyPut<TutorialVideoParentService>(
      () => TutorialVideoParentService(),
      fenix: true,
    );
    Get.lazyPut<ShowcaseShotParentService>(
      () => ShowcaseShotParentService(),
      fenix: true,
    );
    Get.lazyPut<SupportRequestParentService>(
      () => SupportRequestParentService(),
      fenix: true,
    );
    Get.lazyPut<AppReviewParentService>(
      () => AppReviewParentService(),
      fenix: true,
    );
    Get.lazyPut<NurseryFeedbackParentService>(
      () => NurseryFeedbackParentService(),
      fenix: true,
    );
    Get.lazyPut<NurseryFeedbackListController>(
      () => NurseryFeedbackListController(),
      fenix: true,
    );
    Get.lazyPut<OnlineApplicationParentService>(
      () => OnlineApplicationParentService(),
      fenix: true,
    );
    Get.lazyPut<OnlineApplicationSubmitService>(
      () => OnlineApplicationSubmitService(),
      fenix: true,
    );
    Get.lazyPut<PickupRequestParentService>(
      () => PickupRequestParentService(),
      fenix: true,
    );
    Get.lazyPut<PickupRealtimeService>(
      () => PickupRealtimeService(),
      fenix: true,
    );

    // ─── Child State Services ─────────────────────────────────────────────
    Get.lazyPut<ChildStateTemplateParentService>(
      () => ChildStateTemplateParentService(),
      fenix: true,
    );
    Get.lazyPut<ChildStateService>(() => ChildStateService(), fenix: true);
    Get.lazyPut<ChildStatesController>(
      () => ChildStatesController(),
      fenix: true,
    );
    Get.lazyPut<ClassroomStatesController>(
      () => ClassroomStatesController(),
      fenix: true,
    );

    // ─── Eval Level Templates (dynamic activity evaluations) ──────────────
    Get.put<EvalLevelsRegistry>(EvalLevelsRegistry(), permanent: true);
    Get.lazyPut<EvalLevelTemplateParentService>(
      () => EvalLevelTemplateParentService(),
      fenix: true,
    );
    Get.lazyPut<EvalLevelsController>(
      () => EvalLevelsController(),
      fenix: true,
    );

    // ─── Guardian session notes (parent → nursery) ───────────────────────
    Get.lazyPut<GuardianNoteParentService>(
      () => GuardianNoteParentService(),
      fenix: true,
    );
    Get.lazyPut<GuardianNoteController>(
      () => GuardianNoteController(),
      fenix: true,
    );
    Get.lazyPut<ParentNotesInboxController>(
      () => ParentNotesInboxController(),
      fenix: true,
    );

    // ─── Evaluation Reasons ───────────────────────────────────────────────
    Get.lazyPut<EvaluationReasonsService>(
      () => EvaluationReasonsService(),
      fenix: true,
    );
    Get.lazyPut<EvaluationReasonsController>(
      () => EvaluationReasonsController(),
      fenix: true,
    );

    // ─── Teacher Home ─────────────────────────────────────────────────────
    Get.lazyPut<TeacherHomeController>(
      () => TeacherHomeController(),
      fenix: true,
    );

    // ─── Teacher Weekly Schedule ──────────────────────────────────────────
    Get.lazyPut<TeacherWeeklyScheduleController>(
      () => TeacherWeeklyScheduleController(),
      fenix: true,
    );

    // ─── Teacher Activity ─────────────────────────────────────────────────
    Get.lazyPut<TeacherActivityService>(
      () => TeacherActivityService(),
      fenix: true,
    );
    Get.lazyPut<TeacherActivityController>(() => TeacherActivityController());
    Get.lazyPut<MediaApprovalController>(
      () => MediaApprovalController(),
      fenix: true,
    );
    Get.lazyPut<ActivityEndController>(
      () => ActivityEndController(),
      fenix: true,
    );
    Get.lazyPut<HomeworkTabController>(
      () => HomeworkTabController(),
      fenix: true,
    );
    Get.lazyPut<TeacherReportsController>(
      () => TeacherReportsController(),
      fenix: true,
    );
    Get.lazyPut<LinkBookController>(() => LinkBookController(), fenix: true);

    // ─── Branch Manager — Children ────────────────────────────────────────
    Get.lazyPut<ManagerChildrenController>(
      () => ManagerChildrenController(),
      fenix: true,
    );

    // ─── Branch Manager — Staff ───────────────────────────────────────────
    Get.lazyPut<ManagerStaffController>(
      () => ManagerStaffController(),
      fenix: true,
    );

    // ─── Branch Manager — Finance ─────────────────────────────────────────
    // Kept for the manager HOME dashboard aggregates (old-system, removed in
    // Phase 4). The new finance dashboard uses FinanceDashboardController below.
    Get.lazyPut<ManagerFinanceController>(
      () => ManagerFinanceController(),
      fenix: true,
    );
    // New shared finance dashboard — manager scope (own branch).
    Get.lazyPut<FinanceDashboardController>(
      () => FinanceDashboardController(isOwner: false),
      tag: 'manager_finance',
      fenix: true,
    );

    // ─── Branch Manager — More ────────────────────────────────────────────
    Get.lazyPut<ManagerMoreController>(
      () => ManagerMoreController(),
      fenix: true,
    );

    // ─── Nursery Settings — Shifts ────────────────────────────────────────
    Get.lazyPut<ShiftsController>(() => ShiftsController(), fenix: true);

    // ─── Parent — Notification Preferences ────────────────────────────────
    Get.lazyPut<NotificationPrefsController>(
      () => NotificationPrefsController(),
      fenix: true,
    );

    // ─── Parent — Weekly Attendance Report ────────────────────────────────
    Get.lazyPut<WeeklyAttendanceController>(
      () => WeeklyAttendanceController(),
      fenix: true,
    );

    // ─── Parent — Weekly Evaluation Report ────────────────────────────────
    Get.lazyPut<WeeklyEvaluationController>(
      () => WeeklyEvaluationController(),
      fenix: true,
    );

    // ─── Parent — Weekly Learning Report ──────────────────────────────────
    Get.lazyPut<WeeklyLearningController>(
      () => WeeklyLearningController(),
      fenix: true,
    );

    // ─── Parent — Financial Report ────────────────────────────────────────
    Get.lazyPut<FinancialReportController>(
      () => FinancialReportController(),
      fenix: true,
    );

    // ─── Parent — Monthly Report ──────────────────────────────────────────
    Get.lazyPut<MonthlyReportController>(
      () => MonthlyReportController(),
      fenix: true,
    );

    // ─── Branch Manager — Online Applications ─────────────────────────────
    Get.lazyPut<ManagerApplicationsController>(
      () => ManagerApplicationsController(),
      fenix: true,
    );

    // ─── Branch Manager — Dashboard ───────────────────────────────────────
    Get.lazyPut<ManagerDashboardController>(
      () => ManagerDashboardController(),
      fenix: true,
    );

    // ─── Branch Manager — Teacher Reports (bottom-nav tab) ────────────────
    Get.lazyPut<ManagerTeacherReportsController>(
      () => ManagerTeacherReportsController(),
      fenix: true,
    );

    // ─── Branch Manager — Live Teaching donut (home) + day drill-down ─────
    Get.lazyPut<LiveTeachingController>(
      () => LiveTeachingController(),
      fenix: true,
    );
    Get.lazyPut<TeacherTodayController>(
      () => TeacherTodayController(),
      fenix: true,
    );

    // ─── Owner — Executive Dashboard ──────────────────────────────────────
    Get.lazyPut<OwnerExecutiveController>(
      () => OwnerExecutiveController(),
      fenix: true,
    );
    // ─── Owner — Analytics Center (hub + Phase-1 reports) ─────────────────
    Get.lazyPut<AnalyticsCenterController>(() => AnalyticsCenterController());
    Get.lazyPut<OwnerFinanceTrendController>(
      () => OwnerFinanceTrendController(),
    );
    Get.lazyPut<OwnerCollectionsController>(() => OwnerCollectionsController());
    Get.lazyPut<OwnerReceivablesController>(() => OwnerReceivablesController());
    Get.lazyPut<OwnerBranchPnlController>(() => OwnerBranchPnlController());
    Get.lazyPut<OwnerBranchHealthController>(
      () => OwnerBranchHealthController(),
    );
    Get.lazyPut<OwnerOccupancyController>(() => OwnerOccupancyController());
    Get.lazyPut<OwnerInsightsController>(() => OwnerInsightsController());
    // Phase-2 reports
    Get.lazyPut<OwnerChurnController>(() => OwnerChurnController());
    Get.lazyPut<OwnerEngagementController>(() => OwnerEngagementController());
    Get.lazyPut<OwnerTeacherPerfController>(() => OwnerTeacherPerfController());
    Get.lazyPut<OwnerEvaluationsController>(() => OwnerEvaluationsController());
    Get.lazyPut<OwnerAttendanceController>(() => OwnerAttendanceController());
    // Phase-3 finance-detail reports
    Get.lazyPut<OwnerCollectionRateController>(
      () => OwnerCollectionRateController(),
    );
    Get.lazyPut<OwnerRevenueMethodController>(
      () => OwnerRevenueMethodController(),
    );
    Get.lazyPut<OwnerRevenueCategoryController>(
      () => OwnerRevenueCategoryController(),
    );
    Get.lazyPut<OwnerPaymentBehaviorController>(
      () => OwnerPaymentBehaviorController(),
    );
    Get.lazyPut<OwnerRevenueForecastController>(
      () => OwnerRevenueForecastController(),
    );
    // New shared finance dashboard — owner scope (network / branch via switcher).
    Get.lazyPut<FinanceDashboardController>(
      () => FinanceDashboardController(isOwner: true),
      tag: 'owner_finance',
      fenix: true,
    );

    // ─── Platform Subscription Billing ────────────────────────────────────
    Get.lazyPut<PlatformBillingService>(
      () => PlatformBillingService(),
      fenix: true,
    );
    Get.lazyPut<PlatformPaymentService>(
      () => PlatformPaymentService(),
      fenix: true,
    );

    // ─── KidTrack Feedback Campaigns ──────────────────────────────────────
    Get.lazyPut<KidtrackCampaignService>(
      () => KidtrackCampaignService(),
      fenix: true,
    );
    Get.lazyPut<KidtrackFeedbackService>(
      () => KidtrackFeedbackService(),
      fenix: true,
    );
    Get.lazyPut<MySubscriptionController>(
      () => MySubscriptionController(),
      fenix: true,
    );
    Get.lazyPut<SaBillingController>(() => SaBillingController(), fenix: true);
    Get.lazyPut<SaBillingDetailController>(
      () => SaBillingDetailController(),
      fenix: true,
    );
  }
}
