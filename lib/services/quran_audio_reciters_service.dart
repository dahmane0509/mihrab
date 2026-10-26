import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranReciter {
  final String id;
  final String nameAr;
  final String nameEn;
  final String riwayahAr;
  final String riwayahEn;
  final String serverUrl;
  final bool isCustom;

  const QuranReciter({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.riwayahAr,
    required this.riwayahEn,
    required this.serverUrl,
    this.isCustom = false,
  });

  String getSurahUrl(int surahNumber) {
    final cleanBase = serverUrl.endsWith('/')
        ? serverUrl.substring(0, serverUrl.length - 1)
        : serverUrl;
    final formattedNum = surahNumber.toString().padLeft(3, '0');
    return '$cleanBase/$formattedNum.mp3';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'riwayahAr': riwayahAr,
        'riwayahEn': riwayahEn,
        'serverUrl': serverUrl,
        'isCustom': isCustom,
      };

  factory QuranReciter.fromJson(Map<String, dynamic> json) => QuranReciter(
        id: json['id'] as String,
        nameAr: json['nameAr'] as String,
        nameEn: json['nameEn'] as String? ?? json['nameAr'] as String,
        riwayahAr: json['riwayahAr'] as String? ?? 'رواية حفص عن عاصم',
        riwayahEn: json['riwayahEn'] as String? ?? 'Hafs an Asim',
        serverUrl: json['serverUrl'] as String,
        isCustom: json['isCustom'] as bool? ?? true,
      );
}

class QuranAudioRecitersService {
  static const String _prefActiveReciter = 'quran_active_reciter_id';
  static const String _prefCustomReciters = 'quran_custom_reciters';

  /// قائمة القراء الـ 12 الافتراضيين بروابط خوادم mp3quran.net الرسمية الصحيحة (بدلاً من cdn.mp3quran.net غير الموجود)
  static const List<QuranReciter> defaultReciters = [
    QuranReciter(
      id: 'abdulbasit',
      nameAr: 'الشيخ عبد الباسط عبد الصمد',
      nameEn: 'Sheikh Abdulbasit Abdulsamad',
      riwayahAr: 'رواية ورش عن نافع',
      riwayahEn: 'Warsh an Nafi',
      serverUrl: 'https://server7.mp3quran.net/basit',
    ),
    QuranReciter(
      id: 'yassen',
      nameAr: 'الشيخ ياسين الجزائري',
      nameEn: 'Sheikh Yassen Al-Jazairi',
      riwayahAr: 'رواية ورش عن نافع (الجزائر)',
      riwayahEn: 'Warsh an Nafi (Algeria)',
      serverUrl: 'https://server11.mp3quran.net/qari',
    ),
    QuranReciter(
      id: 'sheim',
      nameAr: 'الشيخ عبد العزيز سحيم',
      nameEn: 'Sheikh Abdelaziz Sheim',
      riwayahAr: 'تلاوة خاشعة من الجزائر',
      riwayahEn: 'Touching Algerian Recitation',
      serverUrl: 'https://server10.mp3quran.net/sheim',
    ),
    QuranReciter(
      id: 'kouchi',
      nameAr: 'الشيخ العيون الكوشي',
      nameEn: 'Sheikh Laayoun El Kouchi',
      riwayahAr: 'رواية ورش عن نافع',
      riwayahEn: 'Warsh an Nafi',
      serverUrl: 'https://server11.mp3quran.net/koshi',
    ),
    QuranReciter(
      id: 'kazabri',
      nameAr: 'الشيخ عمر القزابري',
      nameEn: 'Sheikh Omar Al-Kazabri',
      riwayahAr: 'رواية ورش عن نافع',
      riwayahEn: 'Warsh an Nafi',
      serverUrl: 'https://server9.mp3quran.net/omar_warsh',
    ),
    QuranReciter(
      id: 'husary',
      nameAr: 'الشيخ محمود خليل الحصري (ورش)',
      nameEn: 'Sheikh Mahmoud Khalil Al-Husary (Warsh)',
      riwayahAr: 'رواية ورش عن نافع',
      riwayahEn: 'Warsh an Nafi',
      serverUrl: 'https://server13.mp3quran.net/husr',
    ),
    QuranReciter(
      id: 'maher',
      nameAr: 'الشيخ ماهر المعيقلي',
      nameEn: 'Sheikh Maher Al-Muaiqly',
      riwayahAr: 'رواية حفص عن عاصم (الحرم المكي)',
      riwayahEn: 'Hafs an Asim (Makkah Haram)',
      serverUrl: 'https://server12.mp3quran.net/maher',
    ),
    QuranReciter(
      id: 'ghamdi',
      nameAr: 'الشيخ سعد الغامدي',
      nameEn: 'Sheikh Saad Al-Ghamdi',
      riwayahAr: 'رواية حفص عن عاصم',
      riwayahEn: 'Hafs an Asim',
      serverUrl: 'https://server7.mp3quran.net/s_gmd',
    ),
    QuranReciter(
      id: 'minshawi',
      nameAr: 'الشيخ محمد صديق المنشاوي',
      nameEn: 'Sheikh Muhammad Siddiq Al-Minshawi',
      riwayahAr: 'رواية حفص عن عاصم (المصحف المرتل)',
      riwayahEn: 'Hafs an Asim',
      serverUrl: 'https://server10.mp3quran.net/minsh',
    ),
    QuranReciter(
      id: 'shatri',
      nameAr: 'الشيخ أبو بكر الشاطري',
      nameEn: 'Sheikh Abu Bakr Al-Shatri',
      riwayahAr: 'رواية حفص عن عاصم',
      riwayahEn: 'Hafs an Asim',
      serverUrl: 'https://server11.mp3quran.net/shatri',
    ),
    QuranReciter(
      id: 'hudhaifi',
      nameAr: 'الشيخ علي الحذيفي',
      nameEn: 'Sheikh Ali Al-Hudhaifi',
      riwayahAr: 'رواية حفص عن عاصم (إمام المسجد النبوي)',
      riwayahEn: 'Hafs an Asim (Prophet Mosque)',
      serverUrl: 'https://server9.mp3quran.net/hthfi',
    ),
    QuranReciter(
      id: 'islam_sobhi',
      nameAr: 'القارئ إسلام صبحي',
      nameEn: 'Reciter Islam Sobhi',
      riwayahAr: 'رواية حفص عن عاصم',
      riwayahEn: 'Hafs an Asim',
      serverUrl: 'https://server14.mp3quran.net/islam/Rewayat-Hafs-A-n-Assem',
    ),
  ];

  static List<QuranReciter> _customReciters = [];
  static List<QuranReciter> _allReciters = List.from(defaultReciters);

  static final ValueNotifier<QuranReciter> activeReciterNotifier =
      ValueNotifier<QuranReciter>(defaultReciters.first);
  static final ValueNotifier<int> recitersVersionNotifier = ValueNotifier<int>(0);

  static QuranReciter get activeReciter => activeReciterNotifier.value;
  static List<QuranReciter> get allReciters => List.unmodifiable(_allReciters);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final rawCustom = prefs.getString(_prefCustomReciters);
    if (rawCustom != null && rawCustom.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(rawCustom);
        _customReciters = decoded
            .map((e) => QuranReciter.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _customReciters = [];
      }
    }
    _rebuildRecitersList();

    final savedId = prefs.getString(_prefActiveReciter);
    if (savedId != null) {
      final match = _allReciters.where((r) => r.id == savedId);
      if (match.isNotEmpty) {
        activeReciterNotifier.value = match.first;
      }
    }
  }

  static void _rebuildRecitersList() {
    _allReciters = [...defaultReciters, ..._customReciters];
    recitersVersionNotifier.value++;
  }

  static Future<void> setActiveReciter(String reciterId) async {
    final match = _allReciters.where((r) => r.id == reciterId);
    if (match.isNotEmpty) {
      activeReciterNotifier.value = match.first;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefActiveReciter, reciterId);
    }
  }
}
