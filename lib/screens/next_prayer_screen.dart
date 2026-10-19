import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/algeria_wilayas.dart';
import '../data/algeria_communes.dart';
import '../services/prayer_service.dart';
import '../services/adhan_audio_service.dart';
import '../services/location_service.dart';
import '../services/theme_service.dart';
import '../services/app_feedback.dart';
import '../services/prayer_notification_service.dart';
import '../services/language_service.dart';
import '../data/world_cities.dart';
import '../widgets/mihrab_clock_widget.dart';
import '../widgets/prayer_tracker_card.dart';
import '../services/home_widget_service.dart';

class NextPrayerScreen extends StatefulWidget {
  final Wilaya currentWilaya;
  final Commune? currentCommune;
  final VoidCallback onOpenDrawer;
  final VoidCallback onSearchWilaya;
  final void Function(Wilaya, Commune?)? onLocationChanged;

  const NextPrayerScreen({
    super.key,
    required this.currentWilaya,
    this.currentCommune,
    required this.onOpenDrawer,
    required this.onSearchWilaya,
    this.onLocationChanged,
  });

  @override
  State<NextPrayerScreen> createState() => _NextPrayerScreenState();
}

class _NextPrayerScreenState extends State<NextPrayerScreen> {
  late Timer _timer;
  late DateTime _currentTime;
  late Map<String, String> _todayTimes;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _recalculate();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final now = DateTime.now();
        setState(() {
          _currentTime = now;
        });
        _checkAutomaticPrayerAlert(now);
      }
    });
  }

  void _recalculate() {
    Commune commune;
    if (widget.currentWilaya.code >= 1000) {
      final city = WorldCitiesData.getCityByCode(widget.currentWilaya.code);
      commune = widget.currentCommune ?? (city != null ? Commune(
        id: city.code,
        wilayaCode: city.code,
        nameAr: city.nameAr,
        nameFr: city.nameFr,
        latitude: city.latitude,
        longitude: city.longitude,
        type: city.countryAr,
      ) : AlgeriaCommunes.allCommunes[0]);
    } else {
      commune = widget.currentCommune ??
          AlgeriaCommunes.getCommunesByWilaya(widget.currentWilaya.code).firstOrNull ??
          AlgeriaCommunes.allCommunes[0];
    }
    _todayTimes = PrayerService.calculateTimesForCommune(commune, _currentTime);
    final nextInfo = _getNextPrayerInfo();
    HomeWidgetService.updateWidget(
      prayerName: nextInfo['nameAr'] ?? nextInfo['name'] ?? '',
      prayerTime: nextInfo['time'] ?? '',
      remaining: nextInfo['remaining'] ?? '',
      location: commune.nameAr,
    );
  }

  @override
  void didUpdateWidget(covariant NextPrayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWilaya.code != widget.currentWilaya.code ||
        oldWidget.currentCommune?.id != widget.currentCommune?.id) {
      _recalculate();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Automatic Adhan Alert when Prayer time arrives
  void _checkAutomaticPrayerAlert(DateTime now) {
    final prayers = [
      {"name": "الفجر", "key": "fajr"},
      {"name": "الظهر", "key": "dhuhr"},
      {"name": "العصر", "key": "asr"},
      {"name": "المغرب", "key": "maghrib"},
      {"name": "العشاء", "key": "isha"},
    ];

    for (var p in prayers) {
      final tStr = _todayTimes[p['key']];
      if (tStr == null) continue;
      final parts = tStr.split(":");
      final ph = int.parse(parts[0]);
      final pm = int.parse(parts[1]);

      if (now.hour == ph && now.minute == pm) {
        final key = p['key']!;
        if (!PrayerNotificationService.hasTriggeredToday(key)) {
          PrayerNotificationService.markTriggeredToday(key);
          _triggerPrayerAdhanAlert(p['name']!, key);
        }
      }
    }
  }

  void _triggerPrayerAdhanAlert(String prayerName, String prayerKey) {
    if (const bool.fromEnvironment('FLUTTER_TEST')) return;

    PrayerNotificationService.triggerAdhanNotification(
      prayerName: prayerName,
      prayerKey: prayerKey,
      communeName: widget.currentCommune?.nameAr ?? widget.currentWilaya.nameAr,
    );

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final locName = widget.currentCommune?.nameAr ?? widget.currentWilaya.nameAr;
        return AlertDialog(
          backgroundColor: const Color(0xFF0F254E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 2),
          ),
          title: const Row(
            children: [
              Icon(Icons.mosque, color: Color(0xFFD4AF37), size: 28),
              SizedBox(width: 10),
              Text(
                "حان الآن موعد الصلاة",
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "الله أكبر الله أكبر\nحان الآن موعد أذان صلاة $prayerName حسب التوقيت المحلي لـ $locName 🕌",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 12),
              const Text(
                "«حَيَّ عَلَى الصَّلَاةِ، حَيَّ عَلَى الْفَلَاحِ»",
                style: TextStyle(color: Color(0xFFFDE68A), fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.stop, size: 18),
              label: const Text("إيقاف الأذان", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                AdhanAudioService.stopAdhan();
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }


  Map<String, String> _getNextPrayerInfo() {
    final lang = LanguageService.languageCode;
    final isAr = lang == 'ar';
    final prayers = [
      {"name": isAr ? "الفجر" : LanguageService.tr('fajr'), "nameAr": "الفجر", "key": "fajr"},
      {"name": isAr ? "الظهر" : LanguageService.tr('dhuhr'), "nameAr": "الظهر", "key": "dhuhr"},
      {"name": isAr ? "العصر" : LanguageService.tr('asr'), "nameAr": "العصر", "key": "asr"},
      {"name": isAr ? "المغرب" : LanguageService.tr('maghrib'), "nameAr": "المغرب", "key": "maghrib"},
      {"name": isAr ? "العشاء" : LanguageService.tr('isha'), "nameAr": "العشاء", "key": "isha"},
    ];

    final now = _currentTime;
    for (var p in prayers) {
      final tStr = _todayTimes[p['key']];
      if (tStr == null) continue;
      final parts = tStr.split(":");
      final pTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));

      if (now.isBefore(pTime)) {
        final diff = pTime.difference(now);
        return {
          "name": p['name']!,
          "nameAr": p['nameAr']!,
          "time": tStr,
          "remaining": _formatDuration(diff),
        };
      }
    }

    final fajrStr = _todayTimes['fajr'] ?? "05:00";
    final parts = fajrStr.split(":");
    final tomorrowFajr = DateTime(now.year, now.month, now.day + 1, int.parse(parts[0]), int.parse(parts[1]));
    return {
      "name": isAr ? "الفجر" : LanguageService.tr('fajr'),
      "nameAr": "الفجر",
      "time": fajrStr,
      "remaining": _formatDuration(tomorrowFajr.difference(now)),
    };
  }

  String _formatDuration(Duration d) {
    final isAr = LanguageService.languageCode == 'ar';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (isAr) {
      if (h > 0) {
        return "$h س $m د $s ث";
      }
      return "$m د $s ث";
    }
    final sStr = s.toString().padLeft(2, '0');
    final mStr = m.toString().padLeft(2, '0');
    if (h > 0) {
      return "${h}h ${mStr}m ${sStr}s";
    }
    return "${m}m ${sStr}s";
  }

  Future<void> _detectGps() async {
    final lang = LanguageService.languageCode;
    final isAr = lang == 'ar';
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF065F46),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isAr
                    ? "جاري كشف موقعك وتحديد بلديتك/قريتك عبر الـ GPS..."
                    : (lang == 'fr'
                        ? "Détection de votre position via GPS..."
                        : "Detecting your location via GPS..."),
              ),
            ),
          ],
        ),
      ),
    );

    final res = await LocationService.detectLocation();
    if (res != null && widget.onLocationChanged != null) {
      widget.onLocationChanged!(res.wilaya, res.commune);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selected_wilaya', res.wilaya.code);
      await prefs.setInt('selected_commune_id', res.commune.id);

      if (!mounted) return;
      AppFeedback.select();
      await AdhanAudioService.playNotificationChime();
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF065F46),
          content: Text(
            isAr
                ? "تم تحديد موقعك بدقة: ${res.commune.nameAr} (${res.commune.type}) - ولاية ${res.wilaya.nameAr} 📍"
                : "${LanguageService.tr('auto_gps_success')} (${res.commune.nameFr} - ${res.wilaya.nameFr}) 📍",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.currentLocale,
      builder: (context, activeLocale, _) {
        final lang = activeLocale.languageCode;
        final isAr = lang == 'ar';
        final next = _getNextPrayerInfo();
        final communeObj = widget.currentCommune ??
            AlgeriaCommunes.getCommunesByWilaya(widget.currentWilaya.code).firstOrNull ??
            AlgeriaCommunes.allCommunes[0];

        String locationLabel;
        if (isAr) {
          locationLabel = communeObj.type == "بلدية"
              ? "بلدية ${communeObj.nameAr} • ولاية ${widget.currentWilaya.nameAr}"
              : "${communeObj.nameAr} (${communeObj.type}) • ${widget.currentWilaya.nameAr}";
        } else {
          if (widget.currentWilaya.code >= 1000) {
            final city = WorldCitiesData.getCityByCode(widget.currentWilaya.code);
            locationLabel = city != null ? city.getDisplayName(lang) : "${communeObj.nameFr} • ${widget.currentWilaya.nameFr}";
          } else {
            locationLabel = "${communeObj.nameFr} • ${widget.currentWilaya.nameFr}";
          }
        }

        return ValueListenableBuilder<AppThemeColor>(
          valueListenable: ThemeService.currentTheme,
          builder: (context, theme, _) {
            return Scaffold(
              backgroundColor: theme.background,
              appBar: AppBar(
                backgroundColor: theme.darkPrimary,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 26),
                  tooltip: isAr ? "القائمة الجانبية" : LanguageService.tr('menu'),
                  onPressed: widget.onOpenDrawer,
                ),
                title: GestureDetector(
                  onTap: widget.onSearchWilaya,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: theme.accent, size: 18),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          locationLabel,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
                    ],
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.my_location, color: theme.accent),
                    tooltip: isAr ? "تحديد الموقع GPS تلقائياً" : LanguageService.tr('gps_auto_switch'),
                    onPressed: () {
                      AppFeedback.tap();
                      _detectGps();
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                child: Column(
                  children: [
                    // Dates card - Perfectly centered per user request
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.accent.withValues(alpha: 0.35)),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              PrayerService.getFormattedHijriDate(_currentTime, lang),
                              style: TextStyle(color: theme.accent, fontWeight: FontWeight.bold, fontSize: 12.5),
                            ),
                            Text(
                              "•",
                              style: TextStyle(color: theme.accent.withValues(alpha: 0.6), fontSize: 14),
                            ),
                            Text(
                              PrayerService.getFormattedGregorianDate(_currentTime, lang),
                              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Islamic Clock (Supports Analog, Digital, Minimalist)
                    Center(
                      child: MihrabClockWidget(
                        dateTime: _currentTime,
                        prayerTimes: _todayTimes,
                        isAr: isAr,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Next Prayer Countdown Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.darkPrimary, theme.cardBackground],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: theme.accent.withValues(alpha: 0.35), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: theme.accent.withValues(alpha: 0.12),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            isAr
                                ? "الصلاة القادمة: صلاة ${next['name']}"
                                : "${LanguageService.tr('tab_next_prayer')}: ${next['name']}",
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),

                          // Time Text - 24-hour format (e.g. 16:09)
                          Text(
                            next['time'] ?? "",
                            style: TextStyle(
                              color: theme.accent,
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              isAr
                                  ? "متبقي: ${next['remaining']}"
                                  : "${LanguageService.tr('remaining_prefix')}: ${next['remaining']}",
                              style: const TextStyle(color: Color(0xFFFDE68A), fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Daily Prayer Tracker with Streak Badge
                    PrayerTrackerCard(isAr: isAr),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
