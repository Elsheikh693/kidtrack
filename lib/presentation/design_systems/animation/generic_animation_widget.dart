import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GenericAnimationWidget extends StatelessWidget {
  final String animationFileName;

  const GenericAnimationWidget({super.key, required this.animationFileName});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      animationFileName,
      repeat: true,
      // تعيد التشغيل
      reverse: false,
      // ممكن تخليها true لو عايزها بالعكس
      animate: true, // تتحرك تلقائيًا
    );
  }
}
