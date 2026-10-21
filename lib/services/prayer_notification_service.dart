import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';
import '../data/algeria_communes.dart';
import '../data/world_cities.dart';
import 'adhan_audio_service.dart';
import 'prayer_service.dart';
import 'silent_mode_service.dart';
import 'home_widget_service.dart';

/// Service responsible for notifying and playing Adhan audio when prayer times arrive.
class PrayerNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static Timer? _prayerMonitorTimer;
  static String? _lastTriggeredKey;
  static bool _isInitialized = false;

  /// Reactive notifier indicating whether system notifications are enabled
  static final ValueNotifier<bool> notificationsEnabledNotifier =
      ValueNotifier<bool>(true);

  static const AndroidNotificationChannel prayerChannel =
      AndroidNotificationChannel(
    'mihrab_adhan_channel_v9',
    'أذان ومواقيت الصلاة',
    description: 'تنبيهات وأذان الصلوات الخمس في موعدها الدقيق بصوت الأذان الكامل والتنبيه الصوتي',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('athan'),
    enableVibration: true,
    audioAttributesUsage: AudioAttributesUsage.alarm,
  );

  static void _ensureTimeZones() {
    try {
      tz.initializeTimeZones();
    } catch (_) {}
  }

  /// Resolves the timezone location matching the selected wilaya/city or device offset
  static tz.Location _resolveLocation(int wilayaCode) {
    _ensureTimeZones();
    if (wilayaCode < 1000) {
      try {
        return tz.getLocation('Africa/Algiers');
      } catch (_) {}
    } else {
      final city = WorldCitiesData.getCityByCode(wilayaCode);
      if (city != null) {
        try {
          for (final loc in tz.timeZoneDatabase.locations.values) {
            if (loc.currentTimeZone.offset.inHours == city.timeZone.toInt()) {
              return loc;
            }
          }
        } catch (_) {}
      }
    }
    try {
      final devOffset = DateTime.now().timeZoneOffset;
      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.currentTimeZone.offset == devOffset) {
          return loc;
        }
      }
    } catch (_) {}
    try {
      return tz.local;
    } catch (_) {
      return tz.UTC;
    }
  }

  /// Check whether a prayer has already triggered today
  static bool hasTriggeredToday(String prayerKey) {
    final now = DateTime.now();
    final triggerId = "${now.year}-${now.month}-${now.day}_$prayerKey";
    return _lastTriggeredKey == triggerId;
  }

  /// Mark that a prayer has triggered today to prevent double alerts
  static void markTriggeredToday(String prayerKey) {
    final now = DateTime.now();
    _lastTriggeredKey = "${now.year}-${now.month}-${now.day}_$prayerKey";
  }

  /// Helper to get the active commune or international city
  static Future<Commune> _getActiveCommune() async {
    final prefs = await SharedPreferences.getInstance();
    final wilayaCode = prefs.getInt('selected_wilaya') ?? 16;
    final communeId = prefs.getInt('selected_commune_id');

    if (wilayaCode >= 1000) {
      final city = WorldCitiesData.getCityByCode(wilayaCode);
      if (city != null) {
        return Commune(
          id: city.code,
          wilayaCode: city.code,
          nameAr: city.nameAr,
          nameFr: city.nameFr,
          latitude: city.latitude,
          longitude: city.longitude,
        );
      }
    }

    return (communeId != null
            ? AlgeriaCommunes.getCommuneById(communeId)
            : null) ??
        AlgeriaCommunes.getCommunesByWilaya(wilayaCode).firstOrNull ??
        AlgeriaCommunes.allCommunes[0];
  }

  /// Initialize notification channel and start monitoring & scheduling prayer times
  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      tz.initializeTimeZones();
      final prefs = await SharedPreferences.getInstance();
      final wilayaCode = prefs.getInt('selected_wilaya') ?? 16;
      final loc = _resolveLocation(wilayaCode);
      tz.setLocalLocation(loc);

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.actionId == 'stop_adhan') {
            AdhanAudioService.stopAdhan();
          }
        },
      );

      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        // Clean up older channels once
        final cleaned = prefs.getBool('legacy_channels_cleaned_v9') ?? false;
        if (!cleaned) {
          try {
            await Future.wait([
              androidPlugin.deleteNotificationChannel(channelId: 'mihrab_adhan_channel_v8'),
              androidPlugin.deleteNotificationChannel(channelId: 'mihrab_adhan_channel_v7'),
              androidPlugin.deleteNotificationChannel(channelId: 'mihrab_adhan_channel_v6'),
              androidPlugin.deleteNotificationChannel(channelId: 'mihrab_adhan_channel_v5'),
              androidPlugin.deleteNotificationChannel(channelId: 'mihrab_adhan_channel_v4'),
              androidPlugin.deleteNotificationChannel(channelId: 'mihrab_adhan_channel_v3'),
              androidPlugin.deleteNotificationChannel(channelId: 'prayer_adhan_channel_v2'),
              androidPlugin.deleteNotificationChannel(channelId: 'prayer_channel_high'),
            ]);
            await prefs.setBool('legacy_channels_cleaned_v9', true);
          } catch (_) {}
        }

        await androidPlugin.createNotificationChannel(prayerChannel);
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }

      await checkNotificationsEnabled();
      await scheduleAllPrayerNotifications();
      startMonitoring();
      _isInitialized = true;
    } catch (e) {
      debugPrint("PrayerNotificationService initialization note: $e");
    }
  }

  /// Check whether notifications are enabled in Android settings
  static Future<bool> checkNotificationsEnabled() async {
    bool enabled = true;
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final areEnabled = await androidPlugin.areNotificationsEnabled();
        if (areEnabled != null) enabled = areEnabled;
      }
    } catch (_) {}
    try {
      const channel = MethodChannel('com.mihrab.algeria.mihrab_app/settings');
      final nativeEnabled = await channel.invokeMethod<bool>('areNotificationsEnabled');
      if (nativeEnabled != null) enabled = nativeEnabled;
    } catch (_) {}
    notificationsEnabledNotifier.value = enabled;
    return enabled;
  }

  /// Open phone's App Notification Settings page directly
  static Future<void> openNotificationSettings() async {
    try {
      const channel = MethodChannel('com.mihrab.algeria.mihrab_app/settings');
      await channel.invokeMethod('openNotificationSettings');
    } catch (_) {
      try {
        final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestNotificationsPermission();
      } catch (_) {}
    }
  }

  /// Check whether app is whitelisted from battery optimization (Doze mode)
  static Future<bool> isBatteryOptimizationIgnored() async {
    try {
      const channel = MethodChannel('com.mihrab.algeria.mihrab_app/settings');
      return await channel.invokeMethod<bool>('isBatteryOptimizationIgnored') ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Request exemption from battery optimization
  static Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      const channel = MethodChannel('com.mihrab.algeria.mihrab_app/settings');
      await channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (_) {}
  }

  /// Check whether exact alarms are permitted
  static Future<bool> canScheduleExactAlarms() async {
    try {
      const channel = MethodChannel('com.mihrab.algeria.mihrab_app/settings');
      return await channel.invokeMethod<bool>('canScheduleExactAlarms') ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Open settings for exact alarms
  static Future<void> openExactAlarmSettings() async {
    try {
      const channel = MethodChannel('com.mihrab.algeria.mihrab_app/settings');
      await channel.invokeMethod('openExactAlarmSettings');
    } catch (_) {}
  }

  /// Request permissions directly (called on home screen startup)
  static Future<void> requestPermissions() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }
      await checkNotificationsEnabled();
    } catch (_) {}
  }

  /// Schedule all 5 daily prayers using exact alarm manager for today and the next 7 days
  static Future<void> scheduleAllPrayerNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commune = await _getActiveCommune();

      // Configure local timezone location
      final location = _resolveLocation(commune.wilayaCode);
      tz.setLocalLocation(location);

      // Cancel previous scheduled prayer IDs (5001..5030)
      for (int id = 5001; id <= 5030; id++) {
        try {
          await _notifications.cancel(id: id);
        } catch (_) {}
      }

      final now = DateTime.now();
      // Schedule ahead for today and tomorrow (up to 10 alarms) to stay well within Android limits
      final days = List.generate(2, (i) => now.add(Duration(days: i)));

      int notifIdCounter = 5001;
      for (final date in days) {
        final times = PrayerService.calculateTimesForCommuneResult(
          commune: commune,
          date: date,
        );

        final prayers = <String, Map<String, dynamic>>{
          'fajr': {'name': 'الفجر', 'time': times.fajr},
          'dhuhr': {'name': 'الظهر', 'time': times.dhuhr},
          'asr': {'name': 'العصر', 'time': times.asr},
          'maghrib': {'name': 'المغرب', 'time': times.maghrib},
          'isha': {'name': 'العشاء', 'time': times.isha},
        };

        for (final entry in prayers.entries) {
          final key = entry.key;
          final prayerName = entry.value['name'] as String;
          final pTime = entry.value['time'] as DateTime;

          final isMuted = prefs.getBool('mute_$key') ?? false;
          final isNotifEnabled = prefs.getBool('notif_$prayerName') ?? true;
          if (isMuted || !isNotifEnabled) continue;

          tz.TZDateTime scheduledDate;
          try {
            scheduledDate = tz.TZDateTime(
              location,
              pTime.year,
              pTime.month,
              pTime.day,
              pTime.hour,
              pTime.minute,
              0,
            );
          } catch (_) {
            scheduledDate = tz.TZDateTime.from(pTime, location);
          }

          final currentTz = tz.TZDateTime.now(location);

          if (scheduledDate.isAfter(currentTz)) {
            final androidDetails = AndroidNotificationDetails(
              prayerChannel.id,
              prayerChannel.name,
              channelDescription: prayerChannel.description,
              importance: Importance.max,
              priority: Priority.high,
              ticker: "حان موعد صلاة $prayerName",
              icon: '@mipmap/ic_launcher',
              category: AndroidNotificationCategory.alarm,
              sound: const RawResourceAndroidNotificationSound('athan'),
              playSound: true,
              enableVibration: true,
              audioAttributesUsage: AudioAttributesUsage.alarm,
              visibility: NotificationVisibility.public,
              actions: const [
                AndroidNotificationAction(
                  'stop_adhan',
                  'إيقاف الأذان',
                  showsUserInterface: true,
                  cancelNotification: true,
                ),
              ],
            );

            try {
              await _notifications.zonedSchedule(
                id: notifIdCounter++,
                title: "الله أكبر، الله أكبر 🕌 - حان الآن موعد صلاة $prayerName",
                body: "حان موعد أذان صلاة $prayerName في ${commune.nameAr} وما جاورها. حيّ على الصلاة، حيّ على الفلاح.",
                scheduledDate: scheduledDate,
                notificationDetails: NotificationDetails(android: androidDetails),
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              );
            } catch (e) {
              debugPrint("zonedSchedule error: $e");
            }
          }
        }
      }
      // Update native home screen widget with current prayer times
      await HomeWidgetService.updateFromCurrentPrayerTimes();
    } catch (e) {
      debugPrint("scheduleAllPrayerNotifications error: $e");
    }
  }

  /// Start periodic monitoring of prayer times for active foreground responsiveness
  static void startMonitoring() {
    _prayerMonitorTimer?.cancel();
    _prayerMonitorTimer =
        Timer.periodic(const Duration(seconds: 2), (_) => checkCurrentPrayerTime());
  }

  /// Checks if the current time matches any of today's prayer times
  static Future<void> checkCurrentPrayerTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commune = await _getActiveCommune();

      final now = DateTime.now();
      final times = PrayerService.calculateTimesForCommuneResult(
        commune: commune,
        date: now,
      );

      final prayers = <String, Map<String, dynamic>>{
        'fajr': {'name': 'الفجر', 'time': times.fajr},
        'dhuhr': {'name': 'الظهر', 'time': times.dhuhr},
        'asr': {'name': 'العصر', 'time': times.asr},
        'maghrib': {'name': 'المغرب', 'time': times.maghrib},
        'isha': {'name': 'العشاء', 'time': times.isha},
      };

      for (final entry in prayers.entries) {
        final key = entry.key;
        final prayerName = entry.value['name'] as String;
        final pTime = entry.value['time'] as DateTime;

        // Check if user muted this prayer
        final isMuted = prefs.getBool('mute_$key') ?? false;
        final isNotifEnabled = prefs.getBool('notif_$prayerName') ?? true;
        if (isMuted || !isNotifEnabled) continue;

        // Trigger if within 0 to 180 seconds of prayer entry
        final diffSeconds = now.difference(pTime).inSeconds;

        if (diffSeconds >= 0 && diffSeconds < 180 && !hasTriggeredToday(key)) {
          markTriggeredToday(key);
          await triggerAdhanNotification(
            prayerName: prayerName,
            prayerKey: key,
            communeName: commune.nameAr,
          );
          break;
        }
      }
    } catch (e) {
      debugPrint("PrayerNotificationService check error: $e");
    }
  }

  /// Triggers the Heads-up system notification and starts the Adhan audio immediately
  static Future<void> triggerAdhanNotification({
    required String prayerName,
    required String prayerKey,
    required String communeName,
    bool playVoice = true,
  }) async {
    markTriggeredToday(prayerKey);

    // 1. Play Adhan Voice through loudspeaker and full volume when app is open
    if (playVoice) {
      try {
        await AdhanAudioService.playAdhanForPrayer(prayerKey);
      } catch (e) {
        debugPrint("Failed to play adhan audio: $e");
      }
    }

    // 2. Heads-up System Notification
    try {
      final androidDetails = AndroidNotificationDetails(
        prayerChannel.id,
        prayerChannel.name,
        channelDescription: prayerChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        ticker: "حان موعد صلاة $prayerName",
        icon: '@mipmap/ic_launcher',
        category: AndroidNotificationCategory.alarm,
        sound: const RawResourceAndroidNotificationSound('athan'),
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        visibility: NotificationVisibility.public,
        actions: const [
          AndroidNotificationAction(
            'stop_adhan',
            'إيقاف الأذان',
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
      );

      final notifDetails = NotificationDetails(android: androidDetails);
      await _notifications.show(
        id: 5000 + prayerKey.hashCode % 500,
        title: "الله أكبر، الله أكبر 🕌 - حان الآن موعد صلاة $prayerName",
        body: "حان الآن موعد أذان صلاة $prayerName في $communeName وما جاورها. حيّ على الصلاة، حيّ على الفلاح.",
        notificationDetails: notifDetails,
      );
      await HomeWidgetService.updateFromCurrentPrayerTimes();
    } catch (e) {
      debugPrint("Failed to display adhan notification: $e");
    }

    // 3. Auto Silent Mode (Mosque reverence mode)
    try {
      await SilentModeService.enableMosqueSilentMode(durationMinutes: 25);
    } catch (e) {
      debugPrint("Failed to enable auto silent mode: $e");
    }
  }

  /// Test Adhan Notification and audio immediately on demand
  static Future<bool> testAdhanNotification({
    String prayerName = "الظهر",
    String prayerKey = "dhuhr",
    String communeName = "الجزائر العاصمة",
  }) async {
    final areEnabled = await checkNotificationsEnabled();
    await triggerAdhanNotification(
      prayerName: prayerName,
      prayerKey: prayerKey,
      communeName: communeName,
    );
    return areEnabled;
  }

  /// Schedule a test notification and alarm after [delaySeconds] (for testing Doze/sleep mode)
  static Future<void> scheduleTestSleepAdhan({
    int delaySeconds = 10,
    String prayerName = "الظهر",
  }) async {
    final commune = await _getActiveCommune();
    final location = _resolveLocation(commune.wilayaCode);
    final scheduledDate = tz.TZDateTime.now(location).add(Duration(seconds: delaySeconds));

    final androidDetails = AndroidNotificationDetails(
      prayerChannel.id,
      prayerChannel.name,
      channelDescription: prayerChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      ticker: "تجربة أذان صلاة $prayerName في وضع السبات",
      icon: '@mipmap/ic_launcher',
      category: AndroidNotificationCategory.alarm,
      sound: const RawResourceAndroidNotificationSound('athan'),
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      visibility: NotificationVisibility.public,
      actions: const [
        AndroidNotificationAction(
          'stop_adhan',
          'إيقاف الأذان',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    try {
      await _notifications.zonedSchedule(
        id: 9999,
        title: "الله أكبر، الله أكبر 🕌 - حان موعد صلاة $prayerName",
        body: "تجربة تنبيه الأذان في وضع السبات وقفل الشاشة تعمل بنجاح 🌟",
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {}
  }
}
