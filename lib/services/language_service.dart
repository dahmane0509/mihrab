import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_translations.dart';

class LanguageService {
  static const String _prefKey = 'app_language';
  
  /// Supported Locales
  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// Current reactive Locale notifier (Default to Arabic for exact backward-compatibility)
  static final ValueNotifier<Locale> currentLocale = ValueNotifier<Locale>(const Locale('ar'));

  /// Initialize Language from storage or system settings
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString(_prefKey);

      if (savedLang != null && (savedLang == 'ar' || savedLang == 'en' || savedLang == 'fr')) {
        currentLocale.value = Locale(savedLang);
      } else {
        // App strictly defaults to Arabic
        currentLocale.value = const Locale('ar');
      }
    } catch (_) {
      currentLocale.value = const Locale('ar');
    }
  }

  /// Change active language and persist choice
  static Future<void> setLanguage(String langCode) async {
    if (langCode != 'ar' && langCode != 'en' && langCode != 'fr') return;
    
    currentLocale.value = Locale(langCode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, langCode);
    } catch (_) {}
  }

  /// Current active language code ('ar', 'en', 'fr')
  static String get languageCode => currentLocale.value.languageCode;

  /// Whether current active locale is Right-To-Left (Arabic)
  static bool get isRtl => AppTranslations.isRtl(languageCode);

  /// Active text direction
  static TextDirection get textDirection => isRtl ? TextDirection.rtl : TextDirection.ltr;

  /// Helper to translate key for current active locale
  static String tr(String key) => AppTranslations.get(key, languageCode);
}
