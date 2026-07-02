import '../../../../../index/index_main.dart';
import '../controller.dart';
import 'pickup_status_sheet.dart';

class PickupRequestCard extends StatelessWidget {
  final PickupRequestModel request;
  final PickupRequestsController controller;

  const PickupRequestCard({
    super.key,
    required this.request,
    required this.controller,
  });

  Color _statusColor(String status) => switch (status) {
        'requested' => const Color(0xFF0891B2),
        'preparing' => const Color(0xFFF97316),
        'completed' => const Color(0xFF6B7280),
        'rejected' => const Color(0xFFDC2626),
        _ => AppColors.grayMedium,
      };

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(request.status);
    final childName = controller.childName(request.childId);
    final time = controller.formatTime(request.requestedPickupTime);

    return GestureDetector(
      onTap: () => _showStatusSheet(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.grayLight.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.directions_car_rounded, color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      childName,
                      style: context.typography.smSemiBold
                          .copyWith(color: AppColors.textDefault, fontSize: 14),
                    ),
                  ),
                  _StatusBadge(status: request.status, color: color),
                ],
              ),
              if (request.parentNotes != null &&
                  request.parentNotes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  request.parentNotes!,
                  style: context.typography.xsRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 13, color: AppColors.grayMedium),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: context.typography.xsRegular
                        .copyWith(color: AppColors.textSecondaryParagraph),
                  ),
                  const Spacer(),
                  if (request.status != 'completed' &&
                      request.status != 'rejected')
                    TextButton(
                      onPressed: () => _showStatusSheet(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'pickup_action_update'.tr,
                        style: const TextStyle(
                          color: Color(0xFF7C3AED),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusSheet(BuildContext context) {
    if (request.status == 'completed' || request.status == 'rejected') return;
    Get.bottomSheet(
      PickupStatusSheet(request: request, controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'pickup_status_$status'.tr,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
