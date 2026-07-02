import '../../../../../index/index_main.dart';

class CdChildCard extends StatelessWidget {
  final ChildModel child;
  final bool selectMode;
  final bool isSelected;
  final VoidCallback onTransfer;
  final VoidCallback onToggle;

  const CdChildCard({
    super.key,
    required this.child,
    required this.selectMode,
    required this.isSelected,
    required this.onTransfer,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: selectMode ? onToggle : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7C3AED).withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7C3AED)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              if (selectMode) ...[
                AnimatedScale(
                  scale: selectMode ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggle(),
                    activeColor: const Color(0xFF7C3AED),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              _CdChildAvatar(child: child),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.fullName,
                      style: context.typography.smSemiBold.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        if (child.gender != null) ...[
                          Icon(
                            child.gender == 'male'
                                ? Icons.male_rounded
                                : Icons.female_rounded,
                            size: 13.sp,
                            color: child.gender == 'male'
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFFEC4899),
                          ),
                          SizedBox(width: 3.w),
                        ],
                        _StatusDot(status: child.status),
                      ],
                    ),
                  ],
                ),
              ),
              if (!selectMode)
                _TransferButton(onTap: onTransfer),
            ],
          ),
        ),
      ),
    );
  }
}

class _CdChildAvatar extends StatelessWidget {
  final ChildModel child;
  const _CdChildAvatar({required this.child});

  @override
  Widget build(BuildContext context) {
    final initial =
        child.firstName.isNotEmpty ? child.firstName[0].toUpperCase() : '?';
    final fallback = Container(
      width: 42.w,
      height: 42.h,
      decoration: BoxDecoration(
        color: const Color(0xFF059669).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          initial,
          style: context.typography.mdBold.copyWith(
            color: const Color(0xFF059669),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    if (!child.hasImage) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: AppNetworkImage(
        url: child.profileImage,
        width: 42.w,
        height: 42.h,
        errorWidget: fallback,
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String status;
  const _StatusDot({required this.status});

  Color get _color {
    switch (status) {
      case 'active':
        return const Color(0xFF16A34A);
      case 'withdrawn':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFFDC2626);
    }
  }

  String _label() {
    switch (status) {
      case 'active':
        return 'child_status_active'.tr;
      case 'withdrawn':
        return 'child_status_withdrawn'.tr;
      default:
        return 'child_status_inactive'.tr;
    }
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 6.w,
        height: 6.h,
        decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
      ),
      SizedBox(width: 4.w),
      Text(
        _label(),
        style: context.typography.xsMedium.copyWith(fontSize: 11, color: _color),
      ),
    ],
  );
}

class _TransferButton extends StatelessWidget {
  final VoidCallback onTap;
  const _TransferButton({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.swap_horiz_rounded,
            size: 14.sp,
            color: const Color(0xFF7C3AED),
          ),
          SizedBox(width: 4.w),
          Text(
            'cd_transfer'.tr,
            style: context.typography.smSemiBold.copyWith(
              fontSize: 11,
              color: const Color(0xFF7C3AED),
            ),
          ),
        ],
      ),
    ),
  );
}
