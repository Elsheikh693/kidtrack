import 'package:flutter/material.dart';

class IdleWaveClipper extends CustomClipper<Path> {
  const IdleWaveClipper({required this.t});
  final double t;

  @override
  Path getClip(Size size) {
    final amp = 28.0 * (1.0 - t);
    final path = Path();
    path.lineTo(0, size.height - amp);
    path.quadraticBezierTo(
      size.width * 0.28,
      size.height + amp * 0.14,
      size.width * 0.52,
      size.height - amp * 0.57,
    );
    path.quadraticBezierTo(
      size.width * 0.76,
      size.height - amp * 1.14,
      size.width,
      size.height - amp * 0.30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(IdleWaveClipper old) => old.t != t;
}
