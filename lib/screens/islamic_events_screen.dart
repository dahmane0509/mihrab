import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/prayer_service.dart';
import '../services/language_service.dart';
import '../data/algeria_wilayas.dart';

class IslamicEventItem {
  final String title;
  final String titleFr;
  final String hijriDate;
  final String hijriDateFr;
  final String description;
  final String descriptionFr;
  final String virtues;
  final String virtuesFr;
  final IconData icon;
  final Color accentColor;

  const IslamicEventItem({
    required this.title,
    this.titleFr = '',
    required this.hijriDate,
    this.hijriDateFr = '',
    required this.description,
    this.descriptionFr = '',
    required this.virtues,
    this.virtuesFr = '',
    required this.icon,
    required this.accentColor,
  });

  String getTitle(String lang) => (lang != 'ar' && titleFr.isNotEmpty) ? titleFr : title;
  String getDate(String lang) => (lang != 'ar' && hijriDateFr.isNotEmpty) ? hijriDateFr : hijriDate;
  String getDescription(String lang) => (lang != 'ar' && descriptionFr.isNotEmpty) ? descriptionFr : description;
  String getVirtues(String lang) => (lang != 'ar' && virtuesFr.isNotEmpty) ? virtuesFr : virtues;
}

class IslamicEventsScreen extends StatelessWidget {
  const IslamicEventsScreen({super.key});

  static const List<IslamicEventItem> events = [
    IslamicEventItem(
      title: "رأس السنة الهجرية الجديدة",
      titleFr: "Nouvel An Hégirien",
      hijriDate: "1 محرم",
      hijriDateFr: "1er Mouharram",
      description: "بداية العام الهجري الجديد واستحضار ذكرى هجرة النبي ﷺ من مكة إلى المدينة.",
      descriptionFr: "Début de la nouvelle année hégirienne commémorant l'Hégire du Prophète ﷺ.",
      virtues: "يستحب فيه الاستغفار وبدء العام بنوايا صالحة والإكثار من الصيام في شهر الله المحرم.",
      virtuesFr: "Multiplication des bonnes actions, repentir et jeûne durant le mois sacré de Mouharram.",
      icon: Icons.calendar_month,
      accentColor: Color(0xFF10B981),
    ),
    IslamicEventItem(
      title: "يوم عاشوراء المبارك",
      titleFr: "Jour d'Achoura Béni",
      hijriDate: "10 محرم",
      hijriDateFr: "10 Mouharram",
      description: "اليوم الذي نجى الله فيه نبيه موسى عليه السلام وقومه من فرعون.",
      descriptionFr: "Le jour où Allah sauva le Prophète Moïse (Moussa) et son peuple de Pharaon.",
      virtues: "صيامه يكفر ذنوب السنة الماضية، ويستحب صيام يوم قبله (تاسوعاء) مخالفةً لليهود.",
      virtuesFr: "Son jeûne expie les péchés de l'année précédente, recommandé de jeûner Tasou'a avec.",
      icon: Icons.brightness_high,
      accentColor: Color(0xFFF59E0B),
    ),
    IslamicEventItem(
      title: "المولد النبوي الشريف",
      titleFr: "Le Mawlid Nabawi (Naissance du Prophète)",
      hijriDate: "12 ربيع الأول",
      hijriDateFr: "12 Rabi' al-Awwal",
      description: "ذكرى ميلاد الرحمة المهداة نبينا محمد صلى الله عليه وعلى آله وصحبه وسلم.",
      descriptionFr: "Commémoration de la naissance bénie du Prophète Mohammed ﷺ.",
      virtues: "الإكثار من الصلاة والسلام على النبي ﷺ، وتدارس سيرته العطرة والتخلق بأخلاقه.",
      virtuesFr: "Multiplication des prières sur le Prophète ﷺ et méditation sur sa noble vie.",
      icon: Icons.auto_awesome,
      accentColor: Color(0xFF38BDF8),
    ),
    IslamicEventItem(
      title: "ذكرى الإسراء والمعراج",
      titleFr: "Al-Isra wal-Mi'raj",
      hijriDate: "27 رجب",
      hijriDateFr: "27 Rajab",
      description: "المعجزة الكبرى برحلة النبي ﷺ من المسجد الحرام للأقصى وعروجه للسماوات العلى.",
      descriptionFr: "Le Voyage Nocturne de la Mecque à Jérusalem puis l'Ascension Céleste.",
      virtues: "استحضار عظمة فرض الصلوات الخمس ومكانة المسجد الأقصى والخشوع في العبادات.",
      virtuesFr: "Méditation sur l'institution divine des cinq prières quotidiennes et al-Aqsa.",
      icon: Icons.star_border_purple500,
      accentColor: Color(0xFFA78BFA),
    ),
    IslamicEventItem(
      title: "ليلة النصف من شعبان",
      titleFr: "Nuit de la Mi-Cha'ban",
      hijriDate: "15 شعبان",
      hijriDateFr: "15 Cha'ban",
      description: "ليلة مباركة ارتبطت بتحويل القبلة من بيت المقدس إلى الكعبة المشرفة بمكة.",
      descriptionFr: "Nuit bénie liée au changement de direction de la Qibla vers la Kaaba.",
      virtues: "الاستغفار وطلب الرحمة والمغفرة والتسامح، وتهيئة النفس لاستقبال شهر رمضان.",
      virtuesFr: "Prière, demande de pardon et préparation spirituelle à l'accueil du Ramadan.",
      icon: Icons.nightlight_round,
      accentColor: Color(0xFF34D399),
    ),
    IslamicEventItem(
      title: "غرة شهر رمضان المبارك",
      titleFr: "1er Jour de Ramadan Béni",
      hijriDate: "1 رمضان",
      hijriDateFr: "1er Ramadan",
      description: "بداية شهر الصيام والقيام وتلاوة القرآن الكريم ومضاعفة الأجور والعتق من النار.",
      descriptionFr: "Début du mois sacré du jeûne, des prières nocturnes et de la récitation du Coran.",
      virtues: "تفتح فيه أبواب الجنان وتغلق أبواب النيران، وفيه صلاة التراويح والاعتكاف وإطعام الطعام.",
      virtuesFr: "Ouverture des portes du Paradis, prière des Tarawih et aumônes abondantes.",
      icon: Icons.mosque,
      accentColor: Color(0xFFD4AF37),
    ),
    IslamicEventItem(
      title: "ذكرى غزوة بدر الكبرى",
      titleFr: "Bataille de Badr Al-Koubra",
      hijriDate: "17 رمضان",
      hijriDateFr: "17 Ramadan",
      description: "يوم الفرقان بين الحق والباطل وأولى المعارك الفاصلة في تاريخ الإسلام.",
      descriptionFr: "Le jour du discernement (Al-Fourqan) et première grande bataille de l'Islam.",
      virtues: "استشعار نصر الله لعباده المؤمنين والثقة بتأييد الحق والدعاء الصادق.",
      virtuesFr: "Méditation sur la victoire de la vérité et la force de la foi sincere.",
      icon: Icons.shield,
      accentColor: Color(0xFFE11D48),
    ),
    IslamicEventItem(
      title: "ذكرى فتح مكة الأعظم",
      titleFr: "Conquête de la Mecque (Fath Makka)",
      hijriDate: "20 رمضان",
      hijriDateFr: "20 Ramadan",
      description: "دخول النبي ﷺ مكة فاتحاً عزيزاً متواضعاً وتطهير الكعبة من الأصنام.",
      descriptionFr: "Entrée victorieuse et humble du Prophète ﷺ à la Mecque purifiant la Kaaba.",
      virtues: "التحلي بالعفو عند المقدرة والتواضع لله وشكر نعمة الفتح والتمكين.",
      virtuesFr: "Exemple sublime de pardon et d'humilité envers le Créateur.",
      icon: Icons.flag,
      accentColor: Color(0xFF059669),
    ),
    IslamicEventItem(
      title: "ليلة القدر المباركة (العشر الأواخر)",
      titleFr: "La Nuit du Destin (Laylat al-Qadr)",
      hijriDate: "27 رمضان (وترية)",
      hijriDateFr: "27 Ramadan (Impaire)",
      description: "ليلة الشرف والقدر التي أنزل فيها القرآن، وهي خير من ألف شهر.",
      descriptionFr: "Nuit bénie de la révélation du Coran, meilleure que mille mois.",
      virtues: "القيام بالصلاة وقراءة القرآن والدعاء المأثور: «اللهم إنك عفو تحب العفو فاعف عني».",
      virtuesFr: "Prières nocturnes assidues et invocation : « Ô Allah, Tu es Pardonneur et Tu aimes pardonner ».",
      icon: Icons.stars,
      accentColor: Color(0xFFFDE68A),
    ),
    IslamicEventItem(
      title: "عيد الفطر المبارك",
      titleFr: "Fête de l'Aïd al-Fitr",
      hijriDate: "1 شوال",
      hijriDateFr: "1er Chawwal",
      description: "يوم الجائزة والفرح بإتمام صيام شهر رمضان المبارك وصلة الأرحام.",
      descriptionFr: "Jour de réjouissance célébrant l'accomplissement du jeûne de Ramadan.",
      virtues: "إخراج زكاة الفطر قبل الصلاة، التكبير، إظهار البهجة والسرور ومواساة الفقراء.",
      virtuesFr: "Acquittement de Zakat al-Fitr, prière de l'Aïd et visite des proches.",
      icon: Icons.celebration,
      accentColor: Color(0xFF10B981),
    ),
    IslamicEventItem(
      title: "يوم عرفة العظيم",
      titleFr: "Jour d'Arafat Béni",
      hijriDate: "9 ذو الحجة",
      hijriDateFr: "9 Dhul-Hijja",
      description: "أفضل أيام العام، ركن الحج الأعظم بوقوف الحجاج في صعيد عرفات الطاهر.",
      descriptionFr: "Le pilier culminant du Hajj avec le rassemblement sur le mont Arafat.",
      virtues: "صيامه لغير الحاج يكفر سنتين (ماضية ومقبلة)، والإكثار من الدعاء والذكر.",
      virtuesFr: "Son jeûne pour le non-pèlerin expie deux années de péchés (passée et à venir).",
      icon: Icons.landscape,
      accentColor: Color(0xFFF59E0B),
    ),
    IslamicEventItem(
      title: "عيد الأضحى المبارك",
      titleFr: "Fête de l'Aïd al-Adha",
      hijriDate: "10 ذو الحجة",
      hijriDateFr: "10 Dhul-Hijja",
      description: "يوم النحر الأكبر، فرحة المسلمين بذبح الأضاحي إحياءً لسنة إبراهيم عليه السلام.",
      descriptionFr: "La Grande Fête du Sacrifice commémorant l'obéissance du Prophète Abraham.",
      virtues: "صلاة العيد، ذبح الأضحية وتوزيعها على المحتاجين، صلة الرحم والتكبير.",
      virtuesFr: "Prière de l'Aïd, sacrifice rituel partagé avec les nécessiteux et glorifications.",
      icon: Icons.volunteer_activism,
      accentColor: Color(0xFF10B981),
    ),
    IslamicEventItem(
      title: "أيام التشريق الثلاثة",
      titleFr: "Les Jours de Tachriq",
      hijriDate: "11 - 13 ذو الحجة",
      hijriDateFr: "11 - 13 Dhul-Hijja",
      description: "أيام إتمام مناسك الحج ورمي الجمرات والمبيت بمنى.",
      descriptionFr: "Jours de clôture des rites du pèlerinage et de séjour à Mina.",
      virtues: "أيام أكل وشرب وذكر لله تعالى وتكبير دبر الصلوات المكتوبة.",
      virtuesFr: "Jours de joie, de fraternité et d'évocation permanente d'Allah.",
      icon: Icons.wb_sunny,
      accentColor: Color(0xFF38BDF8),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.currentLocale,
      builder: (context, locale, _) {
        final lang = locale.languageCode;
        final isAr = lang == 'ar';
        final now = DateTime.now();
        final todayTimes = PrayerService.calculateTimesForWilaya(AlgeriaWilayas.getWilayaByCode(16), now);
        final hijriStr = todayTimes['hijri_date'] ?? "";
        final gregorianStr = todayTimes['gregorian_date'] ?? "";

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
                  LanguageService.tr('events_page_title'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Today Hijri Badge Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.darkPrimary, const Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.accent, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: theme.accent.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, color: theme.accent, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              LanguageService.tr('events_today_hijri'),
                              style: TextStyle(color: theme.accent, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          hijriStr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          gregorianStr,
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          LanguageService.tr('events_blessed_day'),
                          style: TextStyle(color: theme.accent.withValues(alpha: 0.8), fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.stars, color: theme.accent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          LanguageService.tr('events_major_title'),
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Events list
                  ...events.map((e) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Material(
                        color: theme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        child: ExpansionTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: e.accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: e.accentColor.withValues(alpha: 0.5)),
                            ),
                            child: Icon(e.icon, color: e.accentColor, size: 22),
                          ),
                          title: Text(
                            e.getTitle(lang),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "${isAr ? 'الموعد: ' : 'Date: '}${e.getDate(lang)}",
                              style: TextStyle(color: theme.accent, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(color: Color(0xFF334155)),
                                  const SizedBox(height: 4),
                                  Text(
                                    e.getDescription(lang),
                                    style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.5),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: e.accentColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.lightbulb_outline, color: e.accentColor, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "${isAr ? 'الفضل والعمل المستحب: ' : 'Mérite et œuvre recommandée : '}${e.getVirtues(lang)}",
                                            style: TextStyle(color: e.accentColor, fontSize: 12, height: 1.4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
