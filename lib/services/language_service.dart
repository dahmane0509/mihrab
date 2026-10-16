import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_translations.dart';

class AppLanguage {
  final String code;
  final String name; // International/English name
  final String nativeName; // Native name
  final String flag;
  final bool isRtl;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    this.isRtl = false,
  });
}

class LanguageService {
  static const String _prefKey = 'app_language';

  /// Comprehensive list of 20 major world languages for Muslims and global users
  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇩🇿', isRtl: true),
    AppLanguage(code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧', isRtl: false),
    AppLanguage(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷', isRtl: false),
    AppLanguage(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', flag: '🇹🇷', isRtl: false),
    AppLanguage(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia', flag: '🇮🇩', isRtl: false),
    AppLanguage(code: 'ur', name: 'Urdu', nativeName: 'اردو', flag: '🇵🇰', isRtl: true),
    AppLanguage(code: 'ms', name: 'Malay', nativeName: 'Bahasa Melayu', flag: '🇲🇾', isRtl: false),
    AppLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸', isRtl: false),
    AppLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪', isRtl: false),
    AppLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺', isRtl: false),
    AppLanguage(code: 'fa', name: 'Persian', nativeName: 'فارسی', flag: '🇮🇷', isRtl: true),
    AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', flag: '🇧🇩', isRtl: false),
    AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳', isRtl: false),
    AppLanguage(code: 'it', name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹', isRtl: false),
    AppLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇵🇹', isRtl: false),
    AppLanguage(code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳', isRtl: false),
    AppLanguage(code: 'sw', name: 'Swahili', nativeName: 'Kiswahili', flag: '🇹🇿', isRtl: false),
    AppLanguage(code: 'ha', name: 'Hausa', nativeName: 'Hausa', flag: '🇳🇬', isRtl: false),
    AppLanguage(code: 'nl', name: 'Dutch', nativeName: 'Nederlands', flag: '🇳🇱', isRtl: false),
    AppLanguage(code: 'bs', name: 'Bosnian', nativeName: 'Bosanski', flag: '🇧🇦', isRtl: false),
  ];

  /// Supported Locales for MaterialApp
  static List<Locale> get supportedLocales =>
      supportedLanguages.map((l) => Locale(l.code)).toList();

  /// Current reactive Locale notifier (Default to Arabic)
  static final ValueNotifier<Locale> currentLocale =
      ValueNotifier<Locale>(const Locale('ar'));

  /// Initialize Language from storage or system settings
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString(_prefKey);

      if (savedLang != null && isSupported(savedLang)) {
        currentLocale.value = Locale(savedLang);
      } else {
        currentLocale.value = const Locale('ar');
      }
    } catch (_) {
      currentLocale.value = const Locale('ar');
    }
  }

  /// Whether a language code is supported
  static bool isSupported(String code) =>
      supportedLanguages.any((l) => l.code == code);

  /// Current active language metadata
  static AppLanguage get activeLanguage => getLanguageByCode(languageCode);

  /// Get AppLanguage by code with fallback to Arabic
  static AppLanguage getLanguageByCode(String code) =>
      supportedLanguages.firstWhere(
        (l) => l.code == code,
        orElse: () => supportedLanguages[0],
      );

  /// Change active language and persist choice
  static Future<void> setLanguage(String langCode) async {
    if (!isSupported(langCode)) return;

    currentLocale.value = Locale(langCode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, langCode);
    } catch (_) {}
  }

  /// Current active language code
  static String get languageCode => currentLocale.value.languageCode;

  /// Whether current active locale is Right-To-Left (Arabic, Urdu, Persian)
  static bool get isRtl => AppTranslations.isRtl(languageCode);

  /// Active text direction
  static TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;

  /// Helper to translate key for current active locale
  static String tr(String key) => AppTranslations.get(key, languageCode);
}
