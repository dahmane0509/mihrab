import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mihrab_app/l10n/app_translations.dart';
import 'package:mihrab_app/services/language_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LanguageService & AppTranslations Tests', () {
    test('Defaults to Arabic locale with RTL direction', () {
      LanguageService.currentLocale.value = const Locale('ar');
      expect(LanguageService.languageCode, equals('ar'));
      expect(LanguageService.isRtl, isTrue);
      expect(LanguageService.textDirection, equals(TextDirection.rtl));
      expect(LanguageService.tr('app_name'), equals('مِحْرَاب'));
    });

    test('Translates keys into Arabic, English, and French accurately', () {
      expect(AppTranslations.get('app_name', 'ar'), equals('مِحْرَاب'));
      expect(AppTranslations.get('app_name', 'en'), equals('Mihrab'));
      expect(AppTranslations.get('app_name', 'fr'), equals('Mihrab'));

      expect(AppTranslations.get('tab_next_prayer', 'ar'), equals('الصلاة القادمة'));
      expect(AppTranslations.get('tab_next_prayer', 'en'), equals('Next Prayer'));
      expect(AppTranslations.get('tab_next_prayer', 'fr'), equals('Prochaine Prière'));

      expect(AppTranslations.get('fajr', 'ar'), equals('الفجر'));
      expect(AppTranslations.get('fajr', 'en'), equals('Fajr'));
      expect(AppTranslations.get('fajr', 'fr'), equals('Fajr'));
    });

    test('Switches active language and updates direction', () async {
      await LanguageService.setLanguage('en');
      expect(LanguageService.languageCode, equals('en'));
      expect(LanguageService.isRtl, isFalse);
      expect(LanguageService.textDirection, equals(TextDirection.ltr));
      expect(LanguageService.tr('settings_title'), equals('General Settings & Appearance'));

      await LanguageService.setLanguage('fr');
      expect(LanguageService.languageCode, equals('fr'));
      expect(LanguageService.isRtl, isFalse);
      expect(LanguageService.textDirection, equals(TextDirection.ltr));
      expect(LanguageService.tr('settings_title'), equals('Paramètres Généraux & Apparence'));

      // Restore Arabic default
      await LanguageService.setLanguage('ar');
      expect(LanguageService.languageCode, equals('ar'));
      expect(LanguageService.isRtl, isTrue);
    });

    test('Returns key as fallback when translation does not exist', () {
      expect(AppTranslations.get('non_existent_key_xyz', 'ar'), equals('non_existent_key_xyz'));
      expect(AppTranslations.get('non_existent_key_xyz', 'en'), equals('non_existent_key_xyz'));
    });

    test('Supports 20 major global languages with accurate metadata and RTL detection', () {
      expect(LanguageService.supportedLanguages.length, equals(20));
      expect(LanguageService.isSupported('tr'), isTrue);
      expect(LanguageService.isSupported('id'), isTrue);
      expect(LanguageService.isSupported('ur'), isTrue);
      expect(LanguageService.isSupported('ru'), isTrue);
      expect(LanguageService.isSupported('es'), isTrue);
      expect(LanguageService.isSupported('fa'), isTrue);

      expect(AppTranslations.isRtl('ar'), isTrue);
      expect(AppTranslations.isRtl('ur'), isTrue);
      expect(AppTranslations.isRtl('fa'), isTrue);
      expect(AppTranslations.isRtl('en'), isFalse);
      expect(AppTranslations.isRtl('tr'), isFalse);
    });
  });
}
