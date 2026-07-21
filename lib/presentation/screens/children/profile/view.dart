import '../../../../index/index_main.dart';
import 'widgets/profile_shimmer.dart';
import 'widgets/child_manage_section.dart';
import 'widgets/withdraw_section.dart';
import 'widgets/delete_child_section.dart';

class ChildProfileView extends StatefulWidget {
  const ChildProfileView({super.key});

  @override
  State<ChildProfileView> createState() => _ChildProfileViewState();
}

class _ChildProfileViewState extends State<ChildProfileView> {
  late final ChildProfileController controller;

  @override
  void initState() {
    super.initState();
    // The controller is a fenix singleton (reused across opens), so reload
    // every time the screen opens to guarantee fresh, correct-child data.
    controller = initController(() => ChildProfileController());
    controller.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF374151)),
          title: Obx(() => Text(
                controller.childName,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              )),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const ProfileShimmer();
          }
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 12),
              BasicInfoSection(controller: controller),
              ParentsSection(controller: controller),
              ProfileFilterBar(controller: controller),
              AttendanceSection(controller: controller),
              // Pedagogical feed — hidden for reception, shown to everyone else.
              if (controller.showsLearningFeed) ...[
                ActivitiesSection(controller: controller),
                ChildProfileTeacherNotesSection(controller: controller),
              ],
              ChildManageSection(controller: controller),
              WithdrawSection(controller: controller),
              DeleteChildSection(controller: controller),
              const SizedBox(height: 32),
            ],
          );
        }),
      ),
    );
  }
}
