import 'dart:math' as math;

import '../../../../../index/index_main.dart';

/// The premium hero of the activation landing: the KidTrack logo makes an
/// elastic entrance inside a glowing, pulsing halo, then breathes gently while
/// the welcome text reveals underneath. First impression — so it's polished.
class ActivationLandingHero extends StatefulWidget {
  const ActivationLandingHero({super.key});

  @override
  State<ActivationLandingHero> createState() => _ActivationLandingHeroState();
}

class _ActivationLandingHeroState extends State<ActivationLandingHero>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoScale = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.75, curve: Curves.elasticOut),
    );
    final logoFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    final textAnim = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 240.w,
          height: 240.w,
          child: AnimatedBuilder(
            animation: Listenable.merge([_entrance, _ambient]),
            builder: (context, _) {
              final wave = math.sin(_ambient.value * 2 * math.pi);
              final floatY = wave * 12;
              final breath = 1 + wave * 0.04; // gentle breathing scale
              return Stack(
                alignment: Alignment.center,
                children: [
                  ..._pulseRings(),
                  Transform.translate(
                    offset: Offset(0, floatY),
                    child: Transform.scale(
                      scale: breath,
                      child: FadeTransition(
                        opacity: logoFade,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.35, end: 1).animate(
                            logoScale,
                          ),
                          child: _disc(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 20.h),
        FadeTransition(
          opacity: textAnim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.35),
              end: Offset.zero,
            ).animate(textAnim),
            child: _texts(context),
          ),
        ),
      ],
    );
  }

  /// Two soft haloes that expand and fade continuously — a gentle sonar pulse.
  List<Widget> _pulseRings() {
    return List.generate(2, (i) {
      final p = (_ambient.value + i * 0.5) % 1.0;
      final scale = 0.95 + p * 1.25;
      final opacity = (1 - p) * 0.32 * _entrance.value;
      return Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: 150.w,
            height: 150.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(44.r),
              color: AppColors.white.withValues(alpha: 0.16),
            ),
          ),
        ),
      );
    });
  }

  Widget _disc() {
    return Container(
      width: 150.w,
      height: 150.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(40.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 44.r,
            offset: Offset(0, 18.h),
          ),
          BoxShadow(
            color: AppColors.white.withValues(alpha: 0.45),
            blurRadius: 28.r,
            spreadRadius: -8.r,
          ),
        ],
      ),
      child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
    );
  }

  Widget _texts(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'activation_landing_title'.tr,
          textAlign: TextAlign.center,
          style: context.typography.xsBold.copyWith(
            color: AppColors.white,
            fontSize: 27,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 36.w),
          child: Text(
            'activation_landing_sub'.tr,
            textAlign: TextAlign.center,
            style: context.typography.smRegular.copyWith(
              color: AppColors.white.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
