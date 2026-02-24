import 'package:flutter/material.dart';
import 'package:weathernav/presentation/widgets/app_illustration_kind.dart';

class AppIllustrationPainter extends CustomPainter {
  AppIllustrationPainter({required this.kind, required this.scheme});

  final AppIllustrationKind kind;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case AppIllustrationKind.error:
        _paintError(canvas, size);
      case AppIllustrationKind.weather:
        _paintWeather(canvas, size);
      case AppIllustrationKind.alerts:
        _paintAlerts(canvas, size);
    }
  }

  void _paintError(Canvas canvas, Size size) {
    final bg = Paint()..color = scheme.errorContainer.withValues(alpha: 0.45);
    final fg = Paint()..color = scheme.error.withValues(alpha: 0.9);
    final soft = Paint()
      ..color = scheme.onSurfaceVariant.withValues(alpha: 0.22);

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        0.08 * size.width,
        0.12 * size.height,
        0.84 * size.width,
        0.76 * size.height,
      ),
      Radius.circular(0.18 * size.shortestSide),
    );
    canvas.drawRRect(r, bg);

    final center = Offset(size.width * 0.5, size.height * 0.48);
    canvas.drawCircle(
      center,
      size.shortestSide * 0.22,
      Paint()..color = Colors.white,
    );

    final line = Paint()
      ..color = fg.color
      ..strokeWidth = size.shortestSide * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, center.dy - size.height * 0.12),
      Offset(center.dx, center.dy + size.height * 0.02),
      line,
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy + size.height * 0.12),
      size.shortestSide * 0.03,
      Paint()..color = fg.color,
    );

    final wave = Path()
      ..moveTo(size.width * 0.18, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.32,
        size.height * 0.74,
        size.width * 0.46,
        size.height * 0.82,
      )
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.90,
        size.width * 0.78,
        size.height * 0.82,
      );
    final wPaint = Paint()
      ..color = soft.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.045
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(wave, wPaint);
  }

  void _paintWeather(Canvas canvas, Size size) {
    final bg = Paint()..color = scheme.primaryContainer.withValues(alpha: 0.35);
    final cloud = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = scheme.onSurfaceVariant.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.03;

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        0.08 * size.width,
        0.12 * size.height,
        0.84 * size.width,
        0.76 * size.height,
      ),
      Radius.circular(0.18 * size.shortestSide),
    );
    canvas.drawRRect(r, bg);

    final c = Offset(size.width * 0.52, size.height * 0.46);
    final cloudPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(c.dx - size.width * 0.12, c.dy),
          radius: size.shortestSide * 0.13,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(c.dx, c.dy - size.height * 0.04),
          radius: size.shortestSide * 0.16,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(c.dx + size.width * 0.14, c.dy),
          radius: size.shortestSide * 0.12,
        ),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            c.dx - size.width * 0.26,
            c.dy,
            size.width * 0.52,
            size.height * 0.12,
          ),
          Radius.circular(size.shortestSide * 0.08),
        ),
      );

    canvas.drawPath(cloudPath, cloud);
    canvas.drawPath(cloudPath, stroke);

    final drops = Paint()
      ..color = scheme.primary.withValues(alpha: 0.65)
      ..strokeWidth = size.shortestSide * 0.04
      ..strokeCap = StrokeCap.round;

    for (final dx in [-0.12, 0.0, 0.12]) {
      canvas.drawLine(
        Offset(c.dx + size.width * dx, size.height * 0.70),
        Offset(c.dx + size.width * dx, size.height * 0.78),
        drops,
      );
    }
  }

  void _paintAlerts(Canvas canvas, Size size) {
    final bg = Paint()
      ..color = scheme.secondaryContainer.withValues(alpha: 0.35);
    final shield = Paint()..color = Colors.white;
    final stroke = Paint()
      ..color = scheme.onSurfaceVariant.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.03;

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        0.08 * size.width,
        0.12 * size.height,
        0.84 * size.width,
        0.76 * size.height,
      ),
      Radius.circular(0.18 * size.shortestSide),
    );
    canvas.drawRRect(r, bg);

    final path = Path();
    final top = Offset(size.width * 0.5, size.height * 0.22);
    path.moveTo(top.dx, top.dy);
    path.quadraticBezierTo(
      size.width * 0.30,
      size.height * 0.28,
      size.width * 0.30,
      size.height * 0.44,
    );
    path.quadraticBezierTo(
      size.width * 0.30,
      size.height * 0.70,
      size.width * 0.50,
      size.height * 0.80,
    );
    path.quadraticBezierTo(
      size.width * 0.70,
      size.height * 0.70,
      size.width * 0.70,
      size.height * 0.44,
    );
    path.quadraticBezierTo(
      size.width * 0.70,
      size.height * 0.28,
      top.dx,
      top.dy,
    );

    canvas.drawPath(path, shield);
    canvas.drawPath(path, stroke);

    final check = Paint()
      ..color = scheme.secondary.withValues(alpha: 0.75)
      ..strokeWidth = size.shortestSide * 0.06
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final p1 = Offset(size.width * 0.42, size.height * 0.52);
    final p2 = Offset(size.width * 0.48, size.height * 0.58);
    final p3 = Offset(size.width * 0.60, size.height * 0.46);
    canvas.drawLine(p1, p2, check);
    canvas.drawLine(p2, p3, check);
  }

  @override
  bool shouldRepaint(covariant AppIllustrationPainter oldDelegate) {
    return oldDelegate.kind != kind || oldDelegate.scheme != scheme;
  }
}
