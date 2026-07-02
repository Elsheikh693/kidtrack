import '../../../../../index/index_main.dart';

class IdleClassroomChip extends StatelessWidget {
  const IdleClassroomChip({
    super.key,
    required this.classroom,
    required this.isActive,
    required this.onTap,
    this.studentCount,
  });

  final ClassroomModel classroom;
  final bool isActive;
  final VoidCallback onTap;
  final int? studentCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(left: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.white
              : AppColors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(28),
          border: isActive
              ? null
              : Border.all(
                  color: AppColors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) ...[
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.activityGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              classroom.name,
              style: context.typography.smSemiBold.copyWith(
                color: isActive
                    ? AppColors.activityGreenDark
                    : AppColors.white,
                letterSpacing: 0.2,
              ),
            ),
            if (studentCount != null && studentCount! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.activityGreen.withValues(alpha: 0.15)
                      : AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$studentCount',
                  style: context.typography.xsMedium.copyWith(
                    color: isActive ? AppColors.activityGreen : AppColors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
