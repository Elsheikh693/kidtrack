import '../../../../../index/index_main.dart';

const _line = Color(0xFFEEF0F4);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);

/// Horizontal count-by-shift filter driven by the nursery's dynamic shifts.
/// Tapping a card filters the roster to that shift; tapping it again clears.
class ShiftSwitcher extends StatelessWidget {
  final ChildListController controller;
  const ShiftSwitcher({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Obx(() {
        final shifts = controller.shifts;
        if (shifts.isEmpty) return const SizedBox.shrink();
        final selected = controller.selectedShift.value;

        Widget card(ShiftModel s) {
          final vis = shiftVisuals(s.startMinutes);
          return _ShiftCard(
            label: s.name,
            count: controller.countForShift(s.key),
            icon: vis.icon,
            color: vis.color,
            bg: vis.bg,
            selected: selected == s.key,
            onTap: () => controller.setShift(selected == s.key ? null : s.key),
          );
        }

        // Up to 3 shifts fill the row; more become a horizontal scroll so the
        // cards keep a comfortable size.
        if (shifts.length <= 3) {
          return Row(
            children: [
              for (var i = 0; i < shifts.length; i++) ...[
                if (i > 0) SizedBox(width: 10.w),
                Expanded(child: card(shifts[i])),
              ],
            ],
          );
        }
        return LayoutBuilder(
          builder: (context, c) {
            final w = (c.maxWidth - 20.w) / 3;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < shifts.length; i++) ...[
                    if (i > 0) SizedBox(width: 10.w),
                    SizedBox(width: w, child: card(shifts[i])),
                  ],
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final Color bg;
  final bool selected;
  final VoidCallback onTap;

  const _ShiftCard({
    required this.label,
    required this.count,
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
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.fromLTRB(12.w, 13.h, 12.w, 13.h),
        decoration: BoxDecoration(
          color: selected ? bg : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected ? color : _line,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$count',
                  style: context.typography.xsBold.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 34.w,
                  height: 34.h,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(icon, color: color, size: 19.sp),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.displaySmBold.copyWith(
                fontSize: 13,
                color: selected ? _ink : _muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
