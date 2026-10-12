import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mihrab_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'selected_wilaya': 16,
      'selected_commune_id': 1601,
    });
  });

  testWidgets('MainHomeScreen renders 4 bottom navigation items and switches tabs correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainHomeScreen(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify 4 bottom navigation labels
    expect(find.text('الصلاة القادمة'), findsWidgets);
    expect(find.text('أوقات الصلاة'), findsWidgets);
    expect(find.text('الخدمات والميزات'), findsWidgets);
    expect(find.text('بوصلة القبلة'), findsWidgets);

    // Initial state: Tab 0 (Next prayer screen) is active
    expect(find.textContaining('الصلاة القادمة'), findsWidgets);

    // Switch to Tab 1: Prayer times screen
    await tester.tap(find.text('أوقات الصلاة').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('الصبح'), findsOneWidget);

    // Switch to Tab 2: Services screen
    await tester.tap(find.text('الخدمات والميزات').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('الخدمات والميزات الإسلامية'), findsOneWidget);

    // Switch to Tab 3: Qibla compass
    await tester.tap(find.text('بوصلة القبلة').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('المسافة إلى مكة'), findsOneWidget);

    // Switch back to Tab 0
    await tester.tap(find.text('الصلاة القادمة').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Open drawer
    final menuBtn = find.byTooltip('القائمة الجانبية');
    expect(menuBtn, findsOneWidget);
    await tester.tap(menuBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Drawer appeared
    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('تشغيل صوت الأذان'), findsOneWidget);

    // Scroll drawer to reveal settings
    await tester.drag(find.descendant(of: find.byType(Drawer), matching: find.byType(ListView)), const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('الإعدادات وتخصيص المظهر'), findsOneWidget);
  });
}
