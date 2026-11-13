import 'package:flutter/material.dart';

/// Small filled heart. With [right] the heart is split vertically: left half
/// in [left], right half in [right]. Decorative: the meaning is in the
/// semantics of the parent.
class HeartMark extends StatelessWidget {
  const HeartMark({super.key, required this.left, this.right, this.size = 16});

  final Color left;
  final Color? right;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _HeartPainter(left, right ?? left),
    ),
  );
}

class _HeartPainter extends CustomPainter {
  const _HeartPainter(this.left, this.right);

  final Color left;
  final Color right;

  static Path _heart(Size s) {
    final w = s.width;
    final h = s.height;
    return Path()
      ..moveTo(w * 0.5, h * 0.94)
      ..cubicTo(w * 0.2, h * 0.72, 0, h * 0.52, 0, h * 0.31)
      ..cubicTo(0, h * 0.13, w * 0.13, h * 0.02, w * 0.28, h * 0.02)
      ..cubicTo(w * 0.38, h * 0.02, w * 0.46, h * 0.08, w * 0.5, h * 0.17)
      ..cubicTo(w * 0.54, h * 0.08, w * 0.62, h * 0.02, w * 0.72, h * 0.02)
      ..cubicTo(w * 0.87, h * 0.02, w, h * 0.13, w, h * 0.31)
      ..cubicTo(w, h * 0.52, w * 0.8, h * 0.72, w * 0.5, h * 0.94)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final heart = _heart(size);
    if (left == right) {
      canvas.drawPath(heart, Paint()..color = left);
      return;
    }
    final half = size.width / 2;
    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, 0, half, size.height))
      ..drawPath(heart, Paint()..color = left)
      ..restore()
      ..save()
      ..clipRect(Rect.fromLTWH(half, 0, size.width - half, size.height))
      ..drawPath(heart, Paint()..color = right)
      ..restore();
  }

  @override
  bool shouldRepaint(_HeartPainter old) =>
      old.left != left || old.right != right;
}
