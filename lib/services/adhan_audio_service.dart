import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdhanAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static bool isPlaying = false;
  static ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  static ValueNotifier<String> currentPlayingTitle = ValueNotifier<String>("");

  // Authentic human Muezzin recordings hosted directly on GitHub Raw
  static const Map<String, String> adhanOnlineUrls = {
    "algeria_grand_mosque": "assets/audio/adhan.mp3", // جامع الجزائر
    "traditional_algerian": "assets/audio/adhan.mp3", // أذان مغاربي جزائري
    "waled_mahzas": "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Waled_Mahsas_2_-_Algeria_(%D9%88%D9%84%D9%8A%D8%AF_%D9%85%D8%AD%D8%B3%D8%A7%D8%B3_-_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1).mp3", // الشيخ وليد مهساس - الجزائر
    "makkah": "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Ali_Ibn_Ahmad_Mala_HQ.mp3", // المسجد الحرام - الشيخ علي ملا
    "madinah": "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Al_Haram_Al_Madani_-_Al_Madinah_1_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%A7%D9%84%D8%AD%D8%B1%D9%85_%D8%A7%D9%84%D9%85%D8%AF%D9%86%D9%8A_-_%D8%A7%D9%84%D9%85%D8%AF%D9%8A%D9%86%D8%A9_%D8%A7%D9%84%D9%85%D9%86%D9%88%D8%B1%D8%A9).mp3", // المسجد النبوي - المدينة المنورة
    "al_aqsa": "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Najee_Qazaz_-_Al_Aqsa_Jerusalem_(%D9%86%D8%A7%D8%AC%D9%8A_%D9%82%D8%B2%D8%A7%D8%B2_-_%D8%A7%D9%84%D9%85%D8%B3%D8%AC%D8%AF_%D8%A7%D9%84%D8%A3%D9%82%D8%B5%D9%89_%D8%A7%D9%84%D9%82%D8%AF%D8%B3).mp3", // المسجد الأقصى - الشيخ ناجي قزاز
    "abdulbasit": "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Abdulbasit_Abdusamad_1_-_Egypt_(%D8%B9%D8%A8%D8%AF_%D8%A7%D9%84%D8%A8%D8%A7%D8%B3%D8%B7_%D8%B9%D8%A8%D8%AF_%D8%A7%D9%84%D8%B5%D9%85%D8%AF_-_%D9%85%D8%B5%D8%B1).mp3", // الشيخ عبد الباسط عبد الصمد
    "rifat": "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Muhammad_Refaat_-_Cairo_(%D9%85%D8%AD%D9%85%D8%AF_%D8%B1%D9%81%D8%B9%D8%AA_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3", // الشيخ محمد رفعت
    "husary": "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Mahmoud_Khalil_Al_Hussary_-_Cairo_(%D9%85%D8%AD%D9%85%D9%88%D8%AF_%D8%AE%D9%84%D9%8A%D9%84_%D8%A7%D9%84%D8%AD%D8%B5%D8%B1%D9%8A_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3", // الشيخ محمود خليل الحصري
    "banna": "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Mahmoud_Ali_Al_Banna_-_Cairo_(%D9%85%D8%AD%D9%85%D9%88%D8%AF_%D8%B9%D9%84%D9%8A_%D8%A7%D9%84%D8%A8%D9%86%D8%A7_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3", // الشيخ محمود علي البنا
    "shaisha": "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Abul_Ainain_Shuaisha_-_Cairo_(%D8%A3%D8%A8%D9%88_%D8%A7%D9%84%D8%B9%D9%8A%D9%86%D9%8A%D9%86_%D8%B4%D8%B9%D9%8A%D8%B4%D8%B9_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3", // الشيخ أبو العينين شعيشع
    "afasy": "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Mishary_Al_Afasy_-_HQ_(%D9%85%D8%B4%D8%A7%D8%B1%D9%8A_%D8%A7%D9%84%D8%B9%D9%81%D8%A7%D8%B3%D9%8A).mp3", // الشيخ مشاري العفاسي
    "qatami": "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Nasser_Al_Qatami_-_HQ_(%D9%86%D8%A7%D8%B5%D8%B1_%D8%A7%D9%84%D9%82%D8%B7%D8%A7%D9%85%D9%8A).mp3", // الشيخ ناصر القطامي
    "takbeer_only": "assets/audio/takbeer.wav", // تكبيرات العيد والأذان
  };

  static const Map<String, String> adhanNames = {
    "algeria_grand_mosque": "أذان جامع الجزائر (الجامع الأعظم)",
    "traditional_algerian": "الأذان الجزائري الأصيل (المقام المغاربي)",
    "waled_mahzas": "أذان الشيخ وليد مهساس (الجزائر)",
    "makkah": "أذان المسجد الحرام (مكة المكرمة - الشيخ علي ملا)",
    "madinah": "أذان المسجد النبوي (المدينة المنورة)",
    "al_aqsa": "أذان المسجد الأقصى المبارك (القدس الشريف)",
    "abdulbasit": "أذان الشيخ عبد الباسط عبد الصمد (مصر)",
    "rifat": "أذان الشيخ محمد رفعت (قيثارة السماء)",
    "husary": "أذان الشيخ محمود خليل الحصري",
    "banna": "أذان الشيخ محمود علي البنا",
    "shaisha": "أذان الشيخ أبو العينين شعيشع",
    "afasy": "أذان الشيخ مشاري راشد العفاسي",
    "qatami": "أذان الشيخ ناصر القطامي",
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

  /// Checks local temp cache for adhan audio or schedules background download
  static Future<File?> _getCachedAudioFile(String soundId, String url) async {
    try {
      final tempDir = Directory.systemTemp;
      final cacheFile = File("${tempDir.path}/adhan_$soundId.mp3");
      if (await cacheFile.exists() && await cacheFile.length() > 50000) {
        return cacheFile;
      }
      // If not fully cached, download asynchronously for subsequent offline usage
      _downloadAudioAsync(url, cacheFile);
      return null;
    } catch (_) {
      return null;
    }
  }

  static void _downloadAudioAsync(String url, File targetFile) {
    Future.microtask(() async {
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 10);
        final request = await client.getUrl(Uri.parse(url));
        final response = await request.close();
        if (response.statusCode == 200) {
          final bytes = await consolidateHttpClientResponseBytes(response);
          if (bytes.length > 50000) {
            await targetFile.writeAsBytes(bytes, flush: true);
            debugPrint("Successfully cached Adhan file ${targetFile.path} (${bytes.length} bytes)");
          }
        }
      } catch (e) {
        debugPrint("Download adhan cache notice: $e");
      }
    });
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

      // 3. For online muezzins: check cached file first for 0ms delay
      final onlineUrl = adhanOnlineUrls[soundId];
      if (onlineUrl != null && !onlineUrl.startsWith('assets/')) {
        final cachedFile = await _getCachedAudioFile(soundId, onlineUrl);
        if (cachedFile != null) {
          try {
            await _player.play(DeviceFileSource(cachedFile.path));
            isPlaying = true;
            isPlayingNotifier.value = true;
            return true;
          } catch (cachedErr) {
            debugPrint("Cached adhan play failed: $cachedErr, trying stream");
          }
        }

        // Stream directly from high-speed GitHub raw URL
        try {
          await _player.play(UrlSource(onlineUrl));
          isPlaying = true;
          isPlayingNotifier.value = true;
          return true;
        } catch (streamErr) {
          debugPrint("Online adhan stream failed: $streamErr, playing local adhan asset");
        }
      }

      // 4. Fallback to local adhan asset if network fails or offline
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
