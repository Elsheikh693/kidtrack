import '../../../../../index/index_main.dart';
import 'widgets/tt_activity_card.dart';
import 'widgets/tt_empty.dart';
import 'widgets/tt_filter_bar.dart';
import 'widgets/tt_header.dart';

/// A teacher's day: today's activities (running + completed), filterable by
/// class and subject. Reached by tapping a slice of the home teaching donut.
class TeacherTodayView extends StatefulWidget {
  const TeacherTodayView({super.key});

  @override
  State<TeacherTodayView> createState() => _TeacherTodayViewState();
}

class _TeacherTodayViewState extends State<TeacherTodayView> {
  late final TeacherTodayController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TeacherTodayController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18.sp, color: AppColors.textDefault),
            onPressed: Get.back,
          ),
          title: Obx(
            () => Text(
              controller.teacherName.value,
              style: context.typography.mdBold.copyWith(
                color: AppColors.textDefault,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: controller.accent.value ?? AppColors.activityBlue,
              ),
            );
          }
          final items = controller.filtered;
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
            children: [
              TtHeader(
                name: controller.teacherName.value,
                photo: controller.teacherPhoto.value,
                accent: controller.accent.value ?? AppColors.activityBlue,
                count: items.length,
              ),
              SizedBox(height: 18.h),
              TtFilterBar(controller: controller),
              if (items.isEmpty)
                const TtEmpty()
              else
                for (final a in items) ...[
                  TtActivityCard(
                    activity: a,
                    className: controller.classNameOf(a.classroomId),
                    accent: controller.accent.value ?? AppColors.activityBlue,
                  ),
                  SizedBox(height: 12.h),
                ],
            ],
          );
        }),
      ),
    );
  }
}
