import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mihrab_app/l10n/app_translations.dart';
import 'package:mihrab_app/services/language_service.dart';
import 'package:mihrab_app/screens/settings_screen.dart';
import 'package:mihrab_app/screens/live_broadcast_screen.dart';
import 'package:mihrab_app/screens/quran_card_creator_screen.dart';
import 'package:mihrab_app/screens/auto_adhkar_screen.dart';

void main() {
  for (final lang in ['ar', 'fr', 'en']) {
    group('Localization verification for locale [$lang]', () {
      setUp(() async {
        PackageInfo.setMockInitialValues(
          appName: 'محراب',
          packageName: 'com.mihrab.algeria.mihrab_app',
          version: '1.0.0',
          buildNumber: '1',
          buildSignature: '',
        );
        SharedPreferences.setMockInitialValues({
          'selected_wilaya': 16,
          'adhan_sound': 'algeria_grand_mosque',
          'advance_reminder_minutes': 15,
          'auto_silent_mode': true,
          'use_gps_auto': false,
          'selected_language': lang,
        });
        await LanguageService.init();
        await LanguageService.setLanguage(lang);
      });

      testWidgets('SettingsScreen renders in [$lang]', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SettingsScreen(
              selectedWilayaCode: 16,
              onWilayaChanged: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(AppTranslations.get('settings_title', lang)), findsOneWidget);
        expect(find.text(AppTranslations.get('theme_emerald_name', lang)), findsOneWidget);
        expect(find.text(AppTranslations.get('theme_royal_blue_name', lang)), findsOneWidget);

        await tester.scrollUntilVisible(
          find.text(AppTranslations.get('settings_location_header', lang)),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(AppTranslations.get('settings_location_header', lang)), findsOneWidget);
      });

      testWidgets('LiveBroadcastScreen renders in [$lang]', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: LiveBroadcastScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(AppTranslations.get('live_broadcast_title', lang)), findsOneWidget);
        expect(find.text(AppTranslations.get('live_stations_header', lang)), findsOneWidget);
        expect(find.text(AppTranslations.get('live_stream_btn', lang)), findsWidgets);
      });

      testWidgets('QuranCardCreatorScreen renders UI in [$lang] while keeping sacred Arabic verse', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: QuranCardCreatorScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(AppTranslations.get('card_creator_title', lang)), findsOneWidget);
        expect(find.text(AppTranslations.get('card_share_btn', lang)), findsOneWidget);
        expect(find.text(AppTranslations.get('copy', lang)), findsOneWidget);
        expect(find.text(AppTranslations.get('card_colors_header', lang)), findsOneWidget);

        // Sacred Arabic verse must remain intact in Arabic across all locales
        expect(find.textContaining('أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ'), findsWidgets);
      });

      testWidgets('AutoAdhkarScreen renders in [$lang]', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: AutoAdhkarScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(AppTranslations.get('auto_adhkar_page_title', lang)), findsOneWidget);
        expect(find.text(AppTranslations.get('auto_adhkar_card_title', lang)), findsOneWidget);
        expect(find.text(AppTranslations.get('auto_adhkar_settings_header', lang)), findsOneWidget);
        expect(find.text(AppTranslations.get('freq_15_min', lang)), findsOneWidget);
      });
    });
  }
}
