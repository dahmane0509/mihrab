import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../data/algeria_wilayas.dart';
import '../data/world_cities.dart';
import '../services/language_service.dart';
import '../services/qibla_service.dart';

class QiblaScreen extends StatefulWidget {
  final Wilaya currentWilaya;
  final VoidCallback? onOpenDrawer;

  const QiblaScreen({
    super.key,
    required this.currentWilaya,
    this.onOpenDrawer,
  });

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  StreamSubscription<MagnetometerEvent>? _sensorSubscription;
  double _deviceHeading = 0.0;
  bool _hasSensor = false;

  @override
  void initState() {
    super.initState();
    _initSensor();
  }

  void _initSensor() {
    try {
      _sensorSubscription = magnetometerEventStream().listen(
        (MagnetometerEvent event) {
          // Standard Android Sensor formula (device held horizontally / flat)
          // X is right, Y is top, Z is perpendicular to screen
          double rawHeading = (atan2(-event.x, event.y) * 180.0 / pi + 360.0) % 360.0;

          // Low-pass filter for smooth needle movement
          double diff = rawHeading - _deviceHeading;
          if (diff > 180) diff -= 360;
          if (diff < -180) diff += 360;
          double smoothed = (_deviceHeading + diff * 0.25 + 360.0) % 360.0;

          if (mounted) {
            setState(() {
              _deviceHeading = smoothed;
              _hasSensor = true;
            });
          }
        },
        onError: (Object err) {
          debugPrint("Sensors error: $err");
          if (mounted) {
            setState(() {
              _hasSensor = false;
            });
          }
        },
      );
    } catch (e) {
      debugPrint("Cannot initialize magnetometer: $e");
      _hasSensor = false;
    }
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }

  void _showCalibrationGuide() {
    final isAr = LanguageService.currentLocale.value.languageCode == 'ar';
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.compass_calibration, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isAr ? "معايرة بوصلة القبلة" : LanguageService.tr('qibla_calibration_title'),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? "للحصول على أقصى دقة في تحديد القبلة المشرفة:" : LanguageService.tr('qibla_calibration_desc_title'),
              style: const TextStyle(color: Color(0xFFFDE68A), fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Text(
              isAr
                  ? "1. أمسك الهاتف بشكل أفقي تماماً ومستوٍ.\n"
                    "2. ابتعد عن الأجهزة الإلكترونية والمغناطيس والمعادن والسيارات.\n"
                    "3. قم بتحريك الهاتف في الهواء على شكل الرقم ثمانية (∞) بالإنجليزية مرتين إلى ثلاث مرات لمعايرة مستشعر المغناطيسية."
                  : "${LanguageService.tr('qibla_calibration_step1')}\n"
                    "${LanguageService.tr('qibla_calibration_step2')}\n"
                    "${LanguageService.tr('qibla_calibration_step3')}",
              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.6),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isAr ? "تم، فهمت ذلك" : LanguageService.tr('understood'),
              style: const TextStyle(color: Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.currentLocale,
      builder: (context, locale, _) {
        final lang = locale.languageCode;
        final isAr = lang == 'ar';

        final qiblaBearing = QiblaService.calculateQiblaDirection(
          widget.currentWilaya.latitude,
          widget.currentWilaya.longitude,
        );

        final distanceKm = QiblaService.calculateDistanceToKaabaKm(
          widget.currentWilaya.latitude,
          widget.currentWilaya.longitude,
        );

        // Relative angle between current heading and Qibla bearing
        double offset = (qiblaBearing - _deviceHeading + 360.0) % 360.0;
        if (offset > 180) offset -= 360;

        // Within ±5 degrees is considered facing Qibla
        final isAligned = _hasSensor && (offset.abs() <= 5.0);

        // Location name formatting
        String wilayaName;
        if (widget.currentWilaya.code >= 1000) {
          final city = WorldCitiesData.getCityByCode(widget.currentWilaya.code);
          wilayaName = city != null
              ? city.getDisplayName(lang)
              : (isAr ? widget.currentWilaya.nameAr : widget.currentWilaya.nameFr);
        } else {
          wilayaName = isAr ? widget.currentWilaya.nameAr : widget.currentWilaya.nameFr;
        }

        // Direction instruction message
        String instructionText = "";
        if (!_hasSensor) {
          if (isAr) {
            instructionText = "وجّه رأس الهاتف نحو زاوية ${qiblaBearing.toStringAsFixed(1)}° شرق الشمال";
          } else {
            instructionText = "${LanguageService.tr('point_head_north_east')} ${qiblaBearing.toStringAsFixed(1)}° (${LanguageService.tr('north_east')})";
          }
        } else if (isAligned) {
          instructionText = isAr
              ? "أنت الآن باتجاه القبلة مباشرة نحو الكعبة المشرفة ✓"
              : LanguageService.tr('facing_kaaba_success');
        } else if (offset > 0) {
          instructionText = isAr
              ? "أدر هاتفك نحو اليمين بمقدار ${offset.abs().toStringAsFixed(0)}°"
              : "${LanguageService.tr('turn_right_by')} ${offset.abs().toStringAsFixed(0)}°";
        } else {
          instructionText = isAr
              ? "أدر هاتفك نحو اليسار بمقدار ${offset.abs().toStringAsFixed(0)}°"
              : "${LanguageService.tr('turn_left_by')} ${offset.abs().toStringAsFixed(0)}°";
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0B132B),
          appBar: AppBar(
            backgroundColor: const Color(0xFF064E3B),
            elevation: 0,
            centerTitle: true,
            leading: widget.onOpenDrawer != null
                ? IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 26),
                    tooltip: isAr ? "القائمة الجانبية" : LanguageService.tr('menu'),
                    onPressed: widget.onOpenDrawer,
                  )
                : null,
            title: Text(
              isAr
                  ? "بوصلة القبلة - ${widget.currentWilaya.nameAr}"
                  : "${LanguageService.tr('qibla_compass')} - $wilayaName",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.white),
                tooltip: isAr ? "إرشادات معايرة البوصلة" : LanguageService.tr('calibration_instructions_tooltip'),
                onPressed: _showCalibrationGuide,
              ),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Distance & Qibla Angle Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isAligned ? const Color(0xFF10B981) : const Color(0xFF334155),
                        width: isAligned ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isAr
                                    ? "زاوية القبلة (${widget.currentWilaya.nameAr})"
                                    : "${LanguageService.tr('qibla_angle')} ($wilayaName)",
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isAr
                                    ? "${qiblaBearing.toStringAsFixed(1)}° شرقاً"
                                    : "${qiblaBearing.toStringAsFixed(1)}° ${LanguageService.tr('east_direction')}",
                                style: TextStyle(
                                  color: isAligned ? const Color(0xFF34D399) : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Container(height: 38, width: 1, color: const Color(0xFF334155), margin: const EdgeInsets.symmetric(horizontal: 8)),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isAr
                                    ? "المسافة إلى مكة"
                                    : LanguageService.tr('distance_to_makkah'),
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isAr
                                    ? "${distanceKm.toStringAsFixed(0)} كم"
                                    : "${distanceKm.toStringAsFixed(0)} ${LanguageService.tr('km_unit')}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Interactive Status Banner
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isAligned
                          ? const Color(0xFF065F46)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAligned ? const Color(0xFFD4AF37) : const Color(0xFF334155),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAligned ? Icons.check_circle : Icons.navigation,
                          color: isAligned ? const Color(0xFFFDE68A) : const Color(0xFF38BDF8),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            instructionText,
                            style: TextStyle(
                              color: isAligned ? const Color(0xFFFDE68A) : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Compass Dial with Smooth Rotation
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Glow when facing Kaaba
                      if (isAligned)
                        Container(
                          width: 290,
                          height: 290,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                blurRadius: 35,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                        ),

                      // Rotating Compass Dial
                      Transform.rotate(
                        angle: -_deviceHeading * (pi / 180.0),
                        child: Container(
                          width: 270,
                          height: 270,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E293B),
                            border: Border.all(
                              color: isAligned ? const Color(0xFFD4AF37) : const Color(0xFF475569),
                              width: 3,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Cardinal Directions
                              const Positioned(
                                top: 14,
                                child: Text("N", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              const Positioned(
                                bottom: 14,
                                child: Text("S", style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              const Positioned(
                                left: 14,
                                child: Text("W", style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              const Positioned(
                                right: 14,
                                child: Text("E", style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 14)),
                              ),

                              // Kaaba Pointer Marker on the Dial
                              Transform.rotate(
                                angle: qiblaBearing * (pi / 180.0),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 36.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD4AF37),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(Icons.mosque, color: Colors.black, size: 20),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isAr ? "القبلة" : LanguageService.tr('qibla_marker'),
                                          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Inner dial circle
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF334155), width: 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Fixed Center Needle Pointing Up
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.navigation,
                            color: isAligned ? const Color(0xFF10B981) : const Color(0xFFD4AF37),
                            size: 48,
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isAligned ? const Color(0xFF10B981) : const Color(0xFFD4AF37),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Calibration note
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF64748B), size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            isAr
                                ? "احمل الهاتف أفقياً بعيداً عن المعادن والأجهزة الإلكترونية"
                                : LanguageService.tr('qibla_flat_device_note'),
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
