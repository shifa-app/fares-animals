// رسوم أصلية للألعاب بـ CustomPainter (بلا صور خارجية وبلا حزم):
// - ظلال الحيوانات (G01): صور الحيوانات الحالية لها خلفيات كاملة،
//   فالظلال تُرسم أصلاً كأشكال سوداء مفرغة لا كفلتر على صورة.
// - الأشكال الهندسية (G04).
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// ظل حيوان أسود (رأس فقط — أوضح للطفل) في مساحة 200×200.
/// [animalId] من shadowAnimals في GameEngine.
class ShadowPainter extends CustomPainter {
  final String animalId;
  const ShadowPainter(this.animalId);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final u = size.shortestSide / 200;
    canvas.scale(u, u);
    switch (animalId) {
      case 'lion':
        _circle(canvas, paint, 100, 95, 58); // اللبدة
        _circle(canvas, paint, 62, 48, 14); // أذن
        _circle(canvas, paint, 138, 48, 14); // أذن
        _circle(canvas, paint, 100, 100, 40); // الوجه
      case 'elephant':
        _circle(canvas, paint, 52, 85, 28); // أذن كبيرة
        _circle(canvas, paint, 148, 85, 28); // أذن كبيرة
        _circle(canvas, paint, 100, 90, 42); // الرأس
        final trunk = Path()
          ..moveTo(88, 118)
          ..quadraticBezierTo(84, 160, 92, 178)
          ..lineTo(108, 178)
          ..quadraticBezierTo(116, 160, 112, 118)
          ..close();
        canvas.drawPath(trunk, paint);
      case 'giraffe':
        _rrect(canvas, paint, 88, 70, 24, 120, 12); // الرقبة الطويلة
        _circle(canvas, paint, 100, 55, 26); // الرأس
        _circle(canvas, paint, 88, 28, 6); // قرن صغير
        _circle(canvas, paint, 112, 28, 6); // قرن صغير
        _rrect(canvas, paint, 84, 30, 8, 22, 4);
        _rrect(canvas, paint, 108, 30, 8, 22, 4);
        _ellipse(canvas, paint, 70, 55, 14, 8, -0.4); // أذن
        _ellipse(canvas, paint, 130, 55, 14, 8, 0.4); // أذن
      case 'rabbit':
        _ellipse(canvas, paint, 78, 45, 13, 36, -0.15); // أذن طويلة
        _ellipse(canvas, paint, 122, 45, 13, 36, 0.15); // أذن طويلة
        _circle(canvas, paint, 100, 115, 42); // الرأس
      case 'turtle':
        final dome = Path()
          ..moveTo(30, 140)
          ..arcTo(
            Rect.fromCircle(center: const Offset(100, 140), radius: 70),
            math.pi,
            math.pi,
            false,
          )
          ..close();
        canvas.drawPath(dome, paint);
        _circle(canvas, paint, 178, 135, 18); // الرأس
        _circle(canvas, paint, 55, 150, 10); // رجل
        _circle(canvas, paint, 85, 152, 10);
        _circle(canvas, paint, 120, 152, 10);
        _circle(canvas, paint, 150, 150, 10);
      case 'fish':
        _ellipse(canvas, paint, 95, 100, 55, 32, 0); // الجسم
        final tail = Path()
          ..moveTo(148, 100)
          ..lineTo(185, 68)
          ..lineTo(185, 132)
          ..close();
        canvas.drawPath(tail, paint);
        final fin = Path()
          ..moveTo(78, 70)
          ..lineTo(70, 44)
          ..lineTo(112, 70)
          ..close();
        canvas.drawPath(fin, paint);
      case 'bird':
        _ellipse(canvas, paint, 95, 105, 50, 34, 0); // الجسم
        _circle(canvas, paint, 140, 70, 24); // الرأس
        final beak = Path()
          ..moveTo(160, 66)
          ..lineTo(186, 76)
          ..lineTo(160, 88)
          ..close();
        canvas.drawPath(beak, paint);
        _ellipse(canvas, paint, 85, 105, 28, 15, 0); // الجناح
        final tail = Path()
          ..moveTo(48, 100)
          ..lineTo(18, 82)
          ..lineTo(24, 108)
          ..close();
        canvas.drawPath(tail, paint);
      case 'cat':
        final earL = Path()
          ..moveTo(58, 72)
          ..lineTo(74, 24)
          ..lineTo(92, 68)
          ..close();
        canvas.drawPath(earL, paint);
        final earR = Path()
          ..moveTo(108, 68)
          ..lineTo(126, 24)
          ..lineTo(142, 72)
          ..close();
        canvas.drawPath(earR, paint);
        _circle(canvas, paint, 100, 108, 48); // الرأس
      default:
        _circle(canvas, paint, 100, 100, 60);
    }
  }

  void _circle(Canvas c, Paint p, double x, double y, double r) {
    c.drawCircle(Offset(x, y), r, p);
  }

  void _rrect(Canvas c, Paint p, double x, double y, double w, double h,
      double r) {
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
      p,
    );
  }

  void _ellipse(
      Canvas c, Paint p, double x, double y, double rx, double ry, double rot) {
    c.save();
    c.translate(x, y);
    c.rotate(rot);
    c.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), p);
    c.restore();
  }

  @override
  bool shouldRepaint(covariant ShadowPainter old) =>
      old.animalId != animalId;
}

/// صفحة تلوين (G08): نفس رسوم الظلال لكن بخطوط عريضة فارغة
/// يلوّن الطفل داخلها بفرشاته، ثم يحفظها في معرضه.
class ColoringPainter extends CustomPainter {
  final String animalId;
  const ColoringPainter(this.animalId);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final u = size.shortestSide / 200;
    canvas.scale(u, u);
    switch (animalId) {
      case 'lion':
        _circle(canvas, paint, 100, 95, 58);
        _circle(canvas, paint, 62, 48, 14);
        _circle(canvas, paint, 138, 48, 14);
        _circle(canvas, paint, 100, 100, 40);
      case 'elephant':
        _circle(canvas, paint, 52, 85, 28);
        _circle(canvas, paint, 148, 85, 28);
        _circle(canvas, paint, 100, 90, 42);
        canvas.drawPath(
          Path()
            ..moveTo(88, 118)
            ..quadraticBezierTo(84, 160, 92, 178)
            ..lineTo(108, 178)
            ..quadraticBezierTo(116, 160, 112, 118)
            ..close(),
          paint,
        );
      case 'giraffe':
        _rrect(canvas, paint, 88, 70, 24, 120, 12);
        _circle(canvas, paint, 100, 55, 26);
        _circle(canvas, paint, 88, 28, 6);
        _circle(canvas, paint, 112, 28, 6);
        _rrect(canvas, paint, 84, 30, 8, 22, 4);
        _rrect(canvas, paint, 108, 30, 8, 22, 4);
        _ellipse(canvas, paint, 70, 55, 14, 8, -0.4);
        _ellipse(canvas, paint, 130, 55, 14, 8, 0.4);
      case 'rabbit':
        _ellipse(canvas, paint, 78, 45, 13, 36, -0.15);
        _ellipse(canvas, paint, 122, 45, 13, 36, 0.15);
        _circle(canvas, paint, 100, 115, 42);
      case 'turtle':
        canvas.drawPath(
          Path()
            ..moveTo(30, 140)
            ..arcTo(
              Rect.fromCircle(center: const Offset(100, 140), radius: 70),
              math.pi,
              math.pi,
              false,
            )
            ..close(),
          paint,
        );
        _circle(canvas, paint, 178, 135, 18);
        _circle(canvas, paint, 55, 150, 10);
        _circle(canvas, paint, 85, 152, 10);
        _circle(canvas, paint, 120, 152, 10);
        _circle(canvas, paint, 150, 150, 10);
      case 'fish':
        _ellipse(canvas, paint, 95, 100, 55, 32, 0);
        canvas.drawPath(
          Path()
            ..moveTo(148, 100)
            ..lineTo(185, 68)
            ..lineTo(185, 132)
            ..close(),
          paint,
        );
        canvas.drawPath(
          Path()
            ..moveTo(78, 70)
            ..lineTo(70, 44)
            ..lineTo(112, 70)
            ..close(),
          paint,
        );
      case 'bird':
        _ellipse(canvas, paint, 95, 105, 50, 34, 0);
        _circle(canvas, paint, 140, 70, 24);
        canvas.drawPath(
          Path()
            ..moveTo(160, 66)
            ..lineTo(186, 76)
            ..lineTo(160, 88)
            ..close(),
          paint,
        );
        _ellipse(canvas, paint, 85, 105, 28, 15, 0);
        canvas.drawPath(
          Path()
            ..moveTo(48, 100)
            ..lineTo(18, 82)
            ..lineTo(24, 108)
            ..close(),
          paint,
        );
      case 'cat':
        canvas.drawPath(
          Path()
            ..moveTo(58, 72)
            ..lineTo(74, 24)
            ..lineTo(92, 68)
            ..close(),
          paint,
        );
        canvas.drawPath(
          Path()
            ..moveTo(108, 68)
            ..lineTo(126, 24)
            ..lineTo(142, 72)
            ..close(),
          paint,
        );
        _circle(canvas, paint, 100, 108, 48);
      default:
        _circle(canvas, paint, 100, 100, 60);
    }
  }

  void _circle(Canvas c, Paint p, double x, double y, double r) {
    c.drawCircle(Offset(x, y), r, p);
  }

  void _rrect(Canvas c, Paint p, double x, double y, double w, double h,
      double r) {
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
      p,
    );
  }

  void _ellipse(
      Canvas c, Paint p, double x, double y, double rx, double ry, double rot) {
    c.save();
    c.translate(x, y);
    c.rotate(rot);
    c.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), p);
    c.restore();
  }

  @override
  bool shouldRepaint(covariant ColoringPainter old) =>
      old.animalId != animalId;
}
class ShapePainter extends CustomPainter {
  final String shape;
  final Color color;
  const ShapePainter({required this.shape, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final u = size.shortestSide / 200;
    canvas.scale(u, u);
    switch (shape) {
      case 'circle':
        canvas.drawCircle(const Offset(100, 100), 70, paint);
      case 'square':
        canvas.drawRect(const Rect.fromLTWH(35, 35, 130, 130), paint);
      case 'triangle':
        canvas.drawPath(
          Path()
            ..moveTo(100, 25)
            ..lineTo(175, 165)
            ..lineTo(25, 165)
            ..close(),
          paint,
        );
      case 'star':
        canvas.drawPath(_starPath(100, 100, 75, 32), paint);
      case 'rectangle':
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(20, 65, 160, 70),
            const Radius.circular(8),
          ),
          paint,
        );
      case 'heart':
        canvas.drawPath(
          Path()
            ..moveTo(100, 170)
            ..cubicTo(20, 100, 35, 30, 100, 70)
            ..cubicTo(165, 30, 180, 100, 100, 170)
            ..close(),
          paint,
        );
      case 'diamond':
        canvas.drawPath(
          Path()
            ..moveTo(100, 25)
            ..lineTo(175, 100)
            ..lineTo(100, 175)
            ..lineTo(25, 100)
            ..close(),
          paint,
        );
      case 'oval':
        canvas.drawOval(
          Rect.fromCenter(
            center: const Offset(100, 100),
            width: 150,
            height: 95,
          ),
          paint,
        );
      default:
        canvas.drawCircle(const Offset(100, 100), 70, paint);
    }
  }

  Path _starPath(double cx, double cy, double outer, double inner) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant ShapePainter old) =>
      old.shape != shape || old.color != color;
}
