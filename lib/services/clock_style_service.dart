import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available Clock Styles for the Main Prayer Screen
enum ClockStyleType {
  analog,
  digital,
  minimalist,
}

class ClockStyleService {
  static const String _prefKey = 'selected_clock_style';

  /// Currently active clock style notifier ('analog', 'digital', 'minimalist')
  static final ValueNotifier<String> currentStyle = ValueNotifier<String>('analog');

  /// Initialize clock style from SharedPreferences
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey) ?? 'analog';
      if (saved == 'analog' || saved == 'digital' || saved == 'minimalist') {
        currentStyle.value = saved;
      } else {
        currentStyle.value = 'analog';
      }
    } catch (_) {
      currentStyle.value = 'analog';
    }
  }

  /// Change clock style and persist choice
  static Future<void> setStyle(String style) async {
    if (style != 'analog' && style != 'digital' && style != 'minimalist') return;
    currentStyle.value = style;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, style);
    } catch (_) {}
  }

  /// Returns localized style name
  static String getStyleName(String style, bool isAr) {
    switch (style) {
      case 'digital':
        return isAr ? "الساعة الرقمية الحديثة" : "Modern Digital Clock";
      case 'minimalist':
        return isAr ? "ساعة بسيطة ناعمة بالأرقام العربية" : "Minimalist Arabic Clock";
      case 'analog':
      default:
        return isAr ? "الساعة الكلاسيكية بالعقارب" : "Classic Analog Clock";
    }
  }

  /// Returns localized style description
  static String getStyleDescription(String style, bool isAr) {
    switch (style) {
      case 'digital':
        return isAr ? "عرض رقمي واضح مع توهج زمردي خفيف" : "Clear digital display with subtle glow";
      case 'minimalist':
        return isAr ? "أرقام مشرقية أنيقة وهدوء بصري راقٍ" : "Eastern Arabic numerals with serene aesthetics";
      case 'analog':
      default:
        return isAr ? "قرص دائري أنيق مع عقارب ذهبية ومؤشرات الصلاة" : "Elegant dial with golden hands and prayer dots";
    }
  }
}
