import '../../../../../../index/index_main.dart';

/// Bottom sheet listing the nursery's templates so the manager can start a run
/// from one. Also offers a shortcut to manage templates when none exist.
class RunTemplatePickerSheet extends StatelessWidget {
  final List<AssessmentTemplateModel> templates;
  final ValueChanged<AssessmentTemplateModel> onPick;
  final VoidCallback onManageTemplates;

  const RunTemplatePickerSheet({
    super.key,
    required this.templates,
    required this.onPick,
    required this.onManageTemplates,
  });

  static const _accent = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('assessment_run_pick_template'.tr,
                style: context.typography.mdBold
                    .copyWith(color: const Color(0xFF1E293B))),
            const SizedBox(height: 12),
            if (templates.isEmpty)
              _emptyTemplates(context)
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: templates.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _templateTile(context, templates[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _templateTile(BuildContext context, AssessmentTemplateModel t) {
    return GestureDetector(
      onTap: () => onPick(t),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.assignment_rounded, color: _accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title,
                      style: context.typography.smSemiBold
                          .copyWith(color: const Color(0xFF1E293B))),
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (t.subject != null && t.subject!.isNotEmpty) t.subject!,
                      '${t.items.length} ${'assessment_items_unit'.tr}',
                    ].join(' • '),
                    style: context.typography.xsRegular
                        .copyWith(color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_outlined,
                size: 13, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _emptyTemplates(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('assessment_run_no_templates'.tr,
            style: context.typography.smRegular
                .copyWith(color: const Color(0xFF94A3B8))),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onManageTemplates,
          style: OutlinedButton.styleFrom(
            foregroundColor: _accent,
            side: const BorderSide(color: _accent),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text('assessment_run_create_template_first'.tr,
              style: context.typography.smSemiBold.copyWith(color: _accent)),
        ),
      ],
    );
  }
}
