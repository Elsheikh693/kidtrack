import '../../../../../index/index_main.dart';
import '../controller.dart';

class PickupStatusSheet extends StatelessWidget {
  final PickupRequestModel request;
  final PickupRequestsController controller;

  const PickupStatusSheet({
    super.key,
    required this.request,
    required this.controller,
  });

  static const _nextStatuses = {
    'requested': ['preparing', 'rejected'],
    'preparing': ['completed'],
  };

  @override
  Widget build(BuildContext context) {
    final nexts = _nextStatuses[request.status] ?? [];

    return Directionality(
      textDirection: appTextDirection,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              controller.childName(request.childId),
              style: context.typography.mdBold
                  .copyWith(color: AppColors.textDefault),
            ),
            const SizedBox(height: 4),
            Text(
              '${'pickup_current_status'.tr}: ${'pickup_status_${request.status}'.tr}',
              style: context.typography.smRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
            const SizedBox(height: 20),
            Text(
              'pickup_update_to'.tr,
              style: context.typography.smSemiBold
                  .copyWith(color: AppColors.textDefault),
            ),
            const SizedBox(height: 12),
            if (nexts.isEmpty)
              Text(
                'pickup_no_action'.tr,
                style: context.typography.smRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
              )
            else
              ...nexts.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _StatusOption(
                    status: s,
                    onTap: () {
                      Get.back();
                      controller.updateStatus(request, s);
                    },
                  ),
                ),
              ),
            if (request.staffNotes != null) ...[
              const SizedBox(height: 8),
              Text(
                request.staffNotes!,
                style: context.typography.xsRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final String status;
  final VoidCallback onTap;

  const _StatusOption({required this.status, required this.onTap});

  Color get _color => switch (status) {
        'preparing' => const Color(0xFFF97316),
        'completed' => const Color(0xFF059669),
        'rejected' => const Color(0xFFDC2626),
        _ => AppColors.grayMedium,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                'pickup_status_$status'.tr,
                style: context.typography.smSemiBold.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
