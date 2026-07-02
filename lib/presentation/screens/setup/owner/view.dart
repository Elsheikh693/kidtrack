import '../../../../index/index_main.dart';
import 'widgets/branches_step.dart';

class OwnerSetupView extends StatefulWidget {
  const OwnerSetupView({super.key});

  @override
  State<OwnerSetupView> createState() => _OwnerSetupViewState();
}

class _OwnerSetupViewState extends State<OwnerSetupView> {
  late final OwnerSetupController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => OwnerSetupController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F7FF),
        body: SafeArea(
          child: Column(
            children: [
              const _SetupHeader(),
              Expanded(child: BranchesStep(controller: controller)),
              SetupFinishBar(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupHeader extends StatelessWidget {
  const _SetupHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('setup_owner_title'.tr,
              style: context.typography.xlBold.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1F2937),
              )),
          SizedBox(height: 4.h),
          Text('setup_owner_subtitle'.tr,
              style: context.typography.xsRegular
                  .copyWith(fontSize: 13, color: const Color(0xFF6B7280))),
          SizedBox(height: 16.h),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }
}

class SetupFinishBar extends StatelessWidget {
  final OwnerSetupController controller;
  const SetupFinishBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.finishSetup,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5E35B1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r)),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            elevation: 0,
          ),
          child: Text(
            'setup_finish'.tr,
            style: context.typography.mdBold.copyWith(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
