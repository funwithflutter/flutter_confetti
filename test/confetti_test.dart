import 'package:flutter_test/flutter_test.dart';

import 'package:confetti/confetti.dart';

void main() {
  group('ConfettiController', () {
    test('throws assertion error when `duration` is not positive', () {
      expect(() => ConfettiController(duration: const Duration(days: -20)),
          throwsAssertionError);

      expect(() => ConfettiController(duration: const Duration(seconds: 0)),
          throwsAssertionError);

      expect(
          () => ConfettiController(duration: const Duration(milliseconds: 0)),
          throwsAssertionError);

      expect(
          () => ConfettiController(duration: const Duration(microseconds: 0)),
          throwsAssertionError);
    });
  });
}
