import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_translations.dart';
import '../data/world_languages_catalog.dart';

class AppLanguage {
  final String code;
  final String name; // International/English name
  final String nativeName; // Native name
  final String nameAr; // Arabic name
  final String flag;
  final bool isRtl;
  final bool isCustom;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    this.nameAr = '',
    this.isRtl = false,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'nativeName': nativeName,
        'nameAr': nameAr,
        'flag': flag,
        'isRtl': isRtl,
        'isCustom': isCustom,
      };

  factory AppLanguage.fromJson(Map<String, dynamic> json) => AppLanguage(
        code: json['code'] as String? ?? 'en',
        name: json['name'] as String? ?? '',
        nativeName: json['nativeName'] as String? ?? '',
        nameAr: json['nameAr'] as String? ?? '',
        flag: json['flag'] as String? ?? '🌐',
        isRtl: json['isRtl'] as bool? ?? false,
        isCustom: json['isCustom'] as bool? ?? true,
      );
}

class LanguageService {
  static const String _prefKey = 'app_language';
  static const String _customLangsKey = 'custom_user_languages';

  /// Initial list of 20 major world languages
  static const List<AppLanguage> defaultLanguages = [
    AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', nameAr: 'العربية', flag: '🇩🇿', isRtl: true),
    AppLanguage(code: 'en', name: 'English', nativeName: 'English', nameAr: 'الإنجليزية', flag: '🇬🇧', isRtl: false),
    AppLanguage(code: 'fr', name: 'French', nativeName: 'Français', nameAr: 'الفرنسية', flag: '🇫🇷', isRtl: false),
    AppLanguage(code: 'tr', name: 'Turkish', nativeName: 'Türkçe', nameAr: 'التركية', flag: '🇹🇷', isRtl: false),
    AppLanguage(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia', nameAr: 'الإندونيسية', flag: '🇮🇩', isRtl: false),
    AppLanguage(code: 'ur', name: 'Urdu', nativeName: 'اردو', nameAr: 'الأردية', flag: '🇵🇰', isRtl: true),
    AppLanguage(code: 'ms', name: 'Malay', nativeName: 'Bahasa Melayu', nameAr: 'الملايو', flag: '🇲🇾', isRtl: false),
    AppLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', nameAr: 'الإسبانية', flag: '🇪🇸', isRtl: false),
    AppLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', nameAr: 'الألمانية', flag: '🇩🇪', isRtl: false),
    AppLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский', nameAr: 'الروسية', flag: '🇷🇺', isRtl: false),
    AppLanguage(code: 'fa', name: 'Persian', nativeName: 'فارسی', nameAr: 'الفارسية', flag: '🇮🇷', isRtl: true),
    AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', nameAr: 'البنغالية', flag: '🇧🇩', isRtl: false),
    AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', nameAr: 'الهندية', flag: '🇮🇳', isRtl: false),
    AppLanguage(code: 'it', name: 'Italian', nativeName: 'Italiano', nameAr: 'الإيطالية', flag: '🇮🇹', isRtl: false),
    AppLanguage(code: 'pt', name: 'Portuguese', nativeName: 'Português', nameAr: 'البرتغالية', flag: '🇵🇹', isRtl: false),
    AppLanguage(code: 'zh', name: 'Chinese', nativeName: '中文', nameAr: 'الصينية', flag: '🇨🇳', isRtl: false),
    AppLanguage(code: 'sw', name: 'Swahili', nativeName: 'Kiswahili', nameAr: 'السواحيلية', flag: '🇹🇿', isRtl: false),
    AppLanguage(code: 'ha', name: 'Hausa', nativeName: 'Hausa', nameAr: 'الهوسا', flag: '🇳🇬', isRtl: false),
    AppLanguage(code: 'nl', name: 'Dutch', nativeName: 'Nederlands', nameAr: 'الهولندية', flag: '🇳🇱', isRtl: false),
    AppLanguage(code: 'bs', name: 'Bosnian', nativeName: 'Bosanski', nameAr: 'البوسنية', flag: '🇧🇦', isRtl: false),
  ];

  static List<AppLanguage> _customLanguages = [];
  static List<AppLanguage> _supportedLanguages = List.from(defaultLanguages);

  /// Reactive notifier for supported languages list changes
  static final ValueNotifier<int> languagesVersion = ValueNotifier<int>(0);

  /// Current list of active supported languages (default + user-added)
  static List<AppLanguage> get supportedLanguages => _supportedLanguages;

  /// Supported Locales for MaterialApp
  static List<Locale> get supportedLocales =>
      _supportedLanguages.map((l) => Locale(l.code)).toList();

  /// Current reactive Locale notifier (Default to Arabic)
  static final ValueNotifier<Locale> currentLocale =
      ValueNotifier<Locale>(const Locale('ar'));

  /// Initialize Language from storage or system settings
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load user added custom languages
      final rawCustom = prefs.getString(_customLangsKey);
      if (rawCustom != null && rawCustom.isNotEmpty) {
        try {
          final List<dynamic> list = jsonDecode(rawCustom) as List<dynamic>;
          _customLanguages = list
              .map((item) => AppLanguage.fromJson(item as Map<String, dynamic>))
              .toList();
        } catch (_) {
          _customLanguages = [];
        }
      } else {
        _customLanguages = [];
      }

      _rebuildSupportedLanguages();

      // Load saved active language or auto-detect on first launch
      final savedLang = prefs.getString(_prefKey);
      if (savedLang != null && isSupported(savedLang)) {
        currentLocale.value = Locale(savedLang);
      } else {
        // Auto-detect device system language
        final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
        final devCode = deviceLocale.languageCode.toLowerCase();
        String initialLang;
        if (devCode.startsWith('fr')) {
          initialLang = 'fr';
        } else if (devCode.startsWith('ar')) {
          initialLang = 'ar';
        } else {
          initialLang = 'en';
        }

        currentLocale.value = Locale(initialLang);
        await prefs.setString(_prefKey, initialLang);
      }
    } catch (_) {
      _rebuildSupportedLanguages();
      currentLocale.value = const Locale('ar');
    }
  }

  static void _rebuildSupportedLanguages() {
    final Map<String, AppLanguage> map = {};
    for (final l in defaultLanguages) {
      map[l.code] = l;
    }
    for (final l in _customLanguages) {
      map[l.code] = l;
    }
    _supportedLanguages = map.values.toList();
    languagesVersion.value++;
  }

  /// Whether a language code is supported
  static bool isSupported(String code) =>
      _supportedLanguages.any((l) => l.code == code);

  /// Current active language metadata
  static AppLanguage get activeLanguage => getLanguageByCode(languageCode);

  /// Get AppLanguage by code with fallback to Arabic
  static AppLanguage getLanguageByCode(String code) =>
      _supportedLanguages.firstWhere(
        (l) => l.code == code,
        orElse: () => defaultLanguages[0],
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

  /// Add a new language (from catalog or custom) to supported languages
  static Future<void> addLanguage(AppLanguage language, {bool activateNow = true}) async {
    // Check if code exists
    final index = _supportedLanguages.indexWhere((l) => l.code == language.code);
    if (index == -1) {
      _customLanguages.add(language);
      _rebuildSupportedLanguages();
      await _persistCustomLanguages();
    }

    if (activateNow) {
      await setLanguage(language.code);
    }
  }

  /// Remove a user-added custom language
  static Future<bool> removeCustomLanguage(String code) async {
    final exists = _customLanguages.any((l) => l.code == code);
    if (!exists) return false;

    _customLanguages.removeWhere((l) => l.code == code);
    _rebuildSupportedLanguages();
    await _persistCustomLanguages();

    // If active language was the removed one, fallback to Arabic
    if (languageCode == code) {
      await setLanguage('ar');
    }
    return true;
  }

  static Future<void> _persistCustomLanguages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_customLanguages.map((l) => l.toJson()).toList());
      await prefs.setString(_customLangsKey, encoded);
    } catch (_) {}
  }

  /// Search available global languages catalog for languages not yet in supported languages
  static List<AppLanguage> searchAvailableGlobalLanguages(String query) {
    final q = query.trim().toLowerCase();
    final currentCodes = _supportedLanguages.map((l) => l.code.toLowerCase()).toSet();

    return WorldLanguagesCatalog.availableLanguages.where((l) {
      if (currentCodes.contains(l.code.toLowerCase())) return false;
      if (q.isEmpty) return true;

      return l.code.toLowerCase().contains(q) ||
          l.name.toLowerCase().contains(q) ||
          l.nativeName.toLowerCase().contains(q) ||
          l.nameAr.toLowerCase().contains(q);
    }).toList();
  }

  /// Current active language code
  static String get languageCode => currentLocale.value.languageCode;

  /// Whether current active locale is Right-To-Left (Arabic, Urdu, Persian, Kurdish, Pashto, etc.)
  static bool get isRtl =>
      activeLanguage.isRtl || AppTranslations.isRtl(languageCode);

  /// Active text direction
  static TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;

  /// Helper to translate key for current active locale
  static String tr(String key) => AppTranslations.get(key, languageCode);
}
