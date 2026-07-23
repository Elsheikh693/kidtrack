import '../../../../../../index/index_main.dart';

/// Editor for a template's single grading scale. Two kinds:
///   • rating  → an ordered list of levels (best → worst); fractions are
///     auto-assigned evenly (top = 1.0, bottom = 0.0) so the nursery never
///     types a raw 0-1 number.
///   • numeric → a 0..max slider value.
/// Quick presets fill the common scales in one tap.
class AssessmentScaleEditor extends StatefulWidget {
  final AssessmentScale initial;
  final ValueChanged<AssessmentScale> onChanged;

  const AssessmentScaleEditor({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<AssessmentScaleEditor> createState() => _AssessmentScaleEditorState();
}

class _AssessmentScaleEditorState extends State<AssessmentScaleEditor> {
  static const _accent = Color(0xFF4F46E5);

  String _kind = kScaleKindRating;
  final List<TextEditingController> _levelCtrls = [];
  final _maxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _kind = widget.initial.kind;
    if (widget.initial.levels.isNotEmpty) {
      for (final l in widget.initial.levels) {
        _levelCtrls.add(TextEditingController(text: l.label));
      }
    } else {
      // Sensible default rating scale for a fresh template.
      for (final label in [
        'managerass17_level_excellent'.tr,
        'managerass17_level_good'.tr,
        'managerass17_level_weak'.tr,
      ]) {
        _levelCtrls.add(TextEditingController(text: label));
      }
    }
    _maxCtrl.text = _fmt(widget.initial.numericMax ?? 10);
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  @override
  void dispose() {
    for (final c in _levelCtrls) {
      c.dispose();
    }
    _maxCtrl.dispose();
    super.dispose();
  }

  /// Build the scale from the current inputs and report it up.
  void _emit() {
    if (_kind == kScaleKindNumeric) {
      final max = double.tryParse(_maxCtrl.text.trim()) ?? 10;
      widget.onChanged(AssessmentScale(
        kind: kScaleKindNumeric,
        numericMax: max <= 0 ? 10 : max,
      ));
      return;
    }
    final labels = _levelCtrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    widget.onChanged(AssessmentScale(
      kind: kScaleKindRating,
      levels: buildRatingLevels(labels),
    ));
  }

  /// Evenly distribute fractions over the ordered labels (top = best = 1.0).
  static List<AssessmentScaleLevel> buildRatingLevels(List<String> labels) {
    final n = labels.length;
    return [
      for (var i = 0; i < n; i++)
        AssessmentScaleLevel(
          key: 'lvl_$i',
          label: labels[i],
          fraction: n <= 1 ? 1.0 : (n - 1 - i) / (n - 1),
        ),
    ];
  }

  void _setKind(String kind) {
    setState(() => _kind = kind);
    _emit();
  }

  void _addLevel() {
    setState(() => _levelCtrls.add(TextEditingController()));
    _emit();
  }

  void _removeLevel(int i) {
    setState(() {
      _levelCtrls[i].dispose();
      _levelCtrls.removeAt(i);
      if (_levelCtrls.isEmpty) _levelCtrls.add(TextEditingController());
    });
    _emit();
  }

  void _applyPreset(List<String> labels) {
    setState(() {
      for (final c in _levelCtrls) {
        c.dispose();
      }
      _levelCtrls
        ..clear()
        ..addAll(labels.map((l) => TextEditingController(text: l)));
      _kind = kScaleKindRating;
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _kindChip(context, kScaleKindRating, 'assessment_scale_rating'.tr,
                Icons.star_rounded),
            const SizedBox(width: 10),
            _kindChip(context, kScaleKindNumeric, 'assessment_scale_numeric'.tr,
                Icons.numbers_rounded),
          ],
        ),
        const SizedBox(height: 14),
        if (_kind == kScaleKindRating) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _presetChip(
                  context,
                  'managerass17_preset_three'.tr,
                  () => _applyPreset([
                        'managerass17_level_excellent'.tr,
                        'managerass17_level_good'.tr,
                        'managerass17_level_weak'.tr,
                      ])),
              _presetChip(
                  context,
                  'managerass17_preset_two'.tr,
                  () => _applyPreset([
                        'managerass17_level_pass'.tr,
                        'managerass17_level_fail'.tr,
                      ])),
              _presetChip(
                  context,
                  'managerass17_preset_four'.tr,
                  () => _applyPreset([
                        'managerass17_level_excellent'.tr,
                        'managerass17_level_very_good'.tr,
                        'managerass17_level_good'.tr,
                        'managerass17_level_weak'.tr,
                      ])),
            ],
          ),
          const SizedBox(height: 14),
          Text('assessment_scale_levels_hint'.tr,
              style: context.typography.xsRegular
                  .copyWith(color: const Color(0xFF94A3B8))),
          const SizedBox(height: 8),
          for (int i = 0; i < _levelCtrls.length; i++)
            _levelRow(context, i),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: _addLevel,
              style: TextButton.styleFrom(foregroundColor: _accent),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: Text('assessment_scale_add_level'.tr,
                  style: context.typography.smMedium.copyWith(color: _accent)),
            ),
          ),
        ] else
          _numericField(context),
      ],
    );
  }

  Widget _kindChip(
      BuildContext context, String kind, String label, IconData icon) {
    final selected = _kind == kind;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setKind(kind),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? _accent.withValues(alpha: 0.08)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _accent : const Color(0xFFE2E8F0),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: selected ? _accent : const Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(label,
                  style: context.typography.smSemiBold.copyWith(
                      color:
                          selected ? _accent : const Color(0xFF334155))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _presetChip(BuildContext context, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(label,
            style: context.typography.xsMedium
                .copyWith(color: const Color(0xFF475569))),
      ),
    );
  }

  Widget _levelRow(BuildContext context, int i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 22,
            alignment: Alignment.center,
            child: Text('${i + 1}',
                style: context.typography.smSemiBold
                    .copyWith(color: const Color(0xFF94A3B8))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _levelCtrls[i],
                onChanged: (_) => _emit(),
                style: context.typography.smMedium,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'assessment_scale_level_hint'.tr,
                  hintStyle: context.typography.smRegular
                      .copyWith(color: const Color(0xFFCBD5E1)),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () => _removeLevel(i),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded,
                  size: 18, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numericField(BuildContext context) {
    return Row(
      children: [
        Text('assessment_scale_max_label'.tr,
            style: context.typography.smMedium
                .copyWith(color: const Color(0xFF374151))),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _maxCtrl,
              onChanged: (_) => _emit(),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: context.typography.smSemiBold,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}
