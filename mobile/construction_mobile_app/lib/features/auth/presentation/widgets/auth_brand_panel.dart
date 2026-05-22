import 'package:flutter/material.dart';
import '../../../../core/theme/app_gradients.dart';

class AuthBrandPanel extends StatelessWidget {
  final bool compact;

  const AuthBrandPanel({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradients.brandPanel),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _AuthPatternPainter())),
          if (!compact)
            Center(
              child: _buildLogo(),
            ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Image.asset(
        'assets/branding/constructpro_logo.jpg',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _AuthPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Abstract geometric shapes instead of text
    final finePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    final mediumPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.5;
    final accentPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 2;

    const spacing = 40.0;
    // Grid pattern
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), finePaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), finePaint);
    }

    // Abstract circles
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 0.15, mediumPaint);
    canvas.drawCircle(center, size.width * 0.25, finePaint);

    // Abstract geometric shapes
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.2)
      ..lineTo(size.width * 0.3, size.height * 0.15)
      ..lineTo(size.width * 0.4, size.height * 0.35)
      ..close();

    canvas.drawPath(path, accentPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.6, size.height * 0.6)
      ..lineTo(size.width * 0.8, size.height * 0.55)
      ..lineTo(size.width * 0.9, size.height * 0.75)
      ..close();

    canvas.drawPath(path2, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
