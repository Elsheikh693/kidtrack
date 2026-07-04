import '../../../../index/index_main.dart';
import 'widgets/profile_sliver_header.dart';
import 'widgets/profile_section.dart';
import 'widgets/profile_gallery.dart';
import 'widgets/profile_chips.dart';
import 'widgets/profile_location_card.dart';
import 'widgets/profile_branches.dart';
import 'widgets/profile_login_bar.dart';
import 'widgets/profile_overview.dart';

class NurseryProfileView extends StatefulWidget {
  const NurseryProfileView({super.key});

  @override
  State<NurseryProfileView> createState() => _NurseryProfileViewState();
}

class _NurseryProfileViewState extends State<NurseryProfileView> {
  late final NurseryProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => NurseryProfileController());
  }

  @override
  Widget build(BuildContext context) {
    final n = controller.nursery;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  ProfileSliverHeader(nursery: n),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.h, bottom: 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _sections(context, n),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ProfileLoginBar(
              onLogin: controller.goToLogin,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context, NurseryModel n) {
    final sections = <Widget>[];

    if (n.photos.isNotEmpty) {
      sections.add(ProfileSection(
        horizontalPadding: 0,
        child: ProfileGallery(photos: n.photos),
      ));
    }
    if ((n.description ?? '').isNotEmpty) {
      sections.add(ProfileSection(
        child: AppText(
          text: n.description!,
          textStyle: context.typography.smRegular.copyWith(
            color: AppColors.textPrimaryParagraph,
            height: 1.8,
          ),
          maxLines: 20,
        ),
      ));
    }
    if (n.programs.isNotEmpty) {
      sections.add(ProfileSection(
        title: 'discovery_section_programs'.tr,
        child: ProfileProgramList(programs: n.programs),
      ));
    }
    if (n.activities.isNotEmpty) {
      sections.add(ProfileSection(
        title: 'discovery_section_activities'.tr,
        child: ProfileChips(items: n.activities),
      ));
    }
    if (controller.hasLocation) {
      sections.add(ProfileSection(
        title: 'discovery_section_location'.tr,
        child: ProfileLocationCard(
          address: n.address,
          onOpenMaps: controller.openMaps,
        ),
      ));
    }
    // Key facts (age range + application fee) sit directly above the branches.
    if (controller.hasOverview) {
      sections.add(ProfileSection(
        title: 'discovery_section_details'.tr,
        child: ProfileOverview(nursery: n),
      ));
    }
    if (controller.hasBranches) {
      sections.add(Obx(() {
        final branchViews = controller.branchViews;
        if (branchViews.isEmpty) return const SizedBox.shrink();
        return ProfileSection(
          title: 'discovery_section_branches'.tr,
          child: ProfileBranches(
            branches: branchViews,
            onDirections: controller.openBranchMaps,
            onCall: controller.callBranch,
            onWhatsapp: controller.whatsappBranch,
          ),
        );
      }));
    }

    // Wrap each section in a staggered fade + slide entrance.
    return [
      for (int i = 0; i < sections.length; i++)
        _EntranceFade(index: i, child: sections[i]),
    ];
  }
}

/// Plays a one-shot fade + upward slide when first shown, delayed by [index]
/// so sections cascade in one after another.
class _EntranceFade extends StatefulWidget {
  final int index;
  final Widget child;
  const _EntranceFade({required this.index, required this.child});

  @override
  State<_EntranceFade> createState() => _EntranceFadeState();
}

class _EntranceFadeState extends State<_EntranceFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 90 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
