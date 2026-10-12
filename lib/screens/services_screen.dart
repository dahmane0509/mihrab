import 'package:flutter/material.dart';
import '../data/algeria_wilayas.dart';
import '../data/algeria_communes.dart';
import '../services/theme_service.dart';
import 'quran_screen.dart';
import 'adhkar_screen.dart';
import 'live_broadcast_screen.dart';
import 'quran_card_creator_screen.dart';
import 'settings_screen.dart';
import 'islamic_events_screen.dart';
import 'nearby_mosques_screen.dart';
import 'auto_adhkar_screen.dart';
import '../services/app_feedback.dart';
import '../services/language_service.dart';

class ServicesScreen extends StatelessWidget {
  final Wilaya currentWilaya;
  final Commune? currentCommune;
  final VoidCallback onOpenDrawer;

  const ServicesScreen({
    super.key,
    required this.currentWilaya,
    this.currentCommune,
    required this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.currentLocale,
      builder: (context, _, __) {
        return ValueListenableBuilder<AppThemeColor>(
          valueListenable: ThemeService.currentTheme,
          builder: (context, theme, _) {
            final services = [
              {
                "title": LanguageService.tr('services_quran_title'),
                "subtitle": LanguageService.tr('services_quran_subtitle'),
                "icon": Icons.menu_book,
                "color": theme.accent,
                "onTap": () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const QuranScreen())),
              },
              {
                "title": LanguageService.tr('services_adhkar_title'),
                "subtitle": LanguageService.tr('services_adhkar_subtitle'),
                "icon": Icons.favorite,
                "color": const Color(0xFF10B981),
                "onTap": () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const AdhkarScreen())),
              },
              {
                "title": LanguageService.tr('services_auto_adhkar_title'),
                "subtitle": LanguageService.tr('services_auto_adhkar_subtitle'),
                "icon": Icons.auto_awesome,
                "color": const Color(0xFFF59E0B),
                "onTap": () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const AutoAdhkarScreen())),
              },
              {
                "title": LanguageService.tr('services_live_title'),
                "subtitle": LanguageService.tr('services_live_subtitle'),
                "icon": Icons.live_tv,
                "color": Colors.redAccent,
                "onTap": () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const LiveBroadcastScreen())),
              },
              {
                "title": LanguageService.tr('services_card_creator_title'),
                "subtitle": LanguageService.tr('services_card_creator_subtitle'),
                "icon": Icons.share,
                "color": const Color(0xFFF59E0B),
                "onTap": () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const QuranCardCreatorScreen()),
                ),
              },
              {
                "title": LanguageService.tr('services_events_title'),
                "subtitle": LanguageService.tr('services_events_subtitle'),
                "icon": Icons.calendar_month,
                "color": const Color(0xFF10B981),
                "onTap": () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const IslamicEventsScreen())),
              },
              {
                "title": LanguageService.tr('services_mosques_title'),
                "subtitle": LanguageService.tr('services_mosques_subtitle'),
                "icon": Icons.account_balance,
                "color": const Color(0xFF0284C7),
                "onTap": () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => NearbyMosquesScreen(
                      currentWilaya: currentWilaya,
                      currentCommune: currentCommune,
                    ),
                  ),
                ),
              },
              {
                "title": LanguageService.tr('services_settings_title'),
                "subtitle": LanguageService.tr('services_settings_subtitle'),
                "icon": Icons.settings,
                "color": const Color(0xFFA78BFA),
                "onTap": () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => SettingsScreen(
                      selectedWilayaCode: currentWilaya.code,
                      onWilayaChanged: (_) {},
                    ),
                  ),
                ),
              },
            ];

            return Scaffold(
              backgroundColor: theme.background,
              appBar: AppBar(
                backgroundColor: theme.darkPrimary,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 26),
                  tooltip: LanguageService.tr('menu'),
                  onPressed: onOpenDrawer,
                ),
                title: Text(
                  LanguageService.tr('services_header_title'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                ),
                centerTitle: true,
              ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final s = services[index];
              final color = s['color'] as Color;

              return Material(
                color: theme.cardBackground,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withValues(alpha: 0.4)),
                    ),
                    child: Icon(s['icon'] as IconData, color: color, size: 24),
                  ),
                  title: Text(
                    s['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    s['subtitle'] as String,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: theme.accent, size: 16),
                  onTap: () {
                    AppFeedback.tap();
                    (s['onTap'] as VoidCallback)();
                  },
                ),
              ),
            );
            },
          ),
        );
      },
    );
  },
);
  }
}
