import '../../../../index/index_main.dart';
import 'controller.dart';
import 'widgets/authorized_person_card.dart';

class PickupVerificationView extends StatefulWidget {
  const PickupVerificationView({super.key});

  @override
  State<PickupVerificationView> createState() => _PickupVerificationViewState();
}

class _PickupVerificationViewState extends State<PickupVerificationView> {
  late final PickupVerificationController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => PickupVerificationController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: HomeAppBar(title: 'pickup_verification_title'.tr),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              _ChildHeader(controller: controller),
              Expanded(child: _PersonsList(controller: controller)),
              _BottomActions(controller: controller),
            ],
          );
        }),
      ),
    );
  }
}

class _ChildHeader extends StatelessWidget {
  final PickupVerificationController controller;
  const _ChildHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final child = controller.child.value;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.child_care_rounded,
                color: Color(0xFF7C3AED), size: 26),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                child != null
                    ? '${child.firstName} ${child.lastName}'
                    : '--',
                style: context.typography.mdBold
                    .copyWith(color: AppColors.textDefault),
              ),
              Text(
                'pickup_verification_subtitle'.tr,
                style: context.typography.xsRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PersonsList extends StatelessWidget {
  final PickupVerificationController controller;
  const _PersonsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final persons = controller.authorizedPersons;
      if (persons.isEmpty) {
        return Center(
          child: Text(
            'pickup_no_authorized_persons'.tr,
            style: context.typography.smRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: persons.length,
        itemBuilder: (_, i) => AuthorizedPersonCard(
          person: persons[i],
          onConfirm: () => controller.confirmPickup(persons[i]),
        ),
      );
    });
  }
}

class _BottomActions extends StatelessWidget {
  final PickupVerificationController controller;
  const _BottomActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      color: AppColors.white,
      child: ElevatedButton(
        onPressed: () => controller.reportUnauthorized(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorBackground,
          foregroundColor: AppColors.errorForeground,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppColors.errorForeground.withValues(alpha: 0.3),
            ),
          ),
          elevation: 0,
        ),
        child: Text(
          'pickup_report_unauthorized'.tr,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
