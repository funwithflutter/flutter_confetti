import 'dart:math';
import 'dart:ui' as ui;

final _rand = Random();

double randomize(double min, double max) {
  return ui.lerpDouble(min, max, _rand.nextDouble());
}

void debugPrint(String message) {
  assert(() {
    print('__debug__confetti__$message');
    return true;
  }());
}
