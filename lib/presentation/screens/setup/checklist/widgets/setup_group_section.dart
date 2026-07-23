import '../../../../../index/index_main.dart';
import '../models/setup_group.dart';
import 'setup_step_card.dart';

class SetupHubGroupSection extends StatelessWidget {
  final SetupChecklistController controller;
  final SetupGroup group;
  const SetupHubGroupSection({
    super.key,
    required this.controller,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10.h, right: 4.w),
          child: Text(
            group.titleKey.tr,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textPrimaryParagraph),
          ),
        ),
        ...group.steps.map(
          (s) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: SetupHubStepCard(controller: controller, step: s),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
