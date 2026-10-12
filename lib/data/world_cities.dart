import 'dart:math';
import 'algeria_wilayas.dart';

class WorldCity {
  final int code; // Codes >= 1000
  final String nameAr;
  final String nameEn;
  final String nameFr;
  final String countryAr;
  final String countryEn;
  final String countryFr;
  final double latitude;
  final double longitude;
  final double timeZone;
  final String calculationMethod;

  const WorldCity({
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.nameFr,
    required this.countryAr,
    required this.countryEn,
    required this.countryFr,
    required this.latitude,
    required this.longitude,
    required this.timeZone,
    this.calculationMethod = 'mwl',
  });

  String getDisplayName(String langCode) {
    if (langCode == 'en') return "$nameEn, $countryEn";
    if (langCode == 'fr') return "$nameFr, $countryFr";
    return "$nameAr، $countryAr";
  }

  Wilaya toWilaya() {
    return Wilaya(
      code: code,
      nameAr: "$nameAr ($countryAr)",
      nameFr: "$nameFr ($countryFr)",
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class WorldCitiesData {
  static const List<WorldCity> cities = [
    // Two Holy Sanctuaries & Levant
    WorldCity(
      code: 1001,
      nameAr: "مكة المكرمة",
      nameEn: "Makkah",
      nameFr: "La Mecque",
      countryAr: "المملكة العربية السعودية",
      countryEn: "Saudi Arabia",
      countryFr: "Arabie Saoudite",
      latitude: 21.4225,
      longitude: 39.8262,
      timeZone: 3.0,
      calculationMethod: 'makkah',
    ),
    WorldCity(
      code: 1002,
      nameAr: "المدينة المنورة",
      nameEn: "Madinah",
      nameFr: "Médine",
      countryAr: "المملكة العربية السعودية",
      countryEn: "Saudi Arabia",
      countryFr: "Arabie Saoudite",
      latitude: 24.5247,
      longitude: 39.5692,
      timeZone: 3.0,
      calculationMethod: 'makkah',
    ),
    WorldCity(
      code: 1003,
      nameAr: "القدس الشريف",
      nameEn: "Jerusalem",
      nameFr: "Jérusalem",
      countryAr: "فلسطين",
      countryEn: "Palestine",
      countryFr: "Palestine",
      latitude: 31.7683,
      longitude: 35.2137,
      timeZone: 2.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1004,
      nameAr: "الرياض",
      nameEn: "Riyadh",
      nameFr: "Riyad",
      countryAr: "المملكة العربية السعودية",
      countryEn: "Saudi Arabia",
      countryFr: "Arabie Saoudite",
      latitude: 24.7136,
      longitude: 46.6753,
      timeZone: 3.0,
      calculationMethod: 'makkah',
    ),

    // North Africa & Middle East
    WorldCity(
      code: 1005,
      nameAr: "القاهرة",
      nameEn: "Cairo",
      nameFr: "Le Caire",
      countryAr: "مصر",
      countryEn: "Egypt",
      countryFr: "Égypte",
      latitude: 30.0444,
      longitude: 31.2357,
      timeZone: 2.0,
      calculationMethod: 'egypt',
    ),
    WorldCity(
      code: 1006,
      nameAr: "تونس العاصمة",
      nameEn: "Tunis",
      nameFr: "Tunis",
      countryAr: "تونس",
      countryEn: "Tunisia",
      countryFr: "Tunisie",
      latitude: 36.8065,
      longitude: 10.1815,
      timeZone: 1.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1007,
      nameAr: "الرباط",
      nameEn: "Rabat",
      nameFr: "Rabat",
      countryAr: "المغرب",
      countryEn: "Morocco",
      countryFr: "Maroc",
      latitude: 34.0209,
      longitude: -6.8416,
      timeZone: 1.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1008,
      nameAr: "الدار البيضاء",
      nameEn: "Casablanca",
      nameFr: "Casablanca",
      countryAr: "المغرب",
      countryEn: "Morocco",
      countryFr: "Maroc",
      latitude: 33.5731,
      longitude: -7.5898,
      timeZone: 1.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1009,
      nameAr: "طرابلس",
      nameEn: "Tripoli",
      nameFr: "Tripoli",
      countryAr: "ليبيا",
      countryEn: "Libya",
      countryFr: "Libye",
      latitude: 32.8872,
      longitude: 13.1913,
      timeZone: 2.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1010,
      nameAr: "دبي",
      nameEn: "Dubai",
      nameFr: "Dubaï",
      countryAr: "الإمارات العربية المتحدة",
      countryEn: "United Arab Emirates",
      countryFr: "Émirats Arabes Unis",
      latitude: 25.2048,
      longitude: 55.2708,
      timeZone: 4.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1011,
      nameAr: "أبوظبي",
      nameEn: "Abu Dhabi",
      nameFr: "Abou Dabi",
      countryAr: "الإمارات العربية المتحدة",
      countryEn: "United Arab Emirates",
      countryFr: "Émirats Arabes Unis",
      latitude: 24.4539,
      longitude: 54.3773,
      timeZone: 4.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1012,
      nameAr: "الدوحة",
      nameEn: "Doha",
      nameFr: "Doha",
      countryAr: "قطر",
      countryEn: "Qatar",
      countryFr: "Qatar",
      latitude: 25.2854,
      longitude: 51.5310,
      timeZone: 3.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1013,
      nameAr: "إسطنبول",
      nameEn: "Istanbul",
      nameFr: "Istanbul",
      countryAr: "تركيا",
      countryEn: "Turkey",
      countryFr: "Turquie",
      latitude: 41.0082,
      longitude: 28.9784,
      timeZone: 3.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1014,
      nameAr: "عَمّان",
      nameEn: "Amman",
      nameFr: "Amman",
      countryAr: "الأردن",
      countryEn: "Jordan",
      countryFr: "Jordanie",
      latitude: 31.9454,
      longitude: 35.9284,
      timeZone: 3.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1015,
      nameAr: "بغداد",
      nameEn: "Baghdad",
      nameFr: "Bagdad",
      countryAr: "العراق",
      countryEn: "Iraq",
      countryFr: "Irak",
      latitude: 33.3152,
      longitude: 44.3661,
      timeZone: 3.0,
      calculationMethod: 'mwl',
    ),

    // Europe
    WorldCity(
      code: 1020,
      nameAr: "باريس",
      nameEn: "Paris",
      nameFr: "Paris",
      countryAr: "فرنسا",
      countryEn: "France",
      countryFr: "France",
      latitude: 48.8566,
      longitude: 2.3522,
      timeZone: 1.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1021,
      nameAr: "مارسيليا",
      nameEn: "Marseille",
      nameFr: "Marseille",
      countryAr: "فرنسا",
      countryEn: "France",
      countryFr: "France",
      latitude: 43.2965,
      longitude: 5.3698,
      timeZone: 1.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1022,
      nameAr: "ليون",
      nameEn: "Lyon",
      nameFr: "Lyon",
      countryAr: "فرنسا",
      countryEn: "France",
      countryFr: "France",
      latitude: 45.7640,
      longitude: 4.8357,
      timeZone: 1.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1023,
      nameAr: "لندن",
      nameEn: "London",
      nameFr: "Londres",
      countryAr: "المملكة المتحدة",
      countryEn: "United Kingdom",
      countryFr: "Royaume-Uni",
      latitude: 51.5074,
      longitude: -0.1278,
      timeZone: 0.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1024,
      nameAr: "برلين",
      nameEn: "Berlin",
      nameFr: "Berlin",
      countryAr: "ألمانيا",
      countryEn: "Germany",
      countryFr: "Allemagne",
      latitude: 52.5200,
      longitude: 13.4050,
      timeZone: 1.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1025,
      nameAr: "بروكسل",
      nameEn: "Brussels",
      nameFr: "Bruxelles",
      countryAr: "بلجيكا",
      countryEn: "Belgium",
      countryFr: "Belgique",
      latitude: 50.8503,
      longitude: 4.3517,
      timeZone: 1.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1026,
      nameAr: "مدريد",
      nameEn: "Madrid",
      nameFr: "Madrid",
      countryAr: "إسبانيا",
      countryEn: "Spain",
      countryFr: "Espagne",
      latitude: 40.4168,
      longitude: -3.7038,
      timeZone: 1.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1027,
      nameAr: "روما",
      nameEn: "Rome",
      nameFr: "Rome",
      countryAr: "إيطاليا",
      countryEn: "Italy",
      countryFr: "Italie",
      latitude: 41.9028,
      longitude: 12.4964,
      timeZone: 1.0,
      calculationMethod: 'mwl',
    ),

    // Americas
    WorldCity(
      code: 1030,
      nameAr: "نيويورك",
      nameEn: "New York",
      nameFr: "New York",
      countryAr: "الولايات المتحدة الأمريكية",
      countryEn: "United States",
      countryFr: "États-Unis",
      latitude: 40.7128,
      longitude: -74.0060,
      timeZone: -5.0,
      calculationMethod: 'isna',
    ),
    WorldCity(
      code: 1031,
      nameAr: "واشنطن العاصمة",
      nameEn: "Washington D.C.",
      nameFr: "Washington D.C.",
      countryAr: "الولايات المتحدة الأمريكية",
      countryEn: "United States",
      countryFr: "États-Unis",
      latitude: 38.9072,
      longitude: -77.0369,
      timeZone: -5.0,
      calculationMethod: 'isna',
    ),
    WorldCity(
      code: 1032,
      nameAr: "مونتريال",
      nameEn: "Montreal",
      nameFr: "Montréal",
      countryAr: "كندا",
      countryEn: "Canada",
      countryFr: "Canada",
      latitude: 45.5017,
      longitude: -73.5673,
      timeZone: -5.0,
      calculationMethod: 'isna',
    ),
    WorldCity(
      code: 1033,
      nameAr: "تورونتو",
      nameEn: "Toronto",
      nameFr: "Toronto",
      countryAr: "كندا",
      countryEn: "Canada",
      countryFr: "Canada",
      latitude: 43.6532,
      longitude: -79.3832,
      timeZone: -5.0,
      calculationMethod: 'isna',
    ),

    // Asia & Australia
    WorldCity(
      code: 1040,
      nameAr: "كراتشي",
      nameEn: "Karachi",
      nameFr: "Karachi",
      countryAr: "باكستان",
      countryEn: "Pakistan",
      countryFr: "Pakistan",
      latitude: 24.8607,
      longitude: 67.0011,
      timeZone: 5.0,
      calculationMethod: 'karachi',
    ),
    WorldCity(
      code: 1041,
      nameAr: "جاكرتا",
      nameEn: "Jakarta",
      nameFr: "Jakarta",
      countryAr: "إندونيسيا",
      countryEn: "Indonesia",
      countryFr: "Indonésie",
      latitude: -6.2088,
      longitude: 106.8456,
      timeZone: 7.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1042,
      nameAr: "كوالالمبور",
      nameEn: "Kuala Lumpur",
      nameFr: "Kuala Lumpur",
      countryAr: "ماليزيا",
      countryEn: "Malaysia",
      countryFr: "Malaisie",
      latitude: 3.1390,
      longitude: 101.6869,
      timeZone: 8.0,
      calculationMethod: 'mwl',
    ),
    WorldCity(
      code: 1043,
      nameAr: "سيدني",
      nameEn: "Sydney",
      nameFr: "Sydney",
      countryAr: "أستراليا",
      countryEn: "Australia",
      countryFr: "Australie",
      latitude: -33.8688,
      longitude: 151.2093,
      timeZone: 10.0,
      calculationMethod: 'mwl',
    ),
  ];

  static WorldCity? getCityByCode(int code) {
    try {
      return cities.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  static List<WorldCity> searchCities(String query) {
    if (query.isEmpty) return cities;
    final q = query.toLowerCase().trim();
    return cities.where((c) =>
      c.nameAr.contains(q) ||
      c.nameEn.toLowerCase().contains(q) ||
      c.nameFr.toLowerCase().contains(q) ||
      c.countryAr.contains(q) ||
      c.countryEn.toLowerCase().contains(q) ||
      c.countryFr.toLowerCase().contains(q)
    ).toList();
  }

  static WorldCity findNearestCity(double userLat, double userLng) {
    WorldCity closest = cities[0];
    double minDistance = double.infinity;

    for (var c in cities) {
      double d = _calcDistance(userLat, userLng, c.latitude, c.longitude);
      if (d < minDistance) {
        minDistance = d;
        closest = c;
      }
    }
    return closest;
  }

  static double _calcDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // pi / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}

