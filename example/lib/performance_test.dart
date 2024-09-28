import 'dart:math';

import 'package:flutter/material.dart';

import 'package:confetti/confetti.dart';

void main() => runApp(const ConfettiPerformanceTestSample());

class ConfettiPerformanceTestSample extends StatelessWidget {
  const ConfettiPerformanceTestSample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Confetti Performance Test',
        showPerformanceOverlay: true,
        home: Scaffold(
          backgroundColor: Colors.grey[900],
          body: MyApp(),
        ),
      );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ConfettiController _confettiController;

  final ConfettiStats stats = ConfettiStats();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 10),

      /// The following can be used to retrieve stats on the particles.
      particleStatsCallback: (pStats) => stats.setStats(pStats),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degrees to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              emissionFrequency: 1,
              numberOfParticles: 100,
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: true,
              createParticlePath: drawStar,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    _confettiController.play();
                  },
                  child: _text('start'),
                ),
                TextButton(
                  onPressed: () {
                    _confettiController.stop();
                  },
                  child: _text('stop'),
                ),
                TextButton(
                  onPressed: () {
                    _confettiController.dispose();
                  },
                  child: _text('dispose'),
                ),
              ],
            ),
          ),

          /// Display stats of confetti
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedBuilder(
              animation: stats,
              builder: (context, _) => Column(
                children: [
                  Text(
                    'Particles: ${stats.stats.numberOfParticles}',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  Text(
                    'Active Particles: ${stats.stats.activeNumberOfParticles}',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text _text(String text) => Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      );
}

/// Demonstration showing how to use the `particleStatsCallback` to retrieve
/// [ParticleStats].
class ConfettiStats extends ChangeNotifier {
  ParticleStats stats;
  ConfettiStats() : stats = ParticleStats.empty();

  void setStats(ParticleStats value) {
    stats = value;
    notifyListeners();
  }
}
