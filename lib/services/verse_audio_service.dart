// Updated v1.0.4
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_coordinator.dart';
import 'adhan_audio_service.dart';
import 'prayer_notification_service.dart';

/// Dedicated service for playing the Mihrab Quran verse recitation
/// (Surah Ali 'Imran: 39) smoothly across Splash and Home Screen without cut-off or overlap.
///
/// Audio priority rules (enforced through [AudioCoordinator]):
///  * The Adhan ALWAYS has priority: when it starts, this recitation is stopped instantly.
///  * The automatic startup recitation never starts while the Adhan is playing, during the
///    Adhan window right after a prayer time, or when the app was opened from a prayer alert.
///  * Only the explicit "استماع للتلاوة" button may interrupt a playing Adhan (user intent).
class VerseAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isInitialized = false;
  static int _playOpId = 0;

  // مفتاح حفظ اختيار المستخدم للتلاوة الافتتاحية فقط (عند فتح التطبيق)
  static const String _keyRecitationEnabled = 'enable_startup_recitation';

  /// Reactive notifier for whether automatic startup recitation is enabled by the user
  static final ValueNotifier<bool> recitationEnabledNotifier =
      ValueNotifier<bool>(true);

  // حفظ حالة التلاوة التلقائية عند بدء التشغيل فقط
  // ملاحظة: تفعيل الإعداد لا يوقف الأذان أبداً (الأذان له الأولوية القصوى)
  static Future<void> setRecitationEnabled(bool isEnabled) async {
    recitationEnabledNotifier.value = isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRecitationEnabled, isEnabled);
    if (!isEnabled) {
      await stopVerse();
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
  static final ValueNotifier<bool> isPlayingNotifier =
      ValueNotifier<bool>(false);

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
    AudioCoordinator.registerChannelStopper(AudioChannel.verse, stopVerse);
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
        // Safety net: if the recitation somehow starts while the Adhan owns focus, stop it at once.
        if (isPlaying &&
            AudioCoordinator.isAdhanActive &&
            !AudioCoordinator.isActive(AudioChannel.verse)) {
          debugPrint(
              "VerseAudioService: recitation detected during Adhan -> stopping");
          stopVerse();
        }
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
        AudioCoordinator.abandonFocus(AudioChannel.verse);
      });
    } catch (e) {
      debugPrint("VerseAudioService init error: $e");
    }
  }

  /// Returns true when an automatic (non-user) recitation must NOT start because the Adhan
  /// is playing, is about to play, or was just delivered by a system notification.
  static Future<bool> _isAdhanBlockingAutoPlayback() async {
    if (AudioCoordinator.isAdhanActive ||
        AdhanAudioService.isPlayingNotifier.value) {
      debugPrint(
          "VerseAudioService: auto recitation blocked (Adhan is playing)");
      return true;
    }
    if (await PrayerNotificationService.wasLaunchedFromNotification()) {
      debugPrint(
          "VerseAudioService: auto recitation blocked (launched from prayer notification)");
      return true;
    }
    if (await PrayerNotificationService.isWithinAdhanWindow()) {
      debugPrint(
          "VerseAudioService: auto recitation blocked (inside Adhan time window)");
      return true;
    }
    return false;
  }

  /// Play verse audio directly from local assets.
  ///
  /// * [isStartup] – automatic SplashScreen recitation: respects the user setting and is
  ///   blocked by any Adhan activity.
  /// * [interruptAdhan] – ONLY for the explicit "استماع للتلاوة" button: the user's direct
  ///   action may stop a playing Adhan. Every other caller leaves the Adhan untouched.
  static Future<bool> playVerse({
    bool restartIfPlaying = true,
    bool isStartup = false,
    bool interruptAdhan = false,
  }) async {
    final int myOpId = ++_playOpId;
    await init();

    // Startup-only checks (ONLY applied during automatic SplashScreen startup)
    if (isStartup) {
      final isEnabled = await isRecitationEnabled();
      if (!isEnabled) {
        return false;
      }
    }

    // Automatic / non-explicit playback must never compete with the Adhan.
    if (!interruptAdhan && await _isAdhanBlockingAutoPlayback()) {
      return false;
    }

    if (myOpId != _playOpId) return false;

    if (isPlayingNotifier.value && !restartIfPlaying) {
      return true;
    }

    // Acquire exclusive audio focus (stops Surah player / live radio / chime, and the Adhan
    // only when [interruptAdhan] is true).
    final granted = await AudioCoordinator.requestFocus(
      AudioChannel.verse,
      interruptHigher: interruptAdhan,
    );
    if (!granted || myOpId != _playOpId) {
      if (!granted) AudioCoordinator.abandonFocus(AudioChannel.verse);
      return false;
    }

    try {
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

      // Final guard: if the Adhan claimed focus while we were loading, yield immediately.
      if (myOpId != _playOpId ||
          (AudioCoordinator.isAdhanActive && !interruptAdhan)) {
        await _player.stop();
        AudioCoordinator.abandonFocus(AudioChannel.verse);
        return false;
      }

      isPlayingNotifier.value = played;
      if (!played) AudioCoordinator.abandonFocus(AudioChannel.verse);
      return played;
    } catch (e) {
      debugPrint("VerseAudioService playVerse error: $e");
      if (myOpId == _playOpId) {
        isPlayingNotifier.value = false;
      }
      AudioCoordinator.abandonFocus(AudioChannel.verse);
      return false;
    }
  }

  /// Manual play/stop toggle when user presses the "استماع للتلاوة" button.
  /// Always active and completely independent of general settings (`ayahRecitationEnabled`).
  static Future<void> toggleVerse() async {
    if (isPlayingNotifier.value) {
      await stopVerse();
    } else {
      await playVerse(
          restartIfPlaying: true, isStartup: false, interruptAdhan: true);
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
    } finally {
      AudioCoordinator.abandonFocus(AudioChannel.verse);
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
    } finally {
      AudioCoordinator.abandonFocus(AudioChannel.verse);
    }
  }
}
