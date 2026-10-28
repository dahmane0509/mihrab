import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'verse_audio_service.dart';

class AdhanSoundItem {
  final String id;
  final String name;
  final String url;
  final String desc;
  final bool isDefault;
  final bool isCustom;

  const AdhanSoundItem({
    required this.id,
    required this.name,
    required this.url,
    this.desc = '',
    this.isDefault = false,
    this.isCustom = false,
  });

  String get description => desc;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'desc': desc,
    'description': desc,
    'isDefault': isDefault,
    'isCustom': isCustom,
  };

  factory AdhanSoundItem.fromJson(Map<String, dynamic> json) => AdhanSoundItem(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    url: json['url'] as String? ?? '',
    desc: json['desc'] as String? ?? json['description'] as String? ?? '',
    isDefault: json['isDefault'] as bool? ?? false,
    isCustom: json['isCustom'] as bool? ?? false,
  );
}

class AdhanAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _chimePlayer = AudioPlayer();
  static final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<String> currentPlayingTitle = ValueNotifier<String>("");
  static bool _isInitialized = false;
  static int _playOpId = 0;

  /// Default Built-in and Online Algerian & Islamic Adhan Sounds
  static const List<AdhanSoundItem> defaultAdhans = [
    AdhanSoundItem(
      id: "algeria_grand_mosque",
      name: "أذان جامع الجزائر (الجامع الأعظم)",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Waled_Mahsas_2_-_Algeria_(%D9%88%D9%84%D9%8A%D8%AF_%D9%85%D8%AD%D8%B3%D8%A7%D8%B3_-_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1).mp3",
      desc: "الأذان الجزائري الرسمي المعتمد بصوت الشيخ وليد مهساس",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "waled_mahzas",
      name: "أذان الشيخ وليد مهساس (الجزائر)",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Waled_Mahsas_2_-_Algeria_(%D9%88%D9%84%D9%8A%D8%AF_%D9%85%D8%AD%D8%B3%D8%A7%D8%B3_-_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1).mp3",
      desc: "صوت خاشع ومؤثر من الجزائر",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "traditional_algerian",
      name: "الأذان الجزائري الأصيل (المقام المغاربي)",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Riad_Al_Djazairi_-_Algeria_(%D8%B1%D9%8A%D8%A7%D8%B6_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1%D9%8A_-_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1).mp3",
      desc: "المقام الجزائري التاريخي - الشيخ رياض الجزائري",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "constantine_algeria",
      name: "أذان قسنطينة (عاصمة الشرق الجزائري)",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Haj_Sulaiman_Mukhtar_-_Algeria_(%D8%AD%D8%A7%D8%AC_%D8%B3%D9%84%D9%8A%D9%85%D8%A7%D9%86_%D9%85%D8%AE%D8%AA%D8%A7%D8%B1_-_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1).mp3",
      desc: "أذان قسنطيني أصيل - الحاج سليمان مختار",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "tlemcen_algeria",
      name: "أذان فجر تلمسان (المدينة العتيقة)",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Fajr_Algeria_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%A7%D9%84%D9%81%D8%AC%D8%B1_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1).mp3",
      desc: "أذان فجر مغاربي عذب ونادر من تلمسان",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "makkah",
      name: "أذان المسجد الحرام (مكة المكرمة)",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Ali_Ibn_Ahmad_Mala_HQ.mp3",
      desc: "أذان الحرم المكي الشريف بصوت شيخ المؤذنين علي ملا",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "madinah",
      name: "أذان المسجد النبوي (المدينة المنورة)",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Al_Haram_Al_Madani_-_Al_Madinah_1_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%A7%D9%84%D8%AD%D8%B1%D9%85_%D8%A7%D9%84%D9%85%D8%AF%D9%86%D9%8A_-_%D8%A7%D9%84%D9%85%D8%AF%D9%8A%D9%86%D8%A9_%D8%A7%D9%84%D9%85%D9%86%D9%88%D8%B1%D8%A9).mp3",
      desc: "أذان طيبة الطيبة العذب المؤثر",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "al_aqsa",
      name: "أذان المسجد الأقصى المبارك (القدس الشريف)",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Najee_Qazaz_-_Al_Aqsa_Jerusalem_(%D9%86%D8%A7%D8%AC%D9%8A_%D9%82%D8%B2%D8%A7%D8%B2_-_%D8%A7%D9%84%D9%85%D8%B3%D8%AC%D8%AF_%D8%A7%D9%84%D8%A3%D9%82%D8%B5%D9%89_%D8%A7%D9%84%D9%82%D8%AF%D8%B3).mp3",
      desc: "أذان الأقصى والقدس الشريف - الشيخ ناجي قزاز",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "abdulbasit",
      name: "أذان الشيخ عبد الباسط عبد الصمد",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Abdulbasit_Abdusamad_1_-_Egypt_(%D8%B9%D8%A8%D8%AF_%D8%A7%D9%84%D8%A8%D8%A7%D8%B3%D8%B7_%D8%B9%D8%A8%D8%AF_%D8%A7%D9%84%D8%B5%D9%85%D8%AF_-_%D9%85%D8%B5%D8%B1).mp3",
      desc: "تسجيل تاريخي نادر بصوت فضيلة الشيخ عبد الباسط",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "husary",
      name: "أذان الشيخ محمود خليل الحصري",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Mahmoud_Khalil_Al_Hussary_-_Cairo_(%D9%85%D8%AD%D9%85%D9%88%D8%AF_%D8%AE%D9%84%D9%8A%D9%84_%D8%A7%D9%84%D8%AD%D8%B5%D8%B1%D9%8A_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3",
      desc: "شيخ عموم المقارئ المصرية رحمه الله",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "rifat",
      name: "أذان الشيخ محمد رفعت (قيثارة السماء)",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Muhammad_Refaat_-_Cairo_(%D9%85%D8%AD%D9%85%D8%AF_%D8%B1%D9%81%D8%B9%D8%AA_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3",
      desc: "أذان مغرب رمضان الخالد والتاريخي",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "banna",
      name: "أذان الشيخ محمود علي البنا",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Mahmoud_Ali_Al_Banna_-_Cairo_(%D9%85%D8%AD%D9%85%D9%88%D8%AF_%D8%B9%D9%84%D9%8A_%D8%A7%D9%84%D8%A8%D9%86%D8%A7_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3",
      desc: "صوت مصري شجي مفعم بالخشوع والوقار",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "shaisha",
      name: "أذان الشيخ أبو العينين شعيشع",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Abul_Ainain_Shuaisha_-_Cairo_(%D8%A3%D8%A8%D9%88_%D8%A7%D9%84%D8%B9%D9%8A%D9%86%D9%8A%D9%86_%D8%B4%D8%B9%D9%8A%D8%B4%D8%B9_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3",
      desc: "رائعة تاريخية بصوت الشيخ شعيشع رحمه الله",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "qatami",
      name: "أذان الشيخ ناصر القطامي",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Nasser_Al_Qatami_-_HQ_(%D9%86%D8%A7%D8%B5%D8%B1_%D8%A7%D9%84%D9%82%D8%B7%D8%A7%D9%85%D9%8A).mp3",
      desc: "أداء حجازي مؤثر ومميز",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "zitouna_tunisia",
      name: "أذان جامع الزيتونة المعمور (تونس)",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Tunisia_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%AA%D9%88%D9%86%D8%B3).mp3",
      desc: "الأذان التونسي المغاربي الخاشع",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "qarawiyyin_morocco",
      name: "أذان جامع القرويين (فاس - المغرب)",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Kamal_Muhammad_Al_Marush_2_-_Morocco_(%D9%83%D9%85%D8%A7%D9%84_%D9%85%D8%AD%D9%85%D8%AF_%D8%A7%D9%84%D9%85%D8%B1%D8%B9%D9%88%D8%B4_-_%D8%A7%D9%84%D9%85%D8%BA%D8%B1%D8%A8).mp3",
      desc: "الأذان المغربي الأصيل - كمال المرعوش",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "umayyad_syria",
      name: "أذان الجامع الأموي (دمشق - الشام)",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Syria_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%B3%D9%88%D8%B1%D9%8A%D8%A7).mp3",
      desc: "أذان الجامع الأموي الكبير بدمشق",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "blue_mosque_turkey",
      name: "أذان مسجد السلطان أحمد (إسطنبول - تركيا)",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Turkey_1_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%AA%D8%B1%D9%83%D9%8A%D8%A7).mp3",
      desc: "أذان عثماني بالمقام الصبا",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "sheikh_zayed_uae",
      name: "أذان جامع الشيخ زايد الكبير (أبوظبي)",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Dubai_UAE_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%AF%D8%A8%D9%8A_%D8%A7%D9%84%D8%A5%D9%85%D8%A7%D8%B1%D8%A7%D8%AA).mp3",
      desc: "أذان مهيب خاشع من الإمارات",
      isDefault: true,
    ),
    AdhanSoundItem(
      id: "takbeer_only",
      name: "تكبيرات الأذان والعيد (المسجد الحرام)",
      url: "audio/takbeer.wav",
      desc: "تكبيرات الحرم المكي الشريف فقط دون بقية الأذان",
      isDefault: true,
    ),
  ];

  static List<AdhanSoundItem> _customAdhans = [];

  static List<AdhanSoundItem> get catalogAdhans => defaultAdhans;

  /// Loads custom user adhans from SharedPreferences
  static Future<List<AdhanSoundItem>> getCustomAdhans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('custom_adhans_list') ?? [];
      _customAdhans = list
          .map((item) => AdhanSoundItem.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _customAdhans = [];
    }
    return _customAdhans;
  }

  /// Adds a custom user-defined adhan sound
  static Future<bool> addAdhan(AdhanSoundItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _customAdhans.removeWhere((a) => a.id == item.id);
      _customAdhans.add(item);
      final encoded = _customAdhans.map((a) => jsonEncode(a.toJson())).toList();
      await prefs.setStringList('custom_adhans_list', encoded);
      return true;
    } catch (e) {
      debugPrint("addAdhan error: $e");
      return false;
    }
  }

  /// Deletes a custom user-defined adhan sound
  static Future<bool> deleteAdhan(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _customAdhans.removeWhere((a) => a.id == id);
      final encoded = _customAdhans.map((a) => jsonEncode(a.toJson())).toList();
      await prefs.setStringList('custom_adhans_list', encoded);

      final defaultSound = prefs.getString('adhan_sound');
      if (defaultSound == id) {
        await prefs.setString('adhan_sound', 'algeria_grand_mosque');
      }
      for (var p in ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']) {
        if (prefs.getString('adhan_sound_$p') == id) {
          await prefs.setString('adhan_sound_$p', 'algeria_grand_mosque');
        }
      }
      return true;
    } catch (e) {
      debugPrint("deleteAdhan error: $e");
      return false;
    }
  }

  /// Lookup map of all available URLs
  static Map<String, String> get adhanOnlineUrls {
    final map = <String, String>{};
    for (var a in defaultAdhans) {
      map[a.id] = a.url;
    }
    for (var a in _customAdhans) {
      map[a.id] = a.url;
    }
    return map;
  }

  /// Lookup map of all adhan names
  static Map<String, String> get adhanNames {
    final map = <String, String>{};
    for (var a in defaultAdhans) {
      map[a.id] = a.name;
    }
    for (var a in _customAdhans) {
      map[a.id] = a.name;
    }
    return map;
  }

  /// Initialize listeners and audio session
  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
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
        debugPrint("setAudioContext note: $e");
      }
      _player.onPlayerStateChanged.listen((state) {
        isPlayingNotifier.value = (state == PlayerState.playing);
      });
      _player.onPlayerComplete.listen((_) {
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
    var sound = prefs.getString('adhan_sound_$prayerKey') ??
           prefs.getString('adhan_sound') ??
           'algeria_grand_mosque';
    if (sound == 'afasy') {
      sound = 'algeria_grand_mosque';
      await prefs.setString('adhan_sound_$prayerKey', sound);
    }
    return sound;
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
        client.connectionTimeout = const Duration(seconds: 15);
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

  /// Plays authentic human Adhan recording immediately.
  /// IMPORTANT: Immediately stops all other audio (Verse, previous Adhan, system notification sound) to prevent any overlap!
  static Future<bool> playAdhan({String? soundId}) async {
    final int myOpId = ++_playOpId;

    // 1. Immediately stop any Quran recitation, notification sound, or previous Adhan before starting
    try {
      await VerseAudioService.stopVerse();
    } catch (_) {}
    try {
      await FlutterLocalNotificationsPlugin().cancel(id: 100);
    } catch (_) {}
    try {
      await _player.stop();
      await _chimePlayer.stop();
    } catch (_) {}
    isPlayingNotifier.value = false;

    if (myOpId != _playOpId) return false;

    try {
      await init();
      if (_customAdhans.isEmpty) {
        await getCustomAdhans();
      }
      final prefs = await SharedPreferences.getInstance();
      final selected = soundId ?? prefs.getString('adhan_sound') ?? 'algeria_grand_mosque';

      if (myOpId != _playOpId) return false;

      final title = adhanNames[selected] ?? "الأذان المبارك";
      currentPlayingTitle.value = title;

      try {
        await _player.setVolume(1.0);
      } catch (_) {}

      // 2. If user selected takbeer only
      if (selected == 'takbeer_only') {
        if (myOpId != _playOpId) return false;
        try {
          await _player.play(AssetSource('audio/takbeer.wav'));
          if (myOpId != _playOpId) {
            await _player.stop();
            return false;
          }
          isPlayingNotifier.value = true;
          return true;
        } catch (e) {
          debugPrint("Takbeer asset error: $e");
          return false;
        }
      }

      // 3. If official Algerian Grand Mosque (or Waled Mahsas), play built-in local asset directly
      if (selected == "algeria_grand_mosque" || selected == "waled_mahzas") {
        if (myOpId != _playOpId) return false;
        try {
          await _player.play(AssetSource('audio/adhan.mp3'));
          if (myOpId != _playOpId) {
            await _player.stop();
            return false;
          }
          isPlayingNotifier.value = true;
          return true;
        } catch (e) {
          debugPrint("Local adhan asset error: $e");
        }
      }

      // 4. For user-selected online/custom muezzins: check cached file first for 0ms delay
      final onlineUrl = adhanOnlineUrls[selected];
      if (onlineUrl != null && !onlineUrl.startsWith('assets/') && !onlineUrl.startsWith('audio/')) {
        final cachedFile = await _getCachedAudioFile(selected, onlineUrl);
        if (myOpId != _playOpId) return false;

        if (cachedFile != null) {
          try {
            await _player.play(DeviceFileSource(cachedFile.path));
            if (myOpId != _playOpId) {
              await _player.stop();
              return false;
            }
            isPlayingNotifier.value = true;
            return true;
          } catch (cachedErr) {
            debugPrint("Cached adhan play failed: $cachedErr, trying stream");
          }
        }

        if (myOpId != _playOpId) return false;

        // Stream directly from URL
        try {
          await _player.play(UrlSource(onlineUrl));
          if (myOpId != _playOpId) {
            await _player.stop();
            return false;
          }
          isPlayingNotifier.value = true;
          return true;
        } catch (streamErr) {
          debugPrint("Online adhan stream failed: $streamErr");
          // If this operation was cancelled/superseded (e.g. by stopAdhan or VerseAudioService), NEVER play fallback!
          if (myOpId != _playOpId) return false;
        }
      }

      // 5. Fallback to local adhan asset ONLY if this operation is still active and network failed
      if (myOpId != _playOpId) return false;
      await _player.stop();
      await _player.play(AssetSource('audio/adhan.mp3'));
      if (myOpId != _playOpId) {
        await _player.stop();
        return false;
      }
      isPlayingNotifier.value = true;
      return true;
    } catch (e) {
      debugPrint('playAdhan error: $e');
      if (myOpId == _playOpId) {
        isPlayingNotifier.value = false;
        currentPlayingTitle.value = "";
      }
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
      await _chimePlayer.stop();
      await _chimePlayer.play(AssetSource('audio/notification.mp3'));
    } catch (e) {
      debugPrint('Chime mp3 error: $e');
      try {
        await _chimePlayer.stop();
        await _chimePlayer.play(AssetSource('audio/notification.wav'));
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
    ++_playOpId;
    try {
      await FlutterLocalNotificationsPlugin().cancel(id: 100);
    } catch (_) {}
    try {
      await _player.stop();
      await _chimePlayer.stop();
    } finally {
      isPlayingNotifier.value = false;
      currentPlayingTitle.value = "";
    }
  }
}
