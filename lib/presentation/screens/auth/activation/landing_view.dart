import '../../../../index/index_main.dart';
import 'widgets/activation_code_card.dart';
import 'widgets/activation_landing_background.dart';
import 'widgets/activation_landing_hero.dart';

/// The app's entry screen for anyone not signed in: a branded, animated screen
/// asking only for an activation code (or a QR scan). Replaces the nursery-list
/// landing so an owner never sees other nurseries. After the first sign-in the
/// session persists and the app opens straight into the user's home.
class ActivationLandingView extends StatefulWidget {
  const ActivationLandingView({super.key});

  @override
  State<ActivationLandingView> createState() => _ActivationLandingViewState();
}

class _ActivationLandingViewState extends State<ActivationLandingView>
    with SingleTickerProviderStateMixin {
  late final ActivationCodeController controller;
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ActivationCodeController());
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..forward();
    // Most people type the code — open the keyboard, but only after the entrance
    // animation has played so the hero isn't clipped mid-reveal.
    Future.delayed(const Duration(milliseconds: 1250), () {
      if (mounted) controller.codeFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardAnim = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
    );

    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.primary60],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: ActivationLandingBackground()),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    SizedBox(height: 28.h),
                    const Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: ActivationLandingHero(),
                        ),
                      ),
                    ),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.18),
                        end: Offset.zero,
                      ).animate(cardAnim),
                      child: FadeTransition(opacity: cardAnim, child: _card()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 28.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ActivationCodeCard(controller: controller),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () => Get.toNamed(appSettingsView),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Text(
                  'activation_landing_help'.tr,
                  style: context.typography.smSemiBold.copyWith(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
