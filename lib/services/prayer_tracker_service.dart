import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing daily prayer performance tracking and consecutive days streak
class PrayerTrackerService {
  static const List<String> prayerKeys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

  static final Map<String, String> prayerNamesAr = {
    'fajr': 'الفجر',
    'dhuhr': 'الظهر',
    'asr': 'العصر',
    'maghrib': 'المغرب',
    'isha': 'العشاء',
  };

  static final Map<String, String> prayerNamesEn = {
    'fajr': 'Fajr',
    'dhuhr': 'Dhuhr',
    'asr': 'Asr',
    'maghrib': 'Maghrib',
    'isha': 'Isha',
  };

  /// Notifier for today's completed prayers map: {'fajr': true, 'dhuhr': false, ...}
  static final ValueNotifier<Map<String, bool>> todayPrayersNotifier =
      ValueNotifier<Map<String, bool>>({
    'fajr': false,
    'dhuhr': false,
    'asr': false,
    'maghrib': false,
    'isha': false,
  });

  /// Consecutive days streak count notifier
  static final ValueNotifier<int> streakNotifier = ValueNotifier<int>(0);

  static String _getDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Initialize and load today's prayer tracker & current streak
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = _getDateKey(DateTime.now());
      final rawToday = prefs.getString('tracker_day_$todayKey');

      final Map<String, bool> todayMap = {
        'fajr': false,
        'dhuhr': false,
        'asr': false,
        'maghrib': false,
        'isha': false,
      };

      if (rawToday != null) {
        try {
          final decoded = jsonDecode(rawToday) as Map<String, dynamic>;
          for (final k in prayerKeys) {
            todayMap[k] = decoded[k] == true;
          }
        } catch (_) {}
      }

      todayPrayersNotifier.value = todayMap;

      // Calculate streak
      final streak = await _computeCurrentStreak(prefs);
      streakNotifier.value = streak;
    } catch (e) {
      debugPrint("PrayerTrackerService init error: $e");
    }
  }

  /// Toggle completion state for a given prayer
  static Future<bool> togglePrayer(String prayerKey) async {
    if (!prayerKeys.contains(prayerKey)) return false;

    final currentMap = Map<String, bool>.from(todayPrayersNotifier.value);
    final newState = !(currentMap[prayerKey] ?? false);
    currentMap[prayerKey] = newState;
    todayPrayersNotifier.value = currentMap;

    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = _getDateKey(DateTime.now());
      await prefs.setString('tracker_day_$todayKey', jsonEncode(currentMap));

      // Re-evaluate streak
      final streak = await _computeCurrentStreak(prefs);
      streakNotifier.value = streak;
      await prefs.setInt('prayer_streak_count', streak);
    } catch (_) {}

    return newState;
  }

  /// Whether a specific prayer is completed today
  static bool isPrayerCompleted(String prayerKey) {
    return todayPrayersNotifier.value[prayerKey] == true;
  }

  /// Completed count today (0 to 5)
  static int getCompletedCountToday() {
    return todayPrayersNotifier.value.values.where((v) => v == true).length;
  }

  /// Whether all 5 prayers have been completed today
  static bool isAllCompletedToday() {
    return getCompletedCountToday() == 5;
  }

  /// Compute consecutive days where all 5 prayers were completed
  static Future<int> _computeCurrentStreak(SharedPreferences prefs) async {
    try {
      final now = DateTime.now();
      int streak = 0;

      // Check today first
      final todayKey = _getDateKey(now);
      final rawToday = prefs.getString('tracker_day_$todayKey');
      bool todayAll = false;
      if (rawToday != null) {
        final decoded = jsonDecode(rawToday) as Map<String, dynamic>;
        todayAll = prayerKeys.every((k) => decoded[k] == true);
      }

      if (todayAll) {
        streak++;
      }

      // Check consecutive preceding days (up to 365 days back)
      for (int i = 1; i <= 365; i++) {
        final pastDate = now.subtract(Duration(days: i));
        final pastKey = _getDateKey(pastDate);
        final rawPast = prefs.getString('tracker_day_$pastKey');
        if (rawPast == null) {
          break;
        }

        final decoded = jsonDecode(rawPast) as Map<String, dynamic>;
        final allDone = prayerKeys.every((k) => decoded[k] == true);
        if (allDone) {
          streak++;
        } else {
          break;
        }
      }

      // Fallback: If streak is 0 and user had a saved streak, but hasn't completed all 5 yet today,
      // preserve yesterday's streak so they don't lose it midday!
      if (!todayAll) {
        int yesterdayStreak = 0;
        for (int i = 1; i <= 365; i++) {
          final pastDate = now.subtract(Duration(days: i));
          final pastKey = _getDateKey(pastDate);
          final rawPast = prefs.getString('tracker_day_$pastKey');
          if (rawPast == null) break;
          final decoded = jsonDecode(rawPast) as Map<String, dynamic>;
          if (prayerKeys.every((k) => decoded[k] == true)) {
            yesterdayStreak++;
          } else {
            break;
          }
        }
        return yesterdayStreak;
      }

      return streak;
    } catch (_) {
      return 0;
    }
  }
}
