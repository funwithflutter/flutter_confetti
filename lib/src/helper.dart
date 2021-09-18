import 'dart:math';
import 'dart:ui' as ui;

final _rand = Random();

double randomize(double min, double max) {
  return ui.lerpDouble(min, max, _rand.nextDouble())!;
}
