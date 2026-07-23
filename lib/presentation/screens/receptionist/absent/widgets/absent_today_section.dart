import '../../../../../index/index_main.dart';
import 'absent_today_sheet.dart';

const _ink = Color(0xFF111827);
const _amber = Color(0xFFF59E0B);
const _amberBg = Color(0xFFFEF6E7);

/// "Absent today" section — reused on the reception home and inside the
/// children tab. Lists the active children with no check-in yet today; tapping
/// a child opens the shared parent chat. The caring absence message itself is
/// sent automatically at each child's shift end by the backend.
///
/// [maxHeight] bounds the inline list (with internal scroll) when the section
/// sits above another scroll view (the children tab); leave null on a page that
/// already scrolls (the home). [hideWhenEmpty] drops the whole section when no
/// one is absent, instead of showing the positive empty state.
class AbsentTodaySection extends StatefulWidget {
  final double? maxHeight;
  final bool hideWhenEmpty;

  /// When set, the inline list shows at most this many children and appends a
  /// "view all" row that opens [AbsentTodaySheet] with the full set. Used on the
  /// reception home to keep the section compact.
  final int? previewLimit;

  const AbsentTodaySection({
    super.key,
    this.maxHeight,
    this.hideWhenEmpty = false,
    this.previewLimit,
  });

  @override
  State<AbsentTodaySection> createState() => _AbsentTodaySectionState();
}

class _AbsentTodaySectionState extends State<AbsentTodaySection> {
  late final AbsentTodayController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AbsentTodayController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.absent;

      if (items.isEmpty) {
        if (widget.hideWhenEmpty || controller.isLoading.value) {
          return const SizedBox.shrink();
        }
        return _AllPresent();
      }

      final limit = widget.previewLimit;
      final capped = limit != null && items.length > limit;
      final shown = capped ? items.take(limit).toList() : items;

      final list = Column(
        children: [
          for (final child in shown)
            AbsentChildTile(
              child: child,
              parentName: controller.parentName(child.key),
              onChat: () => controller.openChat(child),
              onWhatsApp: () => controller.openWhatsApp(child),
              hasPhone: controller.hasParentPhone(child.key),
            ),
          if (capped)
            _ViewAllRow(
              remaining: items.length - limit,
              onTap: () => Get.bottomSheet(
                const AbsentTodaySheet(),
                isScrollControlled: true,
              ),
            ),
        ],
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(count: items.length),
          SizedBox(height: 10.h),
          if (widget.maxHeight != null)
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.maxHeight!),
              child: SingleChildScrollView(child: list),
            )
          else
            list,
        ],
      );
    });
  }
}

class _Header extends StatelessWidget {
  final int count;
  const _Header({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: _amberBg,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_off_outlined, size: 18.sp, color: _amber),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            'reception_absent_today_title'.tr,
            style: context.typography.mdBold.copyWith(
              fontSize: 15.5,
              color: _ink,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: _amber,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '$count',
            style: context.typography.smSemiBold.copyWith(
              fontSize: 12.5,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _ViewAllRow extends StatelessWidget {
  final int remaining;
  final VoidCallback onTap;
  const _ViewAllRow({required this.remaining, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 4.h),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _amberBg,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'reception_absent_view_all'.trParams({'n': '$remaining'}),
              style: context.typography.smSemiBold.copyWith(
                fontSize: 13,
                color: _amber,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.expand_more_rounded, size: 18.sp, color: _amber),
          ],
        ),
      ),
    );
  }
}

class _AllPresent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF3),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 22.sp, color: const Color(0xFF16A34A)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'reception_absent_none'.tr,
              style: context.typography.smMedium.copyWith(
                fontSize: 13.5,
                color: const Color(0xFF15803D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
