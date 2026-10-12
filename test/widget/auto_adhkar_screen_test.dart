import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mihrab_app/screens/auto_adhkar_screen.dart';
import 'package:mihrab_app/services/auto_adhkar_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'auto_adhkar_enabled': true,
      'auto_adhkar_interval_minutes': 15,
      'auto_adhkar_sound_enabled': false,
    });
    await AutoAdhkarService.loadSettings();
  });

  testWidgets('AutoAdhkarScreen renders correctly and allows interaction', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AutoAdhkarScreen(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify AppBar Title
    expect(find.text('أذكار وأدعية الشاشة التلقائية'), findsOneWidget);

    // Verify Master toggle card
    expect(find.text('ظهور الأذكار التلقائي على الشاشة'), findsOneWidget);
    expect(find.textContaining('الأذكار المفعلة:'), findsOneWidget);

    // Verify Interval Chips
    expect(find.text('كل 15 دقيقة (مستحسن)'), findsOneWidget);
    expect(find.text('كل 30 دقيقة'), findsOneWidget);

    // Tap on ChoiceChip 30 mins
    await tester.tap(find.text('كل 30 دقيقة'));
    await tester.pump();
    expect(AutoAdhkarService.intervalMinutes, equals(30));

    // Test preview dialog button
    expect(find.text('اختبر الظهور الآن'), findsOneWidget);
    await tester.tap(find.text('اختبر الظهور الآن'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // BottomSheet preview appeared
    expect(find.text('معاينة الذكر المنبثق على الشاشة'), findsOneWidget);
    await tester.tap(find.text('حسناً'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Scroll down to reveal Adhkar list
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Adhkar list rendered
    expect(find.textContaining('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ'), findsWidgets);

    // Open Add Custom Dhikr dialog
    final addBtn = find.byTooltip('إضافة ذكر أو دعاء مخصص');
    expect(addBtn, findsOneWidget);
    await tester.tap(addBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('إضافة ذكر أو دعاء مخصص'), findsOneWidget);
    expect(find.text('حفظ الذكر'), findsOneWidget);
  });
}
