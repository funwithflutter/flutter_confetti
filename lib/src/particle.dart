import 'dart:math';
import 'dart:ui';

import 'package:confetti/src/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vmath;

import 'package:confetti/src/helper.dart';

import 'enums/blast_directionality.dart';

/// {@template particle_system_status}
/// Represents the current status of the particle system.
///
/// This enum has three possible values:
/// - `started`: the particle system has been started and is currently running.
/// - `finished`: the particle system has finished running and is no longer active.
/// - `stopped`: the particle system has been manually stopped and is no longer active.
/// {@endtemplate}
enum ParticleSystemStatus {
  started,
  finished,
  stopped,
}

class ParticleSystem extends ChangeNotifier {
  ParticleSystem({
    required double emissionFrequency,
    required int numberOfParticles,
    required double maxBlastForce,
    required double minBlastForce,
    required double blastDirection,
    required BlastDirectionality blastDirectionality,
    required List<Color>? colors,
    required Size minimumSize,
    required Size maximumSize,
    required double particleDrag,
    required double gravity,
    Path Function(Size size)? createParticlePath,
  })  : assert(maxBlastForce > 0 &&
            minBlastForce > 0 &&
            emissionFrequency >= 0 &&
            emissionFrequency <= 1 &&
            numberOfParticles > 0 &&
            minimumSize.width > 0 &&
            minimumSize.height > 0 &&
            maximumSize.width > 0 &&
            maximumSize.height > 0 &&
            minimumSize.width <= maximumSize.width &&
            minimumSize.height <= maximumSize.height &&
            particleDrag >= 0.0 &&
            particleDrag <= 1 &&
            minimumSize.height <= maximumSize.height),
        assert(gravity >= 0 && gravity <= 1),
        _blastDirection = blastDirection,
        _blastDirectionality = blastDirectionality,
        _gravity = gravity,
        _maxBlastForce = maxBlastForce,
        _minBlastForce = minBlastForce,
        _frequency = emissionFrequency,
        _numberOfParticles = numberOfParticles,
        _colors = colors,
        _minimumSize = minimumSize,
        _maximumSize = maximumSize,
        _particleDrag = particleDrag,
        _rand = Random(),
        _createParticlePath = createParticlePath;

  ParticleSystemStatus? _particleSystemStatus;

  final List<Particle> _particles = [];

  /// A frequency between 0 and 1 to determine how often the emitter
  /// should emit new particles.
  final double _frequency;
  final int _numberOfParticles;
  final double _maxBlastForce;
  final double _minBlastForce;
  final double _blastDirection;
  final BlastDirectionality _blastDirectionality;
  final double _gravity;
  final List<Color>? _colors;
  final Size _minimumSize;
  final Size _maximumSize;
  final double _particleDrag;
  final Path Function(Size size)? _createParticlePath;

  Offset _particleSystemPosition = Offset.zero;
  Size _screenSize = Size.zero;

  late double _bottomBorder;
  late double _rightBorder;
  late double _leftBorder;

  final Random _rand;

  set particleSystemPosition(Offset position) {
    _particleSystemPosition = position;
  }

  set screenSize(Size size) {
    _screenSize = size;
    // needs to be called here to only set the borders once
    _setScreenBorderPositions();
  }

  void stopParticleEmission({bool clearAllParticles = false}) {
    _particleSystemStatus = ParticleSystemStatus.stopped;
    if (clearAllParticles) {
      _particles.clear();
    }
  }

  void startParticleEmission() {
    _particleSystemStatus = ParticleSystemStatus.started;
  }

  void finishParticleEmission() {
    _particles.clear();
    _particleSystemStatus = ParticleSystemStatus.finished;
  }

  /// List of all [Particle]s.
  List<Particle> get particles => _particles;

  /// The number of particles in memory. Consists of active and deactive
  /// particles.
  ///
  /// Old particles that are no longer visible are deactivated, and reused when
  /// needed. New particles are only created when there is an insuffient number
  /// of deactive particles in memory.
  int get numberOfParticles => _particles.length;

  /// The number of active particles currently animating and visible.
  ///
  /// This is not the same as [numberOfParticles].
  int get activeNumberOfParticles => _particles.fold(
        0,
        (previousValue, element) {
          if (element.active) {
            return previousValue + 1;
          } else {
            return previousValue;
          }
        },
      );

  /// {@macro particle_system_status}
  ParticleSystemStatus? get particleSystemStatus => _particleSystemStatus;

  /// Update the particle system animation by moving it forward.
  void update(double deltaTime, {bool pauseEmission = false}) {
    if (_particleSystemStatus != ParticleSystemStatus.finished) {
      _updateParticles(deltaTime);
    }

    if ((_particleSystemStatus == ParticleSystemStatus.stopped) &&
        _particles.isEmpty) {
      finishParticleEmission();
      notifyListeners();
    }

    // Return early if pauseEmission is true
    if (pauseEmission) return;

    if (_particleSystemStatus == ParticleSystemStatus.started) {
      // If there are no particles then immediately generate particles
      // This also ensures that particles are emitted on the first frame
      if (particles.isEmpty) {
        _addParticles(_particles, number: _numberOfParticles);
        return;
      }

      // Determines whether to generate new particles based on the [frequency]
      final chanceToGenerate = _rand.nextDouble();
      if (chanceToGenerate < _frequency) {
        _addParticles(_particles, number: _numberOfParticles);
      }
    }
  }

  void _setScreenBorderPositions() {
    _bottomBorder = _screenSize.height * 1.1;
    _rightBorder = _screenSize.width * 1.1;
    _leftBorder = _screenSize.width - _rightBorder;
  }

  void _updateParticles(double deltaTime) {
    // remove particles from memory if system is stopped, update and return
    if (_particleSystemStatus == ParticleSystemStatus.stopped) {
      _particles
          .removeWhere((particle) => _isOutsideOfBorder(particle.location));
      for (final particle in _particles) {
        particle.update(deltaTime);
      }
      return;
    }

    // deactivate particles no longer visible and update rest
    for (final particle in _particles) {
      if (_isOutsideOfBorder(particle.location)) {
        particle.deactivate();
        continue;
      }
      particle.update(deltaTime);
    }
  }

  bool _isOutsideOfBorder(Offset particleLocation) {
    final globalParticlePosition = particleLocation + _particleSystemPosition;
    return (globalParticlePosition.dy >= _bottomBorder) ||
        (globalParticlePosition.dx >= _rightBorder) ||
        (globalParticlePosition.dx <= _leftBorder);
  }

  void _addParticles(List<Particle> particles, {int number = 1}) {
    int count = 0;

    for (final particle in particles) {
      if (!particle.active) {
        particle.reactivate();
        count++;
        if (count == number) {
          return; // exit early, no need to generate more particles
        }
      }
    }

    // create more particles not enough in memory
    for (var i = 0; i < number - count; i++) {
      particles.add(
        Particle(
          _randomColor(),
          _randomSize(),
          _gravity,
          _particleDrag,
          _createParticlePath,
          generateParticleForceCallback: _generateParticleForce,
        ),
      );
    }
  }

  double get _randomBlastDirection =>
      vmath.radians(Random().nextInt(359).toDouble());

  vmath.Vector2 _generateParticleForce() {
    var blastDirection = _blastDirection;
    if (_blastDirectionality == BlastDirectionality.explosive) {
      blastDirection = _randomBlastDirection;
    }
    final blastRadius = Helper.randomize(_minBlastForce, _maxBlastForce);
    final y = blastRadius * sin(blastDirection);
    final x = blastRadius * cos(blastDirection);
    return vmath.Vector2(x, y);
  }

  Color _randomColor() {
    if (_colors != null) {
      if (_colors!.length == 1) {
        return _colors![0];
      }
      final index = _rand.nextInt(_colors!.length);
      return _colors![index];
    }
    return Helper.randomColor();
  }

  Size _randomSize() {
    return Size(
      Helper.randomize(_minimumSize.width, _maximumSize.width),
      Helper.randomize(_minimumSize.height, _maximumSize.height),
    );
  }
}

typedef GenerateParticleForceCallback = vmath.Vector2 Function();

class Particle {
  Particle(
    Color color,
    Size size,
    this.gravity,
    double particleDrag,
    Path Function(Size size)? createParticlePath, {
    required this.generateParticleForceCallback,
  })  : _startUpForce = generateParticleForceCallback(),
        _color = color,
        _mass = Helper.randomize(1, 11),
        _particleDrag = particleDrag,
        _location = vmath.Vector2.zero(),
        _acceleration = vmath.Vector2.zero(),
        _velocity =
            vmath.Vector2(Helper.randomize(-3, 3), Helper.randomize(-3, 3)),
        _pathShape = createParticlePath != null
            ? createParticlePath(size)
            : createPath(size),
        _aVelocityX = Helper.randomize(-0.1, 0.1),
        _aVelocityY = Helper.randomize(-0.1, 0.1),
        _aVelocityZ = Helper.randomize(-0.1, 0.1),
        _rotateZ = Helper.randomBool(),
        gravityVector = vmath.Vector2(
          0,
          lerpDouble(0.1, 5, gravity)!,
        ),
        _active = true;

  final double gravity;

  final vmath.Vector2 _startUpForce;
  final GenerateParticleForceCallback generateParticleForceCallback;

  final vmath.Vector2 _location;
  final vmath.Vector2 _velocity;
  final vmath.Vector2 _acceleration;

  final double _particleDrag;
  double _aX = 0;
  double _aVelocityX;
  double _aY = 0;
  double _aVelocityY;
  double _aZ = 0;
  double _aVelocityZ;
  final vmath.Vector2 gravityVector;
  late final _aAcceleration = 0.0001 / _mass;

  final Color _color;
  final double _mass;
  final Path _pathShape;

  bool _active;
  bool get active => _active;

  final bool _rotateZ;

  double _timeAlive = 0;
  vmath.Vector2 windforceUp = vmath.Vector2(0, -1);

  static Path createPath(Size size) {
    final pathShape = Path()
      ..moveTo(0, 0)
      ..lineTo(-size.width, 0)
      ..lineTo(-size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // TODO: remove when this is fixed: https://github.com/funwithflutter/flutter_confetti/issues/66
    if (kIsWeb) {
      pathShape
        ..lineTo(-size.width, 0)
        ..lineTo(-size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    }

    return pathShape;
  }

  void reactivate() {
    _timeAlive = 0;

    final f = generateParticleForceCallback();
    _startUpForce.setValues(f.x, f.y);

    _location.setValues(0, 0);
    _acceleration.setValues(0, 0);
    _velocity.setValues(Helper.randomize(-3, 3), Helper.randomize(-3, 3));

    _aX = 0;
    _aY = 0;
    _aZ = 0;
    _aVelocityX = Helper.randomize(-0.1, 0.1);
    _aVelocityY = Helper.randomize(-0.1, 0.1);
    _aVelocityZ = Helper.randomize(-0.1, 0.1);

    gravityVector.setValues(
      0,
      lerpDouble(0.1, 5, gravity)!,
    );

    _active = true;
  }

  void deactivate() {
    _active = false;
  }

  void applyForce(vmath.Vector2 force, double deltaTimeSpeed) {
    final f = force.clone()..divide(vmath.Vector2.all(_mass));
    _acceleration.add(f * deltaTimeSpeed);
  }

  void drag(double deltaTimeSpeed) {
    final speed = sqrt(pow(_velocity.x, 2) + pow(_velocity.y, 2));
    final dragMagnitude = _particleDrag * speed * speed;
    final drag = _velocity.clone()
      ..multiply(vmath.Vector2.all(-1))
      ..normalize()
      ..multiply(vmath.Vector2.all(dragMagnitude));
    applyForce(drag, deltaTimeSpeed);
  }

  void update(double deltaTime) {
    final deltaTimeSpeed = deltaTime * desiredSpeed;
    drag(deltaTimeSpeed);

    if (_timeAlive < 5) {
      applyForce(_startUpForce, deltaTimeSpeed);
    }
    if (_timeAlive < 25) {
      applyForce(windforceUp, deltaTimeSpeed);
      _timeAlive += 1;
    }

    applyForce(gravityVector, deltaTimeSpeed);

    _velocity.add(_acceleration * deltaTimeSpeed);
    _location.add(_velocity * deltaTimeSpeed);
    _acceleration.setZero();

    _aVelocityX += _aAcceleration;
    _aX += _aVelocityX * deltaTimeSpeed;

    _aVelocityY += _aAcceleration;
    _aY += _aVelocityY * deltaTimeSpeed;

    if (_rotateZ) {
      _aZ += _aVelocityZ * deltaTimeSpeed;
      _aVelocityZ += _aAcceleration;
    }
  }

  Offset get location {
    if (_location.x.isNaN || _location.y.isNaN) {
      return const Offset(0, 0);
    }
    return Offset(_location.x, _location.y);
  }

  Color get color => _color;
  Path get path => _pathShape;

  double get angleX => _aX;
  double get angleY => _aY;
  double get angleZ => _aZ;

  bool get rotateZ => _rotateZ;
}
