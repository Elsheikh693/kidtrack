import '../../../../../../index/index_main.dart';

/// Editor for a template's list of items (بنود). Owns a [TextEditingController]
/// per item (title + optional description) and reports the current non-empty
/// items through [onChanged] on every edit. Each item keeps a stable id so a
/// child's result can reference it after edits.
class AssessmentItemsEditor extends StatefulWidget {
  final List<AssessmentItem> initial;
  final ValueChanged<List<AssessmentItem>> onChanged;

  const AssessmentItemsEditor({
    super.key,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<AssessmentItemsEditor> createState() => _AssessmentItemsEditorState();
}

class _AssessmentItemsEditorState extends State<AssessmentItemsEditor> {
  final List<_ItemDraft> _drafts = [];

  static const _accent = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    if (widget.initial.isEmpty) {
      _drafts.add(_ItemDraft());
    } else {
      for (final it in widget.initial) {
        _drafts.add(_ItemDraft(
          id: it.id,
          title: it.title,
          description: it.description ?? '',
          skillId: it.skillId,
        ));
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
    final result = <AssessmentItem>[];
    for (var i = 0; i < _drafts.length; i++) {
      final d = _drafts[i];
      final title = d.titleCtrl.text.trim();
      if (title.isEmpty) continue;
      final desc = d.descCtrl.text.trim();
      result.add(AssessmentItem(
        id: d.id,
        title: title,
        description: desc.isEmpty ? null : desc,
        skillId: d.skillId,
        order: i,
      ));
    }
    widget.onChanged(result);
  }

  void _add() {
    setState(() => _drafts.add(_ItemDraft()));
    _emit();
  }

  void _remove(int i) {
    setState(() {
      _drafts[i].dispose();
      _drafts.removeAt(i);
      if (_drafts.isEmpty) _drafts.add(_ItemDraft());
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _drafts.length; i++)
          _ItemCard(
            key: ObjectKey(_drafts[i]),
            index: i,
            draft: _drafts[i],
            onChanged: _emit,
            onRemove: () => _remove(i),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: _add,
            style: TextButton.styleFrom(
              foregroundColor: _accent,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
            label: Text(
              'assessment_item_add'.tr,
              style: context.typography.smMedium.copyWith(color: _accent),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  final int index;
  final _ItemDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _ItemCard({
    super.key,
    required this.index,
    required this.draft,
    required this.onChanged,
    required this.onRemove,
  });

  static const _accent = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: _accent.withValues(alpha: 0.12),
                child: Text('${index + 1}',
                    style: context.typography.smSemiBold
                        .copyWith(color: _accent)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: draft.titleCtrl,
                  onChanged: (_) => onChanged(),
                  textInputAction: TextInputAction.next,
                  style: context.typography.smMedium,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'assessment_item_title_hint'.tr,
                    hintStyle: context.typography.smRegular
                        .copyWith(color: const Color(0xFFCBD5E1)),
                  ),
                ),
              ),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded,
                      size: 18, color: Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 32, end: 4),
            child: TextField(
              controller: draft.descCtrl,
              onChanged: (_) => onChanged(),
              style: context.typography.xsRegular
                  .copyWith(color: const Color(0xFF64748B)),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'assessment_item_desc_hint'.tr,
                hintStyle: context.typography.xsRegular
                    .copyWith(color: const Color(0xFFCBD5E1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mutable editing state for one item.
class _ItemDraft {
  final String id;
  final String? skillId;
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;

  _ItemDraft({
    String? id,
    this.skillId,
    String title = '',
    String description = '',
  })  : id = id ?? 'item_${DateTime.now().microsecondsSinceEpoch}',
        titleCtrl = TextEditingController(text: title),
        descCtrl = TextEditingController(text: description);

  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
  }
}
