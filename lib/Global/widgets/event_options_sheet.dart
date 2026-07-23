import '../../index/index_main.dart';

/// Bottom sheet that asks which option to log for an EVENT that carries a
/// classification tree (e.g. الأكل → كله / النص / الربع / لم يأكل). Tapping a
/// leaf calls [onPick] with the composed title ("الأكل — النص") and closes.
/// Only shown for events whose template has options; simple events log directly.
Future<void> showEventOptionsSheet({
  required BuildContext context,
  required ChildStateTemplateModel template,
  required void Function(String composedTitle) onPick,
}) {
  return Get.bottomSheet(
    _EventOptionsSheet(template: template, onPick: onPick),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}

class _EventOptionsSheet extends StatelessWidget {
  const _EventOptionsSheet({required this.template, required this.onPick});

  final ChildStateTemplateModel template;
  final void Function(String composedTitle) onPick;

  static const _accent = Color(0xFF0891B2);

  void _pick(String leaf) {
    Get.back();
    onPick('${template.title} — $leaf');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(ChildStateIcons.iconFor(template.icon),
                        color: _accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      template.title,
                      style: context.typography.lgBold
                          .copyWith(color: const Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (final opt in template.options)
                if (opt.subOptions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _leaf(context, opt.label, full: true),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Text(
                      opt.label,
                      style: context.typography.xsMedium
                          .copyWith(color: const Color(0xFF94A3B8)),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final sub in opt.subOptions) _leaf(context, sub),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _leaf(BuildContext context, String label, {bool full = false}) {
    return GestureDetector(
      onTap: () => _pick(label),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: full ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignment: full ? Alignment.centerRight : null,
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _accent.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: context.typography.smSemiBold.copyWith(color: _accent),
        ),
      ),
    );
  }
}
