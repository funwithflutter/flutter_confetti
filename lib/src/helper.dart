import 'dart:math' show Random;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

final _rand = Random();

abstract class Helper {
  static double randomize(double min, double max) =>
      lerpDouble(min, max, _rand.nextDouble())!;

  static Color randomColor() =>
      Colors.primaries[_rand.nextInt(Colors.primaries.length)];

  static bool randomBool() => _rand.nextBool();
}
