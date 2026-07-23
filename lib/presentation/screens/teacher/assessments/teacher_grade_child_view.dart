import '../../../../index/index_main.dart';
import 'widgets/item_grade_row.dart';

/// Grades one child against the run's items: pick a value + note per item, plus
/// an overall note. Shows a live total and saves the attempt on submit.
class TeacherGradeChildView extends StatefulWidget {
  final String childId;
  const TeacherGradeChildView({super.key, required this.childId});

  @override
  State<TeacherGradeChildView> createState() => _TeacherGradeChildViewState();
}

class _TeacherGradeChildViewState extends State<TeacherGradeChildView> {
  late final TeacherRunGradingController controller;

  final Map<String, String?> _values = {};
  final Map<String, TextEditingController> _notes = {};
  final _overallNote = TextEditingController();

  /// The items this session grades — all of them normally, or just the scoped
  /// subset during a retake.
  late final List<AssessmentItem> _items;
  bool _isRetake = false;

  static const _accent = Color(0xFF4F46E5);

  AssessmentRunModel get _run => controller.run.value!;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TeacherRunGradingController>();
    final row = controller.rowForChild(widget.childId);
    final schedule = row?.latestAttempt;
    _isRetake = schedule?.hasScheduledRetake ?? false;

    if (_isRetake) {
      // A retake grades only the scoped items, fresh (a new attempt).
      final scoped = schedule!.scheduledRetakeItemIds.toSet();
      _items = _run.items.where((i) => scoped.contains(i.id)).toList();
      for (final item in _items) {
        _values[item.id] = null;
        _notes[item.id] = TextEditingController();
      }
    } else {
      // Preload an existing attempt so re-grading edits rather than resets.
      _items = _run.items;
      final existing = row?.officialAttempt;
      final byItem = <String, AssessmentItemResult>{
        for (final r in existing?.results ?? const []) r.itemId: r,
      };
      for (final item in _items) {
        _values[item.id] = byItem[item.id]?.rawValue;
        _notes[item.id] =
            TextEditingController(text: byItem[item.id]?.note ?? '');
      }
      _overallNote.text = existing?.overallNote ?? '';
    }
  }

  @override
  void dispose() {
    for (final c in _notes.values) {
      c.dispose();
    }
    _overallNote.dispose();
    super.dispose();
  }

  double? get _liveTotal {
    final fractions = <double>[];
    final weights = <double>[];
    for (final item in _items) {
      final raw = _values[item.id];
      final f = raw == null ? null : _run.scale.fractionFor(raw);
      if (f == null) continue;
      fractions.add(f * item.weight);
      weights.add(item.weight);
    }
    final wSum = weights.fold<double>(0, (a, b) => a + b);
    if (wSum == 0) return null;
    return fractions.fold<double>(0, (a, b) => a + b) / wSum;
  }

  int get _gradedCount =>
      _items.where((i) => _values[i.id] != null).length;

  void _submit() {
    if (_gradedCount < _items.length) {
      Loader.showError('assessment_grade_incomplete'.tr);
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final uid = controller.uid;
    final results = <AssessmentItemResult>[];
    for (final item in _items) {
      final raw = _values[item.id];
      final note = _notes[item.id]?.text.trim() ?? '';
      results.add(AssessmentItemResult(
        itemId: item.id,
        skillId: item.skillId,
        rawValue: raw,
        fraction: raw == null ? null : _run.scale.fractionFor(raw),
        note: note.isEmpty ? null : note,
        weight: item.weight,
        updatedBy: uid,
        updatedAt: now,
      ));
    }
    controller.saveChild(
      childId: widget.childId,
      results: results,
      overallNote: _overallNote.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = controller.childName(widget.childId);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: name.isEmpty ? 'assessment_grade_title'.tr : name,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            _totalBanner(context),
            const SizedBox(height: 16),
            for (int i = 0; i < _items.length; i++)
              ItemGradeRow(
                item: _items[i],
                index: i,
                scale: _run.scale,
                value: _values[_items[i].id],
                noteController: _notes[_items[i].id]!,
                onValueChanged: (v) =>
                    setState(() => _values[_items[i].id] = v),
              ),
            const SizedBox(height: 8),
            _overallNoteField(context),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('assessment_grade_save'.tr,
                    style: context.typography.smSemiBold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _totalBanner(BuildContext context) {
    final total = _liveTotal;
    final pct = total == null ? null : (total * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('assessment_grade_total'.tr,
                    style: context.typography.xsRegular
                        .copyWith(color: const Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(pct == null ? '—' : '$pct%',
                    style: context.typography.xxlBold
                        .copyWith(color: _accent)),
              ],
            ),
          ),
          Text(
            'assessment_grade_progress'.trParams(
                {'done': '$_gradedCount', 'total': '${_items.length}'}),
            style: context.typography.xsMedium
                .copyWith(color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _overallNoteField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _overallNote,
        maxLines: 3,
        style: context.typography.smRegular,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: 'assessment_overall_note_hint'.tr,
          hintStyle: context.typography.smRegular
              .copyWith(color: const Color(0xFFCBD5E1)),
        ),
      ),
    );
  }
}
