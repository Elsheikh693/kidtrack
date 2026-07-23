import '../../../../../index/index_main.dart';

class CdTransferSheet extends StatelessWidget {
  final List<ClassroomModel> classrooms;
  final Function(ClassroomModel) onSelect;
  final int? count;

  const CdTransferSheet({
    super.key,
    required this.classrooms,
    required this.onSelect,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHandle(),
            _SheetTitle(count: count),
            const Divider(height: 1),
            classrooms.isEmpty
                ? _EmptyState()
                : Flexible(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                      shrinkWrap: true,
                      itemCount: classrooms.length,
                      itemBuilder: (_, i) => _ClassroomTile(
                        classroom: classrooms[i],
                        onTap: () => onSelect(classrooms[i]),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(2.r),
      ),
    ),
  );
}

class _SheetTitle extends StatelessWidget {
  final int? count;
  const _SheetTitle({this.count});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 16.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'cd_transfer_title'.tr,
          style: context.typography.mdBold.copyWith(
            fontSize: 17,
            color: const Color(0xFF1E293B),
          ),
        ),
        if (count != null) ...[
          SizedBox(height: 4.h),
          Text(
            'cd_transfer_subtitle'.trParams({'count': count.toString()}),
            style: context.typography.xsRegular.copyWith(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ],
    ),
  );
}

class _ClassroomTile extends StatelessWidget {
  final ClassroomModel classroom;
  final VoidCallback onTap;

  const _ClassroomTile({required this.classroom, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12.r),
    child: Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.class_rounded,
              color: const Color(0xFF7C3AED),
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              classroom.name,
              style: context.typography.smSemiBold.copyWith(
                fontSize: 14,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFF94A3B8),
            size: 20.sp,
          ),
        ],
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 40.h),
    child: Center(
      child: Column(
        children: [
          Icon(Icons.class_outlined, size: 48.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 12.h),
          Text(
            'cd_transfer_empty'.tr,
            style: context.typography.smRegular.copyWith(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    ),
  );
}
