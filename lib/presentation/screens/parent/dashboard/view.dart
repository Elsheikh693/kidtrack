import '../../../../index/index_main.dart';
import '../../../../Global/widgets/parent_sliver_app_bar.dart';
import 'widgets/live_and_pickup_section.dart';
import 'widgets/announcements_section.dart';
import 'widgets/homework_preview_section.dart';
import 'widgets/photos_today_section.dart';
import 'widgets/daily_notes_section.dart';
import 'widgets/dashboard_shimmer.dart';
import 'parent_home_mockup.dart'; // TEMP: preview new home design
import '../feedback/nursery_feedback_sheet.dart';

class ParentDashboardView extends StatefulWidget {
  const ParentDashboardView({super.key});

  @override
  State<ParentDashboardView> createState() => _ParentDashboardViewState();
}

class _ParentDashboardViewState extends State<ParentDashboardView> {
  late final ParentDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ParentDashboardController());
    // First app open → mandatory nursery feedback (skips if already rated).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) NurseryFeedbackPrompt.maybeShow();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ── TEMP PREVIEW: remove this line to restore the real dashboard ──
    return ParentHomeMockup(controller: controller);
    // ─────────────────────────────────────────────────────────────────

    // ignore: dead_code
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;
    const navBarHeight = 80.0;

    return Obx(() {
      if (controller.isLoading.value) {
        return const CustomScrollView(
          physics: NeverScrollableScrollPhysics(),
          slivers: [
            ParentCollapsingHeader(),
            SliverToBoxAdapter(child: DashboardShimmer()),
          ],
        );
      }

      return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const ParentCollapsingHeader(),
        SliverList(
          delegate: SliverChildListDelegate([
            SizedBox(height: 20.h),
            StaggerItem(
              index: 0,
              child: LiveAndPickupSection(controller: controller),
            ),
            StaggerItem(
              index: 1,
              child: PaymentReminderSection(controller: controller),
            ),
            StaggerItem(
              index: 2,
              child: PhotosTodaySection(controller: controller),
            ),
            StaggerItem(
              index: 3,
              child: DailyNotesSection(controller: controller),
            ),
            StaggerItem(
              index: 4,
              child: AnnouncementsSection(controller: controller),
            ),
            StaggerItem(
              index: 5,
              child: HomeworkPreviewSection(controller: controller),
            ),
            SizedBox(height: safeBottom + navBarHeight + 40),
          ]),
        ),
      ],
    );
    });
  }
}
