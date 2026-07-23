import '../../../../../index/index_main.dart';
import '../../../../../Data/models/classroom_activity/classroom_activity_model.dart';
import 'home_section_header.dart';

class RecentPhotosSection extends StatelessWidget {
  const RecentPhotosSection({super.key, required this.activities});

  final List<ClassroomActivityModel> activities;

  List<String> get _photoUrls {
    final urls = <String>[];
    for (final a in activities.reversed) {
      urls.addAll(a.allPhotoUrls);
      if (urls.length >= 9) break;
    }
    return urls.take(9).toList();
  }

  @override
  Widget build(BuildContext context) {
    final urls = _photoUrls;
    if (urls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        HomeSectionHeader(
          label: 'teacher_home_recent_photos'.tr,
          color: AppColors.activityPurple,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemCount: urls.length,
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AppNetworkImage(
                url: urls[i],
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
