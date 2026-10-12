import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/algeria_wilayas.dart';
import '../data/algeria_communes.dart';
import '../services/theme_service.dart';
import '../services/location_service.dart';
import '../services/app_feedback.dart';
import '../services/language_service.dart';

class MosquePlaceInfo {
  final String name;
  final String nameFr;
  final String wilayaName;
  final String wilayaNameFr;
  final String description;
  final String descriptionFr;
  final String historicalNote;
  final String historicalNoteFr;
  final double latitude;
  final double longitude;

  const MosquePlaceInfo({
    required this.name,
    this.nameFr = '',
    required this.wilayaName,
    this.wilayaNameFr = '',
    required this.description,
    this.descriptionFr = '',
    required this.historicalNote,
    this.historicalNoteFr = '',
    required this.latitude,
    required this.longitude,
  });

  String getName(String lang) => (lang != 'ar' && nameFr.isNotEmpty) ? nameFr : name;
  String getWilaya(String lang) => (lang != 'ar' && wilayaNameFr.isNotEmpty) ? wilayaNameFr : wilayaName;
  String getDescription(String lang) => (lang != 'ar' && descriptionFr.isNotEmpty) ? descriptionFr : description;
  String getHistoricalNote(String lang) => (lang != 'ar' && historicalNoteFr.isNotEmpty) ? historicalNoteFr : historicalNote;
}

class NearbyMosquesScreen extends StatefulWidget {
  final Wilaya currentWilaya;
  final Commune? currentCommune;

  const NearbyMosquesScreen({
    super.key,
    required this.currentWilaya,
    this.currentCommune,
  });

  @override
  State<NearbyMosquesScreen> createState() => _NearbyMosquesScreenState();
}

class _NearbyMosquesScreenState extends State<NearbyMosquesScreen> {
  bool _isLocating = false;
  double? _userLat;
  double? _userLng;
  String? _customLocationStatus;

  static const List<MosquePlaceInfo> grandAlgerianMosques = [
    MosquePlaceInfo(
      name: "جامع الجزائر (الجامع الأعظم)",
      nameFr: "Grande Mosquée d'Alger (Djamaâ El-Djazaïr)",
      wilayaName: "الجزائر العاصمة - المحمدية",
      wilayaNameFr: "Alger - Mohammadia",
      description: "ثالث أكبر مسجد في العالم وأكبر مسجد في إفريقيا بمئذنة شاهقة تبلغ 265 متراً.",
      descriptionFr: "3e plus grande mosquée au monde avec un minaret majestueux culminant à 265 mètres.",
      historicalNote: "صرح إسلامي حضاري شامخ يتسع لـ 120 ألف مصلٍ، ويضم مكتبة ضخمة وداراً للقرآن.",
      historicalNoteFr: "Monument islamique remarquable accueillant 120 000 fidèles, avec grande bibliothèque et دار القرآن.",
      latitude: 36.7344,
      longitude: 3.1417,
    ),
    MosquePlaceInfo(
      name: "جامع كتشاوة التاريخي",
      nameFr: "Mosquée Historique Ketchaoua",
      wilayaName: "الجزائر العاصمة - القصبة العتيقة",
      wilayaNameFr: "Alger - Casbah",
      description: "تحفة معمارية إسلامية وأثرية شيدت في العهد العثماني عام 1612م.",
      descriptionFr: "Chef-d'œuvre architectural islamique et ottoman érigé en 1612.",
      historicalNote: "رمز لصمود الهوية الجزائرية، عاد مسجداً شامخاً مع فجر الاستقلال الوطني.",
      historicalNoteFr: "Symbole de la résistance et de l'identité algérienne, redevenue mosquée à l'indépendance.",
      latitude: 36.7850,
      longitude: 3.0610,
    ),
    MosquePlaceInfo(
      name: "مسجد الأمير عبد القادر",
      nameFr: "Mosquée Émir Abdelkader",
      wilayaName: "قسنطينة - مدينة الجسور",
      wilayaNameFr: "Constantine - Ville des Ponts",
      description: "أكبر مساجد الشرق الجزائري وواحد من أجمل الصروح الإسلامية بنقوشه وزخارفه.",
      descriptionFr: "Plus grande mosquée de l'Est algérien avec ses sublimes sculptures et décorations.",
      historicalNote: "يتسع لـ 15 ألف مصلٍ ويحتضن أول جامعة إسلامية جزائرية حديثة.",
      historicalNoteFr: "Capacité de 15 000 fidèles et abrite la première université islamique moderne.",
      latitude: 36.3475,
      longitude: 6.6042,
    ),
    MosquePlaceInfo(
      name: "مسجد عبد الحميد بن باديس",
      nameFr: "Mosquée Abdelhamid Ben Badis",
      wilayaName: "وهران - الباهية",
      wilayaNameFr: "Oran - El Bahia",
      description: "صرح إسلامي مهيب بمئذنة أندلسية ترتفع 104 أمتار ومظهر معماري مغاربي فريد.",
      descriptionFr: "Édifice prestigieux avec minaret andalou de 104 mètres d'architecture maghrébine.",
      historicalNote: "يتسع لأكثر من 25 ألف مصلٍ وسمي تيمناً برائد النهضة الجزائرية.",
      historicalNoteFr: "Accueille plus de 25 000 fidèles, nommée en hommage au grand réformateur algérien.",
      latitude: 35.6987,
      longitude: -0.6349,
    ),
    MosquePlaceInfo(
      name: "مسجد سيدي بومدين الغوث",
      nameFr: "Mosquée Sidi Boumediene",
      wilayaName: "تلمسان - العباد",
      wilayaNameFr: "Tlemcen - El Eubbad",
      description: "مسجد تاريخي أندلسي بني سنة 739هـ (1339م) بفسيفساء وزخارف بديعة.",
      descriptionFr: "Mosquée historique andalouse bâtie en 739 H (1339) avec faïences et arabesques raffinées.",
      historicalNote: "من أقدس المعالم التاريخية والتراثية العريقة في الغرب الجزائري.",
      historicalNoteFr: "Haut lieu de spiritualité et du patrimoine islamique en Algérie occidentale.",
      latitude: 34.8789,
      longitude: -1.2981,
    ),
    MosquePlaceInfo(
      name: "مسجد أول نوفمبر 1954",
      nameFr: "Mosquée 1er Novembre 1954",
      wilayaName: "باتنة - عاصمة الأوراس",
      wilayaNameFr: "Batna - Capitale des Aurès",
      description: "من أكبر مساجد الجزائر يتسع لأكثر من 30 ألف مصلٍ بهندسة معمارية رائعة.",
      descriptionFr: "Parmi les plus vastes mosquées d'Algérie avec plus de 30 000 fidèles.",
      historicalNote: "شيد تخليداً للثورة التحريرية الجزائرية ومحطة إشعاع ديني وتربوي بارزة.",
      historicalNoteFr: "Édifiée en mémoire de la glorieuse révolution de libération nationale.",
      latitude: 35.5562,
      longitude: 6.1741,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _userLat = widget.currentCommune?.latitude ?? widget.currentWilaya.latitude;
    _userLng = widget.currentCommune?.longitude ?? widget.currentWilaya.longitude;
  }

  Future<void> _detectExactLocation() async {
    setState(() => _isLocating = true);
    final res = await LocationService.detectLocation();
    if (mounted) {
      final isAr = LanguageService.languageCode == 'ar';
      setState(() {
        _isLocating = false;
        if (res != null) {
          _userLat = res.latitude;
          _userLng = res.longitude;
          final cName = isAr ? res.commune.nameAr : res.commune.nameFr;
          final wName = isAr ? res.wilaya.nameAr : res.wilaya.nameFr;
          _customLocationStatus = "$cName, $wName (${res.source})";
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF064E3B),
          content: Text(
            isAr
                ? "تم تحديد موقعك بدقة: ${_userLat?.toStringAsFixed(4)}, ${_userLng?.toStringAsFixed(4)}"
                : "Position GPS détectée avec succès: ${_userLat?.toStringAsFixed(4)}, ${_userLng?.toStringAsFixed(4)}",
          ),
        ),
      );
    }
  }

  Future<void> _openMapSearch(String query, {double? destLat, double? destLng}) async {
    AppFeedback.tap();
    final lat = _userLat ?? widget.currentWilaya.latitude;
    final lng = _userLng ?? widget.currentWilaya.longitude;

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF064E3B),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(Icons.map, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text("${LanguageService.tr('nearby_mosques_searching_map')}$query... 🗺️"),
            ),
          ],
        ),
      ),
    );

    Uri mapUri;
    if (destLat != null && destLng != null) {
      // Direct navigation to specific coordinates
      mapUri = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng");
    } else {
      // Nearby search centered around current position
      mapUri = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}&query_place_id=&center=$lat,$lng");
    }

    try {
      bool launched = await launchUrl(mapUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        launched = await launchUrl(mapUri, mode: LaunchMode.platformDefault);
      }
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF991B1B),
            content: Text(
              LanguageService.languageCode == 'ar'
                  ? "تعذر فتح تطبيق الخرائط. يرجى التأكد من توفر متصفح أو Google Maps."
                  : "Impossible d'ouvrir Google Maps. Veuillez vérifier l'application de navigation.",
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF991B1B),
            content: Text("Error: $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.currentLocale,
      builder: (context, locale, _) {
        final lang = locale.languageCode;
        final isAr = lang == 'ar';

        final currentLocationText = _customLocationStatus ??
            (isAr
                ? "${widget.currentCommune?.nameAr ?? widget.currentWilaya.nameAr} - ${widget.currentWilaya.nameAr}"
                : "${widget.currentCommune?.nameFr ?? widget.currentWilaya.nameFr} - ${widget.currentWilaya.nameFr}");

        return ValueListenableBuilder<AppThemeColor>(
          valueListenable: ThemeService.currentTheme,
          builder: (context, theme, _) {
            return Scaffold(
              backgroundColor: theme.background,
              appBar: AppBar(
                backgroundColor: theme.darkPrimary,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  LanguageService.tr('nearby_mosques_page_title'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Location status card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.accent.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.my_location, color: theme.accent, size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${LanguageService.tr('nearby_mosques_loc_status_prefix')}$currentLocationText",
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (_isLocating)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            else
                              TextButton.icon(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF10B981)),
                                label: Text(
                                  LanguageService.tr('nearby_mosques_gps_refresh'),
                                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 12),
                                ),
                                onPressed: _detectExactLocation,
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF065F46),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.mosque, color: Colors.white, size: 18),
                                label: Text(
                                  LanguageService.tr('nearby_mosques_near_btn'),
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () => _openMapSearch(isAr ? "مساجد ومصليات" : "Mosquées"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.restaurant, color: Colors.white, size: 18),
                                label: Text(
                                  LanguageService.tr('nearby_mosques_halal_btn'),
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () => _openMapSearch(isAr ? "مطاعم حلال ومأكولات" : "Restaurants Halal"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.account_balance, color: theme.accent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          LanguageService.tr('nearby_mosques_grand_title'),
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Grand Mosques List
                  ...grandAlgerianMosques.map((mosque) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  mosque.getName(lang),
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: theme.accent.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  mosque.getWilaya(lang),
                                  style: TextStyle(color: theme.accent, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mosque.getDescription(lang),
                            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.4),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.history_edu, color: Color(0xFF94A3B8), size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  mosque.getHistoricalNote(lang),
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.accent,
                                side: BorderSide(color: theme.accent),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.directions, size: 16),
                              label: Text(LanguageService.tr('nearby_mosques_dir_btn'), style: const TextStyle(fontSize: 12)),
                              onPressed: () => _openMapSearch(
                                mosque.getName(lang),
                                destLat: mosque.latitude,
                                destLng: mosque.longitude,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                  // Mosque Etiquette Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFF10B981), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              LanguageService.tr('nearby_mosques_etiquette_title'),
                              style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "« ${LanguageService.tr('nearby_mosques_etiquette_hadith')} »",
                          style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "• ${LanguageService.tr('nearby_mosques_etiquette_1')}\n"
                          "• ${LanguageService.tr('nearby_mosques_etiquette_2')}\n"
                          "• ${LanguageService.tr('nearby_mosques_etiquette_3')}\n"
                          "• ${LanguageService.tr('nearby_mosques_etiquette_4')}",
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
