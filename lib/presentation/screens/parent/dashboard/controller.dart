import '../../../../index/index_main.dart';
import '../../../../Global/services/pickup_realtime_service.dart';
import '../../../../Global/services/parent_education_service.dart';
import '../../../../Global/services/child_status_service.dart';
import '../../../../Global/services/event_service.dart';
import '../../../../Global/services/holiday_service.dart';
import '../../../../Data/models/holiday/holiday_model.dart';
import '../../../../Data/models/child_current_status/child_current_status_model.dart';
import '../../../../Data/models/child_daily_event/child_daily_event_model.dart';
import '../../../../Data/models/nursery_event/nursery_event_model.dart';
import '../../../../Data/models/homework_submission/homework_submission_model.dart';
import '../../../../Data/models/feed/nursery_post_model.dart';
import '../../../../Global/services/feed_service.dart';
import 'parent_daily_note.dart';
import 'effective_child_status.dart';

export 'parent_daily_note.dart';
export 'effective_child_status.dart';

class ParentDashboardController extends GetxController {
  // ── Pickup state ─────────────────────────────────────────────────────────────
  final pickupRequested = false.obs;
  final pickupEta = ''.obs;
  final pickupStatus = ''.obs;
  final _activeRequestKey = ''.obs;

  // ── Child identity ────────────────────────────────────────────────────────────
  final _activeChildId = ''.obs;
  final _activeChildName = ''.obs;
  final _activeClassroomId = ''.obs;
  final _classroomNameStr = 'الفصل'.obs;
  final selectedPeriod = 'weekly'.obs;
  final isLoading = true.obs;

  // ── Selected day (Today vs. History) ──────────────────────────────────────────
  // Default = today → fully live. Any other day → read-only recap of that day.
  final selectedDate = DateTime.now().obs;
  bool get isToday => _isSameDay(selectedDate.value, DateTime.now());

  // ── Streams ───────────────────────────────────────────────────────────────────
  StreamSubscription<PickupRequestModel?>? _requestSub;
  StreamSubscription<List<String>>? _photosSub;
  StreamSubscription<List<NoteModel>>? _notesSub;
  StreamSubscription<ChildCurrentStatusModel?>? _statusSub;
  StreamSubscription<ClassroomActivityModel?>? _activitySub;
  StreamSubscription<List<ChildDailyEventModel>>? _timelineSub;
  StreamSubscription<List<NurseryEventModel>>? _eventsSub;
  StreamSubscription<List<EduHomework>>? _homeworkSub;
  StreamSubscription<List<HolidayModel>>? _holidaysSub;
  StreamSubscription<Set<int>>? _weekendSub;
  StreamSubscription<List<NurseryPostModel>>? _latestPostSub;

  // ── Live child state ──────────────────────────────────────────────────────────
  final childCurrentStatus = Rxn<ChildCurrentStatusModel>();
  final runningClassroomActivity = Rxn<ClassroomActivityModel>();
  final todayTimeline2 = <ChildDailyEventModel>[].obs;
  // Raw feed straight from the stream, before the arrival gate is applied.
  // todayTimeline2 is the gated, view-facing list (starts at check-in).
  List<ChildDailyEventModel> _rawTimeline = const [];
  final todayPhotos = <String>[].obs;
  final dailyNotes = <ParentDailyNote>[].obs;
  // activityId → teacher note text, sourced from the same parent-visible
  // `platform/{nurseryId}/notes` records (key `act_{activityId}_{childId}`)
  // that feed the daily notes section, so the activity sheet stays in sync.
  final _activityNotes = <String, String>{};

  // ── Weekly schedule (today) ─────────────────────────────────────────────────────
  final daySchedule = <ScheduleModel>[].obs;
  final _subjectNames = <String, String>{}.obs; // subjectId → name

  // ── Events ────────────────────────────────────────────────────────────────────
  final nextEvent = Rxn<NurseryEventModel>();
  final isAttendingNextEvent = false.obs;

  // ── Latest social post (home peek) ────────────────────────────────────────────
  // Newest post that matches this parent's audience AND was created today.
  // Self-clears at midnight because the "today" gate stops matching.
  final latestPost = Rxn<NurseryPostModel>();
  final _feedSvc = FeedService();
  List<NurseryPostModel> _latestPostsRaw = const [];

  // ── Pending Invoices (Payment Reminders) ─────────────────────────────────────
  final pendingInvoices = <InvoiceModel>[].obs;

  // ── Homework ──────────────────────────────────────────────────────────────────
  final homework = <EduHomework>[].obs;

  // ── Holidays (nursery-wide days off) ──────────────────────────────────────────
  final holidayDates = <HolidayModel>[].obs;
  final weekendDays = <int>{}.obs;
  final _holidaySvc = HolidayService();

  // ── Services ──────────────────────────────────────────────────────────────────
  final _eventSvc = EventService();
  late final SessionService _session;
  late final PickupRealtimeService _pickupSvc;
  late final ParentEducationService _eduSvc;
  late final ChildStatusService _childStatusSvc;
  late final TeacherActivityService _activitySvc;
  Worker? _childWorker;

  @override
  void onInit() {
    super.onInit();
    _session = SessionService();
    _pickupSvc = Get.find<PickupRealtimeService>();
    _eduSvc = ParentEducationService();
    _childStatusSvc = ChildStatusService();
    _activitySvc = TeacherActivityService();
    // Register the active-child listener only after the initial load resolves,
    // so the first child assignment doesn't trigger a redundant reload.
    _loadActiveChild().then((_) {
      _childWorker =
          ever<String>(Get.find<ActiveChildService>().childId, _onActiveChildChanged);
    });
    _subscribeNextEvent();
    _subscribeHolidays();
    _subscribeLatestPost();
  }

  // ── Latest social post subscription ─────────────────────────────────────────
  void _subscribeLatestPost() {
    _latestPostSub?.cancel();
    _latestPostSub = _feedSvc.watchLatestPosts().listen((list) {
      _latestPostsRaw = list;
      _recomputeLatestPost();
    });
  }

  // Pick the newest post that this parent is allowed to see and that was
  // created today. Re-run whenever the active child changes (its classroom
  // affects audience).
  void _recomputeLatestPost() {
    final now = DateTime.now();
    NurseryPostModel? pick;
    for (final p in _latestPostsRaw) {
      final created = DateTime.fromMillisecondsSinceEpoch(p.createdAt);
      if (!_isSameDay(created, now)) continue;
      if (!_postMatchesAudience(p) || !_postMatchesBranch(p)) continue;
      pick = p; // list is newest-first, so first match wins
      break;
    }
    latestPost.value = pick;
  }

  bool _postMatchesAudience(NurseryPostModel p) {
    if (p.classroomId == null || p.classroomId!.isEmpty) return true;
    return p.classroomId == Get.find<ActiveChildService>().classroomId.value;
  }

  bool _postMatchesBranch(NurseryPostModel p) {
    final myBranch = _session.branchId;
    if (myBranch == null || myBranch.isEmpty) return true;
    return p.isAllBranches || p.branchIds.contains(myBranch);
  }

  // Nursery-wide, so subscribed once (not per child/day).
  void _subscribeHolidays() {
    _holidaysSub?.cancel();
    _holidaysSub = _holidaySvc.watchHolidays().listen(holidayDates.assignAll);
    _weekendSub?.cancel();
    _weekendSub = _holidaySvc.watchWeekendDays().listen(weekendDays.assignAll);
  }

  @override
  void onClose() {
    _childWorker?.dispose();
    _requestSub?.cancel();
    _photosSub?.cancel();
    _notesSub?.cancel();
    _statusSub?.cancel();
    _activitySub?.cancel();
    _timelineSub?.cancel();
    _eventsSub?.cancel();
    _homeworkSub?.cancel();
    _holidaysSub?.cancel();
    _weekendSub?.cancel();
    _latestPostSub?.cancel();
    super.onClose();
  }

  // ── Event subscription ────────────────────────────────────────────────────────

  void _subscribeNextEvent() {
    _eventsSub?.cancel();
    _eventsSub = _eventSvc.watchUpcomingEvents().listen((list) {
      nextEvent.value = list.isNotEmpty ? list.first : null;
      _refreshEventAttendance();
    });
  }

  Future<void> _refreshEventAttendance() async {
    final event = nextEvent.value;
    if (event == null || _activeChildId.value.isEmpty) return;
    isAttendingNextEvent.value = await _eventSvc.isAttending(
      event.id,
      _activeChildId.value,
    );
  }

  Future<void> toggleNextEventAttendance() async {
    final event = nextEvent.value;
    if (event == null || _activeChildId.value.isEmpty) return;
    final currently = isAttendingNextEvent.value;
    Loader.show();
    final ok = currently
        ? await _eventSvc.cancelAttendance(
            eventId: event.id,
            childId: _activeChildId.value,
          )
        : await _eventSvc.confirmAttendance(
            eventId: event.id,
            childId: _activeChildId.value,
            parentId: _session.userId ?? '',
            childName: _activeChildName.value,
            parentName: _session.currentUser?.displayName ?? 'ولي الأمر',
          );
    Loader.dismiss();
    if (ok) {
      isAttendingNextEvent.value = !currently;
      Loader.showSuccess(
        currently
            ? 'event_cancelled_attendance'.tr
            : 'event_confirmed_attendance'.tr,
      );
    }
  }

  // ── Child loading ─────────────────────────────────────────────────────────────

  Future<void> _loadActiveChild() async {
    final svc = Get.find<ActiveChildService>();

    // 1. Use cached values immediately — AppBar shows name at once.
    if (svc.childId.value.isNotEmpty) {
      _activeChildId.value     = svc.childId.value;
      _activeChildName.value   = svc.childName.value;
      _activeClassroomId.value = svc.classroomId.value;
      _startStreams();
      isLoading.value = false;
    }

    // 2. Refresh from Firebase in the background.
    final prevId        = _activeChildId.value;
    final prevClassroom = _activeClassroomId.value;
    final freshId = await svc.loadFromFirebase();
    if (freshId == null) {
      isLoading.value = false;
      return;
    }

    _activeChildId.value     = svc.childId.value;
    _activeChildName.value   = svc.childName.value;
    _activeClassroomId.value = svc.classroomId.value;

    // Re-subscribe only if child/classroom changed (avoids duplicate streams).
    if (prevId != svc.childId.value || prevClassroom != svc.classroomId.value) {
      _startStreams();
    }

    await _loadClassroomName();
    isLoading.value = false;

    // First-login gate: force the parent to complete the child's core profile
    // (DOB, address, blood type, nationality) before they can use the app, then
    // prompt once for notification preferences (chained so the two mandatory
    // sheets never stack).
    await ChildProfileCompletionPrompt.maybeShow();
    await NotificationPrefsPrompt.maybeShow();
  }

  // ── Sibling switching ─────────────────────────────────────────────────────────

  /// All of the parent's children, for the header switcher.
  List<ActiveChildOption> get siblings =>
      Get.find<ActiveChildService>().children;

  /// Switches the active child. The actual data reload is driven by the
  /// [ActiveChildService.childId] listener ([_onActiveChildChanged]), so every
  /// parent tab reacts to the switch uniformly — not just the dashboard.
  Future<void> switchChild(String childId) async {
    if (childId == _activeChildId.value) return;
    final svc = Get.find<ActiveChildService>();
    ActiveChildOption? opt;
    for (final c in svc.children) {
      if (c.id == childId) { opt = c; break; }
    }
    if (opt == null) return;
    await svc.setActive(opt);
  }

  /// Reloads all child-scoped dashboard data when the active child changes.
  void _onActiveChildChanged(String childId) {
    if (childId.isEmpty || childId == _activeChildId.value) return;
    final svc = Get.find<ActiveChildService>();

    // Resolve name/classroom from the children list by id so the header never
    // depends on the order the service sets its fields in.
    ActiveChildOption? opt;
    for (final c in svc.children) {
      if (c.id == childId) { opt = c; break; }
    }

    _activeChildId.value     = childId;
    _activeChildName.value   = opt?.name ?? svc.childName.value;
    _activeClassroomId.value = opt?.classroomId ?? svc.classroomId.value;

    // Reset transient state so we don't briefly show the previous child's data.
    childCurrentStatus.value = null;
    runningClassroomActivity.value = null;
    todayTimeline2.clear();
    _rawTimeline = const [];
    todayPhotos.clear();
    dailyNotes.clear();
    homework.clear();
    pendingInvoices.clear();
    daySchedule.clear();
    _classroomNameStr.value = 'الفصل';

    isLoading.value = true;
    _startStreams();
    _loadClassroomName().then((_) => isLoading.value = false);
    _refreshEventAttendance();
    _recomputeLatestPost();

    // A switched-to sibling may also have an incomplete profile; chain the
    // notification-prefs prompt after it (self-guards once configured).
    ChildProfileCompletionPrompt.maybeShow()
        .then((_) => NotificationPrefsPrompt.maybeShow());
  }

  void _startStreams() {
    // Day-scoped data — works for any selected day.
    _subscribeTimeline();
    _subscribePhotos();
    _subscribeNotes();
    _subscribeHomework();

    if (isToday) {
      // Live-only subscriptions (current status, running activity, schedule…).
      _subscribeChildStatus();
      _subscribeClassroomActivity();
      _loadPendingInvoices();
      _loadSchedule();
    } else {
      _enterHistoryMode();
    }
  }

  /// Past-day view: tear down everything "live now" so a stale Hero/pickup can't
  /// contradict the historical timeline/photos the parent is browsing.
  void _enterHistoryMode() {
    _statusSub?.cancel();
    _activitySub?.cancel();
    childCurrentStatus.value = null;
    runningClassroomActivity.value = null;
    daySchedule.clear();
    pendingInvoices.clear();
    _clearPickupState();
  }

  /// Switch the home to a specific day. Today → live; any other day → recap.
  void setDate(DateTime d) {
    final norm = DateTime(d.year, d.month, d.day);
    if (_isSameDay(norm, selectedDate.value)) return;
    selectedDate.value = norm;
    // Clear the previous day's data so we never briefly mix two days.
    todayTimeline2.clear();
    _rawTimeline = const [];
    todayPhotos.clear();
    dailyNotes.clear();
    _startStreams();
  }

  void backToToday() => setDate(DateTime.now());

  Future<void> _loadSchedule() async {
    final nurseryId = _session.nurseryId ?? '';
    final classroomId = _activeClassroomId.value;
    if (nurseryId.isEmpty || classroomId.isEmpty) return;
    try {
      // Resolve subject names once (id → name) for nice lesson labels.
      if (_subjectNames.isEmpty) {
        final subjects = await _activitySvc.loadSubjects(nurseryId);
        _subjectNames.assignAll({
          for (final s in subjects)
            if (s.key != null) s.key!: s.name,
        });
      }
      final list = await _activitySvc.getTodayScheduleForClassroom(
        nurseryId: nurseryId,
        classroomId: classroomId,
      );
      daySchedule.assignAll(list);
    } catch (_) {}
  }

  Future<void> _loadPendingInvoices() async {
    final childId = _activeChildId.value;
    if (childId.isEmpty) return;

    // Months (YYYYMM) in which reception already recorded a cash collection for
    // this child. A monthly-subscription invoice (month_… key) for one of these
    // months is treated as settled — this reconciles the new collections log with
    // the old invoice-based dues, self-healing even for payments recorded before
    // the invoice was flipped to "paid".
    final paidMonths = <String>{};
    final txns =
        await Get.find<FinancialTransactionParentService>().getByChild(childId);
    for (final t in txns) {
      final d = DateTime.fromMillisecondsSinceEpoch(t.date);
      paidMonths.add('${d.year}${d.month.toString().padLeft(2, '0')}');
    }

    final svc = Get.find<InvoiceParentService>();
    await svc.getAll(callBack: (list) {
      pendingInvoices.value = list
          .whereType<InvoiceModel>()
          .where((i) =>
              i.childId == childId &&
              // The "additional fee" feature (fee_… invoices, e.g. an app
              // subscription) was removed; hide any leftover legacy dues so the
              // parent only sees live monthly-subscription obligations.
              (i.key == null || !i.key!.startsWith('fee_')) &&
              // Still owes money (includes partially-paid invoices, which show
              // their remaining balance). The transaction-based reconciliation
              // is only a fallback for legacy invoices that were never updated
              // with a paidAmount — don't let it hide a real partial balance.
              i.hasOutstanding &&
              !(i.paidAmount <= 0.5 && _settledByCollection(i, paidMonths)))
          .toList()
        ..sort((a, b) {
          if (a.status == 'overdue' && b.status != 'overdue') return -1;
          if (b.status == 'overdue' && a.status != 'overdue') return 1;
          return (b.createdAt ?? 0).compareTo(a.createdAt ?? 0);
        });
    });
  }

  /// A monthly invoice key is `month_{childId}_{YYYYMM}`. It counts as paid when
  /// reception logged any collection for this child in that same calendar month.
  bool _settledByCollection(InvoiceModel invoice, Set<String> paidMonths) {
    final key = invoice.key;
    if (key == null || !key.startsWith('month_') || key.length < 6) return false;
    return paidMonths.contains(key.substring(key.length - 6));
  }

  Future<void> refreshPendingInvoices() => _loadPendingInvoices();

  // ── Realtime subscriptions ────────────────────────────────────────────────────

  void _subscribeChildStatus() {
    final nurseryId = _session.nurseryId ?? '';
    final childId = _activeChildId.value;
    if (nurseryId.isEmpty || childId.isEmpty) return;
    _statusSub?.cancel();
    _statusSub = _childStatusSvc
        .watchStatus(nurseryId, childId)
        .listen((s) {
          childCurrentStatus.value = s;
          // Check-in time just changed → re-gate the timeline so the track
          // starts exactly at arrival (and stays empty before it).
          _rebuildVisibleTimeline();
          // The live status node persists across days, so a stale status from a
          // previous day (e.g. checked_out) must read as not_arrived today.
          final fresh = s != null && _isSameDay(s.updatedAt, DateTime.now());
          // Push live status into ActiveChildService so all AppBars update.
          Get.find<ActiveChildService>().updateStatus(
            fresh ? s.status : ChildStatus.notArrived,
          );
        });
  }

  void _subscribeClassroomActivity() {
    final nurseryId = _session.nurseryId ?? '';
    final classroomId = _activeClassroomId.value;
    if (nurseryId.isEmpty || classroomId.isEmpty) return;
    _activitySub?.cancel();
    _activitySub = _activitySvc
        .watchActiveActivity(nurseryId, classroomId)
        .listen((a) => runningClassroomActivity.value = a);
  }

  void _subscribeTimeline() {
    final nurseryId = _session.nurseryId ?? '';
    final childId = _activeChildId.value;
    if (nurseryId.isEmpty || childId.isEmpty) return;
    _timelineSub?.cancel();
    final stream = isToday
        ? _childStatusSvc.watchTodayEvents(nurseryId, childId)
        : _childStatusSvc.watchEventsForDay(
            nurseryId, childId, selectedDate.value);
    _timelineSub = stream.listen((e) {
      _rawTimeline = e;
      _rebuildVisibleTimeline();
    });
  }

  void _rebuildVisibleTimeline() =>
      todayTimeline2.assignAll(_gateByArrival(_rawTimeline));

  /// The child's daily track only starts once they've arrived: hide everything
  /// before check-in, and show nothing at all until they check in today.
  /// History days are a full recap, so they pass through ungated.
  ///
  /// Arrival is derived from the check-in event in the day's own feed — the
  /// authoritative signal that survives a missing/stale live status node (a
  /// not-yet-arrived child often has no `childCurrentStatus` record at all).
  List<ChildDailyEventModel> _gateByArrival(
      List<ChildDailyEventModel> events) {
    if (!isToday) return events;

    int? arrivalMs;
    for (final e in events) {
      // Reception check-in or a bus drop-off both mean "arrived at nursery".
      if (e.eventType == ChildEventType.checkIn ||
          e.eventType == ChildEventType.busArrived) {
        if (arrivalMs == null || e.createdAt < arrivalMs) arrivalMs = e.createdAt;
      }
    }
    // Fallback: the child is marked present today but the check-in event is
    // missing (data gap) — use the status check-in time instead.
    if (arrivalMs == null) {
      final s = childCurrentStatus.value;
      final fresh = s != null && _isSameDay(s.updatedAt, DateTime.now());
      if (fresh && s.status != ChildStatus.notArrived && s.checkInTime != null) {
        arrivalMs = s.checkInTime!.millisecondsSinceEpoch;
      }
    }
    // No arrival today → the day hasn't started → empty track.
    if (arrivalMs == null) return const [];
    final gate = arrivalMs;
    return events.where((e) => e.createdAt >= gate).toList();
  }

  void _subscribePhotos() {
    final nurseryId = _session.nurseryId ?? '';
    final classroomId = _activeClassroomId.value;
    final childId = _activeChildId.value;
    if (nurseryId.isEmpty || classroomId.isEmpty) return;
    _photosSub?.cancel();
    final stream = isToday
        ? _eduSvc.watchTodayPhotos(nurseryId, classroomId, childId)
        : _eduSvc
            .watchPhotosForDay(
                nurseryId, classroomId, selectedDate.value, childId)
            .map((list) => list.map((p) => p.url).toList());
    _photosSub = stream.listen((urls) => todayPhotos.assignAll(urls));
  }

  void _subscribeNotes() {
    final nurseryId = _session.nurseryId ?? '';
    final childId = _activeChildId.value;
    if (nurseryId.isEmpty || childId.isEmpty) return;
    _notesSub?.cancel();
    final stream = isToday
        ? _eduSvc.watchTodayNotes(nurseryId, childId)
        : _eduSvc.watchNotesForDay(nurseryId, childId, selectedDate.value);
    _notesSub = stream.listen((list) {
      dailyNotes.assignAll(
        list.map(
          (n) => ParentDailyNote(
            text: n.content,
            severity: _mapSeverity(n.category),
          ),
        ),
      );
      _activityNotes.clear();
      for (final n in list) {
        final k = n.key ?? '';
        if (!k.startsWith('act_')) continue;
        // key = act_{activityId}_{childId}; push keys carry no underscore,
        // so the last underscore separates activityId from childId.
        final body = k.substring(4);
        final sep = body.lastIndexOf('_');
        if (sep <= 0) continue;
        final activityId = body.substring(0, sep);
        if (n.content.trim().isNotEmpty) {
          _activityNotes[activityId] = n.content.trim();
        }
      }
    });
  }

  static String _mapSeverity(String category) {
    switch (category) {
      case 'positive':
        return 'positive';
      case 'needs_follow':
        return 'needs_followup';
      case 'important':
        return 'important';
      default:
        return 'info';
    }
  }

  // ── Data loading ──────────────────────────────────────────────────────────────

  Future<void> _loadClassroomName() async {
    final nurseryId = _session.nurseryId ?? '';
    final classroomId = _activeClassroomId.value;
    if (nurseryId.isEmpty || classroomId.isEmpty) return;
    try {
      final name = await _eduSvc.getClassroomName(nurseryId, classroomId);
      if (name.isNotEmpty) _classroomNameStr.value = name;
    } catch (_) {}
  }

  void _subscribeHomework() {
    final nurseryId = _session.nurseryId ?? '';
    final childId = _activeChildId.value;
    final classroomId = _activeClassroomId.value;
    if (nurseryId.isEmpty || childId.isEmpty || classroomId.isEmpty) return;

    final day = selectedDate.value;
    final dayStart =
        DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
    final dayEnd = DateTime(day.year, day.month, day.day)
        .add(const Duration(days: 1))
        .millisecondsSinceEpoch;

    _homeworkSub?.cancel();
    _homeworkSub = _eduSvc
        .watchAllClassroomHomework(nurseryId, classroomId)
        .asyncMap((hwList) async {
          // Homework belongs to the day it was assigned (createdAt) — the day the
          // child brought it home to do — falling back to dueDate if missing.
          final dayList = hwList.where((hw) {
            if (hw.key == null) return false;
            final anchor = hw.createdAt ?? hw.dueDate ?? 0;
            return anchor >= dayStart && anchor < dayEnd;
          }).toList();
          final submitted = await _eduSvc.getSubmittedHomeworkIds(
            nurseryId,
            childId,
            dayList.map((hw) => hw.key!).toList(growable: false),
          );
          return dayList
              .map((hw) => EduHomework(
                    subjectKey: hw.subjectName ?? hw.subjectId ?? '',
                    titleKey: hw.key!,
                    displayTitle: hw.title,
                    dueDate: _formatDueDate(hw.dueDate),
                    isCompleted: submitted.contains(hw.key),
                  ))
              .toList();
        })
        .listen((list) => homework.assignAll(list));
  }

  static String _formatDueDate(int? ms) {
    if (ms == null) return 'اليوم';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  // ── Getters ───────────────────────────────────────────────────────────────────

  String get parentName {
    final n = _session.currentUser?.name;
    return (n != null && n.trim().isNotEmpty) ? n.trim() : 'parent_default_name'.tr;
  }

  String get branchId =>
      Get.find<ActiveChildService>().branchId.value.isNotEmpty
          ? Get.find<ActiveChildService>().branchId.value
          : _session.branchId ?? '';

  String get childName =>
      _activeChildName.value.isNotEmpty ? _activeChildName.value : '';

  String get classroomName => _classroomNameStr.value;

  List<EduHomework> get pendingHomework =>
      homework.where((h) => !h.isCompleted).toList();

  List<EduHomework> get completedHomework =>
      homework.where((h) => h.isCompleted).toList();

  bool get allHomeworkDone =>
      homework.isNotEmpty && homework.every((h) => h.isCompleted);

  // ── Effective child status ────────────────────────────────────────────────────

  /// Most recent activity event from today's timeline (started OR completed),
  /// used to keep showing the last activity in the live card even after it ends.
  ChildDailyEventModel? get _lastTimelineActivity {
    ChildDailyEventModel? latest;
    for (final e in todayTimeline2) {
      if (e.eventType != ChildEventType.activityStarted &&
          e.eventType != ChildEventType.activityCompleted) {
        continue;
      }
      if (latest == null || e.createdAt > latest.createdAt) latest = e;
    }
    return latest;
  }

  EffectiveChildStatus get effectiveStatus {
    final stored = childCurrentStatus.value;
    // Reset the live card daily: a status whose updatedAt isn't today belongs to
    // a previous day, so the child counts as not-arrived until checked in again.
    final fresh = stored != null && _isSameDay(stored.updatedAt, DateTime.now());
    final s = fresh ? stored.status : ChildStatus.notArrived;
    final activity = runningClassroomActivity.value;

    if (s == ChildStatus.checkedOut) {
      return EffectiveChildStatus(
        key: ChildStatus.checkedOut,
        label: 'غادر الحضانة',
        icon: Icons.logout_rounded,
        color: const Color(0xFF64748B),
      );
    }
    if (s == ChildStatus.onBus) {
      return EffectiveChildStatus(
        key: ChildStatus.onBus,
        label: 'في الباص',
        icon: Icons.directions_bus_rounded,
        color: const Color(0xFFD97706),
      );
    }
    if (s == ChildStatus.sleeping) {
      return EffectiveChildStatus(
        key: ChildStatus.sleeping,
        label: 'وقت القيلولة',
        icon: Icons.bedtime_rounded,
        color: const Color(0xFF7C3AED),
      );
    }
    if (s == ChildStatus.havingMeal) {
      return EffectiveChildStatus(
        key: ChildStatus.havingMeal,
        label: 'يتناول الوجبة',
        icon: Icons.restaurant_rounded,
        color: const Color(0xFFDC2626),
      );
    }
    if (activity != null && activity.isActive) {
      final subject = activity.subjectName ?? '';
      return EffectiveChildStatus(
        key: 'in_activity',
        label: subject.isNotEmpty
            ? '$subject — ${activity.title}'
            : activity.title,
        icon: Icons.auto_stories_rounded,
        color: const Color(0xFF2563EB),
        activityTitle: activity.title,
        subjectName: subject,
      );
    }
    if (s == ChildStatus.checkedIn) {
      // No activity is currently running, but if the child did an activity
      // earlier today keep showing the last one instead of the generic
      // "inside nursery" status.
      final last = _lastTimelineActivity;
      final lastTitle = last?.title ?? '';
      if (last != null && lastTitle.isNotEmpty) {
        final subject = last.subjectName ?? '';
        return EffectiveChildStatus(
          key: 'last_activity',
          label: subject.isNotEmpty ? '$subject — $lastTitle' : lastTitle,
          icon: Icons.auto_stories_rounded,
          color: const Color(0xFF2563EB),
          activityTitle: lastTitle,
          subjectName: subject,
        );
      }
      return EffectiveChildStatus(
        key: ChildStatus.checkedIn,
        label: 'داخل الحضانة',
        icon: Icons.home_work_rounded,
        color: const Color(0xFF059669),
      );
    }
    return EffectiveChildStatus(
      key: ChildStatus.notArrived,
      label: 'لم يصل بعد',
      icon: Icons.schedule_rounded,
      color: const Color(0xFF94A3B8),
    );
  }

  bool get isChildActive =>
      effectiveStatus.key != ChildStatus.checkedOut &&
      effectiveStatus.key != ChildStatus.notArrived;

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String get realCheckInTime {
    final t = childCurrentStatus.value?.checkInTime;
    if (t == null) return '--:--';
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ── Home view-model helpers (real data → UI) ──────────────────────────────────

  /// Arabic-Indic digit conversion for nicer labels (٩:٣٠ instead of 9:30).
  static String ar(String s) {
    const w = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const e = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var out = s;
    for (var i = 0; i < 10; i++) {
      out = out.replaceAll(w[i], e[i]);
    }
    return out;
  }

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الخير';
    if (h < 17) return 'مساء الخير';
    return 'مساء الخير';
  }

  String get childInitial =>
      childName.isNotEmpty ? childName.characters.first : 'ط';

  /// Active child id — needed by the home to read per-child activity data.
  String get activeChildId => _activeChildId.value;

  /// Teacher note for an activity, taken from the parent-visible notes feed —
  /// the same source as the daily notes section. Covers notes saved from the
  /// activity end flow (evaluation reasons) that never land in `activity.notes`.
  String? teacherNoteForActivity(String activityId) {
    if (activityId.isEmpty) return null;
    final v = _activityNotes[activityId];
    return (v != null && v.trim().isNotEmpty) ? v.trim() : null;
  }

  /// Fetch a full classroom activity by id (live one first, else today's
  /// completed list). Used when a timeline item is tapped → activity sheet.
  Future<ClassroomActivityModel?> activityById(String activityId) async {
    final running = runningClassroomActivity.value;
    if (running != null && running.key == activityId) return running;
    final nurseryId = _session.nurseryId ?? '';
    final classroomId = _activeClassroomId.value;
    if (nurseryId.isEmpty || classroomId.isEmpty) return null;
    final completed =
        await _activitySvc.getTodayCompleted(nurseryId, classroomId);
    for (final a in completed) {
      if (a.key == activityId) return a;
    }
    return null;
  }

  /// "1716..." → "٩:٣٠"  (compact, no AM/PM — for the timeline column).
  String fmtClockMs(int ms) {
    final t = DateTime.fromMillisecondsSinceEpoch(ms);
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    return '${ar('$h')}:${ar(m)}';
  }

  /// "1716..." → "٩:٣٠ ص"
  String fmtClockMsSuffix(int ms) {
    final t = DateTime.fromMillisecondsSinceEpoch(ms);
    final suffix = t.hour < 12 ? 'ص' : 'م';
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    return '${ar('$h')}:${ar(m)} $suffix';
  }

  /// Activity start clock only — duration/end time intentionally hidden from
  /// parents (a short displayed duration triggered disputes over activity length).
  String activityTimeRange(ClassroomActivityModel a) => fmtClockMsSuffix(a.startedAt);

  /// Human label for a schedule slot (subject name, note, or activity type).
  String scheduleLabel(ScheduleModel s) {
    if (s.subjectId != null && _subjectNames[s.subjectId] != null) {
      return _subjectNames[s.subjectId]!;
    }
    if (s.note != null && s.note!.isNotEmpty) return s.note!;
    switch (s.activityType) {
      case 'break':
        return 'فسحة';
      case 'outdoor':
        return 'نشاط خارجي';
      case 'lunch':
        return 'الغداء';
      case 'nap':
        return 'القيلولة';
      default:
        return 'حصة';
    }
  }

  /// "9:30" → "٩:٣٠ ص"
  String fmtScheduleTime(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return ar(hhmm);
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];
    final suffix = h < 12 ? 'ص' : 'م';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '${ar('$h12')}:${ar(m)} $suffix';
  }

  int _nowMinutes() {
    final n = DateTime.now();
    return n.hour * 60 + n.minute;
  }

  static int _slotMinutes(String hhmm) {
    final p = hhmm.split(':');
    if (p.length != 2) return 0;
    return (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0);
  }

  /// First lesson of the day (for the "before arrival" hero).
  ScheduleModel? get firstLesson =>
      daySchedule.isNotEmpty ? daySchedule.first : null;

  /// Next upcoming schedule slot after the current time.
  ScheduleModel? get nextLesson {
    final now = _nowMinutes();
    for (final s in daySchedule) {
      if (_slotMinutes(s.startTime) > now) return s;
    }
    return null;
  }

  /// Total teaching lessons scheduled today.
  int get lessonsTotal =>
      daySchedule.where((s) => s.activityType == 'lesson').length;

  /// Completed teaching activities today (reactive — from the timeline journal).
  int get lessonsDone => todayTimeline2
      .where((e) => e.eventType == ChildEventType.activityCompleted)
      .length;

  double get dayPercent {
    if (lessonsTotal == 0) return 0;
    return (lessonsDone / lessonsTotal).clamp(0.0, 1.0);
  }

  // ── Live child state (teacher-managed, separate from attendance) ───────────────

  String? get liveStateTitle {
    final t = childCurrentStatus.value?.currentStateTitle;
    if (t != null && t.isNotEmpty) return t;
    // fall back to attendance-derived label when no explicit state is set
    final s = effectiveStatus;
    if (s.isActivity) return null; // classroom activity shown separately
    return null;
  }

  IconData get liveStateIcon {
    final id = childCurrentStatus.value?.currentStateId ?? '';
    if (id.contains('meal') || id.contains('eat') || id.contains('food')) {
      return Icons.restaurant_menu_rounded;
    }
    if (id.contains('sleep') || id.contains('nap')) {
      return Icons.bedtime_rounded;
    }
    if (id.contains('bath') || id.contains('toilet')) {
      return Icons.wc_rounded;
    }
    if (id.contains('play')) return Icons.sports_soccer_rounded;
    return Icons.child_care_rounded;
  }

  String get liveStateSinceLabel {
    final start = childCurrentStatus.value?.currentStateStartedAt;
    if (start == null) return '';
    final mins =
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(start)).inMinutes;
    if (mins <= 0) return 'دلوقتي';
    if (mins < 60) return 'من ${ar('$mins')} دقيقة';
    final h = mins ~/ 60;
    return 'من ${ar('$h')} ساعة';
  }

  String get statusUpdatedLabel {
    final t = childCurrentStatus.value?.updatedAt;
    if (t == null) return '';
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    return 'تم تحديث الحالة ${ar('$h')}:${ar(m)} · مباشر';
  }

  // ── Recap (after check-out) ────────────────────────────────────────────────────

  int get todayActivitiesCount => todayTimeline2
      .where((e) => e.eventType == ChildEventType.activityCompleted)
      .length;

  int get todayPhotosCount => todayPhotos.length;
  int get todayNotesCount => dailyNotes.length;

  // ── History recap (past-day Hero) ─────────────────────────────────────────────

  int _countEvent(String type) =>
      todayTimeline2.where((e) => e.eventType == type).length;

  int get recapActivities => _countEvent(ChildEventType.activityCompleted);
  int get recapPhotos => todayPhotos.length;
  int get recapNotes => dailyNotes.length;

  int get recapMeals {
    final c = _countEvent(ChildEventType.mealCompleted);
    return c > 0 ? c : _countEvent(ChildEventType.mealStarted);
  }

  int get recapNaps {
    final c = _countEvent(ChildEventType.napCompleted);
    return c > 0 ? c : _countEvent(ChildEventType.napStarted);
  }

  String get recapCheckIn {
    for (final e in todayTimeline2) {
      if (e.eventType == ChildEventType.checkIn) {
        return fmtClockMsSuffix(e.createdAt);
      }
    }
    return '';
  }

  String get recapCheckOut {
    var out = '';
    for (final e in todayTimeline2) {
      if (e.eventType == ChildEventType.checkOut) {
        out = fmtClockMsSuffix(e.createdAt);
      }
    }
    return out;
  }

  bool get hasDayData => todayTimeline2.isNotEmpty || todayPhotos.isNotEmpty;

  String get recapHeadline {
    final first = childName.isNotEmpty ? childName.split(' ').first : 'طفلك';
    return '$first قضى يوم جميل';
  }

  static const _arWeekdays = [
    'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد',
  ];
  static const _arMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  /// Pill label: اليوم / إمبارح / الاثنين ٢٢ يونيو
  String get selectedDateLabel {
    final d = selectedDate.value;
    final now = DateTime.now();
    if (_isSameDay(d, now)) return 'اليوم';
    if (_isSameDay(d, now.subtract(const Duration(days: 1)))) return 'إمبارح';
    return '${_arWeekdays[d.weekday - 1]} ${ar('${d.day}')} ${_arMonths[d.month - 1]}';
  }

  /// Hero header: الاثنين، ٢٢ يونيو
  String get selectedDateFull {
    final d = selectedDate.value;
    return '${_arWeekdays[d.weekday - 1]}، ${ar('${d.day}')} ${_arMonths[d.month - 1]}';
  }

  // ── Holidays ────────────────────────────────────────────────────────────────

  HolidayModel? get _specificHolidayForSelected {
    final key = HolidayService.dateKey(selectedDate.value);
    for (final h in holidayDates) {
      if (h.key == key) return h;
    }
    return null;
  }

  /// Whether the day being viewed is a nursery-wide day off — either an
  /// explicitly-marked date or a recurring weekly weekend day.
  bool get isSelectedDayHoliday =>
      _specificHolidayForSelected != null ||
      weekendDays.contains(selectedDate.value.weekday);

  /// Friendly label for the holiday banner (custom occasion name, or a generic
  /// weekly-weekend / holiday fallback).
  String get holidayLabel {
    final h = _specificHolidayForSelected;
    if (h != null && h.label.trim().isNotEmpty) return h.label.trim();
    if (_specificHolidayForSelected == null &&
        weekendDays.contains(selectedDate.value.weekday)) {
      return 'عطلة أسبوعية';
    }
    return 'إجازة';
  }

  // ── Pickup actions ────────────────────────────────────────────────────────────

  Future<void> requestPickup(String eta) async {
    final nurseryId = _session.nurseryId ?? '';
    final childId = _activeChildId.value;
    final parentId = _session.userId ?? '';

    if (childId.isEmpty || nurseryId.isEmpty) {
      pickupEta.value = eta;
      pickupRequested.value = true;
      pickupStatus.value = 'requested';
      return;
    }

    final model = PickupRequestModel(
      nurseryId: nurseryId,
      branchId: branchId,
      childId: childId,
      parentId: parentId,
      requestedPickupTime: DateTime.now()
          .add(Duration(minutes: _etaToMinutes(eta)))
          .millisecondsSinceEpoch,
      parentNotes: 'سأصل خلال $eta',
      status: 'requested',
    );

    Loader.show();
    final key = await _pickupSvc.createRequest(nurseryId, model);
    Loader.dismiss();

    if (key == null) {
      Loader.showError('common_error'.tr);
      return;
    }

    _activeRequestKey.value = key;
    pickupEta.value = eta;
    pickupRequested.value = true;
    pickupStatus.value = 'requested';

    _requestSub?.cancel();
    _requestSub = _pickupSvc.watchRequest(nurseryId, key).listen((req) {
      if (req == null) return;
      pickupStatus.value = req.status;
      if (req.status == 'completed' ||
          req.status == 'cancelled' ||
          req.status == 'rejected')
        _clearPickupState();
    });
  }

  Future<void> cancelPickup() async {
    final key = _activeRequestKey.value;
    if (key.isNotEmpty) {
      await _pickupSvc.cancelRequest(_session.nurseryId ?? '', key);
    }
    _clearPickupState();
  }

  void _clearPickupState() {
    _requestSub?.cancel();
    pickupRequested.value = false;
    pickupEta.value = '';
    pickupStatus.value = '';
    _activeRequestKey.value = '';
  }

  static int _etaToMinutes(String eta) {
    if (eta.contains('10') || eta.contains('١٠')) return 10;
    if (eta.contains('15') || eta.contains('١٥')) return 15;
    if (eta.contains('20') || eta.contains('٢٠')) return 20;
    if (eta.contains('30') || eta.contains('٣٠')) return 30;
    return 15;
  }

  // ── Homework submission ───────────────────────────────────────────────────────

  Future<void> submitHomework(
    String homeworkId, {
    required SubmittedBy by,
    String? note,
  }) async {
    final nurseryId = _session.nurseryId ?? '';
    final classroomId = _activeClassroomId.value;
    final childId = _activeChildId.value;
    if (nurseryId.isEmpty || childId.isEmpty) return;
    final idx = homework.indexWhere((h) => h.titleKey == homeworkId);
    if (idx != -1) {
      final hw = homework[idx];
      homework[idx] = EduHomework(
        subjectKey: hw.subjectKey,
        titleKey: hw.titleKey,
        displayTitle: hw.displayTitle,
        dueDate: hw.dueDate,
        isCompleted: true,
      );
    }
    await _eduSvc.submitHomework(
      nurseryId: nurseryId,
      classroomId: classroomId,
      homeworkId: homeworkId,
      childId: childId,
      submittedBy: by,
      submittedByUid: _session.currentUser?.uid ?? '',
      note: note,
    );
  }

  void setPeriod(String period) => selectedPeriod.value = period;
}
