import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../data/algeria_communes.dart';
import '../services/prayer_service.dart';

class AdhanVoice {
  final String id;
  final String titleAr;
  final String subtitleAr;
  const AdhanVoice({
    required this.id,
    required this.titleAr,
    required this.subtitleAr,
  });
}

class AppSettings {
  static const List<AdhanVoice> adhanVoices = [
    AdhanVoice(
      id: "makkah",
      titleAr: "أذان المسجد الحرام (مكة المكرمة)",
      subtitleAr: "أذان الحرم المكي الشريف",
    ),
    AdhanVoice(
      id: "madinah",
      titleAr: "أذان المسجد النبوي (المدينة المنورة)",
      subtitleAr: "أذان الحرم النبوي الشريف",
    ),
    AdhanVoice(
      id: "al_aqsa",
      titleAr: "أذان المسجد الأقصى المبارك",
      subtitleAr: "أذان القدس الشريف",
    ),
  ];
  static const List<int> reminderMinutesOptions = [0, 5, 10, 15, 20, 30];
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'prayer_adhan_channel';
  static const String channelName = 'أذان أوقات الصلاة';
  static const String channelDesc = 'تشغيل صوت الأذان والتنبيه فور دخول وقت الصلاة بدقة';

  /// تهيئة إشعارات النظام وقناة الأذان
  static Future<void> init() async {
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Africa/Algiers'));

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings settings =
          InitializationSettings(android: androidSettings);

      // متوافق مع إصدار 22
      await _notificationsPlugin.initialize(settings: settings);

      // إنشاء قناة الأذان المخصصة بنوع إنذار (Alarm)
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDesc,
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('adhan'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableVibration: true,
      );

      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(channel);

      // طلب إذن الإشعارات لأندرويد 13 فما فوق
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint("Notification init error: $e");
    }
  }

  /// جدولة مواقيت الصلوات الخمس للبلدية المحددة في منبه أندرويد
  static Future<void> schedulePrayersForCommune(Commune commune) async {
    try {
      final now = DateTime.now();
      
      final timesToday = PrayerCalculationService.calculateTimesForCommune(
        commune: commune,
        date: now,
      );
      final timesTomorrow = PrayerCalculationService.calculateTimesForCommune(
        commune: commune,
        date: now.add(const Duration(days: 1)),
      );

      // إلغاء الجدولة القديمة لتفادي التكرار
      await _notificationsPlugin.cancelAll();

      final allPrayers = [
        {"id": 1, "name": "صلاة الفجر", "time": timesToday.fajr},
        {"id": 2, "name": "صلاة الظهر", "time": timesToday.dhuhr},
        {"id": 3, "name": "صلاة العصر", "time": timesToday.asr},
        {"id": 4, "name": "صلاة المغرب", "time": timesToday.maghrib},
        {"id": 5, "name": "صلاة العشاء", "time": timesToday.isha},
        {"id": 6, "name": "صلاة الفجر", "time": timesTomorrow.fajr},
        {"id": 7, "name": "صلاة الظهر", "time": timesTomorrow.dhuhr},
        {"id": 8, "name": "صلاة العصر", "time": timesTomorrow.asr},
        {"id": 9, "name": "صلاة المغرب", "time": timesTomorrow.maghrib},
        {"id": 10, "name": "صلاة العشاء", "time": timesTomorrow.isha},
      ];

      for (final p in allPrayers) {
        final DateTime pTime = p["time"] as DateTime;
        final tz.TZDateTime tzTime = tz.TZDateTime.from(pTime, tz.local);

        if (tzTime.isAfter(tz.TZDateTime.now(tz.local))) {
          await _notificationsPlugin.zonedSchedule(
            id: p["id"] as int,
            title: "الله أكبر - حان موعد ${p["name"]}",
            body: "حي على الصلاة.. حي على الفلاح (${commune.nameAr})",
            scheduledDate: tzTime,
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                channelId,
                channelName,
                channelDescription: channelDesc,
                importance: Importance.max,
                priority: Priority.max,
                sound: RawResourceAndroidNotificationSound('adhan'),
                playSound: true,
                fullScreenIntent: true,
                category: AndroidNotificationCategory.alarm,
                visibility: NotificationVisibility.public,
                ticker: "موعد الصلاة",
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }
      debugPrint("تمت جدولة أوقات الأذان بنجاح لبلدية: ${commune.nameAr}");
    } catch (e) {
      debugPrint("Schedule prayers error: $e");
    }
  }
}