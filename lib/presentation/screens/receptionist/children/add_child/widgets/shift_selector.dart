import '../../../../../../index/index_main.dart';

const _line = Color(0xFFEEF0F4);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);

/// Single-select shift picker driven by the nursery's dynamic shifts. Cards get
/// their icon/color from the shift start time via [shiftVisuals]; the stored
/// value is the shift key.
class ShiftSelector extends StatelessWidget {
  final List<ShiftModel> shifts;
  final String? value;
  final ValueChanged<String> onChanged;

  const ShiftSelector({
    super.key,
    required this.shifts,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (shifts.isEmpty) {
      return Container(
        height: 52.h,
        alignment: AlignmentDirectional.centerStart,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _line),
        ),
        child: Text(
          'child_shift_none'.tr,
          style: context.typography.smRegular.copyWith(color: _muted),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, c) {
        final gap = 10.w;
        final perRow = shifts.length < 3 ? shifts.length : 3;
        final w = (c.maxWidth - gap * (perRow - 1)) / perRow;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: shifts.map((s) {
            final vis = shiftVisuals(s.startMinutes);
            return SizedBox(
              width: w,
              child: _Option(
                label: s.name,
                icon: vis.icon,
                color: vis.color,
                bg: vis.bg,
                selected: value == s.key,
                onTap: () => onChanged(s.key ?? ''),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Option extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final bool selected;
  final VoidCallback onTap;

  const _Option({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: selected ? bg : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? color : _line,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.typography.displaySmBold.copyWith(
                fontSize: 14,
                color: selected ? _ink : _muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
