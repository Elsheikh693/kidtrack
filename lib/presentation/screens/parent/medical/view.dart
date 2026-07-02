import '../../../../index/index_main.dart';
import '../../../../Global/widgets/parent_sliver_app_bar.dart';
import 'widgets/health_alerts_section.dart';
import 'widgets/medical_info_card.dart';
import 'widgets/health_history_section.dart';
import 'widgets/doctor_notes_section.dart';

class ParentMedicalView extends StatefulWidget {
  const ParentMedicalView({super.key});

  @override
  State<ParentMedicalView> createState() => _ParentMedicalViewState();
}

class _ParentMedicalViewState extends State<ParentMedicalView> {
  late final ParentMedicalController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ParentMedicalController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const ParentSliverAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  StaggerItem(index: 0, child: HealthAlertsSection(controller: controller)),
                  const SizedBox(height: 14),
                  StaggerItem(index: 1, child: MedicalInfoCard(controller: controller)),
                  const SizedBox(height: 14),
                  StaggerItem(index: 2, child: HealthHistorySection(controller: controller)),
                  const SizedBox(height: 14),
                  StaggerItem(index: 3, child: DoctorNotesSection(controller: controller)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
