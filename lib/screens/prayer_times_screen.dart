import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/algeria_wilayas.dart';
import '../data/algeria_communes.dart';
import '../services/prayer_service.dart';
import '../services/adhan_audio_service.dart';
import '../services/prayer_notification_service.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';
import '../data/world_cities.dart';

class PrayerTimesScreen extends StatefulWidget {
  final Wilaya currentWilaya;
  final Commune? currentCommune;
  final VoidCallback onOpenDrawer;

  const PrayerTimesScreen({
    super.key,
    required this.currentWilaya,
    this.currentCommune,
    required this.onOpenDrawer,
  });

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  DateTime _selectedDate = DateTime.now();
  late Map<String, String> _times;
  Map<String, bool> _prayerMuted = {
    "fajr": false,
    "sunrise": true,
    "dhuhr": false,
    "asr": false,
    "maghrib": false,
    "isha": false,
  };

  @override
  void initState() {
    super.initState();
    _loadMutePreferences();
    _recalcTimes();
  }

  @override
  void didUpdateWidget(covariant PrayerTimesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWilaya.code != widget.currentWilaya.code ||
        oldWidget.currentCommune?.id != widget.currentCommune?.id) {
      _recalcTimes();
    }
  }

  Future<void> _loadMutePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prayerMuted = {
        "fajr": prefs.getBool('mute_fajr') ?? false,
        "sunrise": prefs.getBool('mute_sunrise') ?? true,
        "dhuhr": prefs.getBool('mute_dhuhr') ?? false,
        "asr": prefs.getBool('mute_asr') ?? false,
        "maghrib": prefs.getBool('mute_maghrib') ?? false,
        "isha": prefs.getBool('mute_isha') ?? false,
      };
    });
  }

  void _recalcTimes() {
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
    setState(() {
      _times = PrayerService.calculateTimesForCommune(commune, _selectedDate);
    });
  }

  Future<void> _toggleMute(String key, String arabicName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = _prayerMuted[key] ?? false;
    final updated = !current;

    setState(() {
      _prayerMuted[key] = updated;
    });
    await prefs.setBool('mute_$key', updated);
    PrayerNotificationService.scheduleAllPrayerNotifications();

    if (!mounted) return;
    AdhanAudioService.playNotificationChime();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: updated ? const Color(0xFF334155) : const Color(0xFF065F46),
        duration: const Duration(seconds: 2),
        content: Text(
          updated
              ? "تم كتم التنبيه لصلاة $arabicName 🔕"
              : "تم تفعيل التنبيه والأذان لصلاة $arabicName 🔔",
        ),
      ),
    );
  }

  String _to12Hour(String? time24) {
    if (time24 == null) return "--:--";
    try {
      final parts = time24.split(":");
      int h = int.parse(parts[0]);
      final m = parts[1];
      final isPm = h >= 12;
      if (h == 0) h = 12;
      if (h > 12) h -= 12;
      return "$h:$m ${isPm ? 'م' : 'ص'}";
    } catch (_) {
      return time24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.currentLocale,
      builder: (context, activeLocale, _) {
        final lang = activeLocale.languageCode;
        final isAr = lang == 'ar';
        final communeName = isAr
            ? (widget.currentCommune?.nameAr ?? widget.currentWilaya.nameAr)
            : (widget.currentCommune?.nameFr ?? widget.currentWilaya.nameFr);

        final prayersList = [
          {"key": "fajr", "name": isAr ? "الصبح" : LanguageService.tr('fajr'), "icon": Icons.nightlight_round, "color": const Color(0xFF38BDF8)},
          {"key": "sunrise", "name": isAr ? "الشروق" : LanguageService.tr('sunrise'), "icon": Icons.wb_twilight, "color": const Color(0xFFF59E0B)},
          {"key": "dhuhr", "name": isAr ? "الظهر" : LanguageService.tr('dhuhr'), "icon": Icons.wb_sunny, "color": const Color(0xFF10B981)},
          {"key": "asr", "name": isAr ? "العصر" : LanguageService.tr('asr'), "icon": Icons.wb_cloudy, "color": const Color(0xFF34D399)},
          {"key": "maghrib", "name": isAr ? "المغرب" : LanguageService.tr('maghrib'), "icon": Icons.flare, "color": const Color(0xFFFB923C)},
          {"key": "isha", "name": isAr ? "العشاء" : LanguageService.tr('isha'), "icon": Icons.nights_stay, "color": const Color(0xFF818CF8)},
        ];

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
            title: Text(
              isAr
                  ? "أوقات الصلاة • بلدية $communeName"
                  : "${LanguageService.tr('tab_prayer_times')} • $communeName",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.volume_up_outlined, color: Colors.amber),
                tooltip: "تجربة صوت الأذان والإشعار",
                onPressed: () async {
                  await PrayerNotificationService.testAdhanNotification(
                    prayerName: "الظهر",
                    prayerKey: "dhuhr",
                    communeName: communeName,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF064E3B),
                      content: Text("جاري تشغيل صوت الأذان لتوقيت $communeName 🕌"),
                      action: SnackBarAction(
                        label: "إيقاف",
                        textColor: const Color(0xFFFDE68A),
                        onPressed: () => AdhanAudioService.stopAdhan(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            children: [
              // Date Navigation Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.cardBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      tooltip: isAr ? "اليوم التالي" : LanguageService.tr('next_day'),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                          _recalcTimes();
                        });
                      },
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              PrayerService.getFormattedGregorianDate(_selectedDate, LanguageService.languageCode),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              PrayerService.getFormattedHijriDate(_selectedDate, LanguageService.languageCode),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: theme.accent, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      tooltip: isAr ? "اليوم السابق" : LanguageService.tr('previous_day'),
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                          _recalcTimes();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Prayers List
              ...prayersList.map((p) {
                final key = p['key'] as String;
                final name = p['name'] as String;
                final icon = p['icon'] as IconData;
                final color = p['color'] as Color;
                final time24 = _times[key];
                final isMuted = _prayerMuted[key] ?? false;
                final isSunrise = key == "sunrise";

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    children: [
                      // Prayer Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 10),
                      // Prayer Name
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Prayer Times & Iqamah Info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            time24 ?? "--:--",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _to12Hour(time24),
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                              ),
                              if (!isSunrise && PrayerService.defaultIqamahDelays.containsKey(key)) ...[
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: theme.primary.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    isAr
                                        ? "إقامة +${PrayerService.defaultIqamahDelays[key]}د"
                                        : "Iqama +${PrayerService.defaultIqamahDelays[key]}m",
                                    style: TextStyle(color: theme.primary, fontSize: 10),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      // Notification Alert Button
                      if (!isSunrise)
                        IconButton(
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            isMuted ? Icons.notifications_off_outlined : Icons.notifications_active,
                            color: isMuted ? Colors.white30 : theme.accent,
                            size: 22,
                          ),
                          tooltip: isMuted
                              ? (isAr ? "تفعيل التنبيه" : "Unmute")
                              : (isAr ? "كتم التنبيه" : "Mute"),
                          onPressed: () => _toggleMute(key, name),
                        )
                      else
                        const SizedBox(width: 36),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  },
);
}
}
