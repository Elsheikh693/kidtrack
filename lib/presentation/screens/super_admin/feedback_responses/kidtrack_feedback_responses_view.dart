import '../../../../index/index_main.dart';
import 'kidtrack_feedback_responses_controller.dart';
import 'widgets/kidtrack_response_card.dart';
import 'widgets/kidtrack_responses_hero.dart';

class KidtrackFeedbackResponsesView extends StatefulWidget {
  const KidtrackFeedbackResponsesView({super.key});

  @override
  State<KidtrackFeedbackResponsesView> createState() =>
      _KidtrackFeedbackResponsesViewState();
}

class _KidtrackFeedbackResponsesViewState
    extends State<KidtrackFeedbackResponsesView> {
  late final KidtrackFeedbackResponsesController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => KidtrackFeedbackResponsesController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: HomeAppBar(
          title: controller.campaignTitle.isNotEmpty
              ? controller.campaignTitle
              : 'sa_feedback_open_btn'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.items.isEmpty) {
            return _EmptyState(controller: controller);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            itemCount: controller.items.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) return KidtrackResponsesHero(controller: controller);
              return KidtrackResponseCard(item: controller.items[i - 1]);
            },
          );
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.controller});

  final KidtrackFeedbackResponsesController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.reviews_outlined, size: 64, color: AppColors.grayMedium),
          const SizedBox(height: 16),
          Text(
            'sa_feedback_responses_empty'.tr,
            style: context.typography.mdRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}
