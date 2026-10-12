import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeColor {
  final String id;
  final String nameAr;
  final Color primary;
  final Color darkPrimary;
  final Color accent;
  final Color background;
  final Color cardBackground;

  const AppThemeColor({
    required this.id,
    required this.nameAr,
    required this.primary,
    required this.darkPrimary,
    required this.accent,
    required this.background,
    required this.cardBackground,
  });
}

class ThemeService {
  static const List<AppThemeColor> availableThemes = [
    AppThemeColor(
      id: "emerald",
      nameAr: "الأخضر الزمردي الأندلسي (الافتراضي)",
      primary: Color(0xFF10B981),
      darkPrimary: Color(0xFF064E3B),
      accent: Color(0xFFD4AF37),
      background: Color(0xFF0F172A),
      cardBackground: Color(0xFF1E293B),
    ),
    AppThemeColor(
      id: "royal_blue",
      nameAr: "الأزرق الملكي القرطبي",
      primary: Color(0xFF3B82F6),
      darkPrimary: Color(0xFF1E3A8A),
      accent: Color(0xFFFBBF24),
      background: Color(0xFF0B132B),
      cardBackground: Color(0xFF1C2541),
    ),
    AppThemeColor(
      id: "amber_desert",
      nameAr: "الصحراوي الذهبي (الرمال والواحات)",
      primary: Color(0xFFD97706),
      darkPrimary: Color(0xFF78350F),
      accent: Color(0xFFFDE68A),
      background: Color(0xFF1C1917),
      cardBackground: Color(0xFF292524),
    ),
    AppThemeColor(
      id: "midnight",
      nameAr: "الأسود والذهبي الفاخر",
      primary: Color(0xFFD4AF37),
      darkPrimary: Color(0xFF1A1A1A),
      accent: Color(0xFFE5C07B),
      background: Color(0xFF121212),
      cardBackground: Color(0xFF1E1E1E),
    ),
  ];

  static final ValueNotifier<AppThemeColor> currentTheme = ValueNotifier<AppThemeColor>(availableThemes[0]);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final themeId = prefs.getString('app_theme_id') ?? "emerald";
    final match = availableThemes.firstWhere(
      (t) => t.id == themeId,
      orElse: () => availableThemes[0],
    );
    currentTheme.value = match;
  }

  static Future<void> setTheme(AppThemeColor theme) async {
    currentTheme.value = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_theme_id', theme.id);
  }
}
