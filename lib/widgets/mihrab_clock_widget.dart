import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/clock_style_service.dart';

class MihrabClockWidget extends StatelessWidget {
  final DateTime dateTime;
  final Map<String, dynamic> prayerTimes;
  final bool isAr;

  const MihrabClockWidget({
    super.key,
    required this.dateTime,
    required this.prayerTimes,
    this.isAr = true,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ClockStyleService.currentStyle,
      builder: (context, style, _) {
        return ValueListenableBuilder<AppThemeColor>(
          valueListenable: ThemeService.currentTheme,
          builder: (context, theme, _) {
            switch (style) {
              case 'digital':
                return _buildDigitalClock(context, theme);
              case 'minimalist':
                return _buildMinimalistClock(context, theme);
              case 'analog':
              default:
                return _buildAnalogClock(context, theme);
            }
          },
        );
      },
    );
  }

  // 1. Classic Analog Clock
  Widget _buildAnalogClock(BuildContext context, AppThemeColor theme) {
    return SizedBox(
      width: 158,
      height: 158,
      child: CustomPaint(
        painter: ModernAnalogClockPainter(
          dateTime: dateTime,
          prayerTimes: prayerTimes,
          accentColor: theme.accent,
          primaryColor: theme.primary,
        ),
      ),
    );
  }

  // 2. Modern Digital Clock
  Widget _buildDigitalClock(BuildContext context, AppThemeColor theme) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final isPm = dateTime.hour >= 12;
    final periodStr = isAr ? (isPm ? "مساءً" : "صباحاً") : (isPm ? "PM" : "AM");

    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF071224),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.accent.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header subtle status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primary,
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isAr ? "الوقت الحالي" : "Current Time",
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  periodStr,
                  style: TextStyle(
                    color: theme.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Main Digital Time Display
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "$hour:$minute",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: theme.accent.withValues(alpha: 0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    second,
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Seconds progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: dateTime.second / 59.0,
              minHeight: 3.5,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Minimalist Arabic Numerals Clock
  Widget _buildMinimalistClock(BuildContext context, AppThemeColor theme) {
    return SizedBox(
      width: 158,
      height: 158,
      child: CustomPaint(
        painter: MinimalistArabicClockPainter(
          dateTime: dateTime,
          accentColor: theme.accent,
          primaryColor: theme.primary,
        ),
      ),
    );
  }
}

/// Painter for the Classic Analog Clock
class ModernAnalogClockPainter extends CustomPainter {
  final DateTime dateTime;
  final Map<String, dynamic> prayerTimes;
  final Color accentColor;
  final Color primaryColor;

  ModernAnalogClockPainter({
    required this.dateTime,
    required this.prayerTimes,
    this.accentColor = const Color(0xFFD4AF37),
    this.primaryColor = const Color(0xFF10B981),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF0F254E), Color(0xFF071224), Color(0xFF030712)],
        stops: [0.0, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    final ringPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8;
    canvas.drawCircle(center, radius - 2, ringPaint);

    final innerRimPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius - 9, innerRimPaint);

    final arcPaint = Paint()
      ..shader = SweepGradient(
        colors: [primaryColor, const Color(0xFFF59E0B), const Color(0xFFEF4444)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (dateTime.minute / 60.0) * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4.5),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30.0 - 90.0) * (math.pi / 180.0);
      final numRadius = radius - 22;
      final x = center.dx + numRadius * math.cos(angle);
      final y = center.dy + numRadius * math.sin(angle);

      textPainter.text = TextSpan(
        text: "$i",
        style: const TextStyle(
          color: Color(0xFFE2E8F0),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }

    final hour = dateTime.hour % 12;
    final hourAngle = ((hour + dateTime.minute / 60.0) * 30.0 - 90.0) * (math.pi / 180.0);
    final hourPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    final hourEnd = Offset(
      center.dx + (radius * 0.5) * math.cos(hourAngle),
      center.dy + (radius * 0.5) * math.sin(hourAngle),
    );
    canvas.drawLine(center, hourEnd, hourPaint);

    final minAngle = ((dateTime.minute + dateTime.second / 60.0) * 6.0 - 90.0) * (math.pi / 180.0);
    final minPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    final minEnd = Offset(
      center.dx + (radius * 0.72) * math.cos(minAngle),
      center.dy + (radius * 0.72) * math.sin(minAngle),
    );
    canvas.drawLine(center, minEnd, minPaint);

    final secAngle = (dateTime.second * 6.0 - 90.0) * (math.pi / 180.0);
    final secPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final secEnd = Offset(
      center.dx + (radius * 0.85) * math.cos(secAngle),
      center.dy + (radius * 0.85) * math.sin(secAngle),
    );
    canvas.drawLine(center, secEnd, secPaint);

    final pinPaint = Paint()..color = accentColor;
    canvas.drawCircle(center, 5, pinPaint);
  }

  @override
  bool shouldRepaint(covariant ModernAnalogClockPainter oldDelegate) {
    return oldDelegate.dateTime.second != dateTime.second;
  }
}

/// Painter for the Minimalist Arabic Clock
class MinimalistArabicClockPainter extends CustomPainter {
  final DateTime dateTime;
  final Color accentColor;
  final Color primaryColor;

  static const List<String> arabicNumerals = [
    "١٢", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩", "١٠", "١١"
  ];

  MinimalistArabicClockPainter({
    required this.dateTime,
    this.accentColor = const Color(0xFFD4AF37),
    this.primaryColor = const Color(0xFF10B981),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Soft dark background
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF020617)],
        stops: [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // Subtle single border ring
    final ringPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(center, radius - 2, ringPaint);

    // 12 Arabic Numerals (١٢، ١، ٢، ٣، ...)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30.0 - 90.0) * (math.pi / 180.0);
      final numRadius = radius - 20;
      final x = center.dx + numRadius * math.cos(angle);
      final y = center.dy + numRadius * math.sin(angle);

      final isCardinal = (i % 3 == 0); // 12, 3, 6, 9
      textPainter.text = TextSpan(
        text: arabicNumerals[i],
        style: TextStyle(
          color: isCardinal ? accentColor : const Color(0xFFE2E8F0),
          fontSize: 13,
          fontWeight: isCardinal ? FontWeight.bold : FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }

    // Hour hand
    final hour = dateTime.hour % 12;
    final hourAngle = ((hour + dateTime.minute / 60.0) * 30.0 - 90.0) * (math.pi / 180.0);
    final hourPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    final hourEnd = Offset(
      center.dx + (radius * 0.48) * math.cos(hourAngle),
      center.dy + (radius * 0.48) * math.sin(hourAngle),
    );
    canvas.drawLine(center, hourEnd, hourPaint);

    // Minute hand
    final minAngle = ((dateTime.minute + dateTime.second / 60.0) * 6.0 - 90.0) * (math.pi / 180.0);
    final minPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final minEnd = Offset(
      center.dx + (radius * 0.70) * math.cos(minAngle),
      center.dy + (radius * 0.70) * math.sin(minAngle),
    );
    canvas.drawLine(center, minEnd, minPaint);

    // Second hand - delicate emerald line
    final secAngle = (dateTime.second * 6.0 - 90.0) * (math.pi / 180.0);
    final secPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final secEnd = Offset(
      center.dx + (radius * 0.82) * math.cos(secAngle),
      center.dy + (radius * 0.82) * math.sin(secAngle),
    );
    canvas.drawLine(center, secEnd, secPaint);

    // Center jewel pin
    final pinOuterPaint = Paint()..color = accentColor;
    canvas.drawCircle(center, 4.5, pinOuterPaint);
    final pinInnerPaint = Paint()..color = const Color(0xFF020617);
    canvas.drawCircle(center, 2.0, pinInnerPaint);
  }

  @override
  bool shouldRepaint(covariant MinimalistArabicClockPainter oldDelegate) {
    return oldDelegate.dateTime.second != dateTime.second;
  }
}
