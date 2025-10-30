import 'package:flutter/material.dart';

class DecorativeIcon extends StatelessWidget {
  final Color? backgroundColor;
  final Color? accentColor;
  final double size;

  const DecorativeIcon({
    super.key,
    this.backgroundColor,
    this.accentColor,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        backgroundColor ?? const Color(0xFFF5F3E8); // Cor bege/creme da logo
    final decorColor =
        accentColor ?? const Color(0xFFC5A572); // Cor dourada das vinhas

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: decorColor.withValues(alpha: 0.3), width: 1),
      ),
      child: CustomPaint(
        painter: _DecorativePainter(decorColor),
      ),
    );
  }
}

class _DecorativePainter extends CustomPainter {
  final Color color;

  _DecorativePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Desenhar vinhas no canto superior esquerdo
    _drawTopLeftVine(canvas, size, paint, fillPaint);

    // Desenhar vinhas no canto inferior direito
    _drawBottomRightVine(canvas, size, paint, fillPaint);

    // Desenhar linhas decorativas nas diagonais
    _drawDiagonalLines(canvas, size, paint);
  }

  void _drawTopLeftVine(
      Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final path = Path();

    // Vinha principal curvada
    path.moveTo(size.width * 0.15, size.height * 0.05);
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.1,
      size.width * 0.05,
      size.height * 0.15,
    );

    // Espirais decorativas
    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.08),
      size.width * 0.02,
      fillPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.12),
      size.width * 0.015,
      fillPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.12),
      size.width * 0.012,
      fillPaint,
    );

    // Folhas pequenas
    final leaf1 = Path();
    leaf1.moveTo(size.width * 0.12, size.height * 0.1);
    leaf1.quadraticBezierTo(
      size.width * 0.14,
      size.height * 0.08,
      size.width * 0.16,
      size.height * 0.1,
    );
    leaf1.quadraticBezierTo(
      size.width * 0.14,
      size.height * 0.12,
      size.width * 0.12,
      size.height * 0.1,
    );
    canvas.drawPath(leaf1, fillPaint);

    canvas.drawPath(path, paint);
  }

  void _drawBottomRightVine(
      Canvas canvas, Size size, Paint paint, Paint fillPaint) {
    final path = Path();

    // Vinha principal curvada (espelhada)
    path.moveTo(size.width * 0.85, size.height * 0.95);
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.9,
      size.width * 0.95,
      size.height * 0.85,
    );

    // Espirais decorativas
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.92),
      size.width * 0.02,
      fillPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.88),
      size.width * 0.015,
      fillPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.88),
      size.width * 0.012,
      fillPaint,
    );

    // Folhas pequenas
    final leaf2 = Path();
    leaf2.moveTo(size.width * 0.88, size.height * 0.9);
    leaf2.quadraticBezierTo(
      size.width * 0.86,
      size.height * 0.92,
      size.width * 0.84,
      size.height * 0.9,
    );
    leaf2.quadraticBezierTo(
      size.width * 0.86,
      size.height * 0.88,
      size.width * 0.88,
      size.height * 0.9,
    );
    canvas.drawPath(leaf2, fillPaint);

    canvas.drawPath(path, paint);
  }

  void _drawDiagonalLines(Canvas canvas, Size size, Paint paint) {
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Linha diagonal superior
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.05),
      Offset(size.width * 0.5, size.height * 0.05),
      linePaint,
    );

    // Linha diagonal inferior
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.95),
      Offset(size.width * 0.75, size.height * 0.95),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
