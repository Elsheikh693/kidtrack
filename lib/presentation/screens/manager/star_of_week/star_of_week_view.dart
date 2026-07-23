import '../../../../index/index_main.dart';
import 'reveal/star_reveal_view.dart';
import 'star_of_week_controller.dart';
import 'widgets/star_child_tile.dart';
import 'widgets/star_current_banner.dart';
import 'widgets/star_empty.dart';
import 'widgets/star_pick_bar.dart';
import 'widgets/star_search_field.dart';

class StarOfWeekView extends StatefulWidget {
  const StarOfWeekView({super.key});

  @override
  State<StarOfWeekView> createState() => _StarOfWeekViewState();
}

class _StarOfWeekViewState extends State<StarOfWeekView> {
  late final StarOfWeekController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<StarOfWeekController>();
  }

  Future<void> _publish() async {
    final star = await controller.publish();
    if (star != null) await showStarReveal(star);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: OwnerAppBar(
        title: 'sotw_title'.tr,
        onBack: () => Get.back<void>(),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            if (controller.currentStar.value != null)
              SliverToBoxAdapter(
                child: StarCurrentBanner(
                  star: controller.currentStar.value!,
                  onTap: () => showStarReveal(controller.currentStar.value!),
                ),
              ),
            SliverToBoxAdapter(
              child: StarSearchField(controller: controller),
            ),
            if (controller.filteredChildren.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: StarEmpty(),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => StarChildTile(
                    child: controller.filteredChildren[i],
                    controller: controller,
                  ),
                  childCount: controller.filteredChildren.length,
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: 180.h)),
          ],
        );
      }),
      bottomSheet: Obx(
        () => controller.selectedChild.value == null
            ? const SizedBox.shrink()
            : StarPickBar(controller: controller, onPublish: _publish),
      ),
    );
  }
}
