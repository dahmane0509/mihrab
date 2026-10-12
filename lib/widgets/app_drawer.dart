import 'package:flutter/material.dart';
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
                  // Animated Header with the New Logo
                  DrawerHeader(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, _) {
                            return Container(
                              width: 52,
                              height: 52,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
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
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/icon/app_icon.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.mosque, color: Colors.white, size: 30),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAr ? "مِحْرَاب" : LanguageService.tr('drawer_brand'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          isAr
                              ? "موقعك الحالي: $communeName (${widget.currentWilaya.nameAr})"
                              : "${LanguageService.tr('drawer_current_location')}: $communeName ($wilayaName)",
                          style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 12),
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
                      isAr ? "تغيير ألوان التطبيق وصوت الأذان" : LanguageService.tr('drawer_settings_sub'),
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
                          ? "الإصدار 1.0.0 (الجزائر - 1541 بلدية والقرى والمداشر)"
                          : LanguageService.tr('drawer_about_sub'),
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    onTap: () {
                      AppFeedback.tap();
                      Navigator.pop(context);
                      showAboutDialog(
                        context: context,
                        applicationName: isAr ? "مِحْرَاب" : LanguageService.tr('app_name'),
                        applicationVersion: isAr ? "1.0.0 (الجزائر)" : "1.0.0",
                        applicationLegalese: isAr
                            ? "تطبيق إسلامي شامل للجزائر: مواقيت الصلاة لجميع البلديات والقرى والمداشر، القرآن الكريم قراءة واستماعاً، البث المباشر، وبوصلة القبلة."
                            : (langCode == 'fr'
                                ? "Compagnon islamique complet : Horaires de prière, Saint Coran, diffusion en direct et boussole Qibla."
                                : "Comprehensive Islamic companion: Prayer times, Holy Quran reading & audio, live broadcasts, and Qibla compass."),
                      );
                    },
                  ),
                  const Divider(color: Color(0xFF334155)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _buildLangChip('ar', '🇩🇿 العربية', theme),
                        const SizedBox(width: 6),
                        _buildLangChip('en', '🇬🇧 EN', theme),
                        const SizedBox(width: 6),
                        _buildLangChip('fr', '🇫🇷 FR', theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLangChip(String code, String label, AppThemeColor theme) {
    final isSelected = LanguageService.languageCode == code;
    return Expanded(
      child: InkWell(
        onTap: () async {
          AppFeedback.tap();
          await LanguageService.setLanguage(code);
          if (mounted) {
            setState(() {});
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? theme.accent : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? theme.accent : const Color(0xFF334155),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

