import '../../../../../index/index_main.dart';

/// Sticky-ish day label separating groups of guardian notes in the inbox.
class ParentNotesDayHeader extends StatelessWidget {
  const ParentNotesDayHeader({
    super.key,
    required this.date,
    required this.count,
  });

  final DateTime date;
  final int count;

  static const _accent = Color(0xFF6C4DDB);
  List<String> get _months => [
        'staffparen31_month_jan'.tr,
        'staffparen31_month_feb'.tr,
        'staffparen31_month_mar'.tr,
        'staffparen31_month_apr'.tr,
        'staffparen31_month_may'.tr,
        'staffparen31_month_jun'.tr,
        'staffparen31_month_jul'.tr,
        'staffparen31_month_aug'.tr,
        'staffparen31_month_sep'.tr,
        'staffparen31_month_oct'.tr,
        'staffparen31_month_nov'.tr,
        'staffparen31_month_dec'.tr,
      ];

  String get _label {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'parent_notes_today'.tr;
    if (d == today.subtract(const Duration(days: 1))) {
      return 'parent_notes_yesterday'.tr;
    }
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 18,
            decoration: BoxDecoration(
              color: _accent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 9),
          AppText(
            text: _label,
            textStyle: context.typography.mdBold.copyWith(
              color: AppColors.textDefault,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: AppText(
              text: '$count',
              textStyle: context.typography.xsBold.copyWith(color: _accent),
            ),
          ),
        ],
      ),
    );
  }
}
