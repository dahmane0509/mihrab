import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';
import '../services/prayer_service.dart';
import '../data/algeria_communes.dart';
import '../data/world_cities.dart';

/// Service managing communication with the native Android Home Screen Widget
class HomeWidgetService {
  static const MethodChannel _channel =
      MethodChannel('com.mihrab.algeria.mihrab_app/settings');

  /// Update widget with upcoming prayer information
  static Future<void> updateWidget({
    required String prayerName,
    required String prayerTime,
    required String remaining,
    required String location,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('updateWidget', {
        'prayerName': prayerName,
        'prayerTime': prayerTime,
        'remaining': remaining,
        'location': location,
      });
    } catch (e) {
      debugPrint("HomeWidgetService updateWidget error: $e");
    }
  }

  /// Automatically calculates next prayer and pushes it to native Home Widget
  static Future<void> updateFromCurrentPrayerTimes() async {
    if (!Platform.isAndroid) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final wilayaCode = prefs.getInt('selected_wilaya') ?? 16;
      final communeId = prefs.getInt('selected_commune_id');

      Commune commune;
      if (wilayaCode >= 1000) {
        final city = WorldCitiesData.getCityByCode(wilayaCode);
        commune = (city != null
            ? Commune(
                id: city.code,
                wilayaCode: city.code,
                nameAr: city.nameAr,
                nameFr: city.nameFr,
                latitude: city.latitude,
                longitude: city.longitude,
                type: city.countryAr,
              )
            : AlgeriaCommunes.allCommunes[0]);
      } else {
        commune = (communeId != null ? AlgeriaCommunes.getCommuneById(communeId) : null) ??
            AlgeriaCommunes.getCommunesByWilaya(wilayaCode).firstOrNull ??
            AlgeriaCommunes.allCommunes[0];
      }

      final now = DateTime.now();
      final times = PrayerService.calculateTimesForCommuneResult(
        commune: commune,
        date: now,
      );

      final prayers = [
        {'nameAr': 'الفجر', 'time': times.fajr},
        {'nameAr': 'الظهر', 'time': times.dhuhr},
        {'nameAr': 'العصر', 'time': times.asr},
        {'nameAr': 'المغرب', 'time': times.maghrib},
        {'nameAr': 'العشاء', 'time': times.isha},
      ];

      Map<String, dynamic>? nextPrayer;
      Duration? minDiff;

      for (var p in prayers) {
        final pTime = p['time'] as DateTime;
        if (now.isBefore(pTime)) {
          nextPrayer = p;
          minDiff = pTime.difference(now);
          break;
        }
      }

      if (nextPrayer == null) {
        final tomorrowTimes = PrayerService.calculateTimesForCommuneResult(
          commune: commune,
          date: now.add(const Duration(days: 1)),
        );
        nextPrayer = {'nameAr': 'الفجر', 'time': tomorrowTimes.fajr};
        minDiff = tomorrowTimes.fajr.difference(now);
      }

      final pTime = nextPrayer['time'] as DateTime;
      final timeStr =
          "${pTime.hour.toString().padLeft(2, '0')}:${pTime.minute.toString().padLeft(2, '0')}";
      final h = minDiff!.inHours;
      final m = minDiff.inMinutes % 60;
      final remainingStr = h > 0 ? "متبقي $h س و $m د" : "متبقي $m دقيقة";

      await updateWidget(
        prayerName: nextPrayer['nameAr'] as String,
        prayerTime: timeStr,
        remaining: remainingStr,
        location: commune.nameAr,
      );
    } catch (e) {
      debugPrint("updateFromCurrentPrayerTimes error: $e");
    }
  }

  /// Request OS to pin the widget directly to Android home screen
  static Future<bool> requestPinWidget() async {
    if (!Platform.isAndroid) return false;
    try {
      final success = await _channel.invokeMethod<bool>('pinWidget');
      return success ?? false;
    } catch (e) {
      debugPrint("HomeWidgetService pinWidget error: $e");
      return false;
    }
  }

  /// Show widget guide or pin dialog to the user
  static Future<void> showWidgetInstructionsDialog(
    BuildContext context, {
    AppThemeColor? theme,
  }) async {
    final activeTheme = theme ?? ThemeService.currentTheme.value;
    final isAr = LanguageService.languageCode == 'ar';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: activeTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: activeTheme.accent.withValues(alpha: 0.4), width: 1.2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activeTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.widgets_rounded, color: activeTheme.accent, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isAr ? "ويدجت الشاشة الرئيسية" : "Home Screen Widget",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr
                  ? "تابع مواقيت الصلاة والعد التنازلي مباشرة من شاشة هاتفك الرئيسية دون الحاجة لفتح التطبيق:"
                  : "Track prayer times and countdown directly on your home screen:",
              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? "خطوات التثبيت اليدوي:" : "Manual Steps:",
                    style: TextStyle(
                      color: activeTheme.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAr
                        ? "1. اضغط مطولاً على أي مساحة فارغة في شاشتك الرئيسية.\n"
                          "2. اختر «التطبيقات المصغّرة / Widgets».\n"
                          "3. ابحث عن «محراب» واسحب الويدجت إلى شاشتك."
                        : "1. Long press an empty area on your home screen.\n"
                          "2. Tap Widgets.\n"
                          "3. Search for 'Mihrab' and place it.",
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? "إغلاق" : "Close", style: const TextStyle(color: Colors.white60)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: activeTheme.accent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            icon: const Icon(Icons.add_to_home_screen_rounded, size: 18),
            label: Text(
              isAr ? "إضافة مباشرة الآن" : "Add to Home Screen",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final pinned = await requestPinWidget();
              if (!context.mounted) return;
              if (pinned) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF065F46),
                    content: Text("تم إرسال طلب إضافة الويدجت لشاشتك الرئيسية بنجاح 📱"),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
