import 'dart:math';

import 'package:flutter/material.dart';
import 'package:confetti/src/particle.dart';

import 'enums/blast_directionality.dart';
import 'enums/confetti_controller_state.dart';

class ConfettiWidget extends StatefulWidget {
  const ConfettiWidget({
    Key key,
    @required this.confettiController,
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
    this.minimumSize = const Size(20, 10),
    this.maximumSize = const Size(30, 15),
    this.particleDrag = 0.05,
    this.canvas,
    this.child,
  })  : assert(
            confettiController != null,
            emissionFrequency != null &&
                numberOfParticles != null &&
                maxBlastForce != null &&
                minBlastForce != null &&
                blastDirectionality != null &&
                blastDirection != null),
        assert(emissionFrequency >= 0 &&
            emissionFrequency <= 1 &&
            numberOfParticles > 0 &&
            maxBlastForce > 0 &&
            minBlastForce > 0 &&
            maxBlastForce > minBlastForce),
        assert(gravity >= 0 && gravity <= 1),
        super(key: key);

  /// The [ConfettiController] must not be null.
  final ConfettiController confettiController;

  /// The [maxBlastForce] and [minBlastForce] will determine the maximum and minimum blast force applied to
  /// a particle within it's first 5 frames of life. The default [maxBlastForce] is set to `20`
  final double maxBlastForce;

  /// The [maxBlastForce] and [minBlastForce] will determine the maximum and minimum blast force applied to
  /// a particle within it's first 5 frames of life. The default [minBlastForce] is set to `5`
  final double minBlastForce;

  /// The [blastDirectionality] is an enum that takes one of two values - directional or explosive.
  /// The default is set to directional
  final BlastDirectionality blastDirectionality;

  /// The [blastDirection] is a radial value to determine the direction of the particle emission.
  /// The default is set to `PI` (180 degrees). A value of `PI` will emit to the left of the canvas/screen.
  final double blastDirection;

  /// The [gravity] is the speed at which the confetti will fall.
  /// The higher the [gravity] the faster it will fall.
  ///
  /// It can be set to a value between `0` and `1`
  /// Default value is `0.1`
  final double gravity;

  /// The [emissionFrequency] should be a value between 0 and 1. The higher the value the higher the
  /// likelihood that particles will be emitted on a single frame. Default is set to `0.02` (2% chance)
  final double emissionFrequency;

  /// The [numberOfParticles] to be emitted per emission. Default is set to `10`
  final int numberOfParticles;

  /// The [shouldLoop] attribute determines if the [emissionDuration] will reset which will result
  /// in continues particles being emitted.
  final bool shouldLoop;

  /// The [displayTarget] attribute determines if a crosshair will be displayed to show the location
  /// of the particle emitter
  final bool displayTarget;

  /// List of Colors to iterate over - if null then random values will be chosen
  final List<Color> colors;

  /// An optional parameter to set the minimum size potential size for the confetti.
  /// Must be smaller than the [maximumSize] attribute. Cannot be null
  final Size minimumSize;

  /// An optional parameter to set the maximum potential size for the confetti.
  /// Must be bigger than the [minimumSize] attribute. Cannot be null
  final Size maximumSize;

  /// An optional parameter to specify drag force, effecting the movement of the confetti.
  /// Using `1.0` will give no drag at all, while, for example, using `0.1` will give a lot of drag. Default is set to `0.05`.
  final double particleDrag;

  /// An optional parameter to specify the area size where the confetti will be thrown.
  /// By default this is set to screen size.
  final Size canvas;

  /// Child widget to display
  final Widget child;

  @override
  _ConfettiWidgetState createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey _particleSystemKey = GlobalKey();

  AnimationController _animController;
  Animation<double> _animation;
  ParticleSystem _particleSystem;

  /// Keeps track of emition position on screen layout changes
  Offset _emitterPosition;

  /// Keeps track of the screen size on layout changes
  /// Controls the sizing restrictions for when confetti should be vissible
  Size _screenSize = const Size(0, 0);

  @override
  void initState() {
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
        maximumsize: widget.maximumSize,
        particleDrag: widget.particleDrag);

    _particleSystem.addListener(_particleSystemListener);

    _initAnimation();
    super.initState();
  }

  void _initAnimation() {
    _animController = AnimationController(
        vsync: this, duration: widget.confettiController.duration);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animController);
    _animation.addListener(_animationListener);
    _animation.addStatusListener(_animationStatusListener);

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
    }
  }

  void _animationListener() {
    if (_particleSystem.particleSystemStatus == ParticleSystemStatus.finished) {
      _animController.stop();
      return;
    }
    _particleSystem.update();
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

  void _stopEmission() {
    if (_particleSystem.particleSystemStatus == ParticleSystemStatus.stopped) {
      return;
    }
    _particleSystem.stopParticleEmission();
  }

  void _startAnimation() {
    // Make sure widgets are built before setting screen size and position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setScreenSize();
      _setEmitterPosition();
      _animController.forward(from: 0);
    });
  }

  void _stopAnimation() {
    _animController.stop();
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
    final RenderBox containerRenderBox =
        _particleSystemKey.currentContext.findRenderObject();
    return containerRenderBox.localToGlobal(Offset.zero);
  }

  Size _getScreenSize() {
    return widget.canvas ?? MediaQuery.of(context).size;
  }

  /// On layout change update the position of the emitter
  /// and the screen size
  ///
  /// Only update the emitter if it has already been set.
  /// To avoid RenderObject issues.
  /// The emitter position is first set in the [addPostFrameCallback]
  /// in [initState]
  void _updatePositionAndSize() {
    if (_getScreenSize() != _screenSize) {
      _setScreenSize();
      if (_emitterPosition != null) {
        _setEmitterPosition();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _updatePositionAndSize();
    return RepaintBoundary(
      child: CustomPaint(
        key: _particleSystemKey,
        foregroundPainter: ParticlePainter(
          _animController,
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
    _particleSystem = null;
    super.dispose();
  }
}

class ParticlePainter extends CustomPainter {
  ParticlePainter(Listenable repaint,
      {@required this.particles,
      paintEmitterTarget = true,
      emitterTargetColor = Colors.black})
      : _paintEmitterTarget = paintEmitterTarget,
        _emitterPaint = Paint()
          ..color = emitterTargetColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
        _particlePaint = Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill,
        super(repaint: repaint);

  final List<Particle> particles;

  final Paint _emitterPaint;
  final bool _paintEmitterTarget;
  final Paint _particlePaint;

  @override
  void paint(Canvas canvas, Size size) {
    if (_paintEmitterTarget) {
      _paintEmitter(canvas);
    }
    if (particles == null) {
      return;
    }
    _paintParticles(canvas);
  }

  // TODO: seperate this
  void _paintEmitter(Canvas canvas) {
    const radius = 10.0;
    canvas.drawCircle(Offset.zero, radius, _emitterPaint);
    final path = Path();
    path.moveTo(0, -radius);
    path.lineTo(0, radius);
    path.moveTo(-radius, 0);
    path.lineTo(radius, 0);
    canvas.drawPath(path, _emitterPaint);
  }

  void _paintParticles(Canvas canvas) {
    for (final particle in particles) {
      final rotationMatrix4 = Matrix4.identity();
      rotationMatrix4
        ..translate(particle.location.dx, particle.location.dy)
        ..rotateX(particle.angleX)
        ..rotateY(particle.angleY)
        ..rotateZ(particle.angleZ);

      final finalPath = particle.path.transform(rotationMatrix4.storage);
      canvas.drawPath(finalPath, _particlePaint..color = particle.color);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ConfettiController extends ChangeNotifier {
  ConfettiController({this.duration = const Duration(seconds: 30)})
      : assert(duration != null &&
            !duration.isNegative &&
            duration.inMicroseconds > 0);

  Duration duration;

  ConfettiControllerState _state = ConfettiControllerState.stopped;

  ConfettiControllerState get state => _state;

  void play() {
    _state = ConfettiControllerState.playing;
    notifyListeners();
  }

  void stop() {
    _state = ConfettiControllerState.stopped;
    notifyListeners();
  }
}
