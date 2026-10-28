import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/algeria_wilayas.dart';
import '../data/algeria_communes.dart';
import '../services/theme_service.dart';
import '../services/adhan_audio_service.dart';
import '../screens/settings_screen.dart';
import '../screens/live_broadcast_screen.dart';
import '../screens/islamic_events_screen.dart';
import '../screens/nearby_mosques_screen.dart';
import '../screens/auto_adhkar_screen.dart';
import '../services/app_feedback.dart';
import '../services/language_service.dart';

class AppDrawer extends StatefulWidget {
  final Wilaya currentWilaya;
  final Commune? currentCommune;
  final void Function(Wilaya, Commune?) onLocationChanged;

  const AppDrawer({
    super.key,
    required this.currentWilaya,
    this.currentCommune,
    required this.onLocationChanged,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 4.0, end: 14.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.currentLocale,
      builder: (context, locale, _) {
        final langCode = locale.languageCode;
        final isAr = langCode == 'ar';
        return ValueListenableBuilder<AppThemeColor>(
          valueListenable: ThemeService.currentTheme,
          builder: (context, theme, _) {
            final communeName = isAr
                ? (widget.currentCommune?.nameAr ?? widget.currentWilaya.nameAr)
                : (widget.currentCommune?.nameFr ?? widget.currentWilaya.nameFr);
            final wilayaName = isAr ? widget.currentWilaya.nameAr : widget.currentWilaya.nameFr;

            return Drawer(
              backgroundColor: theme.cardBackground,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Animated Header with the New Logo (Flexible Container to prevent overflow)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF071224),
                          theme.darkPrimary,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, _) {
                            return Container(
                              width: 48,
                              height: 48,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    blurRadius: _glowAnimation.value,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: Image.asset(
                                  'assets/icon/app_icon.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.mosque, color: Colors.white, size: 28),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isAr ? "محراب" : LanguageService.tr('drawer_brand'),
                          style: GoogleFonts.alexandria(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2.0,
                            shadows: const [
                              Shadow(
                                color: Color(0x6600E5FF),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAr
                              ? "موقعك الحالي: $communeName (${widget.currentWilaya.nameAr})"
                              : "${LanguageService.tr('drawer_current_location')}: $communeName ($wilayaName)",
                          style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Drawer Navigation Items (Removed duplicate Qibla Compass per user request)
                  ListTile(
                    leading: Icon(Icons.volume_up, color: theme.accent),
                    title: Text(
                      isAr ? "تشغيل صوت الأذان" : LanguageService.tr('drawer_play_adhan'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      isAr ? "استمع للأذان المعتمد الآن" : LanguageService.tr('drawer_play_adhan_sub'),
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    onTap: () {
                      AppFeedback.tap();
                      Navigator.pop(context);
                      AdhanAudioService.playAdhan();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF065F46),
                          duration: const Duration(seconds: 4),
                          content: Text(
                            isAr
                                ? "يرتفع الآن صوت الأذان المبارك 🕌"
                                : (langCode == 'fr'
                                    ? "L'appel à la prière retentit maintenant 🕌"
                                    : "The call to prayer is sounding now 🕌"),
                          ),
                          action: SnackBarAction(
                            label: isAr ? "إيقاف" : LanguageService.tr('stop_audio'),
                            textColor: const Color(0xFFFDE68A),
                            onPressed: () => AdhanAudioService.stopAdhan(),
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.live_tv, color: Colors.redAccent),
                    title: Text(
                      isAr ? "البث المباشر (مكة، المدينة، الجزائر)" : LanguageService.tr('drawer_live'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      isAr ? "إذاعة القرآن وقنوات الحرمين" : LanguageService.tr('drawer_live_sub'),
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    onTap: () {
                      AppFeedback.tap();
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const LiveBroadcastScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month, color: Color(0xFF10B981)),
                    title: Text(
                      isAr ? "المناسبات الإسلامية والتقويم" : LanguageService.tr('drawer_events'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      isAr ? "أعياد ومناسبات العام الهجري" : LanguageService.tr('drawer_events_sub'),
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    onTap: () {
                      AppFeedback.tap();
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const IslamicEventsScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.account_balance, color: Color(0xFF38BDF8)),
                    title: Text(
                      isAr ? "المساجد القريبة ودليل المعالم" : LanguageService.tr('drawer_mosques'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      isAr ? "أقرب المساجد والملاحة بالخريطة" : LanguageService.tr('drawer_mosques_sub'),
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    onTap: () {
                      AppFeedback.tap();
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => NearbyMosquesScreen(
                            currentWilaya: widget.currentWilaya,
                            currentCommune: widget.currentCommune,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.auto_awesome, color: Color(0xFFF59E0B)),
                    title: Text(
                      isAr ? "أذكار الشاشة التلقائية" : LanguageService.tr('drawer_adhkar'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      isAr ? "ظهور الأذكار أثناء تصفح الهاتف" : LanguageService.tr('drawer_adhkar_sub'),
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    onTap: () {
                      AppFeedback.tap();
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const AutoAdhkarScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.palette, color: theme.accent),
                    title: Text(
                      isAr ? "الإعدادات وتخصيص المظهر" : LanguageService.tr('drawer_settings'),
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      isAr ? "لغات التطبيق (20 لغة عالمية)، المظهر، وتنبيهات الأذان" : LanguageService.tr('drawer_settings_sub'),
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    onTap: () {
                      AppFeedback.tap();
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SettingsScreen(
                            selectedWilayaCode: widget.currentWilaya.code,
                            onWilayaChanged: (code) {
                              final w = AlgeriaWilayas.getWilayaByCode(code);
                              final c = AlgeriaCommunes.getCommunesByWilaya(code).firstOrNull;
                              widget.onLocationChanged(w, c);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Color(0xFF334155)),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.white54),
                    title: Text(
                      isAr ? "عن تطبيق مِحْرَاب" : LanguageService.tr('drawer_about'),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    subtitle: Text(
                      isAr
                          ? "الإصدار 1.0.4 — موثوقية تقنية ومصادر شرعية وفلكية معتمدة"
                          : LanguageService.tr('drawer_about_sub'),
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    onTap: () {
                      AppFeedback.tap();
                      Navigator.pop(context);
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Row(
                            children: [
                              Icon(Icons.verified, color: theme.accent, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isAr ? "عن تطبيق مِحْرَاب (الإصدار 1.0.4)" : LanguageService.tr('drawer_about'),
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          content: SingleChildScrollView(
                            child: Text(
                              isAr
                                  ? "صُمِّم تطبيق «مِحْرَاب» وفق أعلى معايير الجودة الهندسية والموثوقية التقنية ليكون رفيقاً رقمياً دقيقاً وموثوقاً؛ حيث تخضع النصوص القرآنية فيه لمطابقةٍ صارمة مع المراجع القياسية المعتمدة مثل (مشروع تنزيل - Tanzil) لضمان سلامة الرسم والتشكيل وتطابق أرقام الآيات والسور دون أي خطأ. كما تمت مراجعة وتدقيق خوارزميات حساب مواقيت الصلاة واتجاه القبلة برمجياً بالاعتماد على المكتبات الفلكية المعتمدة عالمياً مثل (مكتبة Adhan) وربطها بالإحداثيات الجغرافية الدقيقة والمناطق الزمنية القياسية. وإلى جانب ذلك، يعتمد التطبيق منظومة فحص آلي لقواعد البيانات لضمان تكامل البيانات، وتوثيق الأحاديث النبوية والأذكار وتخريجها بالاستناد إلى المصادر الموثوقة مثل (موقع الدرر السنية)، مع التحقق الكامل من سلامة الترميز القياسي (UTF-8) لضمان عرض النصوص العربية بأعلى درجات الوضوح والدقة."
                                  : (langCode == 'fr'
                                      ? "Conçu selon les normes d'ingénierie les plus strictes, Mihrab garantit une fiabilité optimale : validation des textes coraniques via le standard Tanzil, calculs astronomiques précis des prières et de la Qibla via la bibliothèque Adhan, et vérification automatisée des hadiths (Al-Dorar Al-Saniyyah) avec encodage UTF-8 intégral."
                                      : "Engineered to the highest standards of accuracy and reliability, Mihrab validates Quranic texts against the Tanzil standard, verifies prayer times and Qibla calculations via the astronomical Adhan library, and runs automated UTF-8 database checks with authentic Hadith referencing from Al-Dorar Al-Saniyyah."),
                              textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                              style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 13.5, height: 1.75),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                isAr ? "إغلاق" : "OK",
                                style: TextStyle(color: theme.accent, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

