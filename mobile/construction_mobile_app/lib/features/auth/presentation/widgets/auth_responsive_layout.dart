import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class AuthResponsiveLayout extends StatelessWidget {
  final Widget form;

  const AuthResponsiveLayout({
    super.key,
    required this.form,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark
        ? AppColors.blueprintLineDark
        : AppColors.blueprintLineLight;
    final opacity = isDark ? 0.04 : 0.05;

    return Scaffold(
      body: Stack(
        children: [
          // Blueprint background
          Positioned.fill(
            child: CustomPaint(
              painter: _BlueprintPainter(
                lineColor: lineColor,
                opacity: opacity,
              ),
            ),
          ),
          // Subtle overlay
          Positioned.fill(
            child: Container(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          // Form overlay (elevated card)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: _ElevatedCard(
                    child: form,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ElevatedCard extends StatelessWidget {
  final Widget child;

  const _ElevatedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevatedCard : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
          bottom: Radius.circular(24),
        ),
        border: Border.all(
          color: AppColors.borderFor(Theme.of(context).brightness),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BlueprintPainter extends CustomPainter {
  final Color lineColor;
  final double opacity;

  _BlueprintPainter({
    required this.lineColor,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = lineColor.withValues(alpha: opacity * 0.5)
      ..style = PaintingStyle.fill;

    // Horizontal guide lines at wider intervals
    for (double y = 80; y < size.height; y += 120) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical guide lines at wider intervals
    for (double x = 100; x < size.width; x += 140) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Thinner secondary grid
    final thinPaint = Paint()
      ..color = lineColor.withValues(alpha: opacity * 0.5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (double y = 40; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), thinPaint);
    }

    for (double x = 50; x < size.width; x += 70) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), thinPaint);
    }

    // Partial wall-outline rectangles (floor-plan corners)
    final rectPaint = Paint()
      ..color = lineColor.withValues(alpha: opacity * 1.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Top-left room outline
    _drawFloorPlanCorner(canvas, rectPaint, 30, 60, 160, 120);
    // Mid-right room outline
    _drawFloorPlanCorner(canvas, rectPaint, size.width - 200, 180, 170, 100);
    // Bottom-left room outline
    if (size.height > 400) {
      _drawFloorPlanCorner(canvas, rectPaint, 60, size.height - 200, 140, 80);
    }
    // Bottom-right partial outline
    if (size.height > 500) {
      _drawFloorPlanCorner(canvas, rectPaint, size.width - 180,
          size.height - 160, 120, 90);
    }

    // Structural line segments (partial walls)
    final segPaint = Paint()
      ..color = lineColor.withValues(alpha: opacity * 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Horizontal structural segments
    canvas.drawLine(const Offset(200, 250), const Offset(350, 250), segPaint);
    if (size.width > 400) {
      canvas.drawLine(
          Offset(size.width - 300, 350), Offset(size.width - 150, 350),
          segPaint);
    }

    // Vertical structural segments
    canvas.drawLine(const Offset(280, 180), const Offset(280, 300), segPaint);
    if (size.height > 600) {
      canvas.drawLine(Offset(size.width - 250, size.height - 350),
          Offset(size.width - 250, size.height - 200), segPaint);
    }

    // Tiny drafting intersections (cross marks)
    final crossPaint = Paint()
      ..color = lineColor.withValues(alpha: opacity * 0.7)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const crossSize = 6.0;
    final intersections = <Offset>[
      const Offset(100, 120),
      const Offset(240, 60),
      Offset(size.width - 120, 100),
      const Offset(60, 300),
      Offset(size.width - 80, size.height * 0.4),
      Offset(150, size.height * 0.6),
    ];

    for (final p in intersections) {
      if (p.dx < size.width && p.dy < size.height) {
        canvas.drawLine(
            Offset(p.dx - crossSize, p.dy), Offset(p.dx + crossSize, p.dy),
            crossPaint);
        canvas.drawLine(
            Offset(p.dx, p.dy - crossSize), Offset(p.dx, p.dy + crossSize),
            crossPaint);
      }
    }

    // Small filled squares at some intersections (construction marks)
    const markSize = 3.0;
    final marks = <Offset>[
      const Offset(100, 120),
      Offset(size.width * 0.7, 180),
    ];

    for (final p in marks) {
      if (p.dx < size.width && p.dy < size.height) {
        canvas.drawRect(
            Rect.fromCenter(center: p, width: markSize * 2, height: markSize * 2),
            fillPaint);
      }
    }
  }

  void _drawFloorPlanCorner(
      Canvas canvas, Paint paint, double x, double y, double w, double h) {
    const cornerLen = 20.0;

    // Top-left corner
    canvas.drawLine(Offset(x, y), Offset(x + cornerLen, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + cornerLen), paint);

    // Top-right corner
    canvas.drawLine(
        Offset(x + w, y), Offset(x + w - cornerLen, y), paint);
    canvas.drawLine(
        Offset(x + w, y), Offset(x + w, y + cornerLen), paint);

    // Bottom-left corner
    canvas.drawLine(
        Offset(x, y + h), Offset(x + cornerLen, y + h), paint);
    canvas.drawLine(
        Offset(x, y + h), Offset(x, y + h - cornerLen), paint);

    // Bottom-right corner
    canvas.drawLine(Offset(x + w, y + h), Offset(x + w - cornerLen, y + h),
        paint);
    canvas.drawLine(Offset(x + w, y + h), Offset(x + w, y + h - cornerLen),
        paint);

    // Partial top and bottom walls
    canvas.drawLine(Offset(x + w * 0.3, y), Offset(x + w * 0.7, y), paint);
    canvas.drawLine(
        Offset(x + w * 0.2, y + h), Offset(x + w * 0.5, y + h), paint);

    // Partial left wall
    canvas.drawLine(
        Offset(x, y + h * 0.4), Offset(x, y + h * 0.7), paint);
  }

  @override
  bool shouldRepaint(covariant _BlueprintPainter oldDelegate) {
    return lineColor != oldDelegate.lineColor || opacity != oldDelegate.opacity;
  }
}
