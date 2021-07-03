import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgDrawable {
  SvgDrawable(
    this.drawableRoot, {
    this.width,
    this.height,
  });

  final DrawableRoot drawableRoot;

  /// If specified, the width to use for the SVG.  If unspecified, the SVG
  /// will take the width of its parent.
  final double? width;

  /// If specified, the height to use for the SVG.  If unspecified, the SVG
  /// will take the height of its parent.
  final double? height;

  void draw(Canvas canvas, {Float64List? transform}) {
    if (transform != null) {
      canvas
        ..save()
        ..transform(transform);
    }

    drawableRoot.draw(canvas, Rect.fromLTWH(0, 0, width ?? 0, height ?? 0));

    if (transform != null) {
      canvas.restore();
    }
  }
}
