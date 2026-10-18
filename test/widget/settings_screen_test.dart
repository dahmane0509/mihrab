import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mihrab_app/screens/settings_screen.dart';
import 'package:mihrab_app/services/theme_service.dart';

void main() {
  setUp(() {
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
    });
  });

  testWidgets('SettingsScreen displays theme choices, adhan sounds, and updates preferences', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(
          selectedWilayaCode: 16,
          onWilayaChanged: (_) {},
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify AppBar Title
    expect(find.text('الإعدادات العامة وتخصيص المظهر'), findsOneWidget);

    // Verify Global Language Selector section
    expect(find.textContaining('لغة التطبيق'), findsOneWidget);
    expect(find.textContaining('20 لغة عالمية'), findsWidgets);
    expect(find.text('🇩🇿 العربية'), findsOneWidget);
    expect(find.text('🇬🇧 English'), findsOneWidget);
    expect(find.text('🇫🇷 Français'), findsOneWidget);

    // Verify Theme Choices are listed
    expect(find.text('الأخضر الزمردي الأندلسي (الافتراضي)'), findsOneWidget);
    expect(find.text('الأزرق الملكي القرطبي'), findsOneWidget);
    expect(find.text('الصحراوي الذهبي (الرمال والواحات)'), findsOneWidget);
    expect(find.text('الأسود والذهبي الفاخر'), findsOneWidget);

    // Tap second theme
    await tester.tap(find.text('الأزرق الملكي القرطبي'));
    await tester.pump();
    expect(ThemeService.currentTheme.value.id, equals('royal_blue'));

    // Switch back to Emerald default
    await tester.tap(find.text('الأخضر الزمردي الأندلسي (الافتراضي)'));
    await tester.pump();
    expect(ThemeService.currentTheme.value.id, equals('emerald'));

    // Scroll down to reveal Adhan sounds section
    await tester.drag(find.byType(ListView), const Offset(0, -1400));
    await tester.pumpAndSettle();

    final adhanFinder = find.textContaining('أذان جامع الجزائر');
    expect(adhanFinder, findsWidgets);
    // Scroll down further to reveal Mosque Mode
    await tester.scrollUntilVisible(
      find.text('الوضع الصامت التلقائي في المسجد'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final mosqueModeFinder = find.text('الوضع الصامت التلقائي في المسجد');
    expect(mosqueModeFinder, findsOneWidget);

    // Scroll down to reveal Support & Updates Section with the 3 new tiles
    await tester.scrollUntilVisible(
      find.text('التحقق من التحديثات'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Verify Tile 1: Check for Updates
    expect(find.text('التحقق من التحديثات'), findsOneWidget);
    expect(find.text('فحص الآن'), findsOneWidget);

    // Verify Tile 2: Report Bug
    expect(find.text('بلّغ عن خطأ'), findsOneWidget);

    // Verify Tile 3: Request Feature
    expect(find.text('اقترح ميزة جديدة'), findsOneWidget);

    // Test Interaction: Tap "بلّغ عن خطأ" opens bug report sheet
    final bugFinder = find.text('بلّغ عن خطأ');
    await tester.ensureVisible(bugFinder);
    await tester.pumpAndSettle();
    await tester.tap(bugFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('الإبلاغ عن خطأ أو مشكلة تقنية'), findsOneWidget);
    expect(find.text('مواقيت الصلاة'), findsWidgets);
    expect(find.text('إرسال التقرير عبر البريد'), findsOneWidget);

    // Dismiss bug report sheet
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Test Interaction: Tap "اقترح ميزة جديدة" opens feature request sheet
    await tester.tap(find.text('اقترح ميزة جديدة'));
    await tester.pumpAndSettle();
    expect(find.text('اقترح ميزة جديدة لمحراب'), findsOneWidget);
    expect(find.text('إضافة صوت أذان جديد'), findsWidgets);
    expect(find.text('إرسال الاقتراح للمطورين'), findsOneWidget);

    // Dismiss feature request sheet
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });
}
