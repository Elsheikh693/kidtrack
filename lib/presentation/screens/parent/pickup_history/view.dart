import '../../../../index/index_main.dart';
import 'controller.dart';

class PickupHistoryView extends StatefulWidget {
  const PickupHistoryView({super.key});

  @override
  State<PickupHistoryView> createState() => _PickupHistoryViewState();
}

class _PickupHistoryViewState extends State<PickupHistoryView> {
  late final PickupHistoryController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => PickupHistoryController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_ios,
                color: AppColors.textDefault, size: 20),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'pickup_history_title'.tr,
                style: context.typography.lgBold
                    .copyWith(color: AppColors.textDefault),
              ),
              Obx(() => Text(
                controller.isLoading.value ? '' : controller.childName,
                style: const TextStyle(
                  color: AppColors.textSecondaryParagraph,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              )),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: AppColors.borderNeutralPrimary.withValues(alpha: 0.3),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.records.isEmpty) return _EmptyState();
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: controller.records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _PickupCard(
              record: controller.records[i],
              isFirst: i == 0,
            ),
          );
        }),
      ),
    );
  }
}

class _PickupCard extends StatelessWidget {
  const _PickupCard({required this.record, required this.isFirst});

  final PickupRecord record;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF059669);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: isFirst
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Date header ────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isFirst
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : AppColors.backgroundNeutral100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: isFirst ? AppColors.primary : AppColors.textSecondaryParagraph,
                ),
                const SizedBox(width: 6),
                Text(
                  record.date,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isFirst ? AppColors.primary : AppColors.textSecondaryParagraph,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          // ── Detail row ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'parentpick26_pickup_received'.tr,
                        style: context.typography.smSemiBold
                            .copyWith(color: AppColors.textDefault),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'parentpick26_pickup_left_safely'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Time badge ──────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 13, color: color),
                      const SizedBox(height: 2),
                      Text(
                        record.formattedTime,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded,
              size: 64, color: AppColors.borderNeutralPrimary),
          const SizedBox(height: 16),
          Text(
            'pickup_history_empty_title'.tr,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
          const SizedBox(height: 6),
          Text(
            'pickup_history_empty_sub'.tr,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryParagraph,
            ),
          ),
        ],
      ),
    );
  }
}
