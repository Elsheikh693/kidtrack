import '../../../../index/index_main.dart';

class EvaluationReasonsView extends StatelessWidget {
  const EvaluationReasonsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EvaluationReasonsController>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutralDefault,
        appBar: AppBar(
          title: Text(
            'eval_reasons_screen_title'.tr,
            style: context.typography.displaySmBold
                .copyWith(color: AppColors.textDisplay),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          foregroundColor: AppColors.textDisplay,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.grey.shade100),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddSheet(context, ctrl),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text('eval_reasons_add'.tr),
          elevation: 2,
        ),
        body: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(strokeWidth: 2));
          }
          if (ctrl.reasons.isEmpty) {
            return _EmptyState(onAdd: () => _showAddSheet(context, ctrl));
          }
          return RefreshIndicator(
            onRefresh: ctrl.refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: ctrl.reasons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ReasonTile(
                reason: ctrl.reasons[i],
                ctrl: ctrl,
                onEdit: () => _showEditSheet(context, ctrl, ctrl.reasons[i]),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showAddSheet(BuildContext context, EvaluationReasonsController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: _ReasonFormSheet(
          title: 'eval_reasons_add_title'.tr,
          onSave: (v) => ctrl.addReason(v),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, EvaluationReasonsController ctrl,
      EvaluationReasonModel reason) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: _ReasonFormSheet(
          title: 'eval_reasons_edit_title'.tr,
          initialValue: reason.title,
          onSave: (v) => ctrl.updateTitle(reason, v),
        ),
      ),
    );
  }
}

// ── Reason Tile ───────────────────────────────────────────────────────────────

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.reason,
    required this.ctrl,
    required this.onEdit,
  });
  final EvaluationReasonModel reason;
  final EvaluationReasonsController ctrl;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: reason.isActive
                ? AppColors.activityGreen.withValues(alpha: 0.08)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.label_rounded,
            size: 16,
            color: reason.isActive
                ? AppColors.activityGreen
                : Colors.grey.shade400,
          ),
        ),
        title: Text(
          reason.title,
          style: context.typography.smMedium.copyWith(
            color: reason.isActive
                ? AppColors.textDisplay
                : Colors.grey.shade400,
            decoration:
                reason.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: reason.isActive
            ? null
            : Text(
                'eval_reasons_disabled'.tr,
                style: context.typography.xsRegular
                    .copyWith(color: Colors.grey.shade400),
              ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded,
              color: Colors.grey.shade400, size: 20),
          onSelected: (action) {
            if (action == 'edit') onEdit();
            if (action == 'toggle') ctrl.toggleActive(reason);
            if (action == 'delete') _confirmDelete(context);
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('eval_reasons_action_edit'.tr),
              ]),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(children: [
                Icon(
                  reason.isActive
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 16,
                  color: AppColors.activityAmber,
                ),
                const SizedBox(width: 8),
                Text(reason.isActive
                    ? 'eval_reasons_action_disable'.tr
                    : 'eval_reasons_action_enable'.tr),
              ]),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                const Icon(Icons.delete_rounded,
                    size: 16, color: AppColors.activityRed),
                const SizedBox(width: 8),
                Text('eval_reasons_action_delete'.tr,
                    style:
                        const TextStyle(color: AppColors.activityRed)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('eval_reasons_delete_title'.tr),
          content: Text(
            '${'eval_reasons_delete_body'.tr} "${reason.title}"؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ctrl.delete(reason);
              },
              child: Text(
                'delete'.tr,
                style: const TextStyle(color: AppColors.activityRed),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form Sheet (Add / Edit) ───────────────────────────────────────────────────

class _ReasonFormSheet extends StatefulWidget {
  const _ReasonFormSheet({
    required this.title,
    this.initialValue = '',
    required this.onSave,
  });
  final String title;
  final String initialValue;
  final Future<void> Function(String) onSave;

  @override
  State<_ReasonFormSheet> createState() => _ReasonFormSheetState();
}

class _ReasonFormSheetState extends State<_ReasonFormSheet> {
  late final TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await widget.onSave(_ctrl.text.trim());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textDisplay),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            textDirection: TextDirection.rtl,
            autofocus: true,
            maxLength: 60,
            decoration: InputDecoration(
              hintText: 'eval_reasons_hint'.tr,
              hintTextDirection: TextDirection.rtl,
              filled: true,
              fillColor: AppColors.backgroundNeutralDefault,
              counterText: '',
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text('eval_reasons_save'.tr,
                      style: context.typography.smSemiBold),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.label_off_rounded,
                  size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'eval_reasons_empty_title'.tr,
              style: context.typography.smSemiBold
                  .copyWith(color: AppColors.textDisplay),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'eval_reasons_empty_body'.tr,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('eval_reasons_add'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
