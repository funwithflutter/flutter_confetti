import 'dart:math';

import 'package:confetti/src/particle_stats.dart';
import 'package:confetti/src/constants.dart';
import 'package:confetti/src/particle.dart';
import 'package:flutter/material.dart';

import 'enums/blast_directionality.dart';
import 'enums/confetti_controller_state.dart';

class ConfettiWidget extends StatefulWidget {
  const ConfettiWidget({
    Key? key,
    required this.confettiController,
    this.emissionFrequency = 0.02,
    this.numberOfParticles = 10,
    this.maxBlastForce = 20,
    this.minBlastForce = 5,
    this.blastDirectionality = BlastDirectionality.directional,
    this.blastDirection = pi,
    this.gravity = 0.2,
    this.shouldLoop = false,
    this.displayTarget = false,
    this.colors,
    this.strokeColor = Colors.black,
    this.strokeWidth = 0,
    this.minimumSize = const Size(20, 10),
    this.maximumSize = const Size(30, 15),
    this.particleDrag = 0.05,
    this.canvas,
    this.pauseEmissionOnLowFrameRate = true,
    this.createParticlePath,
    this.child,
  })  : assert(
          emissionFrequency >= 0 &&
              emissionFrequency <= 1 &&
              numberOfParticles > 0 &&
              maxBlastForce > 0 &&
              minBlastForce > 0 &&
              maxBlastForce > minBlastForce,
        ),
        assert(gravity >= 0 && gravity <= 1,
            '`gravity` needs to be between 0 and 1'),
        assert(strokeWidth >= 0, '`strokeWidth needs to be bigger than 0'),
        super(key: key);

  /// Controls the animation.
  final ConfettiController confettiController;

  /// The [maxBlastForce] and [minBlastForce] will determine the maximum and
  /// minimum blast force applied to  a particle within it's first 5 frames of
  /// life. The default [maxBlastForce] is set to `20`
  final double maxBlastForce;

  /// The [maxBlastForce] and [minBlastForce] will determine the maximum and
  /// minimum blast force applied to a particle within it's first 5 frames of
  /// life. The default [minBlastForce] is set to `5`
  final double minBlastForce;

  /// {@macro blast_directionality}
  ///
  /// The default value is [BlastDirectionality.directional], the direction
  /// can be set with [blastDirection].
  final BlastDirectionality blastDirectionality;

  /// The [blastDirection] is a radial value to determine the direction of the
  /// particle emission.
  ///
  /// The default is set to `PI` (180 degrees).
  /// A value of `PI` will emit to the left of the canvas/screen.
  final double blastDirection;

  /// The [createParticlePath] is an optional function that returns a custom
  /// `Path` to generate particles.
  ///
  /// The default function returns a rectangular path.
  final Path Function(Size size)? createParticlePath;

  /// The [gravity] is the speed at which the confetti will fall.
  /// The higher the [gravity] the faster it will fall.
  ///
  /// It can be set to a value between `0` and `1`
  ///
  /// Default value is `0.1`
  final double gravity;

  /// The [emissionFrequency] should be a value between 0 and 1.
  /// The higher the value the higher the likelihood that particles will be
  /// emitted on a single frame.
  ///
  /// Default is set to `0.02` (2% chance).
  final double emissionFrequency;

  /// The [numberOfParticles] to be emitted per emission.
  ///
  /// Default is set to `10`.
  final int numberOfParticles;

  /// The [shouldLoop] attribute determines if the animation will
  /// reset once it completes, resulting in a continuous particle emission.
  final bool shouldLoop;

  /// The [displayTarget] attribute determines if a crosshair will be displayed
  /// to show the location of the particle emitter.
  final bool displayTarget;

  /// List of Colors to iterate over - if null then random values will be chosen
  final List<Color>? colors;

  /// Stroke width of the confetti (0.0 by default, no stroke)
  final double strokeWidth;

  /// Stroke color of the confetti (black by default, requires a strokeWidth > 0)
  final Color strokeColor;

  /// An optional parameter to set the minimum size potential size for
  /// the confetti.
  ///
  /// Must be smaller than the [maximumSize] attribute.
  final Size minimumSize;

  /// An optional parameter to set the maximum potential size for the confetti.
  /// Must be bigger than the [minimumSize] attribute.
  final Size maximumSize;

  /// An optional parameter to specify drag force, effecting the movement
  /// of the confetti.
  ///
  /// Using `1.0` will give no drag at all, while, for example, using `0.1`
  /// will give a lot of drag. Default is set to `0.05`.
  final double particleDrag;

  /// An optional parameter to specify the area size where the confetti will
  /// be thrown.
  ///
  /// By default this is set to the window size.
  final Size? canvas;

  /// If `true` new particles will not be created if the FPS is lower
  /// than 60. Default is `true`, set to `false` to ensure particles are always
  /// created, regardless of frame rate.
  final bool pauseEmissionOnLowFrameRate;

  /// Child widget to display
  final Widget? child;

  @override
  _ConfettiWidgetState createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey _particleSystemKey = GlobalKey();

  late AnimationController _animController;
  late Animation<double> _animation;
  late ParticleSystem _particleSystem;

  /// Keeps track of emition position on screen layout changes
  late Offset _emitterPosition;

  /// Keeps track of the screen size on layout changes.
  ///
  /// Controls the sizing restrictions for when confetti should be visible.
  Size _screenSize = const Size(0, 0);

  @override
  void initState() {
    super.initState();
    widget.confettiController.addListener(_handleChange);

    _particleSystem = ParticleSystem(
      emissionFrequency: widget.emissionFrequency,
      numberOfParticles: widget.numberOfParticles,
      maxBlastForce: widget.maxBlastForce,
      minBlastForce: widget.minBlastForce,
      gravity: widget.gravity,
      blastDirection: widget.blastDirection,
      blastDirectionality: widget.blastDirectionality,
      colors: widget.colors,
      minimumSize: widget.minimumSize,
      maximumSize: widget.maximumSize,
      particleDrag: widget.particleDrag,
      createParticlePath: widget.createParticlePath,
    );

    _particleSystem.addListener(_particleSystemListener);

    _initAnimation();
  }

  void _initAnimation() {
    _animController = AnimationController(
        vsync: this, duration: widget.confettiController.duration);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animController);
    _animation
      ..addListener(_animationListener)
      ..addStatusListener(_animationStatusListener);

    if (widget.confettiController.state == ConfettiControllerState.playing) {
      _startAnimation();
      _startEmission();
    }
  }

  void _handleChange() {
    if (widget.confettiController.state == ConfettiControllerState.playing) {
      _startAnimation();
      _startEmission();
    } else if (widget.confettiController.state ==
        ConfettiControllerState.stopped) {
      _stopEmission();
    } else if (widget.confettiController.state ==
        ConfettiControllerState.stoppedAndCleared) {
      _stopEmission(clearAllParticles: true);
    } else if (widget.confettiController.state ==
        ConfettiControllerState.disposed) {
      _stopEmission(clearAllParticles: true);
    }
  }

  late var lastTime = DateTime.now().millisecondsSinceEpoch;

  void _animationListener() {
    if (_particleSystem.particleSystemStatus == ParticleSystemStatus.finished) {
      _animController.stop();
      return;
    }
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final deltaTime = (currentTime - lastTime) / 1000;

    lastTime = currentTime;

    if (deltaTime > kLowLimit) {
      _particleSystem.update(kLowLimit,
          pauseEmission: widget.pauseEmissionOnLowFrameRate);
    } else {
      _particleSystem.update(deltaTime);
    }

    widget.confettiController.particleStatsCallback?.call(
      ParticleStats(
        numberOfParticles: _particleSystem.numberOfParticles,
        activeNumberOfParticles: _particleSystem.activeNumberOfParticles,
      ),
    );
  }

  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (!widget.shouldLoop) {
        _stopEmission();
      }
      _continueAnimation();
    }
  }

  void _particleSystemListener() {
    if (_particleSystem.particleSystemStatus == ParticleSystemStatus.finished) {
      _stopAnimation();
    }
  }

  void _startEmission() {
    _particleSystem.startParticleEmission();
  }

  void _stopEmission({bool clearAllParticles = false}) {
    if (_particleSystem.particleSystemStatus == ParticleSystemStatus.stopped) {
      return;
    }
    _particleSystem.stopParticleEmission(clearAllParticles: clearAllParticles);
  }

  void _startAnimation() {
    // Make sure widgets are built before setting screen size and position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _setScreenSize();
        _setEmitterPosition();
        _animController.forward(from: 0);
      }
    });
  }

  void _stopAnimation() {
    _animController.stop();
    widget.confettiController.stop();
  }

  void _continueAnimation() {
    _animController.forward(from: 0);
  }

  void _setScreenSize() {
    _screenSize = _getScreenSize();
    _particleSystem.screenSize = _screenSize;
  }

  void _setEmitterPosition() {
    _emitterPosition = _getContainerPosition();
    _particleSystem.particleSystemPosition = _emitterPosition;
  }

  Offset _getContainerPosition() {
    final containerRenderBox =
        _particleSystemKey.currentContext?.findRenderObject() as RenderBox?;
    return containerRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
  }

  Size _getScreenSize() {
    return widget.canvas ?? MediaQuery.of(context).size;
  }

  /// On layout change update the position of the emitter
  /// and the screen size.
  ///
  /// Only update the emitter if it has already been set, to avoid RenderObject
  /// issues.
  ///
  /// The emitter position is first set in the `addPostFrameCallback`
  /// in [initState].
  void _updatePositionAndSize() {
    if (_getScreenSize() != _screenSize) {
      _setScreenSize();
      _setEmitterPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    _updatePositionAndSize(); // TODO: improve
    return RepaintBoundary(
      child: CustomPaint(
        key: _particleSystemKey,
        willChange: true,
        foregroundPainter: ParticlePainter(
          _animController,
          strokeWidth: widget.strokeWidth,
          strokeColor: widget.strokeColor,
          particles: _particleSystem.particles,
          paintEmitterTarget: widget.displayTarget,
        ),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    widget.confettiController.stop();
    _animController.dispose();
    widget.confettiController.removeListener(_handleChange);
    _particleSystem.removeListener(_particleSystemListener);
    super.dispose();
  }
}

class ParticlePainter extends CustomPainter {
  ParticlePainter(
    Listenable? repaint, {
    required this.particles,
    bool paintEmitterTarget = true,
    Color emitterTargetColor = Colors.black,
    Color strokeColor = Colors.black,
    this.strokeWidth = 0,
  })  : _paintEmitterTarget = paintEmitterTarget,
        _emitterPaint = Paint()
          ..color = emitterTargetColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
        _particlePaint = Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill,
        _particleStrokePaint = Paint()
          ..color = strokeColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke,
        super(repaint: repaint);

  final List<Particle> particles;

  final Paint _emitterPaint;
  final bool _paintEmitterTarget;
  final Paint _particlePaint;
  final Paint _particleStrokePaint;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (_paintEmitterTarget) {
      _paintEmitter(canvas);
    }
    _paintParticles(canvas);
  }

  // TODO: seperate this
  void _paintEmitter(Canvas canvas) {
    const radius = 10.0;
    canvas.drawCircle(Offset.zero, radius, _emitterPaint);
    final path = Path()
      ..moveTo(0, -radius)
      ..lineTo(0, radius)
      ..moveTo(-radius, 0)
      ..lineTo(radius, 0);
    canvas.drawPath(path, _emitterPaint);
  }

  void _paintParticles(Canvas canvas) {
    for (final particle in particles) {
      if (!particle.active) continue;
      final rotationMatrix4 = Matrix4.identity()
        ..translate(particle.location.dx, particle.location.dy)
        ..rotateX(particle.angleX)
        ..rotateY(particle.angleY);

      if (particle.rotateZ) {
        rotationMatrix4.rotateZ(particle.angleZ);
      }

      final finalPath = particle.path.transform(rotationMatrix4.storage);
      canvas.drawPath(finalPath, _particlePaint..color = particle.color);
      if (strokeWidth > 0) {
        canvas.drawPath(finalPath, _particleStrokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// {@template particle_stats_callback}
/// This callback provides [ParticleStats] as an argument.
/// {@endtemplate}
typedef ParticleStatsCallback = void Function(ParticleStats stats);

class ConfettiController extends ChangeNotifier {
  ConfettiController({
    this.duration = const Duration(seconds: 30),
    this.particleStatsCallback,
  }) : assert(!duration.isNegative && duration.inMicroseconds > 0);

  Duration duration;

  ConfettiControllerState _state = ConfettiControllerState.stopped;

  /// {@macro confetti_controller_state}
  ConfettiControllerState get state => _state;

  /// {@macro particle_stats_callback}
  final ParticleStatsCallback? particleStatsCallback;

  void play() {
    _state = ConfettiControllerState.playing;
    notifyListeners();
  }

  void stop({bool clearAllParticles = false}) {
    // if state is already disposed, it can not be stopped.
    if (_state == ConfettiControllerState.disposed) return;

    if (clearAllParticles) {
      _state = ConfettiControllerState.stoppedAndCleared;
    } else {
      _state = ConfettiControllerState.stopped;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _state = ConfettiControllerState.disposed;
    notifyListeners();
    super.dispose();
  }
}
