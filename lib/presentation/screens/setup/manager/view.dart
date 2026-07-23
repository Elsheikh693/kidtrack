import '../../../../index/index_main.dart';
import 'controller.dart';
import 'widgets/branch_info_step.dart';
import 'widgets/programs_step.dart';
import 'widgets/subjects_step.dart';
import 'widgets/classrooms_step.dart';
import 'widgets/staff_step.dart';
import 'widgets/fees_step.dart';

class ManagerSetupView extends StatefulWidget {
  const ManagerSetupView({super.key});

  @override
  State<ManagerSetupView> createState() => _ManagerSetupViewState();
}

class _ManagerSetupViewState extends State<ManagerSetupView> {
  late final ManagerSetupController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ManagerSetupController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F7FF),
        body: SafeArea(
          child: Column(
            children: [
              _ManagerSetupHeader(controller: controller),
              Expanded(
                child: Obx(() {
                  switch (controller.currentStep.value) {
                    case 0:  return BranchInfoStep(controller: controller);
                    case 1:  return ProgramsStep(controller: controller);
                    case 2:  return SubjectsStep(controller: controller);
                    case 3:  return ClassroomsStep(controller: controller);
                    case 4:  return StaffStep(controller: controller);
                    default: return FeesStep(controller: controller);
                  }
                }),
              ),
              _ManagerNavBar(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ManagerSetupHeader extends StatelessWidget {
  final ManagerSetupController controller;
  const _ManagerSetupHeader({required this.controller});

  static const _steps = [
    ('setup_step_branch',     Icons.storefront_rounded),
    ('setup_step_programs',   Icons.school_rounded),
    ('setup_step_subjects',   Icons.menu_book_rounded),
    ('setup_step_classrooms', Icons.meeting_room_rounded),
    ('setup_step_staff',      Icons.people_rounded),
    ('setup_step_fees',       Icons.payments_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('setup_manager_title'.tr,
              style: context.typography.xlBold.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1F2937),
              )),
          SizedBox(height: 4.h),
          Text('setup_manager_subtitle'.tr,
              style: context.typography.xsRegular
                  .copyWith(fontSize: 13, color: const Color(0xFF6B7280))),
          SizedBox(height: 20.h),
          Obx(() => _MgrStepRow(
                steps: _steps,
                current: controller.currentStep.value,
              )),
          SizedBox(height: 16.h),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }
}

// ── Nav bar ───────────────────────────────────────────────────────────────────

class _ManagerNavBar extends StatelessWidget {
  final ManagerSetupController controller;
  const _ManagerNavBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Obx(() {
        final step = controller.currentStep.value;
        final isLast = step == 5;
        return Row(
          children: [
            if (step > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.back,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5E35B1),
                    side: const BorderSide(color: Color(0xFF5E35B1)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text('setup_back'.tr,
                      style: context.typography.smSemiBold),
                ),
              ),
            if (step > 0) SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: controller.next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E35B1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  elevation: 0,
                ),
                child: Text(
                  isLast ? 'setup_finish'.tr : 'setup_next'.tr,
                  style: context.typography.mdBold.copyWith(fontSize: 16),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Step indicator row ────────────────────────────────────────────────────────

class _MgrStepRow extends StatelessWidget {
  final List<(String, IconData)> steps;
  final int current;
  const _MgrStepRow({required this.steps, required this.current});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final isDone = current > i ~/ 2;
            return SizedBox(
              width: 24.w,
              height: 2.h,
              child: ColoredBox(
                  color: isDone
                      ? const Color(0xFF5E35B1)
                      : const Color(0xFFE5E7EB)),
            );
          }
          final idx = i ~/ 2;
          final isDone   = current > idx;
          final isActive = current == idx;
          return _MgrStepDot(
            icon: steps[idx].$2,
            label: steps[idx].$1.tr,
            isDone: isDone,
            isActive: isActive,
          );
        }),
      ),
    );
  }
}

class _MgrStepDot extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDone;
  final bool isActive;
  const _MgrStepDot(
      {required this.icon,
      required this.label,
      required this.isDone,
      required this.isActive});

  @override
  Widget build(BuildContext context) {
    final Color bg = isDone
        ? const Color(0xFF10B981)
        : isActive
            ? const Color(0xFF5E35B1)
            : const Color(0xFFE5E7EB);
    final Color fg =
        (isDone || isActive) ? Colors.white : const Color(0xFF9CA3AF);
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(isDone ? Icons.check_rounded : icon,
              color: fg, size: 18.sp),
        ),
        SizedBox(height: 4.h),
        Text(label,
            style: context.typography.xsMedium.copyWith(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive
                  ? const Color(0xFF5E35B1)
                  : isDone
                      ? const Color(0xFF10B981)
                      : const Color(0xFF9CA3AF),
            )),
      ],
    );
  }
}
