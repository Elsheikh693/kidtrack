import 'package:confetti/confetti.dart';

import '../../../../../index/index_main.dart';
import '../../../shared/assessment/assessment_share_preview_sheet.dart';
import '../../../shared/assessment/assessment_share.dart';
import 'widgets/star_reveal_stage.dart';
import 'widgets/star_share_card.dart';
import 'widgets/star_twinkle_field.dart';

/// Opens the full-screen celebratory reveal for a Star-of-the-Week pick.
/// Shared by the manager (right after publishing) and parents (tapping the
/// feed highlight), so everyone sees the exact same show.
Future<void> showStarReveal(StarOfWeekModel star) async {
  await Get.to<void>(
    () => StarRevealView(star: star),
    fullscreenDialog: true,
    transition: Transition.fadeIn,
    duration: const Duration(milliseconds: 350),
    opaque: true,
  );
}

class StarRevealView extends StatefulWidget {
  const StarRevealView({super.key, required this.star});

  final StarOfWeekModel star;

  @override
  State<StarRevealView> createState() => _StarRevealViewState();
}

class _StarRevealViewState extends State<StarRevealView>
    with TickerProviderStateMixin {
  late final AnimationController _reveal;
  late final AnimationController _glow;
  late final ConfettiController _leftConfetti;
  late final ConfettiController _rightConfetti;
  late final ConfettiController _burst;

  static const _gold = Color(0xFFF5C542);

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _leftConfetti = ConfettiController(duration: const Duration(seconds: 2));
    _rightConfetti = ConfettiController(duration: const Duration(seconds: 2));
    _burst = ConfettiController(duration: const Duration(seconds: 1));

    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _reveal.forward();
    _burst.play();
    _leftConfetti.play();
    _rightConfetti.play();
  }

  /// Load the nursery branding, then preview + share a celebratory image.
  Future<void> _share() async {
    final id = SessionService().nurseryId ?? '';
    String name = '';
    String? logo;
    await Get.find<NurseryParentService>().getAll(callBack: (list) {
      final nurseries = list.whereType<NurseryModel>();
      if (nurseries.isEmpty) return;
      final n = nurseries.firstWhere(
        (x) => x.key == id,
        orElse: () => nurseries.first,
      );
      name = n.name;
      logo = n.logo;
    });

    final card = StarShareCard(
      childName: widget.star.childName,
      childPhotoUrl: widget.star.childPhotoUrl,
      caption: widget.star.caption,
      nurseryName: name,
      nurseryLogo: logo,
    );

    Get.bottomSheet(
      AssessmentSharePreviewSheet(
        card: card,
        title: 'star_share_preview_title'.tr,
        subtitle: 'star_share_preview_sub'.tr,
        accent: const Color(0xFF7C3AED),
        onShare: () {
          Get.back();
          captureAndShareAssessment(
            card: card,
            shareText:
                'star_share_text'.trParams({'name': widget.star.childName}),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  void dispose() {
    _reveal.dispose();
    _glow.dispose();
    _leftConfetti.dispose();
    _rightConfetti.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFF190A3A),
        body: Stack(
          children: [
            // Deep radial glow behind everything.
            const Positioned.fill(child: _BackdropGlow()),
            const Positioned.fill(child: StarTwinkleField()),
            // Confetti sources.
            _confetti(_leftConfetti, const Alignment(-1, -1), 0.5),
            _confetti(_rightConfetti, const Alignment(1, -1), 2.6),
            Align(
              alignment: const Alignment(0, -0.15),
              child: _burstConfetti(),
            ),
            // The star.
            SafeArea(
              child: StarRevealStage(
                star: widget.star,
                reveal: _reveal,
                glow: _glow,
                gold: _gold,
              ),
            ),
            // Close.
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: _CloseButton(reveal: _reveal),
            ),
            // Share on social (fades in with the reveal).
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + 24,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _reveal,
                  curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
                ),
                child: Center(child: _ShareButton(onTap: _share)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confetti(
    ConfettiController c,
    Alignment align,
    double direction,
  ) {
    return Align(
      alignment: align,
      child: ConfettiWidget(
        confettiController: c,
        blastDirection: direction,
        emissionFrequency: 0.04,
        numberOfParticles: 12,
        maxBlastForce: 22,
        minBlastForce: 8,
        gravity: 0.25,
        shouldLoop: false,
        colors: const [
          _gold,
          Color(0xFFFFFFFF),
          Color(0xFF8B72EF),
          Color(0xFFEC4899),
          Color(0xFF34D399),
        ],
      ),
    );
  }

  Widget _burstConfetti() {
    return ConfettiWidget(
      confettiController: _burst,
      blastDirectionality: BlastDirectionality.explosive,
      emissionFrequency: 0.0,
      numberOfParticles: 26,
      maxBlastForce: 26,
      minBlastForce: 10,
      gravity: 0.3,
      shouldLoop: false,
      colors: const [
        _gold,
        Color(0xFFFFFFFF),
        Color(0xFF8B72EF),
        Color(0xFFEC4899),
      ],
    );
  }
}

// ─── Backdrop radial glow ──────────────────────────────────────────────────────

class _BackdropGlow extends StatelessWidget {
  const _BackdropGlow();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.1,
          colors: [
            Color(0xFF3B1E73),
            Color(0xFF190A3A),
            Color(0xFF0E0524),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

// ─── Close button (fades in with the reveal) ───────────────────────────────────

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.reveal});

  final AnimationController reveal;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: reveal,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
      child: IconButton(
        onPressed: () => Get.back<void>(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ─── Share-on-social button (gold pill) ────────────────────────────────────────

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.onTap});

  final VoidCallback onTap;

  static const _gold = Color(0xFFF5C542);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_gold, Color(0xFFEBB431)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _gold.withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.ios_share_rounded,
                color: Color(0xFF3B1E73), size: 19),
            const SizedBox(width: 8),
            Text(
              'star_share_button'.tr,
              style: context.typography.smSemiBold
                  .copyWith(color: const Color(0xFF3B1E73)),
            ),
          ],
        ),
      ),
    );
  }
}
