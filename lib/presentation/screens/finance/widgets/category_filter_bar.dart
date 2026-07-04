import '../../../../index/index_main.dart';

const _ink = Color(0xFF1E293B);
const _muted = Color(0xFF94A3B8);
const _field = Color(0xFFF8FAFC);
const _border = Color(0xFFE2E8F0);

/// A single category dropdown for the "عرض الكل" screens. Options come from the
/// controller (fee categories for collections, expense categories for
/// expenses); [selectedId] is `null` for the "all categories" default. The
/// month is fixed by the dashboard view, so this filters by category only.
class CategoryFilterBar extends StatelessWidget {
  final List<CategoryRevenue> options;
  final String? selectedId;
  final Color accent;
  final ValueChanged<String?> onChanged;

  const CategoryFilterBar({
    super.key,
    required this.options,
    required this.selectedId,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: _field,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list_rounded, size: 19.sp, color: accent),
          SizedBox(width: 10.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedId,
                isExpanded: true,
                borderRadius: BorderRadius.circular(12.r),
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 22.sp, color: _muted),
                style:
                    context.typography.smMedium.copyWith(color: _ink, fontSize: 14),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'finance_filter_all_categories'.tr,
                      style: context.typography.smMedium
                          .copyWith(color: _ink, fontSize: 14),
                    ),
                  ),
                  ...options.map(
                    (c) => DropdownMenuItem<String?>(
                      value: c.categoryId,
                      child: Text(
                        '${c.categoryName} (${c.transactionsCount})',
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.smMedium
                            .copyWith(color: _ink, fontSize: 14),
                      ),
                    ),
                  ),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
