import '../../../../index/index_main.dart';
import 'onboard_data.dart';
import 'onboard_scene.dart';

class OnboardPage extends StatefulWidget {
  const OnboardPage({super.key, required this.data});

  final OnboardData data;

  @override
  State<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  /// Staggered fade + slide for a text block. [start]/[end] are fractions of
  /// the intro timeline so the chip leads, then title, then subtitle.
  Widget _staggered({
    required double start,
    required double end,
    required Widget child,
  }) {
    final anim = CurvedAnimation(
      parent: _intro,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, 22 * (1 - anim.value)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: OnboardScene(data: d),
          ),
          _staggered(
            start: 0.0,
            end: 0.45,
            child:
                _Chip(text: d.chip, color: d.accentColor, light: d.accentLight),
          ),
          SizedBox(height: 16.h),
          _staggered(
            start: 0.18,
            end: 0.7,
            child: Text(
              d.title,
              textAlign: TextAlign.center,
              style: context.typography.xxlBold.copyWith(
                fontSize: 27.sp,
                color: AppColors.textDefault,
                height: 1.32,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _staggered(
            start: 0.35,
            end: 1.0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                d.subtitle,
                textAlign: TextAlign.center,
                style: context.typography.smRegular.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.grayMedium,
                  height: 1.7,
                ),
              ),
            ),
          ),
          SizedBox(height: 22.h),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color, required this.light});

  final String text;
  final Color color;
  final Color light;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: light,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 7.w),
          Text(
            text,
            style: context.typography.smSemiBold.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
