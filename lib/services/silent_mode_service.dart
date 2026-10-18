import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for managing Android Phone Silent/Vibrate/Normal Ringer Mode
/// specifically during congregational prayer times in the mosque.
class SilentModeService {
  static const MethodChannel _channel =
      MethodChannel('com.mihrab.algeria.mihrab_app/settings');

  static Timer? _restoreTimer;
  static bool _isSilentActive = false;

  /// Whether phone is currently in auto-silent prayer state
  static bool get isSilentActive => _isSilentActive;

  /// Check if Android Do Not Disturb / Notification Policy access is granted
  static Future<bool> isDndAccessGranted() async {
    try {
      final res = await _channel.invokeMethod<bool>('isDndAccessGranted');
      return res ?? false;
    } catch (e) {
      debugPrint("isDndAccessGranted error: $e");
      return false;
    }
  }

  /// Open device Settings screen where user can grant DND access
  static Future<bool> openDndSettings() async {
    try {
      final res = await _channel.invokeMethod<bool>('openDndSettings');
      return res ?? false;
    } catch (e) {
      debugPrint("openDndSettings error: $e");
      return false;
    }
  }

  /// Sets device ringer mode: 'silent', 'vibrate', 'normal'
  static Future<bool> setRingerMode(String mode) async {
    try {
      final res = await _channel.invokeMethod<bool>('setRingerMode', {'mode': mode});
      return res ?? true;
    } catch (e) {
      debugPrint("setRingerMode error: $e");
      return false;
    }
  }

  /// Get current ringer mode: 'silent', 'vibrate', 'normal'
  static Future<String> getRingerMode() async {
    try {
      final res = await _channel.invokeMethod<String>('getRingerMode');
      return res ?? 'normal';
    } catch (e) {
      return 'normal';
    }
  }

  /// Automatically silence phone for [durationMinutes] (default from prefs or 25 min) during prayer
  static Future<bool> enableMosqueSilentMode({int? durationMinutes}) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('auto_silent_mode') ?? true;
    if (!isEnabled) return false;

    final targetMode = prefs.getString('mosque_silent_type') ?? 'silent';
    final targetDuration = durationMinutes ?? prefs.getInt('mosque_silent_duration') ?? 25;

    try {
      final success = await setRingerMode(targetMode);
      if (success) {
        _isSilentActive = true;
        _restoreTimer?.cancel();
        _restoreTimer = Timer(Duration(minutes: targetDuration), () async {
          await restoreNormalMode();
        });
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("enableMosqueSilentMode error: $e");
      return false;
    }
  }

  /// Restores normal ringtone mode
  static Future<bool> restoreNormalMode() async {
    try {
      _restoreTimer?.cancel();
      _restoreTimer = null;
      final success = await setRingerMode('normal');
      _isSilentActive = false;
      return success;
    } catch (e) {
      debugPrint("restoreNormalMode error: $e");
      _isSilentActive = false;
      return false;
    }
  }

  /// Test silent mode for [durationSeconds] then automatically restore normal mode
  static Future<bool> testSilentMode({int durationSeconds = 5}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final targetMode = prefs.getString('mosque_silent_type') ?? 'silent';
      final success = await setRingerMode(targetMode);
      if (success) {
        Timer(Duration(seconds: durationSeconds), () async {
          await setRingerMode('normal');
        });
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("testSilentMode error: $e");
      return false;
    }
  }
}
