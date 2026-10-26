/// Comprehensive Reciters Model and Global Catalog for Mihrab App
class QuranReciter {
  final String id;
  final String name;
  final String server; // Base CDN URL (without trailing slash or with, normalized)
  final String riwayah;
  final String country;
  final bool isCustom;

  const QuranReciter({
    required this.id,
    required this.name,
    required this.server,
    this.riwayah = 'رواية حفص عن عاصم',
    this.country = '🇸🇦',
    this.isCustom = false,
  });

  String get countryFlag => country;
  String get subtext => riwayah;

  String get audioServerUrl => server.endsWith('/') ? server.substring(0, server.length - 1) : server;

  String getSurahUrl(int surahNumber) {
    final padded = surahNumber.toString().padLeft(3, '0');
    return '$audioServerUrl/$padded.mp3';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'server': server,
        'riwayah': riwayah,
        'country': country,
        'isCustom': isCustom,
      };

  factory QuranReciter.fromJson(Map<String, dynamic> json) => QuranReciter(
        id: json['id'] as String? ?? 'reciter_${DateTime.now().millisecondsSinceEpoch}',
        name: json['name'] as String? ?? 'قارئ غير معروف',
        server: json['server'] as String? ?? '',
        riwayah: json['riwayah'] as String? ?? 'رواية حفص عن عاصم',
        country: json['country'] as String? ?? '🌍',
        isCustom: json['isCustom'] as bool? ?? true,
      );
}

class QuranRecitersCatalog {
  /// Default pre-installed reciters in the app
  static const List<QuranReciter> defaultReciters = [
    QuranReciter(
      id: "jaza",
      name: "الشيخ ياسين الجزائري",
      riwayah: "رواية ورش عن نافع (الجزائر)",
      country: "🇩🇿",
      server: "https://server11.mp3quran.net/qari",
    ),
    QuranReciter(
      id: "sheim",
      name: "الشيخ عبد العزيز سحيم",
      riwayah: "رواية ورش عن نافع (الجزائر)",
      country: "🇩🇿",
      server: "https://server10.mp3quran.net/sheim",
    ),
    QuranReciter(
      id: "kouchi",
      name: "الشيخ العيون الكوشي",
      riwayah: "رواية ورش عن نافع",
      country: "🇲🇦",
      server: "https://server11.mp3quran.net/koshi",
    ),
    QuranReciter(
      id: "kazabri",
      name: "الشيخ عمر القزابري",
      riwayah: "رواية ورش عن نافع",
      country: "🇲🇦",
      server: "https://server9.mp3quran.net/omar_warsh",
    ),
    QuranReciter(
      id: "husr_warsh",
      name: "الشيخ محمود خليل الحصري (ورش)",
      riwayah: "رواية ورش عن نافع",
      country: "🇪🇬",
      server: "https://server13.mp3quran.net/husr",
    ),
    QuranReciter(
      id: "afasy",
      name: "الشيخ مشاري بن راشد العفاسي",
      riwayah: "رواية حفص عن عاصم",
      country: "🇰🇼",
      server: "https://server8.mp3quran.net/afs",
    ),
    QuranReciter(
      id: "sudais",
      name: "الشيخ عبد الرحمن السديس",
      riwayah: "رواية حفص عن عاصم (إمام الحرم المكي)",
      country: "🇸🇦",
      server: "https://server11.mp3quran.net/sds",
    ),
    QuranReciter(
      id: "maher",
      name: "الشيخ ماهر المعيقلي",
      riwayah: "رواية حفص عن عاصم (إمام الحرم المكي)",
      country: "🇸🇦",
      server: "https://server12.mp3quran.net/maher",
    ),
    QuranReciter(
      id: "dosari",
      name: "الشيخ ياسر الدوسري",
      riwayah: "رواية حفص عن عاصم (إمام الحرم المكي)",
      country: "🇸🇦",
      server: "https://server11.mp3quran.net/yasser",
    ),
    QuranReciter(
      id: "basit",
      name: "الشيخ عبد الباسط عبد الصمد (مرتل)",
      riwayah: "رواية حفص عن عاصم",
      country: "🇪🇬",
      server: "https://server7.mp3quran.net/basit",
    ),
    QuranReciter(
      id: "minsh",
      name: "الشيخ محمد صديق المنشاوي (مرتل)",
      riwayah: "رواية حفص عن عاصم",
      country: "🇪🇬",
      server: "https://server10.mp3quran.net/minsh",
    ),
    QuranReciter(
      id: "s_gmd",
      name: "الشيخ سعد الغامدي",
      riwayah: "رواية حفص عن عاصم",
      country: "🇸🇦",
      server: "https://server7.mp3quran.net/s_gmd",
    ),
    QuranReciter(
      id: "islam_sobhi",
      name: "القارئ إسلام صبحي",
      riwayah: "رواية حفص عن عاصم",
      country: "🇪🇬",
      server: "https://server14.mp3quran.net/islam/Rewayat-Hafs-A-n-Assem",
    ),
    QuranReciter(
      id: "hudhaifi",
      name: "الشيخ علي بن عبد الرحمن الحذيفي",
      riwayah: "رواية حفص عن عاصم (إمام المسجد النبوي)",
      country: "🇸🇦",
      server: "https://server9.mp3quran.net/hthfi",
    ),
  ];

  /// Comprehensive Catalog of additional world reciters available for instant search & addition
  static const List<QuranReciter> availableCatalog = [
    QuranReciter(
      id: "shur",
      name: "الشيخ سعود الشريم",
      riwayah: "رواية حفص عن عاصم",
      country: "🇸🇦",
      server: "https://server7.mp3quran.net/shur",
    ),
    QuranReciter(
      id: "shatri",
      name: "الشيخ أبو بكر الشاطري",
      riwayah: "رواية حفص عن عاصم",
      country: "🇸🇦",
      server: "https://server11.mp3quran.net/shatri",
    ),
    QuranReciter(
      id: "qatami",
      name: "الشيخ ناصر القطامي",
      riwayah: "رواية حفص عن عاصم",
      country: "🇸🇦",
      server: "https://server6.mp3quran.net/qtm",
    ),
    QuranReciter(
      id: "hazza",
      name: "الشيخ هزاع البلوشي",
      riwayah: "رواية حفص عن عاصم",
      country: "🇴🇲",
      server: "https://server11.mp3quran.net/hazza",
    ),
    QuranReciter(
      id: "abkar",
      name: "الشيخ إدريس أبكر",
      riwayah: "رواية حفص عن عاصم",
      country: "🇾🇪",
      server: "https://server6.mp3quran.net/abkr",
    ),
    QuranReciter(
      id: "fares",
      name: "الشيخ فارس عباد",
      riwayah: "رواية حفص عن عاصم",
      country: "🇾🇪",
      server: "https://server8.mp3quran.net/frs_a",
    ),
    QuranReciter(
      id: "ajmy",
      name: "الشيخ أحمد بن علي العجمي",
      riwayah: "رواية حفص عن عاصم",
      country: "🇸🇦",
      server: "https://server10.mp3quran.net/ajm",
    ),
    QuranReciter(
      id: "jleel",
      name: "الشيخ خالد الجليل",
      riwayah: "رواية حفص عن عاصم",
      country: "🇸🇦",
      server: "https://server10.mp3quran.net/jleel",
    ),
    QuranReciter(
      id: "juhany",
      name: "الشيخ عبد الله عواد الجهني",
      riwayah: "رواية حفص عن عاصم (إمام الحرم المكي)",
      country: "🇸🇦",
      server: "https://server13.mp3quran.net/jhn",
    ),
    QuranReciter(
      id: "balilah",
      name: "الشيخ بندر بليلة",
      riwayah: "رواية حفص عن عاصم (إمام الحرم المكي)",
      country: "🇸🇦",
      server: "https://server6.mp3quran.net/balilah",
    ),
    QuranReciter(
      id: "ali_jaber",
      name: "الشيخ علي جابر (رحمه الله)",
      riwayah: "رواية حفص عن عاصم (إمام الحرم المكي الأسبق)",
      country: "🇸🇦",
      server: "https://server11.mp3quran.net/a_jbr",
    ),
    QuranReciter(
      id: "budair",
      name: "الشيخ صلاح البدير",
      riwayah: "رواية حفص عن عاصم (إمام المسجد النبوي)",
      country: "🇸🇦",
      server: "https://server6.mp3quran.net/s_bud",
    ),
    QuranReciter(
      id: "luhaidan",
      name: "الشيخ محمد اللحيدان",
      riwayah: "رواية حفص عن عاصم",
      country: "🇸🇦",
      server: "https://server8.mp3quran.net/lhdan",
    ),
    QuranReciter(
      id: "yamani",
      name: "الشيخ وديع اليمني",
      riwayah: "رواية حفص عن عاصم",
      country: "🇾🇪",
      server: "https://server6.mp3quran.net/wdee",
    ),
    QuranReciter(
      id: "raad",
      name: "الشيخ رعد الكردي",
      riwayah: "رواية حفص عن عاصم",
      country: "🇮🇶",
      server: "https://server6.mp3quran.net/raad",
    ),
    QuranReciter(
      id: "banna",
      name: "الشيخ محمود علي البنا",
      riwayah: "رواية حفص عن عاصم",
      country: "🇪🇬",
      server: "https://server8.mp3quran.net/bna",
    ),
    QuranReciter(
      id: "tablawi",
      name: "الشيخ محمد محمود الطبلاوي",
      riwayah: "رواية حفص عن عاصم",
      country: "🇪🇬",
      server: "https://server12.mp3quran.net/tblwi",
    ),
    QuranReciter(
      id: "rifai",
      name: "الشيخ هاني الرفاعي",
      riwayah: "رواية حفص عن عاصم",
      country: "🇸🇦",
      server: "https://server8.mp3quran.net/rifai",
    ),
    QuranReciter(
      id: "salimi",
      name: "الشيخ منصور السالمي",
      riwayah: "رواية حفص عن عاصم",
      country: "🇸🇦",
      server: "https://server14.mp3quran.net/mansor",
    ),
    QuranReciter(
      id: "husr_hafs",
      name: "الشيخ محمود خليل الحصري (حفص)",
      riwayah: "رواية حفص عن عاصم (مرتل)",
      country: "🇪🇬",
      server: "https://server13.mp3quran.net/husr",
    ),
    QuranReciter(
      id: "basit_mojawwad",
      name: "الشيخ عبد الباسط عبد الصمد (مجود)",
      riwayah: "رواية حفص عن عاصم (تلاوة مجودة نادرة)",
      country: "🇪🇬",
      server: "https://server7.mp3quran.net/basit/Almusshaf-Al-Mojawwad",
    ),
    QuranReciter(
      id: "minsh_mojawwad",
      name: "الشيخ محمد صديق المنشاوي (مجود)",
      riwayah: "رواية حفص عن عاصم (تلاوة مجودة خاشعة)",
      country: "🇪🇬",
      server: "https://server10.mp3quran.net/minsh/Almusshaf-Al-Mojawwad",
    ),
    QuranReciter(
      id: "soufi_khalaf",
      name: "الشيخ عبد الرشيد صوفي (خلف عن حمزة)",
      riwayah: "رواية خلف عن حمزة",
      country: "🇸🇴",
      server: "https://server16.mp3quran.net/soufi/Rewayat-Khalaf-A-n-Hamzah",
    ),
    QuranReciter(
      id: "soufi_soosi",
      name: "الشيخ عبد الرشيد صوفي (السوسي)",
      riwayah: "رواية السوسي عن أبي عمرو",
      country: "🇸🇴",
      server: "https://server16.mp3quran.net/soufi/Rewayat-AlSoosi-A-n-Abi-Amr",
    ),
    QuranReciter(
      id: "saltany_dori",
      name: "الشيخ مفتاح السلطني (الدوري)",
      riwayah: "رواية الدوري عن أبي عمرو",
      country: "🇱🇾",
      server: "https://server14.mp3quran.net/saltany/Rewayat-Aldori-A-n-Abi-Amr",
    ),
    QuranReciter(
      id: "mustafa_ismail",
      name: "الشيخ مصطفى إسماعيل",
      riwayah: "رواية حفص عن عاصم (مرتل)",
      country: "🇪🇬",
      server: "https://server8.mp3quran.net/mustafa",
    ),
    QuranReciter(
      id: "nabil_rifai",
      name: "الشيخ نبيل الرفاعي",
      riwayah: "رواية حفص عن عاصم",
      country: "🇸🇦",
      server: "https://server9.mp3quran.net/nabil",
    ),
    QuranReciter(
      id: "muhammad_ayyoub",
      name: "الشيخ محمد أيوب (رحمه الله)",
      riwayah: "رواية حفص عن عاصم (إمام المسجد النبوي الأسبق)",
      country: "🇸🇦",
      server: "https://server8.mp3quran.net/ayyub",
    ),
    QuranReciter(
      id: "abdullah_basfar",
      name: "الشيخ عبد الله بصفر",
      riwayah: "رواية حفص عن عاصم",
      country: "🇸🇦",
      server: "https://server6.mp3quran.net/bsfr",
    ),
    QuranReciter(
      id: "khalifa_tunaiji",
      name: "الشيخ خليفة الطنيجي",
      riwayah: "رواية حفص عن عاصم",
      country: "🇦🇪",
      server: "https://server12.mp3quran.net/tnjy",
    ),
  ];
}
