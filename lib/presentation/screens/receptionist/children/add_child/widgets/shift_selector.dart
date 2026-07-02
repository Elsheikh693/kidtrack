import '../../../../../../index/index_main.dart';

const _morning = Color(0xFFF59E0B);
const _morningBg = Color(0xFFFEF6E7);
const _between = Color(0xFF14B8A6);
const _betweenBg = Color(0xFFE6FAF7);
const _evening = Color(0xFF6366F1);
const _eveningBg = Color(0xFFEEF0FE);
const _line = Color(0xFFEEF0F4);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);

class ShiftSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const ShiftSelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Option(
            label: 'shift_morning'.tr,
            icon: Icons.wb_sunny_rounded,
            color: _morning,
            bg: _morningBg,
            selected: value == 'morning',
            onTap: () => onChanged('morning'),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _Option(
            label: 'shift_between'.tr,
            icon: Icons.brightness_6_rounded,
            color: _between,
            bg: _betweenBg,
            selected: value == 'between',
            onTap: () => onChanged('between'),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _Option(
            label: 'shift_evening'.tr,
            icon: Icons.bedtime_rounded,
            color: _evening,
            bg: _eveningBg,
            selected: value == 'evening',
            onTap: () => onChanged('evening'),
          ),
        ),
      ],
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
        padding: EdgeInsets.symmetric(vertical: 16.h),
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
