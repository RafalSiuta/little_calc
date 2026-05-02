import 'package:flutter/material.dart';

Color formatColorOpacity(Color color, double opacity) {
  final normalizedOpacity = opacity.clamp(0.0, 1.0).toDouble();

  return Color.fromRGBO(
    (color.r * 255.0).round() & 0xff,
    (color.g * 255.0).round() & 0xff,
    (color.b * 255.0).round() & 0xff,
    normalizedOpacity,
  );
}
