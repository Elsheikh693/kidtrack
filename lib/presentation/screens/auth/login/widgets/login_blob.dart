import '../../../../../index/index_main.dart';

class LoginBlob extends StatelessWidget {
  const LoginBlob({super.key, required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white.withValues(alpha: opacity),
        ),
      );
}
