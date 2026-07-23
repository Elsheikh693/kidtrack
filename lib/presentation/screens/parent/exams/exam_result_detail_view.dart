import 'package:confetti/confetti.dart';

import '../../../../index/index_main.dart';
import '../../shared/assessment/assessment_share.dart';
import '../../shared/exams/exam_grade_meta.dart';
import '../../shared/exams/exam_share_card.dart';
import 'widgets/exam_reveal_stage.dart';

/// Full-screen celebratory reveal of one exam result for the parent: confetti,
/// the grade popping in, and a branded social share. Grade colour themes the
/// whole scene.
class ExamResultDetailView extends StatefulWidget {
  const ExamResultDetailView({
    super.key,
    required this.result,
    required this.childName,
    required this.nurseryName,
    required this.nurseryLogo,
  });

  final ExamResultModel result;
  final String childName;
  final String nurseryName;
  final String? nurseryLogo;

  @override
  State<ExamResultDetailView> createState() => _ExamResultDetailViewState();
}

class _ExamResultDetailViewState extends State<ExamResultDetailView>
    with TickerProviderStateMixin {
  late final AnimationController _reveal;
  late final AnimationController _glow;
  late final ConfettiController _leftConfetti;
  late final ConfettiController _rightConfetti;
  late final ConfettiController _burst;

  ExamGrade get _grade =>
      ExamGrade.fromKey(widget.result.grade) ?? ExamGrade.good;

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _glow = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat();
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

  @override
  void dispose() {
    _reveal.dispose();
    _glow.dispose();
    _leftConfetti.dispose();
    _rightConfetti.dispose();
    _burst.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    await captureAndShareAssessment(
      shareText: '${'exam_share_text'.tr} ${widget.nurseryName}',
      card: ExamShareCard(
        childName: widget.childName,
        nurseryName: widget.nurseryName,
        nurseryLogo: widget.nurseryLogo,
        grade: _grade,
        subject: widget.result.subjectName,
        title: widget.result.examTitle,
        date: widget.result.examDate,
        paperUrl: widget.result.paperUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = ExamGradeMeta.of(_grade);
    final deep = Color.lerp(meta.color, Colors.black, 0.5) ?? meta.color;
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: deep,
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.3),
                    radius: 1.15,
                    colors: [meta.color, deep],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
            _confetti(_leftConfetti, const Alignment(-1, -1), 0.5, meta.color),
            _confetti(_rightConfetti, const Alignment(1, -1), 2.6, meta.color),
            Align(
              alignment: const Alignment(0, -0.2),
              child: _burstConfetti(meta.color),
            ),
            SafeArea(
              child: ExamRevealStage(
                result: widget.result,
                childName: widget.childName,
                reveal: _reveal,
                glow: _glow,
                onShare: _share,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: IconButton(
                onPressed: () => Get.back<void>(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 22),
                ),
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
    Color themed,
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
        colors: [
          Colors.white,
          themed,
          const Color(0xFFFFC93C),
          const Color(0xFFEC4899),
          const Color(0xFF34D399),
        ],
      ),
    );
  }

  Widget _burstConfetti(Color themed) {
    return ConfettiWidget(
      confettiController: _burst,
      blastDirectionality: BlastDirectionality.explosive,
      emissionFrequency: 0.0,
      numberOfParticles: 26,
      maxBlastForce: 26,
      minBlastForce: 10,
      gravity: 0.3,
      shouldLoop: false,
      colors: [
        Colors.white,
        themed,
        const Color(0xFFFFC93C),
        const Color(0xFFEC4899),
      ],
    );
  }
}
