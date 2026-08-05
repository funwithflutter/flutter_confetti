import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:confetti/src/particle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

  group('ParticleSystem', () {
    test('updates colors via setter', () {
      final system = ParticleSystem(
        emissionFrequency: 0.02,
        numberOfParticles: 10,
        maxBlastForce: 20,
        minBlastForce: 5,
        gravity: 0.2,
        blastDirection: pi,
        blastDirectionality: BlastDirectionality.directional,
        colors: const [Colors.blue],
        minimumSize: const Size(20, 10),
        maximumSize: const Size(30, 15),
        particleDrag: 0.05,
      );

      system.colors = const [Colors.red];

      // Start emission to generate particles
      system.startParticleEmission();
      system.screenSize = const Size(400, 800);
      system.update(0.016);

      final particles = system.particles;
      expect(particles.isNotEmpty, isTrue);
      // All generated particles should use the updated color (red, not blue)
      for (final particle in particles) {
        expect(particle.color, equals(Colors.red));
      }
    });

    test('colors setter affects newly generated particles', () {
      final system = ParticleSystem(
        emissionFrequency: 0.02,
        numberOfParticles: 10,
        maxBlastForce: 20,
        minBlastForce: 5,
        gravity: 0.2,
        blastDirection: pi,
        blastDirectionality: BlastDirectionality.directional,
        colors: const [Colors.blue],
        minimumSize: const Size(20, 10),
        maximumSize: const Size(30, 15),
        particleDrag: 0.05,
      );

      system.startParticleEmission();
      system.screenSize = const Size(400, 800);
      system.update(0.016);

      // First batch should be blue
      for (final particle in system.particles) {
        expect(particle.color, equals(Colors.blue));
      }

      // Update colors and generate new particles
      system.colors = const [Colors.green];
      system.stopParticleEmission(clearAllParticles: true);
      system.update(0.016); // finish

      system.startParticleEmission();
      system.update(0.016);

      // New batch should be green
      for (final particle in system.particles) {
        expect(particle.color, equals(Colors.green));
      }
    });
  });

  testWidgets('ConfettiWidget rebuilds with updated colors', (tester) async {
    final controller = ConfettiController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConfettiWidget(
            confettiController: controller,
            colors: const [Colors.blue],
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConfettiWidget(
            confettiController: controller,
            colors: const [Colors.red],
          ),
        ),
      ),
    );

    // Widget should not throw when rebuilt with new colors
    expect(tester.takeException(), isNull);

    controller.dispose();
  });
}
