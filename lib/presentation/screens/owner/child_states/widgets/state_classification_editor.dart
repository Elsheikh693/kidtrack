import '../../../../../index/index_main.dart';

/// Editor for a child-state template's 2-level classification.
///
/// Owns all [TextEditingController]s for the options and their sub-options and
/// reports the current (non-empty) options through [onChanged] on every edit.
class StateClassificationEditor extends StatefulWidget {
  final List<ChildStateOption> initial;
  final ValueChanged<List<ChildStateOption>> onChanged;

  const StateClassificationEditor({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<StateClassificationEditor> createState() =>
      _StateClassificationEditorState();
}

class _StateClassificationEditorState extends State<StateClassificationEditor> {
  final List<_OptionDraft> _drafts = [];

  static const _accent = Color(0xFF0891B2);

  @override
  void initState() {
    super.initState();
    if (widget.initial.isEmpty) {
      _drafts.add(_OptionDraft());
    } else {
      for (final o in widget.initial) {
        _drafts.add(_OptionDraft(label: o.label, subs: o.subOptions));
      }
    }
  }

  @override
  void dispose() {
    for (final d in _drafts) {
      d.dispose();
    }
    super.dispose();
  }

  void _emit() {
    final result = <ChildStateOption>[];
    for (final d in _drafts) {
      final label = d.labelCtrl.text.trim();
      if (label.isEmpty) continue;
      final subs = d.subCtrls
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      result.add(ChildStateOption(label: label, subOptions: subs));
    }
    widget.onChanged(result);
  }

  void _addOption() {
    setState(() => _drafts.add(_OptionDraft()));
    _emit();
  }

  void _removeOption(int i) {
    setState(() {
      _drafts[i].dispose();
      _drafts.removeAt(i);
      if (_drafts.isEmpty) _drafts.add(_OptionDraft());
    });
    _emit();
  }

  void _addSub(int i) {
    setState(() => _drafts[i].subCtrls.add(TextEditingController()));
    _emit();
  }

  void _removeSub(int i, int j) {
    setState(() {
      _drafts[i].subCtrls[j].dispose();
      _drafts[i].subCtrls.removeAt(j);
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _drafts.length; i++)
          StateOptionEditorCard(
            key: ObjectKey(_drafts[i]),
            labelController: _drafts[i].labelCtrl,
            subControllers: _drafts[i].subCtrls,
            onChanged: _emit,
            onRemove: () => _removeOption(i),
            onAddSub: () => _addSub(i),
            onRemoveSub: (j) => _removeSub(i, j),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: _addOption,
            style: TextButton.styleFrom(
              foregroundColor: _accent,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
            label: Text(
              'child_state_add_option'.tr,
              style: context.typography.smMedium.copyWith(color: _accent),
            ),
          ),
        ),
      ],
    );
  }
}

/// Mutable editing state for a single option and its sub-options.
class _OptionDraft {
  final TextEditingController labelCtrl;
  final List<TextEditingController> subCtrls;

  _OptionDraft({String label = '', List<String> subs = const []})
      : labelCtrl = TextEditingController(text: label),
        subCtrls =
            subs.map((s) => TextEditingController(text: s)).toList();

  void dispose() {
    labelCtrl.dispose();
    for (final c in subCtrls) {
      c.dispose();
    }
  }
}
