import 'package:flutter/material.dart'; // Import the necessary package

/// {@template app_shadow}
/// Shadow class contains all shadows used in app
/// {@endtemplate}
class AppShadow {
  AppShadow._();

  /// Small shadow.
  static const List<BoxShadow> dealsCartTopShadow = [
    BoxShadow(
      color: Color(0x1018280F), // Shadow color
      offset: Offset(0, 2), // X and Y offset
      blurRadius: 1, // Blur radius
      spreadRadius: 2, // Spread radius
    ),
    BoxShadow(
      color: Color(0x1018281A), // Second shadow color
      offset: Offset(0, 2), // X and Y offset
      blurRadius: 1, // Blur radius
      spreadRadius: 2, // Spread radius
    ),
  ];
}
