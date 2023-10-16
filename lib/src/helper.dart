import 'dart:math' show Random;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

final _rand = Random.secure();

class Helper {
  static double randomize(double min, double max) {
    return lerpDouble(min, max, _rand.nextDouble())!;
  }

  static Color randomColor() {
    return Colors.primaries[Random.secure().nextInt(Colors.primaries.length)];
  }
}
