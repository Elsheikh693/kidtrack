import '../../../../index/index_main.dart';

class OnboardDot extends StatelessWidget {
  const OnboardDot({super.key, required this.active, required this.color});

  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(right: 6.w),
      width: active ? 24.w : 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: active ? color : AppColors.grayLight,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }
}
