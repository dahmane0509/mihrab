// Updated v1.0.4
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'adhan_audio_service.dart';
import 'prayer_notification_service.dart';

/// Dedicated service for playing the Mihrab Quran verse recitation
/// (Surah Ali 'Imran: 39) smoothly across Splash and Home Screen without cut-off or overlap.
class VerseAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isInitialized = false;
  static int _playOpId = 0;

  // مفتاح حفظ اختيار المستخدم للتلاوة الافتتاحية فقط (عند فتح التطبيق)
  static const String _keyRecitationEnabled = 'enable_startup_recitation';

  /// Reactive notifier for whether automatic startup recitation is enabled by the user
  static final ValueNotifier<bool> recitationEnabledNotifier = ValueNotifier<bool>(true);

  // حفظ حالة التلاوة التلقائية عند بدء التشغيل فقط
  static Future<void> setRecitationEnabled(bool isEnabled) async {
    recitationEnabledNotifier.value = isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRecitationEnabled, isEnabled);
    if (!isEnabled) {
      await stopVerse();
    } else {
      await AdhanAudioService.stopAdhan();
    }
  }

  // قراءة حالة التلاوة التلقائية عند بدء التشغيل (القيمة الافتراضية true)
  static Future<bool> isRecitationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_keyRecitationEnabled) ?? true;
    recitationEnabledNotifier.value = enabled;
    return enabled;
  }

  /// Stop current recitation (alias for stopVerse)
  static Future<void> stop() => stopVerse();

  /// Reactive notifier for UI components (play/pause state)
  static final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);

  /// Reactive notifier for audio position/progress
  static final ValueNotifier<Duration> positionNotifier =
      ValueNotifier<Duration>(Duration.zero);
  static final ValueNotifier<Duration> durationNotifier =
      ValueNotifier<Duration>(Duration.zero);

  static AudioPlayer get player => _player;

  /// Initialize listeners and audio context
  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    recitationEnabledNotifier.value = await isRecitationEnabled();

    try {
      await _player.setReleaseMode(ReleaseMode.stop);

      try {
        await _player.setAudioContext(AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {
              AVAudioSessionOptions.duckOthers,
            },
          ),
        ));
      } catch (e) {
        debugPrint("VerseAudioService setAudioContext note: $e");
      }

      _player.onPlayerStateChanged.listen((state) {
        final isPlaying = (state == PlayerState.playing);
        isPlayingNotifier.value = isPlaying;
      });

      _player.onPositionChanged.listen((pos) {
        positionNotifier.value = pos;
      });

      _player.onDurationChanged.listen((dur) {
        durationNotifier.value = dur;
      });

      _player.onPlayerComplete.listen((_) {
        isPlayingNotifier.value = false;
        positionNotifier.value = Duration.zero;
      });
    } catch (e) {
      debugPrint("VerseAudioService init error: $e");
    }
  }

  /// Play verse audio directly from local assets.
  /// Manual playback (isStartup == false) is 100% independent of general/startup settings
  /// (`enable_startup_recitation` / `ayahRecitationEnabled`) and always plays immediately.
  static Future<bool> playVerse({
    bool restartIfPlaying = true,
    bool isStartup = false,
  }) async {
    final int myOpId = ++_playOpId;
    await init();

    // Startup-only checks (ONLY applied during automatic SplashScreen startup)
    if (isStartup) {
      final isEnabled = await isRecitationEnabled();
      if (!isEnabled) {
        return false;
      }

      if (AdhanAudioService.isPlayingNotifier.value) {
        debugPrint("VerseAudioService: Startup recitation skipped because Adhan is actively playing");
        return false;
      }

      final fromNotif = await PrayerNotificationService.wasLaunchedFromNotification();
      if (fromNotif) {
        debugPrint("VerseAudioService: Startup recitation skipped because app launched via prayer notification");
        return false;
      }
    }

    if (myOpId != _playOpId) return false;

    if (isPlayingNotifier.value && !restartIfPlaying) {
      return true;
    }

    try {
      // إيقاف أي أذان أو تلاوة سابقة قيد التشغيل تماماً قبل بدء التلاوة الجديدة
      await AdhanAudioService.stopAdhan();
      await _player.stop();

      if (myOpId != _playOpId) return false;

      await _player.setVolume(1.0);

      // Try mihrab_verse.mp3 first, then fallback to abdulbasit_3_39.mp3
      bool played = false;

      try {
        await rootBundle.load('assets/audio/mihrab_verse.mp3');
        if (myOpId != _playOpId) return false;
        await _player.play(AssetSource('audio/mihrab_verse.mp3'));
        played = true;
      } catch (_) {
        played = false;
      }

      if (!played) {
        if (myOpId != _playOpId) return false;
        try {
          await _player.play(AssetSource('audio/abdulbasit_3_39.mp3'));
          played = true;
        } catch (e) {
          debugPrint("Failed to play abdulbasit_3_39.mp3: $e");
        }
      }

      if (myOpId != _playOpId) {
        await _player.stop();
        return false;
      }

      isPlayingNotifier.value = played;
      return played;
    } catch (e) {
      debugPrint("VerseAudioService playVerse error: $e");
      if (myOpId == _playOpId) {
        isPlayingNotifier.value = false;
      }
      return false;
    }
  }

  /// Manual play/stop toggle when user presses the "استماع للتلاوة" button.
  /// Always active and completely independent of general settings (`ayahRecitationEnabled`).
  static Future<void> toggleVerse() async {
    if (isPlayingNotifier.value) {
      await stopVerse();
    } else {
      await playVerse(restartIfPlaying: true, isStartup: false);
    }
  }

  /// Pause current recitation
  static Future<void> pauseVerse() async {
    ++_playOpId;
    try {
      await _player.pause();
      isPlayingNotifier.value = false;
    } catch (e) {
      debugPrint("VerseAudioService pauseVerse error: $e");
    }
  }

  /// Stop current recitation
  static Future<void> stopVerse() async {
    ++_playOpId;
    try {
      await _player.stop();
      isPlayingNotifier.value = false;
      positionNotifier.value = Duration.zero;
    } catch (e) {
      debugPrint("VerseAudioService stopVerse error: $e");
    }
  }
}
