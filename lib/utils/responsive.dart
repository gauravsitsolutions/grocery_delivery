import 'package:flutter/material.dart';

class R {
  static late double _w;
  static late double _h;
  static late double _scale;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Base design size (iPhone 11)
    const baseWidth = 375.0;
    const baseHeight = 812.0;

    _w = size.width / baseWidth;
    _h = size.height / baseHeight;

    // Use the smaller scale to avoid overflow on short screens
    _scale = _w < _h ? _w : _h;
  }

  /// Font size (safe on all screens)
  static double sp(double size) =>
      (size * _scale).clamp(size * 0.85, size * 1.15);

  /// Width scaling
  static double w(double size) => size * _w;

  /// Height scaling (safe)
  static double h(double size) => (size * _h).clamp(size * 0.9, size * 1.1);

  /// Radius scaling
  static double r(double size) => size * _scale;
}
