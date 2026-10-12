import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/algeria_wilayas.dart';
import '../data/algeria_communes.dart';
import '../data/world_cities.dart';
import 'language_service.dart';

enum CalculationMethod {
  algeria,
  mwl,
  makkah,
  egypt,
  karachi,
  isna,
}

extension CalculationMethodExt on CalculationMethod {
  String get id {
    switch (this) {
      case CalculationMethod.algeria:
        return 'algeria';
      case CalculationMethod.mwl:
        return 'mwl';
      case CalculationMethod.makkah:
        return 'makkah';
      case CalculationMethod.egypt:
        return 'egypt';
      case CalculationMethod.karachi:
        return 'karachi';
      case CalculationMethod.isna:
        return 'isna';
    }
  }

  String get nameAr {
    switch (this) {
      case CalculationMethod.algeria:
        return 'وزارة الشؤون الدينية والأوقاف الجزائرية (المعتمد)';
      case CalculationMethod.mwl:
        return 'رابطة العالم الإسلامي (MWL)';
      case CalculationMethod.makkah:
        return 'جامعة أم القرى (مكة المكرمة)';
      case CalculationMethod.egypt:
        return 'الهيئة المصرية العامة للمساحة';
      case CalculationMethod.karachi:
        return 'جامعة العلوم الإسلامية بكراتشي';
      case CalculationMethod.isna:
        return 'الاتحاد الإسلامي لأمريكا الشمالية (ISNA)';
    }
  }

  String get nameEn {
    switch (this) {
      case CalculationMethod.algeria:
        return 'Ministry of Religious Affairs (Algeria)';
      case CalculationMethod.mwl:
        return 'Muslim World League (MWL)';
      case CalculationMethod.makkah:
        return 'Umm Al-Qura University (Makkah)';
      case CalculationMethod.egypt:
        return 'Egyptian General Authority of Survey';
      case CalculationMethod.karachi:
        return 'University of Islamic Sciences (Karachi)';
      case CalculationMethod.isna:
        return 'Islamic Society of North America (ISNA)';
    }
  }

  String get nameFr {
    switch (this) {
      case CalculationMethod.algeria:
        return 'Ministère des Affaires Religieuses (Algérie)';
      case CalculationMethod.mwl:
        return 'Ligue Islamique Mondiale (MWL)';
      case CalculationMethod.makkah:
        return 'Université Oumm Al-Qura (La Mecque)';
      case CalculationMethod.egypt:
        return 'Autorité Générale Égyptienne de l\'Arpentage';
      case CalculationMethod.karachi:
        return 'Université des Sciences Islamiques (Karachi)';
      case CalculationMethod.isna:
        return 'Société Islamique d\'Amérique du Nord (ISNA)';
    }
  }

  String localizedName(String lang) {
    if (lang == 'en') return nameEn;
    if (lang == 'fr') return nameFr;
    return nameAr;
  }

  String get descriptionAr {
    switch (this) {
      case CalculationMethod.algeria:
        return 'زاوية الفجر 18°، زاوية العشاء 17°، والمذهب المالكي';
      case CalculationMethod.mwl:
        return 'زاوية الفجر 18°، زاوية العشاء 17°';
      case CalculationMethod.makkah:
        return 'زاوية الفجر 18.5°، العشاء بعد المغرب بـ 90 دقيقة';
      case CalculationMethod.egypt:
        return 'زاوية الفجر 19.5°، زاوية العشاء 17.5°';
      case CalculationMethod.karachi:
        return 'زاوية الفجر 18°، زاوية العشاء 18°';
      case CalculationMethod.isna:
        return 'زاوية الفجر 15°، زاوية العشاء 15°';
    }
  }

  String get descriptionEn {
    switch (this) {
      case CalculationMethod.algeria:
        return 'Fajr 18°, Isha 17°, Maliki juristic default';
      case CalculationMethod.mwl:
        return 'Fajr 18°, Isha 17°';
      case CalculationMethod.makkah:
        return 'Fajr 18.5°, Isha 90 minutes after Maghrib';
      case CalculationMethod.egypt:
        return 'Fajr 19.5°, Isha 17.5°';
      case CalculationMethod.karachi:
        return 'Fajr 18°, Isha 18°';
      case CalculationMethod.isna:
        return 'Fajr 15°, Isha 15°';
    }
  }

  String get descriptionFr {
    switch (this) {
      case CalculationMethod.algeria:
        return 'Fajr 18°, Isha 17°, rite malékite';
      case CalculationMethod.mwl:
        return 'Fajr 18°, Isha 17°';
      case CalculationMethod.makkah:
        return 'Fajr 18.5°, Isha 90 min après Maghrib';
      case CalculationMethod.egypt:
        return 'Fajr 19.5°, Isha 17.5°';
      case CalculationMethod.karachi:
        return 'Fajr 18°, Isha 18°';
      case CalculationMethod.isna:
        return 'Fajr 15°, Isha 15°';
    }
  }

  String localizedDescription(String lang) {
    if (lang == 'en') return descriptionEn;
    if (lang == 'fr') return descriptionFr;
    return descriptionAr;
  }

  double get fajrAngle {
    switch (this) {
      case CalculationMethod.algeria:
        return 18.0;
      case CalculationMethod.mwl:
        return 18.0;
      case CalculationMethod.makkah:
        return 18.5;
      case CalculationMethod.egypt:
        return 19.5;
      case CalculationMethod.karachi:
        return 18.0;
      case CalculationMethod.isna:
        return 15.0;
    }
  }

  double get ishaAngle {
    switch (this) {
      case CalculationMethod.algeria:
        return 17.0;
      case CalculationMethod.mwl:
        return 17.0;
      case CalculationMethod.makkah:
        return 17.0; // fallback if angle based
      case CalculationMethod.egypt:
        return 17.5;
      case CalculationMethod.karachi:
        return 18.0;
      case CalculationMethod.isna:
        return 15.0;
    }
  }
}

enum JuristicMethod {
  standard, // Maliki, Shafi'i, Hanbali (Shadow 1)
  hanafi,   // Hanafi (Shadow 2)
}

extension JuristicMethodExt on JuristicMethod {
  String get id => this == JuristicMethod.hanafi ? 'hanafi' : 'standard';

  String get nameAr {
    switch (this) {
      case JuristicMethod.standard:
        return 'الجمهور: المالكي والشافعي والحنبلي (ظل المثل)';
      case JuristicMethod.hanafi:
        return 'المذهب الحنفي (ظل المثلين)';
    }
  }

  String get nameEn {
    switch (this) {
      case JuristicMethod.standard:
        return 'Standard: Maliki, Shafi\'i, Hanbali (Single shadow)';
      case JuristicMethod.hanafi:
        return 'Hanafi (Double shadow factor)';
    }
  }

  String get nameFr {
    switch (this) {
      case JuristicMethod.standard:
        return 'Standard : Malékite, Chaféite, Hanbalite (Une ombre)';
      case JuristicMethod.hanafi:
        return 'Hanafite (Double facteur d\'ombre)';
    }
  }

  String localizedName(String lang) {
    if (lang == 'en') return nameEn;
    if (lang == 'fr') return nameFr;
    return nameAr;
  }
}

class PrayerAdjustments {
  final int fajrMinutes;
  final int sunriseMinutes;
  final int dhuhrMinutes;
  final int asrMinutes;
  final int maghribMinutes;
  final int ishaMinutes;

  const PrayerAdjustments({
    this.fajrMinutes = 0,
    this.sunriseMinutes = 0,
    this.dhuhrMinutes = 0,
    this.asrMinutes = 0,
    this.maghribMinutes = 0,
    this.ishaMinutes = 0,
  });

  Map<String, int> toMap() => {
    'fajr': fajrMinutes,
    'sunrise': sunriseMinutes,
    'dhuhr': dhuhrMinutes,
    'asr': asrMinutes,
    'maghrib': maghribMinutes,
    'isha': ishaMinutes,
  };
}

class PrayerTimeResult {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  PrayerTimeResult({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });
}

class NextPrayerInfo {
  final String nameAr;
  final DateTime time;
  final Duration remaining;
  final double progress;

  NextPrayerInfo({
    required this.nameAr,
    required this.time,
    required this.remaining,
    required this.progress,
  });
}

class PrayerCalculationService {
  static PrayerTimeResult calculateTimesByCoordinates({
    required double lat,
    required double lng,
    required DateTime date,
    double timeZone = 1.0, // UTC+1 for Algeria throughout the year
    CalculationMethod method = CalculationMethod.algeria,
    JuristicMethod juristic = JuristicMethod.standard,
    PrayerAdjustments adjustments = const PrayerAdjustments(),
  }) {
    final int year = date.year;
    final int month = date.month;
    final int day = date.day;

    double jd = _julianDate(year, month, day) - (lng / (15.0 * 24.0));

    final double d = jd - 2451545.0;
    final double g = _fixAngle(357.529 + 0.98560028 * d);
    final double q = _fixAngle(280.459 + 0.98564736 * d);
    final double l = _fixAngle(q + 1.915 * sin(_radians(g)) + 0.020 * sin(_radians(2 * g)));
    final double e = 23.439 - 0.00000036 * d;
    final double ra = _degrees(atan2(cos(_radians(e)) * sin(_radians(l)), cos(_radians(l)))) / 15.0;
    final double decl = _degrees(asin(sin(_radians(e)) * sin(_radians(l))));
    final double eqt = (q / 15.0) - _fixHour(ra);

    final double noon = _fixHour(12.0 + timeZone - (lng / 15.0) - eqt);

    const double sunAlt = -0.833;
    final double sunriseHour = noon - _sunAngleHour(sunAlt, lat, decl);
    final double sunsetHour = noon + _sunAngleHour(sunAlt, lat, decl);

    final double fajrHour = noon - _sunAngleHour(-method.fajrAngle, lat, decl);
    
    double ishaHour;
    if (method == CalculationMethod.makkah) {
      // Umm al-Qura: 90 mins after sunset
      ishaHour = sunsetHour + 1.5;
    } else {
      ishaHour = noon + _sunAngleHour(-method.ishaAngle, lat, decl);
    }

    final double shadowFactor = (juristic == JuristicMethod.hanafi) ? 2.0 : 1.0;
    final double asrAlt = _degrees(atan(1.0 / (shadowFactor + tan(_radians((lat - decl).abs())))));
    final double asrHour = noon + _sunAngleHour(asrAlt, lat, decl);

    return PrayerTimeResult(
      fajr: _hoursToDateTime(date, fajrHour).add(Duration(minutes: adjustments.fajrMinutes)),
      sunrise: _hoursToDateTime(date, sunriseHour).add(Duration(minutes: adjustments.sunriseMinutes)),
      dhuhr: _hoursToDateTime(date, noon).add(Duration(minutes: adjustments.dhuhrMinutes)),
      asr: _hoursToDateTime(date, asrHour).add(Duration(minutes: adjustments.asrMinutes)),
      maghrib: _hoursToDateTime(date, sunsetHour).add(Duration(minutes: adjustments.maghribMinutes)),
      isha: _hoursToDateTime(date, ishaHour).add(Duration(minutes: adjustments.ishaMinutes)),
    );
  }

  static PrayerTimeResult calculateTimes({
    required Wilaya wilaya,
    required DateTime date,
    double timeZone = 1.0,
    CalculationMethod method = CalculationMethod.algeria,
    JuristicMethod juristic = JuristicMethod.standard,
    PrayerAdjustments adjustments = const PrayerAdjustments(),
  }) {
    double effectiveTz = timeZone;
    CalculationMethod effectiveMethod = method;

    if (wilaya.code >= 1000) {
      final city = WorldCitiesData.getCityByCode(wilaya.code);
      if (city != null) {
        effectiveTz = (timeZone != 1.0) ? timeZone : city.timeZone;
        if (method == CalculationMethod.algeria) {
          effectiveMethod = CalculationMethod.values.firstWhere(
            (m) => m.id == city.calculationMethod,
            orElse: () => CalculationMethod.mwl,
          );
        }
      } else {
        effectiveTz = (timeZone != 1.0) ? timeZone : (DateTime.now().timeZoneOffset.inMinutes / 60.0);
      }
    }

    return calculateTimesByCoordinates(
      lat: wilaya.latitude,
      lng: wilaya.longitude,
      date: date,
      timeZone: effectiveTz,
      method: effectiveMethod,
      juristic: juristic,
      adjustments: adjustments,
    );
  }

  static PrayerTimeResult calculateTimesForCommune({
    required Commune commune,
    required DateTime date,
    double timeZone = 1.0,
    CalculationMethod method = CalculationMethod.algeria,
    JuristicMethod juristic = JuristicMethod.standard,
    PrayerAdjustments adjustments = const PrayerAdjustments(),
  }) {
    return calculateTimesByCoordinates(
      lat: commune.latitude,
      lng: commune.longitude,
      date: date,
      timeZone: timeZone,
      method: method,
      juristic: juristic,
      adjustments: adjustments,
    );
  }

  static NextPrayerInfo getNextPrayer(PrayerTimeResult times, DateTime now) {
    final prayers = [
      MapEntry("الفجر", times.fajr),
      MapEntry("الشروق", times.sunrise),
      MapEntry("الظهر", times.dhuhr),
      MapEntry("العصر", times.asr),
      MapEntry("المغرب", times.maghrib),
      MapEntry("العشاء", times.isha),
    ];

    for (int i = 0; i < prayers.length; i++) {
      if (now.isBefore(prayers[i].value)) {
        final prevTime = i == 0 ? times.isha.subtract(const Duration(days: 1)) : prayers[i - 1].value;
        final totalDuration = prayers[i].value.difference(prevTime).inSeconds;
        final elapsed = now.difference(prevTime).inSeconds;
        final progress = (elapsed / totalDuration).clamp(0.0, 1.0);

        return NextPrayerInfo(
          nameAr: prayers[i].key,
          time: prayers[i].value,
          remaining: prayers[i].value.difference(now),
          progress: progress,
        );
      }
    }

    final tomorrowFajr = times.fajr.add(const Duration(days: 1));
    final totalDuration = tomorrowFajr.difference(times.isha).inSeconds;
    final elapsed = now.difference(times.isha).inSeconds;

    return NextPrayerInfo(
      nameAr: "الفجر",
      time: tomorrowFajr,
      remaining: tomorrowFajr.difference(now),
      progress: (elapsed / totalDuration).clamp(0.0, 1.0),
    );
  }

  static double _julianDate(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() + (30.6001 * (month + 1)).floor() + day + b - 1524.5;
  }

  static double _sunAngleHour(double angle, double lat, double decl) {
    final double cosH = (sin(_radians(angle)) - sin(_radians(lat)) * sin(_radians(decl))) /
        (cos(_radians(lat)) * cos(_radians(decl)));
    if (cosH > 1.0) return 0.0;
    if (cosH < -1.0) return 12.0;
    return _degrees(acos(cosH)) / 15.0;
  }

  static double _radians(double degrees) => degrees * (pi / 180.0);
  static double _degrees(double radians) => radians * (180.0 / pi);
  static double _fixAngle(double a) => a - 360.0 * (a / 360.0).floor();
  static double _fixHour(double a) => a - 24.0 * (a / 24.0).floor();

  static DateTime _hoursToDateTime(DateTime date, double hours) {
    int totalMinutes = (hours * 60).round();
    int h = (totalMinutes ~/ 60) % 24;
    int m = totalMinutes % 60;
    return DateTime(date.year, date.month, date.day, h, m);
  }
}

class PrayerService {
  static CalculationMethod activeMethod = CalculationMethod.algeria;
  static JuristicMethod activeJuristic = JuristicMethod.standard;
  static PrayerAdjustments activeAdjustments = const PrayerAdjustments();

  // Mosque Iqamah delays (minutes after adhan)
  static const Map<String, int> defaultIqamahDelays = {
    'fajr': 25,
    'dhuhr': 15,
    'asr': 15,
    'maghrib': 10,
    'isha': 15,
  };

  static Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final methodStr = prefs.getString('calculation_method') ?? 'algeria';
      final juristicStr = prefs.getString('juristic_method') ?? 'standard';

      activeMethod = CalculationMethod.values.firstWhere(
        (m) => m.id == methodStr,
        orElse: () => CalculationMethod.algeria,
      );

      activeJuristic = JuristicMethod.values.firstWhere(
        (j) => j.id == juristicStr,
        orElse: () => JuristicMethod.standard,
      );

      activeAdjustments = PrayerAdjustments(
        fajrMinutes: prefs.getInt('adj_fajr') ?? 0,
        sunriseMinutes: prefs.getInt('adj_sunrise') ?? 0,
        dhuhrMinutes: prefs.getInt('adj_dhuhr') ?? 0,
        asrMinutes: prefs.getInt('adj_asr') ?? 0,
        maghribMinutes: prefs.getInt('adj_maghrib') ?? 0,
        ishaMinutes: prefs.getInt('adj_isha') ?? 0,
      );
    } catch (_) {}
  }

  static Map<String, String> calculateTimesForWilaya(
    Wilaya wilaya,
    DateTime date, {
    CalculationMethod? method,
    JuristicMethod? juristic,
    PrayerAdjustments? adjustments,
  }) {
    final res = PrayerCalculationService.calculateTimes(
      wilaya: wilaya,
      date: date,
      method: method ?? activeMethod,
      juristic: juristic ?? activeJuristic,
      adjustments: adjustments ?? activeAdjustments,
    );
    String formatTime(DateTime dt) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return "$h:$m";
    }

    return {
      "fajr": formatTime(res.fajr),
      "sunrise": formatTime(res.sunrise),
      "dhuhr": formatTime(res.dhuhr),
      "asr": formatTime(res.asr),
      "maghrib": formatTime(res.maghrib),
      "isha": formatTime(res.isha),
      "hijri_date": _calculateHijri(date),
      "gregorian_date": _formatArabicDate(date),
    };
  }

  static Map<String, String> calculateTimesForCommune(
    Commune commune,
    DateTime date, {
    CalculationMethod? method,
    JuristicMethod? juristic,
    PrayerAdjustments? adjustments,
  }) {
    final res = PrayerCalculationService.calculateTimesForCommune(
      commune: commune,
      date: date,
      method: method ?? activeMethod,
      juristic: juristic ?? activeJuristic,
      adjustments: adjustments ?? activeAdjustments,
    );
    String formatTime(DateTime dt) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return "$h:$m";
    }

    return {
      "fajr": formatTime(res.fajr),
      "sunrise": formatTime(res.sunrise),
      "dhuhr": formatTime(res.dhuhr),
      "asr": formatTime(res.asr),
      "maghrib": formatTime(res.maghrib),
      "isha": formatTime(res.isha),
      "hijri_date": _calculateHijri(date),
      "gregorian_date": _formatArabicDate(date),
    };
  }

  static PrayerTimeResult calculateTimes({
    required Wilaya wilaya,
    required DateTime date,
    double timeZone = 1.0,
    CalculationMethod? method,
    JuristicMethod? juristic,
    PrayerAdjustments? adjustments,
  }) => PrayerCalculationService.calculateTimes(
    wilaya: wilaya,
    date: date,
    timeZone: timeZone,
    method: method ?? activeMethod,
    juristic: juristic ?? activeJuristic,
    adjustments: adjustments ?? activeAdjustments,
  );

  static PrayerTimeResult calculateTimesForCommuneResult({
    required Commune commune,
    required DateTime date,
    double timeZone = 1.0,
    CalculationMethod? method,
    JuristicMethod? juristic,
    PrayerAdjustments? adjustments,
  }) => PrayerCalculationService.calculateTimesForCommune(
    commune: commune,
    date: date,
    timeZone: timeZone,
    method: method ?? activeMethod,
    juristic: juristic ?? activeJuristic,
    adjustments: adjustments ?? activeAdjustments,
  );

  static NextPrayerInfo getNextPrayer(PrayerTimeResult times, DateTime now) =>
      PrayerCalculationService.getNextPrayer(times, now);

  static String getFormattedGregorianDate(DateTime date, [String? lang]) {
    final language = lang ?? LanguageService.languageCode;
    if (language == 'en') {
      const days = [
        "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
      ];
      const months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
      ];
      final dayName = days[date.weekday - 1];
      final monthName = months[date.month - 1];
      return "$dayName, $monthName ${date.day}, ${date.year}";
    } else if (language == 'fr') {
      const days = [
        "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"
      ];
      const months = [
        "janvier", "février", "mars", "avril", "mai", "juin",
        "juillet", "août", "septembre", "octobre", "novembre", "décembre"
      ];
      final dayName = days[date.weekday - 1];
      final monthName = months[date.month - 1];
      return "$dayName, ${date.day} $monthName ${date.year}";
    }
    return _formatArabicDate(date);
  }

  static String getFormattedHijriDate(DateTime date, [String? lang]) {
    final language = lang ?? LanguageService.languageCode;
    int y = date.year;
    int m = date.month;
    int d = date.day;
    if (m < 3) {
      y -= 1;
      m += 12;
    }
    double a = (y / 100.0).floorToDouble();
    double b = 2 - a + (a / 4.0).floorToDouble();
    double jd = (365.25 * (y + 4716)).floorToDouble() + (30.6001 * (m + 1)).floorToDouble() + d + b - 1524.5;
    double l = jd - 1948440 + 10632;
    double n = ((l - 1) / 10631).floorToDouble();
    l = l - 10631 * n + 354;
    double j = ((10985 - l) / 5316).floorToDouble() * ((50 * l) / 17719).floorToDouble() +
        (l / 5670).floorToDouble() * ((43 * l) / 15238).floorToDouble();
    l = l - ((30 - j) / 15).floorToDouble() * ((17719 * j) / 50).floorToDouble() -
        (j / 16).floorToDouble() * ((15238 * j) / 43).floorToDouble() + 29;
    int hm = ((24 * l) / 709).floor();
    int hd = (l - ((709 * hm) / 24).floor()).toInt();
    int hy = (30 * n + j - 30).toInt();

    if (language == 'en') {
      const hijriMonthsEn = [
        "Muharram", "Safar", "Rabi' al-Awwal", "Rabi' al-Thani", "Jumada al-Ula", "Jumada al-Akhirah",
        "Rajab", "Sha'ban", "Ramadan", "Shawwal", "Dhu al-Qi'dah", "Dhu al-Hijjah"
      ];
      final hMonthName = hijriMonthsEn[(hm - 1).clamp(0, 11)];
      return "$hd $hMonthName $hy AH";
    } else if (language == 'fr') {
      const hijriMonthsFr = [
        "Mouharram", "Safar", "Rabi' al-Awwal", "Rabi' al-Thani", "Joumada al-Oula", "Joumada al-Akhira",
        "Rajab", "Chaabane", "Ramadan", "Chawwal", "Dhou al-Qi'da", "Dhou al-Hijja"
      ];
      final hMonthName = hijriMonthsFr[(hm - 1).clamp(0, 11)];
      return "$hd $hMonthName $hy H";
    }

    return _calculateHijri(date);
  }

  static String _formatArabicDate(DateTime date) {
    const days = [
      "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت", "الأحد"
    ];
    const months = [
      "جانفي", "فيفري", "مارس", "أفريل", "ماي", "جوان",
      "جويلية", "أوت", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return "$dayName، ${date.day} $monthName ${date.year}";
  }

  static String _calculateHijri(DateTime date) {
    int y = date.year;
    int m = date.month;
    int d = date.day;
    if (m < 3) {
      y -= 1;
      m += 12;
    }
    double a = (y / 100.0).floorToDouble();
    double b = 2 - a + (a / 4.0).floorToDouble();
    double jd = (365.25 * (y + 4716)).floorToDouble() + (30.6001 * (m + 1)).floorToDouble() + d + b - 1524.5;
    double l = jd - 1948440 + 10632;
    double n = ((l - 1) / 10631).floorToDouble();
    l = l - 10631 * n + 354;
    double j = ((10985 - l) / 5316).floorToDouble() * ((50 * l) / 17719).floorToDouble() +
        (l / 5670).floorToDouble() * ((43 * l) / 15238).floorToDouble();
    l = l - ((30 - j) / 15).floorToDouble() * ((17719 * j) / 50).floorToDouble() -
        (j / 16).floorToDouble() * ((15238 * j) / 43).floorToDouble() + 29;
    int hm = ((24 * l) / 709).floor();
    int hd = (l - ((709 * hm) / 24).floor()).toInt();
    int hy = (30 * n + j - 30).toInt();

    const hijriMonths = [
      "محرم", "صفر", "ربيع الأول", "ربيع الثاني", "جمادى الأولى", "جمادى الآخرة",
      "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"
    ];
    final hMonthName = hijriMonths[(hm - 1).clamp(0, 11)];
    return "$hd $hMonthName $hy هـ";
  }
}

