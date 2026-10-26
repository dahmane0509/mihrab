// Updated v1.0.1
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'adhan_audio_service.dart';


/// Dedicated service for playing the Mihrab Quran verse recitation
/// (Surah Ali 'Imran: 39) smoothly across Splash and Home Screen without cut-off.
class VerseAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isInitialized = false;
  // مفتاح حفظ اختيار المستخدم للتلاوة الافتتاحية
  static const String _keyRecitationEnabled = 'enable_startup_recitation';

  // حفظ حالة القفل (تفعيل / إيقاف)
  static Future<void> setRecitationEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRecitationEnabled, isEnabled);
  }

  // قراءة حالة القفل (القيمة الافتراضية true)
  static Future<bool> isRecitationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRecitationEnabled) ?? true;
  }

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

    try {
      await _player.setReleaseMode(ReleaseMode.stop);

      try {
        await _player.setAudioContext(AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gainTransient,
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

  /// Play verse audio from local assets (supporting both user-placed file and standard asset)
  static Future<bool> playVerse({bool restartIfPlaying = false}) async {
    await init();
    // 1. فحص هل أوقف المستخدم التلاوة من زر القفل في الإعدادات
    final isEnabled = await isRecitationEnabled();
    if (!isEnabled) {
      return false;
    }

    // 2. فحص هل الأذان يعمل حالياً لمنع تداخل الصوتين معاً
    if (AdhanAudioService.isPlayingNotifier.value) {
      return false;
    }

    if (isPlayingNotifier.value && !restartIfPlaying) {
      return true;
    }

    try {
      await _player.stop();
      await _player.setVolume(1.0);

      // Try user-provided mihrab_verse.mp3 first, then fallback to abdulbasit_3_39.mp3
      bool played = false;

      // Check if mihrab_verse.mp3 asset is loadable
      try {
        await rootBundle.load('assets/audio/mihrab_verse.mp3');
        await _player.play(AssetSource('audio/mihrab_verse.mp3'));
        played = true;
      } catch (_) {
        played = false;
      }

      if (!played) {
        try {
          await _player.play(AssetSource('audio/abdulbasit_3_39.mp3'));
          played = true;
        } catch (e) {
          debugPrint("Failed to play abdulbasit_3_39.mp3: $e");
        }
      }

      isPlayingNotifier.value = played;
      return played;
    } catch (e) {
      debugPrint("VerseAudioService playVerse error: $e");
      isPlayingNotifier.value = false;
      return false;
    }
  }

  /// Toggle play / pause
  static Future<void> toggleVerse() async {
    if (isPlayingNotifier.value) {
      await pauseVerse();
    } else {
      await playVerse(restartIfPlaying: false);
    }
  }

  /// Pause current recitation
  static Future<void> pauseVerse() async {
    try {
      await _player.pause();
      isPlayingNotifier.value = false;
    } catch (e) {
      debugPrint("VerseAudioService pauseVerse error: $e");
    }
  }

  /// Stop current recitation
  static Future<void> stopVerse() async {
    try {
      await _player.stop();
      isPlayingNotifier.value = false;
      positionNotifier.value = Duration.zero;
    } catch (e) {
      debugPrint("VerseAudioService stopVerse error: $e");
    }
  }
}
