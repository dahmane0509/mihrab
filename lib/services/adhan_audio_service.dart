import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdhanAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool isPlaying = false;
  static ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  static ValueNotifier<String> currentPlayingTitle = ValueNotifier<String>("");

  // Authentic human Muezzin recordings
  static const Map<String, String> adhanOnlineUrls = {
    "algeria_grand_mosque": "assets/audio/adhan.mp3", // جامع الجزائر
    "traditional_algerian": "assets/audio/adhan.mp3", // أذان مغاربي جزائري
    "makkah": "https://quran-fjamfcbbeybteyat.z01.azurefd.net/Audio3/Adan/4003.mp3", // المسجد الحرام - الشيخ علي ملا
    "madinah": "https://quran-fjamfcbbeybteyat.z01.azurefd.net/Audio3/Adan/4005.mp3", // المسجد النبوي - الشيخ عصام بخاري
    "al_aqsa": "https://quran-fjamfcbbeybteyat.z01.azurefd.net/Audio3/Adan/4007.mp3", // المسجد الأقصى - الشيخ ناجي قزاز
    "abdulbasit": "https://quran-fjamfcbbeybteyat.z01.azurefd.net/Audio3/Adan/1026.mp3", // الشيخ عبد الباسط عبد الصمد (أذان القاهرة الأصلي)
    "rifat": "https://quran-fjamfcbbeybteyat.z01.azurefd.net/Audio3/Adan/1027.mp3", // الشيخ محمد رفعت (قيثارة السماء)
    "husary": "https://quran-fjamfcbbeybteyat.z01.azurefd.net/Audio3/Adan/1030.mp3", // الشيخ محمود خليل الحصري
    "banna": "https://quran-fjamfcbbeybteyat.z01.azurefd.net/Audio3/Adan/1029.mp3", // الشيخ محمود علي البنا
    "shaisha": "https://quran-fjamfcbbeybteyat.z01.azurefd.net/Audio3/Adan/1024.mp3", // الشيخ أبو العينين شعيشع
    "takbeer_only": "https://quran-fjamfcbbeybteyat.z01.azurefd.net/Audio3/Adan/4025.mp3", // تكبيرات العيد والأذان
  };

  static const Map<String, String> adhanNames = {
    "algeria_grand_mosque": "أذان جامع الجزائر (الجامع الأعظم)",
    "traditional_algerian": "الأذان الجزائري الأصيل (المقام المغاربي)",
    "makkah": "أذان المسجد الحرام (مكة المكرمة - الشيخ علي ملا)",
    "madinah": "أذان المسجد النبوي (المدينة المنورة - الشيخ عصام بخاري)",
    "al_aqsa": "أذان المسجد الأقصى المبارك (القدس الشريف)",
    "abdulbasit": "أذان الشيخ عبد الباسط عبد الصمد (أذان مصر التاريخي)",
    "rifat": "أذان الشيخ محمد رفعت (قيثارة السماء)",
    "husary": "أذان الشيخ محمود خليل الحصري",
    "banna": "أذان الشيخ محمود علي البنا",
    "shaisha": "أذان الشيخ أبو العينين شعيشع",
    "takbeer_only": "تكبيرات الأذان والعيد (المسجد الحرام)",
  };

  static Future<void> init() async {
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
        debugPrint("setAudioContext note: $e");
      }
      _player.onPlayerStateChanged.listen((state) {
        isPlaying = (state == PlayerState.playing);
        isPlayingNotifier.value = isPlaying;
      });
      _player.onPlayerComplete.listen((_) {
        isPlaying = false;
        isPlayingNotifier.value = false;
        currentPlayingTitle.value = "";
      });
    } catch (e) {
      debugPrint("Audio init error: $e");
    }
  }

  /// Get specific adhan sound configured for a prayer ('fajr', 'dhuhr', 'asr', 'maghrib', 'isha')
  static Future<String> getSoundForPrayer(String prayerKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('adhan_sound_$prayerKey') ??
           prefs.getString('adhan_sound') ??
           'algeria_grand_mosque';
  }

  /// Set specific adhan sound for a prayer
  static Future<void> setSoundForPrayer(String prayerKey, String soundId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('adhan_sound_$prayerKey', soundId);
  }

  /// Plays authentic human Adhan recording immediately
  static Future<bool> playAdhan({String soundId = "algeria_grand_mosque"}) async {
    try {
      await stopAdhan();
      final title = adhanNames[soundId] ?? "الأذان المبارك";
      currentPlayingTitle.value = title;
      try {
        await _player.setVolume(1.0);
      } catch (_) {}

      // 1. If user selected takbeer only, play local authentic takbeer asset
      if (soundId == "takbeer_only") {
        try {
          await _player.play(AssetSource('audio/takbeer.wav'));
          isPlaying = true;
          isPlayingNotifier.value = true;
          return true;
        } catch (e) {
          debugPrint("Takbeer asset error: $e");
        }
      }

      // 2. If Algerian Grand Mosque or Traditional Algerian, play authentic Algerian local asset
      if (soundId == "algeria_grand_mosque" || soundId == "traditional_algerian") {
        try {
          await _player.play(AssetSource('audio/adhan.mp3'));
          isPlaying = true;
          isPlayingNotifier.value = true;
          return true;
        } catch (e) {
          debugPrint("Local adhan asset error: $e");
        }
      }

      // 3. For specific muezzins, stream their authentic recording online (with 3s timeout for fast response)
      final onlineUrl = adhanOnlineUrls[soundId];
      if (onlineUrl != null && !onlineUrl.startsWith('assets/')) {
        try {
          await _player.play(UrlSource(onlineUrl)).timeout(const Duration(seconds: 3));
          isPlaying = true;
          isPlayingNotifier.value = true;
          return true;
        } catch (streamErr) {
          debugPrint("Online adhan stream timed out or failed: $streamErr, playing local adhan asset immediately");
        }
      }

      // 4. Fallback to local adhan asset if offline, slow network, or error
      await _player.play(AssetSource('audio/adhan.mp3'));
      isPlaying = true;
      isPlayingNotifier.value = true;
      return true;
    } catch (e) {
      debugPrint("playAdhan error: $e");
      isPlaying = false;
      isPlayingNotifier.value = false;
      currentPlayingTitle.value = "";
      return false;
    }
  }

  /// Plays adhan assigned specifically for a prayer name
  static Future<bool> playAdhanForPrayer(String prayerKey) async {
    final soundId = await getSoundForPrayer(prayerKey);
    return playAdhan(soundId: soundId);
  }

  /// Short pleasant alert chime
  static Future<void> playNotificationChime() async {
    try {
      final quickPlayer = AudioPlayer();
      await quickPlayer.play(AssetSource('audio/notification.mp3'));
    } catch (e) {
      debugPrint("Chime mp3 error: $e");
      try {
        final quickPlayer2 = AudioPlayer();
        await quickPlayer2.play(AssetSource('audio/notification.wav'));
      } catch (_) {
        try {
          await SystemSound.play(SystemSoundType.alert);
        } catch (_) {}
      }
    }
  }

  /// Play Takbeer
  static Future<bool> playTakbeer() async {
    return playAdhan(soundId: "takbeer_only");
  }

  /// Stop any currently playing audio
  static Future<void> stopAdhan() async {
    try {
      await _player.stop();
      isPlaying = false;
      isPlayingNotifier.value = false;
      currentPlayingTitle.value = "";
    } catch (e) {
      debugPrint("Audio stop error: $e");
    }
  }
}
