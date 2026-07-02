import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Svgicon extends StatelessWidget {
  final String icon;
  final Color? color;
  final double? height;
  final double? width;

  const Svgicon(
      {super.key, required this.icon, this.color, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      height: height,
      width: width,
    );
  }
}
