import 'dart:math';

import 'package:flutter/material.dart';
import 'package:confetti/src/particle.dart';
import 'package:vector_math/vector_math.dart' as vmath;

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
    this.shouldLoop = false,
    this.displayTarget = false,
    this.colors,
    this.minimumSize = const Size(20, 10),
    this.maximumSize = const Size(30, 15),
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

  get _randomBlastDirection => vmath.radians(Random().nextInt(359).toDouble());

  @override
  void initState() {
    widget.confettiController.addListener(_handleChange);

    _particleSystem = ParticleSystem(
      emissionFrequency: widget.emissionFrequency,
      numberOfParticles: widget.numberOfParticles,
      maxBlastForce: widget.maxBlastForce,
      minBlastForce: widget.minBlastForce,
      blastDirection: widget.blastDirectionality == BlastDirectionality.directional ? widget.blastDirection : _randomBlastDirection,
      colors: widget.colors,
      minimumSize: widget.minimumSize,
      maximumsize: widget.maximumSize,
    );

    _particleSystem.addListener(_particleSystemListener);

    _initAnimation();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        _onBuildComplete); // called to set the size of the screen
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
    setState(() {});
  }

  void _animationListener() {
    if (_particleSystem.particleSystemStatus == ParticleSystemStatus.finished) {
      _animController.stop();
      return;
    }
    _particleSystem.update();

    setState(() {});
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
    // debugPrint('START emission');
    _particleSystem.startParticleEmission();
  }

  void _stopEmission() {
    if (_particleSystem.particleSystemStatus == ParticleSystemStatus.stopped) {
      return;
    }
    // debugPrint('STOP emission');
    _particleSystem.stopParticleEmission();
  }

  void _startAnimation() {
    // debugPrint('START animation');
    _animController.forward(from: 0);
  }

  void _stopAnimation() {
    // debugPrint('STOP animation');
    _animController.stop();
  }

  void _continueAnimation() {
    // debugPrint('CONTINUE animation');
    _animController.forward(from: 0);
  }

  void _onBuildComplete(_) {
    _setScreenSize();
  }

  void _setScreenSize() {
    final position = _getContainerPosition();
    final screenSize = _getScreenSize();
    _particleSystem.particleSystemPosition = position;
    _particleSystem.screenSize = screenSize;
  }

  Offset _getContainerPosition() {
    final RenderBox containerRenderBox =
        _particleSystemKey.currentContext.findRenderObject();
    return containerRenderBox.localToGlobal(Offset.zero);
  }

  Size _getScreenSize() {
    return MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: _particleSystemKey,
      foregroundPainter: ParticlePainter(
        particles: _particleSystem.particles,
        paintEmitterTarget: widget.displayTarget,
      ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    print('dispose called');
    _animController.dispose();
    widget.confettiController.removeListener(_handleChange);
    _particleSystem.removeListener(_particleSystemListener);
    _particleSystem = null;
    super.dispose();
  }
}

class ParticlePainter extends CustomPainter {
  ParticlePainter(
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
          ..style = PaintingStyle.fill;

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

  Matrix4 rotationMatrix4;
  Path pathShape;
  Path rotatedPath;
  Path drawPath;

  void _paintParticles(Canvas canvas) {
    for (final particle in particles) {
      // final rotationMatrix4 = Matrix4.identity()
      //   ..rotateY(particle.angleY)
      //   ..rotateX(particle.angleX)
      //   ..rotateZ(particle.angleZ);
      rotationMatrix4 = Matrix4.identity();
      rotationMatrix4
        ..rotateY(particle.angleY)
        ..rotateX(particle.angleX)
        ..rotateZ(particle.angleZ);

      pathShape = Path();
      pathShape.moveTo(0, 0);
      pathShape.lineTo(-particle.size.width, 0);
      pathShape.lineTo(-particle.size.width, particle.size.height);
      pathShape.lineTo(0, particle.size.height);
      pathShape.close();
      rotatedPath = pathShape.transform(rotationMatrix4.storage);
      drawPath = rotatedPath.shift(particle.location);
      canvas.drawPath(drawPath, _particlePaint..color = particle.color);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

enum ConfettiControllerState {
  playing,
  stopped,
}

enum BlastDirectionality {
  directional,
  explosive
}

class ConfettiController extends ChangeNotifier {
  ConfettiController({this.duration = const Duration(seconds: 30)})
      : assert(duration != null);

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
