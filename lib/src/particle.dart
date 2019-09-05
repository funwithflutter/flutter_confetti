import 'dart:math';

import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'package:vector_math/vector_math.dart' as vmath;

import 'package:confetti/src/helper.dart';

enum ParticleSystemStatus {
  started,
  finished,
  stopped,
}

class ParticleSystem extends ChangeNotifier {
  ParticleSystem({
    @required double emissionFrequency,
    @required int numberOfParticles,
    @required double maxBlastForce,
    @required double minBlastForce,
    @required double blastDirection,
  })  : assert(emissionFrequency != null &&
            numberOfParticles != null &&
            maxBlastForce != null &&
            minBlastForce != null &&
            blastDirection != null),
        assert(maxBlastForce > 0 &&
            minBlastForce > 0 &&
            emissionFrequency >= 0 &&
            emissionFrequency <= 1 &&
            numberOfParticles > 0),
        _blastDirection = blastDirection,
        _maxBlastForce = maxBlastForce,
        _minBlastForce = minBlastForce,
        _frequency = emissionFrequency,
        _numberOfParticles = numberOfParticles,
        _rand = Random();

  ParticleSystemStatus _particleSystemStatus;

  List<Particle> _particles;

  /// A frequency between 0 and 1 to determine how often the emitter
  /// should emit new particles.
  final double _frequency;
  final int _numberOfParticles;
  final double _maxBlastForce;
  final double _minBlastForce;
  final double _blastDirection;

  Offset _particleSystemPosition;
  Size _screenSize;

  double _bottomBorder;
  double _rightBorder;
  double _leftBorder;

  final Random _rand;

  set particleSystemPosition(Offset position) {
    _particleSystemPosition = position;
  }

  set screenSize(Size size) {
    _screenSize = size;
    _setScreenBorderPositions(); // needs to be called here to only set the borders once
  }

  void stopParticleEmission() {
    _particleSystemStatus = ParticleSystemStatus.stopped;
  }

  void startParticleEmission() {
    _particleSystemStatus = ParticleSystemStatus.started;
  }

  void finishParticleEmission() {
    _particleSystemStatus = ParticleSystemStatus.finished;
  }

  List<Particle> get particles => _particles;
  ParticleSystemStatus get particleSystemStatus => _particleSystemStatus;

  void update() {
    _clean();
    if (_particleSystemStatus != ParticleSystemStatus.finished) {
      _updateParticles();
    }

    if (_particleSystemStatus == ParticleSystemStatus.started) {
      // Determines whether to generate new particles based on the [frequency]
      final chanceToGenerate = _rand.nextDouble();
      if (chanceToGenerate < _frequency) {
        _generateParticles(number: _numberOfParticles);
      }
    }

    if (_particleSystemStatus == ParticleSystemStatus.stopped &&
        _particles.isEmpty) {
      finishParticleEmission();
      notifyListeners();
    }
  }

  void _setScreenBorderPositions() {
    _bottomBorder = _screenSize.height * 1.1;
    _rightBorder = _screenSize.width * 1.1;
    _leftBorder = _screenSize.width - _rightBorder;
  }

  void _updateParticles() {
    if (particles == null) {
      return;
    }
    for (final particle in _particles) {
      particle.update();
    }
  }

  void _clean() {
    if (_particleSystemPosition != null && _screenSize != null && particles != null) {
      _particles.removeWhere((particle) => _isOutsideOfBorder(particle.location));
    }
  }

  bool _isOutsideOfBorder(Offset particleLocation) {
    final globalParticlePosition = particleLocation + _particleSystemPosition;
    return (globalParticlePosition.dy >= _bottomBorder) ||
        (globalParticlePosition.dx >= _rightBorder) ||
        (globalParticlePosition.dx <= _leftBorder);
  }

  void _generateParticles({int number = 1}) {
    final _newParticles =
        List<Particle>.generate(number, (i) => Particle(_generateParticleForce()));
    if (_particles != null) {
      _particles.addAll(_newParticles);
    } else {
      _particles = _newParticles;
    }
  }

  vmath.Vector2 _generateParticleForce() {
    final blastRadius = randomize(_minBlastForce, _maxBlastForce);
    final y = blastRadius * sin(_blastDirection);
    final x = blastRadius * cos(_blastDirection);
    return vmath.Vector2(x, y);
  }
}

class Particle {
  Particle(vmath.Vector2 startUpForce)
      : _startUpForce = startUpForce,
        _color = RandomColor().randomColor(),
        _mass = randomize(1, 11),
        _location = vmath.Vector2.zero(),
        _acceleration = vmath.Vector2.zero(),
        _velocity = vmath.Vector2(randomize(-3, 3), randomize(-3, 3)),
        _size = Size(randomize(20, 30), randomize(10, 15)),
        _aVelocityX = randomize(-0.1, 0.1),
        _aVelocityY = randomize(-0.1, 0.1),
        _aVelocityZ = randomize(-0.1, 0.1);

  vmath.Vector2 _startUpForce;

  vmath.Vector2 _location;
  vmath.Vector2 _velocity;
  vmath.Vector2 _acceleration;

  double _aX = 0;
  double _aVelocityX;
  double _aY = 0;
  double _aVelocityY;
  double _aZ = 0;
  double _aVelocityZ;
  final _aAcceleration = 0.0001;

  final Color _color;
  final double _mass;
  final Size _size;

  double _timeAlive = 0;

  void applyForce(vmath.Vector2 force) {
    final f = force.clone();
    f.divide(vmath.Vector2.all(_mass));
    _acceleration.add(f);
  }

  void drag() {
    const c = 0.05;
    final speed = sqrt(pow(_velocity.x, 2) + pow(_velocity.y, 2));
    final dragMagnitude = c * speed * speed;
    final drag = _velocity.clone();
    drag.multiply(vmath.Vector2.all(-1));
    drag.normalize();
    drag.multiply(vmath.Vector2.all(dragMagnitude));
    applyForce(drag);
  }

  void _applyStartUpFoce() {
    applyForce(_startUpForce);
  }

  void _applyWindForceUp() {
    applyForce(vmath.Vector2(0, -1));
  }

  void update() {
    drag();

    if (_timeAlive < 5) {
      _applyStartUpFoce();
    }
    if (_timeAlive < 25) {
      _applyWindForceUp();
    }

    _timeAlive += 1;

    applyForce(vmath.Vector2(0, 0.3));

    _velocity.add(_acceleration);
    _location.add(_velocity);
    _acceleration.multiply(vmath.Vector2.zero());

    _aVelocityX += _aAcceleration / _mass;
    _aVelocityY += _aAcceleration / _mass;
    _aVelocityZ += _aAcceleration / _mass;
    _aX += _aVelocityX;
    _aY += _aVelocityY;
    _aZ += _aVelocityZ;
  }

  Offset get location {
    if (_location.x.isNaN || _location.y.isNaN) {
      return const Offset(0, 0);
    }
    return Offset(_location.x, _location.y);
  }

  Color get color => _color;
  Size get size => _size;

  double get angleX => _aX;
  double get angleY => _aY;
  double get angleZ => _aZ;
}
