import '../../../../../index/index_main.dart';
import '../activity_end_controller.dart';

class EndCommentSheet extends StatefulWidget {
  const EndCommentSheet({
    super.key,
    required this.child,
    required this.endCtrl,
  });
  final ChildModel child;
  final ActivityEndController endCtrl;

  @override
  State<EndCommentSheet> createState() => _EndCommentSheetState();
}

class _EndCommentSheetState extends State<EndCommentSheet> {
  late List<String> _selected;
  bool _showCustomField = false;
  final _customCtrl = TextEditingController();
  bool _addingCustom = false;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(
      widget.endCtrl.getChildReasons(widget.child.key ?? ''),
    );
    widget.endCtrl.refreshReasons();
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _toggle(String title) {
    setState(() {
      if (_selected.contains(title)) {
        _selected.remove(title);
      } else {
        _selected.add(title);
      }
    });
  }

  Future<void> _addCustomReason() async {
    final text = _customCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _addingCustom = true);
    await widget.endCtrl.addNewReason(widget.child.key ?? '', text);
    setState(() {
      if (!_selected.contains(text)) _selected.add(text);
      _customCtrl.clear();
      _showCustomField = false;
      _addingCustom = false;
    });
  }

  void _save() {
    final childId = widget.child.key ?? '';
    // Sync selected list back to controller
    final current = List<String>.from(widget.endCtrl.childReasons[childId] ?? []);
    // Remove deselected
    for (final r in List.from(current)) {
      if (!_selected.contains(r)) {
        widget.endCtrl.toggleReason(childId, r);
      }
    }
    // Add newly selected
    for (final r in _selected) {
      if (!current.contains(r)) {
        widget.endCtrl.toggleReason(childId, r);
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.activityPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.label_rounded,
                    color: AppColors.activityPurple,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'eval_reasons_sheet_title'.tr,
                        style: context.typography.smSemiBold
                            .copyWith(color: AppColors.textDisplay),
                      ),
                      Text(
                        widget.child.firstName,
                        style: context.typography.xsRegular
                            .copyWith(color: AppColors.textSecondaryParagraph),
                      ),
                    ],
                  ),
                ),
                // Navigate to manage reasons
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.toNamed(evaluationReasonsView);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      size: 22,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Reasons chips — scrollable
          Flexible(
            child: Obx(() {
              final activeReasons = widget.endCtrl.reasons
                  .where((r) => r.isActive)
                  .toList();
              if (widget.endCtrl.isLoadingReasons.value) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activeReasons.isEmpty && _selected.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'eval_reasons_empty_hint'.tr,
                            style: context.typography.xsMedium
                                .copyWith(color: Colors.grey.shade400),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else ...[
                      // Show all active + any selected custom reasons not in list
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Active library reasons
                          ...activeReasons.map((r) => _ReasonChip(
                                label: r.title,
                                isSelected: _selected.contains(r.title),
                                onTap: () => _toggle(r.title),
                              )),
                          // Custom reasons typed this session that aren't in library yet
                          ..._selected
                              .where((t) => !activeReasons
                                  .any((r) => r.title == t))
                              .map((t) => _ReasonChip(
                                    label: t,
                                    isSelected: true,
                                    onTap: () => _toggle(t),
                                    isCustom: true,
                                  )),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Custom reason input
                    if (_showCustomField) ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customCtrl,
                              textDirection: appTextDirection,
                              autofocus: true,
                              maxLength: 60,
                              decoration: InputDecoration(
                                hintText: 'eval_reasons_custom_hint'.tr,
                                hintTextDirection: TextDirection.rtl,
                                filled: true,
                                fillColor: AppColors.backgroundNeutralDefault,
                                counterText: '',
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                      color: AppColors.activityPurple,
                                      width: 1.5),
                                ),
                              ),
                              onSubmitted: (_) => _addCustomReason(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _addingCustom ? null : _addCustomReason,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.activityPurple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _addingCustom
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    // "Add custom" button
                    if (!_showCustomField)
                      GestureDetector(
                        onTap: () => setState(() => _showCustomField = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded,
                                  size: 15, color: Colors.grey.shade500),
                              const SizedBox(width: 6),
                              Text(
                                'eval_reasons_add_custom'.tr,
                                style: context.typography.xsMedium
                                    .copyWith(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                  ],
                ),
              );
            }),
          ),
          // Footer
          Container(
            padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPad + 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selected.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '${'eval_reasons_selected_count'.tr}: ${_selected.length}',
                      style: context.typography.xsMedium
                          .copyWith(color: AppColors.activityPurple),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.activityPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _save,
                    child: Text(
                      _selected.isEmpty
                          ? 'eval_reasons_save_empty'.tr
                          : 'eval_reasons_save'.tr,
                      style: context.typography.smSemiBold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reason Chip ───────────────────────────────────────────────────────────────

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCustom = false,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCustom;

  @override
  Widget build(BuildContext context) {
    final color =
        isCustom ? AppColors.activityAmber : AppColors.activityPurple;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.25),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_rounded, size: 13, color: Colors.white),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: context.typography.xsMedium.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
