import 'dart:typed_data';

import 'package:flutter/rendering.dart';

abstract class Drawable {
  void draw(Canvas canvas, {Float64List? transform});
}

class PathDrawable implements Drawable {
  PathDrawable(
      Path Function(Size size) createParticlePath, Size size, this._color)
      : _pathShape = createParticlePath(size);

  final Path _pathShape;
  final Color _color;

  @override
  void draw(Canvas canvas, {Float64List? transform}) {
    final _particlePaint = Paint()
      ..color = _color
      ..style = PaintingStyle.fill;

    final finalPath =
        transform != null ? _pathShape.transform(transform) : _pathShape;
    canvas.drawPath(finalPath, _particlePaint);
  }
}

class SquareDrawable extends PathDrawable {
  SquareDrawable(Size size, Color color)
      : super(
            (size) => Path()
              ..moveTo(0, 0)
              ..lineTo(-size.width, 0)
              ..lineTo(-size.width, size.height)
              ..lineTo(0, size.height)
              ..close(),
            size,
            color);
}
