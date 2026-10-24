import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdhanSoundItem {
  final String id;
  final String name;
  final String desc;
  final String url;
  final bool isCustom;

  const AdhanSoundItem({
    required this.id,
    required this.name,
    required this.desc,
    required this.url,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'desc': desc,
    'url': url,
    'isCustom': isCustom,
  };

  factory AdhanSoundItem.fromJson(Map<String, dynamic> json) => AdhanSoundItem(
    id: json['id'] as String,
    name: json['name'] as String,
    desc: json['desc'] as String? ?? '',
    url: json['url'] as String,
    isCustom: json['isCustom'] as bool? ?? true,
  );
}

class AdhanAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _chimePlayer = AudioPlayer();
  static bool isPlaying = false;
  static ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  static ValueNotifier<String> currentPlayingTitle = ValueNotifier<String>("");

  // Built-in Adhan options
  static final List<AdhanSoundItem> defaultAdhans = [
    const AdhanSoundItem(
      id: "algeria_grand_mosque",
      name: "أذان جامع الجزائر (الجامع الأعظم)",
      desc: "الأذان الجزائري الرسمي الموحد بأجمل صوت",
      url: "assets/audio/adhan.mp3",
    ),
    const AdhanSoundItem(
      id: "traditional_algerian",
      name: "الأذان الجزائري الأصيل (المقام المغاربي)",
      desc: "أذان مغاربي جزائري تقليدي خاشع ومهيب",
      url: "assets/audio/adhan.mp3",
    ),
    const AdhanSoundItem(
      id: "waled_mahzas",
      name: "أذان الشيخ وليد مهساس",
      desc: "الجزائر - نبرة سكينة وخشوع عذب",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Waled_Mahsas_2_-_Algeria_(%D9%88%D9%84%D9%8A%D8%AF_%D9%85%D8%AD%D8%B3%D8%A7%D8%B3_-_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1).mp3",
    ),
    const AdhanSoundItem(
      id: "makkah",
      name: "أذان المسجد الحرام",
      desc: "مكة المكرمة - الشيخ علي أحمد ملا",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Ali_Ibn_Ahmad_Mala_HQ.mp3",
    ),
    const AdhanSoundItem(
      id: "madinah",
      name: "أذان المسجد النبوي الشريف",
      desc: "المدينة المنورة - نبرة مدنية زكية",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Al_Haram_Al_Madani_-_Al_Madinah_1_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%A7%D9%84%D8%AD%D8%B1%D9%85_%D8%A7%D9%84%D9%85%D8%AF%D9%86%D9%8A_-_%D8%A7%D9%84%D9%85%D8%AF%D9%8A%D9%86%D8%A9_%D8%A7%D9%84%D9%85%D9%86%D9%88%D8%B1%D8%A9).mp3",
    ),
    const AdhanSoundItem(
      id: "al_aqsa",
      name: "أذان المسجد الأقصى المبارك",
      desc: "القدس الشريف - الشيخ ناجي قزاز",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Najee_Qazaz_-_Al_Aqsa_Jerusalem_(%D9%86%D8%A7%D8%AC%D9%8A_%D9%82%D8%B2%D8%A7%D8%B2_-_%D8%A7%D9%84%D9%85%D8%B3%D8%AC%D8%AF_%D8%A7%D9%84%D8%A3%D9%82%D8%B5%D9%89_%D8%A7%D9%84%D9%82%D8%AF%D8%B3).mp3",
    ),
    const AdhanSoundItem(
      id: "abdulbasit",
      name: "أذان الشيخ عبد الباسط عبد الصمد",
      desc: "مصر - من روائع التلاوة والآذان الخالد",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Abdulbasit_Abdusamad_1_-_Egypt_(%D8%B9%D8%A8%D8%AF_%D8%A7%D9%84%D8%A8%D8%A7%D8%B3%D8%B7_%D8%B9%D8%A8%D8%AF_%D8%A7%D9%84%D8%B5%D9%85%D8%AF_-_%D9%85%D8%B5%D8%B1).mp3",
    ),
    const AdhanSoundItem(
      id: "rifat",
      name: "أذان الشيخ محمد رفعت",
      desc: "قيثارة السماء وأذان القاهرة التاريخي الخالد",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Muhammad_Refaat_-_Cairo_(%D9%85%D8%AD%D9%85%D8%AF_%D8%B1%D9%81%D8%B9%D8%AA_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3",
    ),
    const AdhanSoundItem(
      id: "husary",
      name: "أذان الشيخ محمود خليل الحصري",
      desc: "أذان رصين متقن بالأحكام والتجويد",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Mahmoud_Khalil_Al_Hussary_-_Cairo_(%D9%85%D8%AD%D9%85%D9%88%D8%AF_%D8%AE%D9%84%D9%8A%D9%84_%D8%A7%D9%84%D8%AD%D8%B5%D8%B1%D9%8A_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3",
    ),
    const AdhanSoundItem(
      id: "banna",
      name: "أذان الشيخ محمود علي البنا",
      desc: "أداء رفيع وشجي من كبار قراء مصر",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Mahmoud_Ali_Al_Banna_-_Cairo_(%D9%85%D8%AD%D9%85%D9%88%D8%AF_%D8%B9%D9%84%D9%8A_%D8%A7%D9%84%D8%A8%D9%86%D8%A7_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3",
    ),
    const AdhanSoundItem(
      id: "shaisha",
      name: "أذان الشيخ أبو العينين شعيشع",
      desc: "نبرة عذبة من الزمن الجميل الأصيل",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Abul_Ainain_Shuaisha_-_Cairo_(%D8%A3%D8%A8%D9%88_%D8%A7%D9%84%D8%B9%D9%8A%D9%86%D9%8A%D9%86_%D8%B4%D8%B9%D9%8A%D8%B4%D8%B9_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3",
    ),
    const AdhanSoundItem(
      id: "qatami",
      name: "أذان الشيخ ناصر القطامي",
      desc: "أذان نجد الشجي والمؤثر",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Nasser_Al_Qatami_-_HQ_(%D9%86%D8%A7%D8%B5%D8%B1_%D8%A7%D9%84%D9%82%D8%B7%D8%A7%D9%85%D9%8A).mp3",
    ),
    const AdhanSoundItem(
      id: "takbeer_only",
      name: "تكبيرات الأذان والعيد (المسجد الحرام)",
      desc: "تكبيرات جماعية مهيبة وخاشعة",
      url: "assets/audio/takbeer.wav",
    ),
  ];

  // Extended catalog of authentic regional Adhans ready to add with 1-click
  static final List<AdhanSoundItem> catalogAdhans = [
    const AdhanSoundItem(
      id: "zaytouna_tunis",
      name: "أذان جامع الزيتونة المعمور (تونس)",
      desc: "المقام المغاربي التونسي الأصيل ذو النبرة العذبة",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Tunisia_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%AA%D9%88%D9%86%D8%B3).mp3",
    ),
    const AdhanSoundItem(
      id: "qarawiyyin_fes",
      name: "أذان جامع القرويين بفاس (المغرب)",
      desc: "تراث مغاربي أندلسي عريق ونغم شجي",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Kamal_Muhammad_Al_Marush_2_-_Morocco_(%D9%83%D9%85%D8%A7%D9%84_%D9%85%D8%AD%D9%85%D8%AF_%D8%A7%D9%84%D9%85%D8%B1%D8%B9%D9%88%D8%B4_-_%D8%A7%D9%84%D9%85%D8%BA%D8%B1%D8%A8).mp3",
    ),
    const AdhanSoundItem(
      id: "umayyad_damascus",
      name: "أذان الجامع الأموي الكبير (دمشق)",
      desc: "نغمة شامية مهيبة من أقدم جوامع الإسلام",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Syria_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%B3%D9%88%D8%B1%D9%8A%D8%A7).mp3",
    ),
    const AdhanSoundItem(
      id: "istanbul_sultanahmet",
      name: "أذان جامع السلطان أحمد (إسطنبول - تركيا)",
      desc: "مقام صبا وشجن عثماني مؤثر وفريد",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Turkey_1_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%AA%D8%B1%D9%83%D9%8A%D8%A7).mp3",
    ),
    const AdhanSoundItem(
      id: "zayed_abudhabi",
      name: "أذان جامع الشيخ زايد الكبير (أبوظبي)",
      desc: "نبرة خشوع ووقار خليجي هادئ",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Dubai_UAE_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%AF%D8%A8%D9%8A_%D8%A7%D9%84%D8%A5%D9%85%D8%A7%D8%B1%D8%A7%D8%AA).mp3",
    ),
    const AdhanSoundItem(
      id: "tlemcen_algeria",
      name: "أذان تلمسان التاريخي (الجزائر)",
      desc: "أصالة جوهرة الغرب الجزائري والتراث الأندلسي",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Riad_Al_Djazairi_-_Algeria_(%D8%B1%D9%8A%D8%A7%D8%B6_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1%D9%8A_-_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1).mp3",
    ),
    const AdhanSoundItem(
      id: "constantine_algeria",
      name: "أذان قسنطينة الزكي (الجزائر)",
      desc: "أداء أندلسي عريق من مدينة الجسور المعلقة",
      url: "https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Haj_Sulaiman_Mukhtar_-_Algeria_(%D8%AD%D8%A7%D8%AC_%D8%B3%D9%84%D9%8A%D9%85%D8%A7%D9%86_%D9%85%D8%AE%D8%AA%D8%A7%D8%B1_-_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1).mp3",
    ),
  ];

  static List<AdhanSoundItem> _customAdhans = [];
  static bool _customLoaded = false;

  /// Loads custom added adhans from storage
  static Future<List<AdhanSoundItem>> getCustomAdhans() async {
    if (_customLoaded) return _customAdhans;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList('custom_adhans_list') ?? [];
      _customAdhans = raw.map((item) => AdhanSoundItem.fromJson(jsonDecode(item) as Map<String, dynamic>)).toList();
      _customLoaded = true;
    } catch (e) {
      debugPrint("Error loading custom adhans: $e");
      _customAdhans = [];
    }
    return _customAdhans;
  }

  /// Get all active adhans (default + user added)
  static Future<List<AdhanSoundItem>> getAllAdhans() async {
    final custom = await getCustomAdhans();
    return [...defaultAdhans, ...custom];
  }

  /// Add a new adhan (from catalog or custom URL)
  static Future<bool> addAdhan(AdhanSoundItem adhan) async {
    try {
      final current = await getAllAdhans();
      if (current.any((a) => a.id == adhan.id)) return false;

      final custom = await getCustomAdhans();
      custom.add(adhan);
      _customAdhans = custom;

      final prefs = await SharedPreferences.getInstance();
      final encoded = custom.map((a) => jsonEncode(a.toJson())).toList();
      await prefs.setStringList('custom_adhans_list', encoded);
      return true;
    } catch (e) {
      debugPrint("addAdhan error: $e");
      return false;
    }
  }

  /// Delete a user-added adhan
  static Future<bool> deleteAdhan(String id) async {
    try {
      final custom = await getCustomAdhans();
      custom.removeWhere((a) => a.id == id);
      _customAdhans = custom;

      final prefs = await SharedPreferences.getInstance();
      final encoded = custom.map((a) => jsonEncode(a.toJson())).toList();
      await prefs.setStringList('custom_adhans_list', encoded);

      // If this adhan was selected as default or for any prayer, revert to algeria_grand_mosque
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
      await _chimePlayer.stop();
      await _chimePlayer.play(AssetSource('audio/notification.mp3'));
    } catch (e) {
      debugPrint("Chime mp3 error: $e");
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
