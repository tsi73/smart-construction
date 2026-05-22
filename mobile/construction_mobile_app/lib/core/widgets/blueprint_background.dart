import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Intensity levels for the blueprint background pattern.
enum BlueprintIntensity {
  /// Very subtle - main app screens. Opacity 3-5%.
  subtle,

  /// Slightly more visible - auth and creation screens. Opacity 5-8%.
  medium,

  /// Enhanced visibility - splash and special screens. Opacity 7-10%.
  enhanced,
}

/// A premium, reusable construction blueprint background.
///
/// Combines multiple layers of architectural/construction-inspired elements:
/// - Micro-grid: tight spacing for refined structure
/// - Macro-grid: wider spacing for visual rhythm
/// - Construction accents: drafting marks, alignment crosses, corner brackets
/// - Structural elements: partial walls, measurement lines
///
/// Light mode: soft off-white base with cool blue-gray grid and accents
/// Dark mode: deep navy base with muted blueprint blue lines and marks
///
/// Opacity is kept extremely low (3-10% depending on intensity) so the pattern
/// never competes with content—it enhances the premium, technical feel.
class BlueprintBackground extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final BlueprintIntensity intensity;

  const BlueprintBackground({
    super.key,
    required this.child,
    this.enabled = true,
    this.intensity = BlueprintIntensity.subtle,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _BlueprintPainter(
              isDark: isDark,
              intensity: intensity,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _BlueprintPainter extends CustomPainter {
  final bool isDark;
  final BlueprintIntensity intensity;

  _BlueprintPainter({
    required this.isDark,
    required this.intensity,
  });

  // Get opacity multiplier based on intensity
  double _getOpacityMultiplier() {
    switch (intensity) {
      case BlueprintIntensity.subtle:
        return 1.0; // 3-5%
      case BlueprintIntensity.medium:
        return 1.3; // 5-8%
      case BlueprintIntensity.enhanced:
        return 1.8; // 7-10%
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final lineColor = isDark
        ? AppColors.blueprintLineDark
        : AppColors.blueprintLineLight;

    final baseOpacity = isDark ? 0.03 : 0.04;
    final opacityMult = _getOpacityMultiplier();
    final opacity = (baseOpacity * opacityMult).clamp(0.0, 0.15);

    // === LAYER 1: MICRO-GRID ===
    // Fine grid for refined structure
    final microGridPaint = Paint()
      ..color = lineColor.withValues(alpha: opacity * 0.6)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), microGridPaint);
    }
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), microGridPaint);
    }

    // === LAYER 2: MACRO-GRID ===
    // Larger grid for visual rhythm
    final macroGridPaint = Paint()
      ..color = lineColor.withValues(alpha: opacity * 0.8)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double y = 120; y < size.height; y += 160) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), macroGridPaint);
    }
    for (double x = 140; x < size.width; x += 180) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), macroGridPaint);
    }

    // === LAYER 3: CONSTRUCTION ACCENTS ===
    final accentPaint = Paint()
      ..color = lineColor.withValues(alpha: opacity * 1.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Floor plan corner brackets (architectural elements)
    _drawFloorPlanCorner(canvas, accentPaint, 25, 60, 140, 110);
    if (size.width > 400) {
      _drawFloorPlanCorner(
          canvas, accentPaint, size.width - 180, 200, 160, 95);
    }
    if (size.height > 400) {
      _drawFloorPlanCorner(canvas, accentPaint, 50, size.height - 180, 130, 75);
    }
    if (size.height > 500 && size.width > 400) {
      _drawFloorPlanCorner(canvas, accentPaint, size.width - 170,
          size.height - 150, 110, 85);
    }

    // Structural wall segments (construction details)
    final wallPaint = Paint()
      ..color = lineColor.withValues(alpha: opacity * 0.9)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Horizontal structural segments
    canvas.drawLine(const Offset(180, 280), const Offset(340, 280), wallPaint);
    if (size.width > 400) {
      canvas.drawLine(
          Offset(size.width - 320, 380), Offset(size.width - 160, 380),
          wallPaint);
    }

    // Vertical structural segments
    canvas.drawLine(const Offset(260, 160), const Offset(260, 340), wallPaint);
    if (size.height > 600) {
      canvas.drawLine(Offset(size.width - 260, size.height - 380),
          Offset(size.width - 260, size.height - 220), wallPaint);
    }

    // Alignment crosses and measurement marks
    _drawAlignmentCrosses(canvas, size, opacity, lineColor);

    // Subtle diagonal reference lines (blueprint details)
    _drawReferenceLines(canvas, size, opacity, lineColor);

    // Tiny intersection points and construction marks
    _drawConstructionMarks(canvas, size, opacity, lineColor);
  }

  void _drawFloorPlanCorner(Canvas canvas, Paint paint, double x, double y,
      double w, double h) {
    const cornerLen = 18.0;

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

    // Partial wall segments (floor plan elements)
    canvas.drawLine(Offset(x + w * 0.3, y), Offset(x + w * 0.7, y), paint);
    canvas.drawLine(
        Offset(x + w * 0.2, y + h), Offset(x + w * 0.5, y + h), paint);
    canvas.drawLine(
        Offset(x, y + h * 0.4), Offset(x, y + h * 0.7), paint);
  }

  void _drawAlignmentCrosses(Canvas canvas, Size size, double opacity, Color lineColor) {
    final crossPaint = Paint()
      ..color = lineColor.withValues(alpha: opacity * 0.7)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const crossSize = 5.5;
    final crossPositions = <Offset>[
      const Offset(90, 130),
      const Offset(230, 70),
      Offset(size.width - 110, 90),
      const Offset(65, 320),
      Offset(size.width - 85, size.height * 0.4),
      Offset(140, size.height * 0.65),
    ];

    for (final p in crossPositions) {
      if (p.dx < size.width && p.dy < size.height) {
        // Horizontal line
        canvas.drawLine(
            Offset(p.dx - crossSize, p.dy), Offset(p.dx + crossSize, p.dy),
            crossPaint);
        // Vertical line
        canvas.drawLine(
            Offset(p.dx, p.dy - crossSize), Offset(p.dx, p.dy + crossSize),
            crossPaint);
      }
    }
  }

  void _drawReferenceLines(Canvas canvas, Size size, double opacity, Color lineColor) {
    final refPaint = Paint()
      ..color = lineColor.withValues(alpha: opacity * 0.4)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Subtle diagonal reference lines (blueprint guides)
    const diagonalPositions = [
      (Offset(50, 100), Offset(180, 50)),
      (Offset(300, 200), Offset(380, 150)),
    ];

    for (final (start, end) in diagonalPositions) {
      if (start.dx < size.width &&
          start.dy < size.height &&
          end.dx < size.width &&
          end.dy < size.height) {
        canvas.drawLine(start, end, refPaint);
      }
    }

    // Horizontal reference lines
    if (size.height > 400) {
      canvas.drawLine(Offset(30, size.height * 0.45),
          Offset(150, size.height * 0.45), refPaint);
    }
    if (size.height > 500) {
      canvas.drawLine(Offset(size.width - 200, size.height * 0.7),
          Offset(size.width - 50, size.height * 0.7), refPaint);
    }
  }

  void _drawConstructionMarks(Canvas canvas, Size size, double opacity, Color lineColor) {
    final markPaint = Paint()
      ..color = lineColor.withValues(alpha: opacity * 0.5)
      ..style = PaintingStyle.fill;

    const markRadius = 1.5;
    final markPositions = <Offset>[
      const Offset(90, 130),
      Offset(size.width * 0.7, 190),
      Offset(size.width * 0.3, size.height * 0.55),
      Offset(size.width - 100, size.height * 0.75),
    ];

    for (final p in markPositions) {
      if (p.dx < size.width && p.dy < size.height) {
        canvas.drawCircle(p, markRadius, markPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BlueprintPainter oldDelegate) {
    return isDark != oldDelegate.isDark || intensity != oldDelegate.intensity;
  }
}

