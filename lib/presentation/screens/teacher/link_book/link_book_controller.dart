import '../../../../index/index_main.dart';

// ─── Derived data models ────────────────────────────────────────────────────

class ChildDailySummary {
  final ChildModel child;
  final List<ClassroomActivityModel> allActivities;
  final List<ClassroomActivityModel> participated;
  final List<String> skills;
  final List<LbStrength> strengths;
  final List<LbFocusArea> focusAreas;
  final List<String> achievements;
  final double engagementScore;
  final String heroText;
  final String avgRatingLabel;
  final double avgRatingValue;
  final String? bestActivityTitle;
  final List<String> autoInsights;
  final List<String> allPhotoUrls;

  const ChildDailySummary({
    required this.child,
    required this.allActivities,
    required this.participated,
    required this.skills,
    required this.strengths,
  required this.focusAreas,
    required this.achievements,
    required this.engagementScore,
    required this.heroText,
    required this.avgRatingLabel,
    required this.avgRatingValue,
    required this.bestActivityTitle,
    required this.autoInsights,
    required this.allPhotoUrls,
  });
}

class LbStrength {
  final String label;
  final IconData icon;
  final Color color;
  const LbStrength(this.label, this.icon, this.color);
}

class LbFocusArea {
  final String label;
  final String parentLabel;
  final IconData icon;
  const LbFocusArea(this.label, this.parentLabel, this.icon);
}

// ─── Trend data ─────────────────────────────────────────────────────────────

class DayTrend {
  final DateTime date;
  final double avgRating;
  final double participationRate;
  DayTrend(this.date, this.avgRating, this.participationRate);
}

// ─── Controller ─────────────────────────────────────────────────────────────

class LinkBookController extends GetxController {
  final _service = Get.find<TeacherActivityService>();

  // ── State ────────────────────────────────────────────────────────────────

  final selectedDate = Rx<DateTime>(DateTime.now());
  final classrooms = <ClassroomModel>[].obs;
  final selectedClassroomId = RxnString();
  final children = <ChildModel>[].obs;
  final selectedChildId = RxnString();

  final activities = <ClassroomActivityModel>[].obs;
  final trendActivities = <ClassroomActivityModel>[].obs;
  final isLoading = false.obs;
  final isLoadingTrend = false.obs;
  final isLoadingClassrooms = true.obs;

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get _nurseryId => SessionService().nurseryId ?? '';
  String get _teacherId => SessionService().userId ?? '';

  bool get isChildMode => selectedChildId.value != null;
  bool get hasClassroom => selectedClassroomId.value != null;

  ClassroomModel? get selectedClassroom =>
      classrooms.firstWhereOrNull((c) => c.key == selectedClassroomId.value);

  ChildModel? get selectedChild =>
      children.firstWhereOrNull((c) => c.key == selectedChildId.value);

  String get formattedDate {
    final d = selectedDate.value;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sel = DateTime(d.year, d.month, d.day);
    if (sel == today) return 'اليوم';
    if (sel == today.subtract(const Duration(days: 1))) return 'أمس';
    return '${d.day}/${d.month}/${d.year}';
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadClassrooms();
  }

  Future<void> _loadClassrooms() async {
    isLoadingClassrooms.value = true;
    final list = await _service.resolveClassrooms(_nurseryId, _teacherId);
    classrooms.value = list;
    if (list.isNotEmpty) {
      selectedClassroomId.value = list.first.key;
      await _loadChildren();
      await _loadActivities();
    }
    isLoadingClassrooms.value = false;
  }

  Future<void> _loadChildren() async {
    final cid = selectedClassroomId.value;
    if (cid == null) return;
    final list = await _service.loadChildren(_nurseryId, cid);
    children.value = list;
    selectedChildId.value = null;
  }

  Future<void> _loadActivities() async {
    final cid = selectedClassroomId.value;
    if (cid == null) return;
    isLoading.value = true;
    try {
      final d = selectedDate.value;
      final start = DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
      final end =
          DateTime(d.year, d.month, d.day, 23, 59, 59).millisecondsSinceEpoch;
      final list = await _service.getCompletedForDateRange(
        _nurseryId,
        cid,
        startMs: start,
        endMs: end,
      );
      activities.value = list;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadTrend() async {
    final cid = selectedClassroomId.value;
    if (cid == null) return;
    isLoadingTrend.value = true;
    try {
      final now = DateTime.now();
      final start =
          DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6)).millisecondsSinceEpoch;
      final end =
          DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;
      final list = await _service.getCompletedForDateRange(
        _nurseryId,
        cid,
        startMs: start,
        endMs: end,
      );
      trendActivities.value = list;
    } finally {
      isLoadingTrend.value = false;
    }
  }

  // ── User interactions ─────────────────────────────────────────────────────

  Future<void> selectDate(DateTime date) async {
    selectedDate.value = date;
    await _loadActivities();
    if (isChildMode) await _loadTrend();
  }

  Future<void> selectClassroom(String? classroomId) async {
    if (selectedClassroomId.value == classroomId) return;
    selectedClassroomId.value = classroomId;
    await _loadChildren();
    await _loadActivities();
  }

  Future<void> selectChild(String? childId) async {
    selectedChildId.value = childId;
    if (childId != null && trendActivities.isEmpty) await _loadTrend();
  }

  Future<void> reload() async {
    await _loadActivities();
    if (isChildMode) await _loadTrend();
  }

  // ── Classroom report ──────────────────────────────────────────────────────

  int get totalActivities => activities.length;

  int get totalEvaluations =>
      activities.fold(0, (acc, a) => acc + a.evaluations.length);

  int get participatingStudents {
    final ids = <String>{};
    for (final a in activities) {
      ids.addAll(a.childIds);
    }
    return ids.length;
  }

  double get averageRating {
    final evals = activities
        .expand((a) => a.evaluations.values)
        .map((v) => _evalScore(v))
        .toList();
    if (evals.isEmpty) return 0;
    return evals.reduce((a, b) => a + b) / evals.length;
  }

  double _evalScore(String key) {
    switch (key) {
      case 'excellent':
        return 5;
      case 'needs_follow':
        return 3;
      case 'needs_attention':
        return 1;
      default:
        return 3;
    }
  }

  String get averageRatingLabel => _ratingLabel(averageRating);

  // ── Child daily summary ───────────────────────────────────────────────────

  ChildDailySummary buildChildSummary() {
    final child = selectedChild!;
    final childId = child.key!;
    final participated =
        activities.where((a) => a.childIds.contains(childId)).toList();

    final evals = participated
        .map((a) => a.evalFor(childId))
        .whereType<EvalLevel>()
        .toList();
    final avgScore = evals.isEmpty
        ? 0.0
        : evals.map(_evalLevelScore).reduce((a, b) => a + b) / evals.length;

    final engagement = activities.isEmpty
        ? 0.0
        : (participated.length / activities.length) * 100;

    final bestAct = participated.isEmpty
        ? null
        : participated.reduce(
            (best, a) {
              final bScore = _evalLevelScore(a.evalFor(childId));
              final aScore = _evalLevelScore(best.evalFor(childId));
              return bScore > aScore ? a : best;
            },
          );

    final skills = _computeSkills(participated);
    final strengths = _computeStrengths(child, participated, evals);
    final focusAreas = _computeFocusAreas(child, participated, evals, activities);
    final achievements = _computeAchievements(childId, participated, activities, evals);
    final heroText = _generateHeroText(child, participated, avgScore);
    final insights = _generateInsights(child, participated, activities, evals, avgScore);
    final photos = participated
        .expand((a) => a.allPhotoUrls)
        .toList();

    return ChildDailySummary(
      child: child,
      allActivities: activities,
      participated: participated,
      skills: skills,
      strengths: strengths,
      focusAreas: focusAreas,
      achievements: achievements,
      engagementScore: engagement,
      heroText: heroText,
      avgRatingLabel: _ratingLabel(avgScore),
      avgRatingValue: avgScore,
      bestActivityTitle: bestAct?.title,
      autoInsights: insights,
      allPhotoUrls: photos,
    );
  }

  // ── 7-day trend ───────────────────────────────────────────────────────────

  List<DayTrend> buildTrend(String childId) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      final dayStart = day.millisecondsSinceEpoch;
      final dayEnd =
          DateTime(day.year, day.month, day.day, 23, 59, 59).millisecondsSinceEpoch;
      final dayActs = trendActivities
          .where((a) => a.startedAt >= dayStart && a.startedAt <= dayEnd)
          .toList();
      final participated =
          dayActs.where((a) => a.childIds.contains(childId)).toList();
      final evals = participated
          .map((a) => a.evalFor(childId))
          .whereType<EvalLevel>()
          .map(_evalLevelScore)
          .toList();
      final avg = evals.isEmpty
          ? 0.0
          : evals.reduce((a, b) => a + b) / evals.length;
      final partRate =
          dayActs.isEmpty ? 0.0 : participated.length / dayActs.length;
      return DayTrend(day, avg, partRate);
    });
  }

  String trendLabel(List<DayTrend> trend) {
    if (trend.length < 3) return 'مستقر';
    final recent = trend.skip(trend.length - 3).map((t) => t.avgRating).toList();
    final older = trend.take(trend.length - 3).map((t) => t.avgRating).toList();
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.isEmpty ? recentAvg : older.reduce((a, b) => a + b) / older.length;
    if (recentAvg > olderAvg + 0.3) return 'تحسن';
    if (recentAvg < olderAvg - 0.3) return 'يحتاج متابعة';
    return 'مستقر';
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static double _evalLevelScore(EvalLevel? level) {
    switch (level) {
      case EvalLevel.excellent:
        return 5;
      case EvalLevel.needsFollow:
        return 3;
      case EvalLevel.needsAttention:
        return 1;
      default:
        return 0;
    }
  }

  static const Map<String, List<String>> _subjectSkills = {
    'english': ['المفردات', 'الاستماع', 'التواصل'],
    'إنجليز': ['المفردات', 'الاستماع', 'التواصل'],
    'لغة إنجليز': ['المفردات', 'الاستماع', 'التواصل'],
    'عربي': ['القراءة', 'الكتابة', 'التعبير'],
    'اللغة العرب': ['القراءة', 'الكتابة', 'التعبير'],
    'رياضيات': ['العد', 'حل المشكلات', 'التفكير المنطقي'],
    'math': ['العد', 'حل المشكلات', 'التفكير المنطقي'],
    'فن': ['الإبداع', 'المهارات الحركية الدقيقة', 'التعبير البصري'],
    'رسم': ['الإبداع', 'المهارات الحركية الدقيقة', 'التعبير البصري'],
    'art': ['الإبداع', 'المهارات الحركية الدقيقة', 'التعبير البصري'],
    'علوم': ['الاستكشاف', 'الملاحظة', 'التساؤل'],
    'science': ['الاستكشاف', 'الملاحظة', 'التساؤل'],
    'موسيقى': ['الإيقاع', 'الاستماع الموسيقي', 'التعبير الفني'],
    'رياضة': ['اللياقة', 'التعاون', 'التنسيق'],
    'قرآن': ['الحفظ', 'التلاوة', 'الأخلاق'],
  };

  static const List<String> _defaultSkills = ['المشاركة', 'التركيز', 'التعاون'];

  List<String> _computeSkills(List<ClassroomActivityModel> participated) {
    final skills = <String>{};
    for (final a in participated) {
      final subject = (a.subjectName ?? a.title).toLowerCase();
      String? matched;
      for (final key in _subjectSkills.keys) {
        if (subject.contains(key.toLowerCase())) {
          matched = key;
          break;
        }
      }
      final list = matched != null ? _subjectSkills[matched]! : _defaultSkills;
      skills.addAll(list);
    }
    return skills.toList();
  }

  List<LbStrength> _computeStrengths(
    ChildModel child,
    List<ClassroomActivityModel> participated,
    List<EvalLevel> evals,
  ) {
    final strengths = <LbStrength>[];
    final excellentCount = evals.where((e) => e == EvalLevel.excellent).length;
    if (excellentCount > 0) {
      strengths.add(LbStrength(
        'مشاركة ممتازة',
        Icons.star_rounded,
        const Color(0xFFD97706),
      ));
    }
    if (participated.length >= 2) {
      strengths.add(LbStrength(
        'تعلم نشط',
        Icons.bolt_rounded,
        const Color(0xFF7C3AED),
      ));
    }
    for (final a in participated) {
      final eval = a.evalFor(child.key!);
      if (eval != EvalLevel.excellent) continue;
      final sub = (a.subjectName ?? '').toLowerCase();
      if (sub.contains('إنجليز') || sub.contains('english') || sub.contains('لغة')) {
        if (!strengths.any((LbStrength s) => s.label == 'تميز لغوي')) {
          strengths.add(LbStrength('تميز لغوي', Icons.record_voice_over_rounded, const Color(0xFF059669)));
        }
      }
      if (sub.contains('فن') || sub.contains('رسم') || sub.contains('art')) {
        if (!strengths.any((LbStrength s) => s.label == 'إبداع فني')) {
          strengths.add(LbStrength('إبداع فني', Icons.palette_rounded, const Color(0xFFEC4899)));
        }
      }
      if (sub.contains('رياضيات') || sub.contains('math')) {
        if (!strengths.any((LbStrength s) => s.label == 'تفكير رياضي')) {
          strengths.add(LbStrength('تفكير رياضي', Icons.calculate_rounded, const Color(0xFF2563EB)));
        }
      }
    }
    if (strengths.isEmpty && participated.isNotEmpty) {
      strengths.add(LbStrength('حضور منتظم', Icons.check_circle_rounded, const Color(0xFF16A34A)));
    }
    return strengths;
  }

  List<LbFocusArea> _computeFocusAreas(
    ChildModel child,
    List<ClassroomActivityModel> participated,
    List<EvalLevel> evals,
    List<ClassroomActivityModel> allActivities,
  ) {
    final focus = <LbFocusArea>[];
    if (participated.length < allActivities.length && allActivities.isNotEmpty) {
      focus.add(LbFocusArea('المشاركة في جميع الأنشطة', 'تشجيع المشاركة', Icons.group_rounded));
    }
    final attentionActivities = participated.where((a) => a.evalFor(child.key!) == EvalLevel.needsAttention).toList();
    for (final a in attentionActivities) {
      final sub = a.subjectName ?? a.title;
      focus.add(LbFocusArea(sub, 'يحتاج دعم إضافي', Icons.support_rounded));
    }
    return focus.take(2).toList();
  }

  List<String> _computeAchievements(
    String childId,
    List<ClassroomActivityModel> participated,
    List<ClassroomActivityModel> allActivities,
    List<EvalLevel> evals,
  ) {
    final badges = <String>[];
    if (participated.length == allActivities.length && allActivities.isNotEmpty) {
      badges.add('مشاركة مثالية');
    }
    final excellentCount = evals.where((e) => e == EvalLevel.excellent).length;
    if (excellentCount == evals.length && evals.isNotEmpty) {
      badges.add('نجم اليوم');
    }
    if (participated.length >= 2) badges.add('متعلم نشيط');
    for (final a in participated) {
      final eval = a.evalFor(childId);
      if (eval != EvalLevel.excellent) continue;
      final sub = (a.subjectName ?? '').toLowerCase();
      if ((sub.contains('إنجليز') || sub.contains('english')) && !badges.contains('نجم اللغة')) {
        badges.add('نجم اللغة');
      }
      if ((sub.contains('فن') || sub.contains('رسم') || sub.contains('art')) && !badges.contains('فنان مبدع')) {
        badges.add('فنان مبدع');
      }
      if ((sub.contains('رياضيات') || sub.contains('math')) && !badges.contains('عبقري الأرقام')) {
        badges.add('عبقري الأرقام');
      }
    }
    return badges;
  }

  String _generateHeroText(
    ChildModel child,
    List<ClassroomActivityModel> participated,
    double avgScore,
  ) {
    final name = child.firstName;
    if (participated.isEmpty) return '$name لم يشارك في أنشطة اليوم.';
    final count = participated.length;
    final mood = avgScore >= 4
        ? 'يوماً رائعاً'
        : avgScore >= 2.5
            ? 'يوماً جيداً'
            : 'يوماً في الحضانة';
    final word = count == 1 ? 'نشاط واحد' : '$count أنشطة';
    final best = participated.firstWhereOrNull(
      (a) => a.evalFor(child.key!) == EvalLevel.excellent,
    );
    final subjectMention =
        best?.subjectName != null ? ' وتميّز في ${best!.subjectName}' : '';
    return '$name قضى $mood. شارك في $word$subjectMention.';
  }

  List<String> _generateInsights(
    ChildModel child,
    List<ClassroomActivityModel> participated,
    List<ClassroomActivityModel> allActivities,
    List<EvalLevel> evals,
    double avgScore,
  ) {
    final name = child.firstName;
    final insights = <String>[];
    if (participated.length == allActivities.length && allActivities.isNotEmpty) {
      insights.add('$name شارك في جميع أنشطة اليوم.');
    } else if (participated.isEmpty) {
      insights.add('$name لم يشارك في أنشطة اليوم.');
    } else {
      insights.add('$name شارك في ${participated.length} من أصل ${allActivities.length} أنشطة.');
    }
    if (avgScore >= 4) {
      insights.add('أظهر ${child.firstName} أداءً ممتازاً خلال اليوم.');
    } else if (avgScore >= 2.5) {
      insights.add('يُبدي ${child.firstName} أداءً جيداً مع مجال للتحسين.');
    }
    for (final a in participated) {
      final eval = a.evalFor(child.key!);
      if (eval == EvalLevel.excellent && a.subjectName != null) {
        insights.add('أبدع ${child.firstName} في ${a.subjectName}.');
        break;
      }
    }
    final attention = participated.where((a) => a.evalFor(child.key!) == EvalLevel.needsAttention).toList();
    if (attention.isNotEmpty) {
      final sub = attention.first.subjectName ?? attention.first.title;
      insights.add('يحتاج ${child.firstName} دعماً إضافياً في $sub.');
    }
    return insights;
  }

  static String _ratingLabel(double score) {
    if (score >= 4.5) return 'ممتاز';
    if (score >= 3.5) return 'جيد جداً';
    if (score >= 2.5) return 'جيد';
    if (score >= 1.5) return 'مقبول';
    if (score > 0) return 'يحتاج دعم';
    return '—';
  }
}
