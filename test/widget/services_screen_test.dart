import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mihrab_app/data/algeria_communes.dart';
import 'package:mihrab_app/data/algeria_wilayas.dart';
import 'package:mihrab_app/screens/services_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ServicesScreen renders Islamic service cards and opens share dialog', (WidgetTester tester) async {
    final wilaya = AlgeriaWilayas.getWilayaByCode(16);
    final commune = AlgeriaCommunes.getCommunesByWilaya(16).first;

    bool drawerCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ServicesScreen(
          currentWilaya: wilaya,
          currentCommune: commune,
          onOpenDrawer: () {
            drawerCalled = true;
          },
        ),
      ),
    );

    await tester.pump();

    // Verify Title
    expect(find.text('الخدمات والميزات الإسلامية'), findsOneWidget);

    // Verify Core Service Cards visible initially
    expect(find.text('القرآن الكريم (قراءة واستماع)'), findsOneWidget);
    expect(find.text('حصن المسلم والسبحة الإلكترونية'), findsOneWidget);
    expect(find.text('أذكار الشاشة التلقائية أثناء التصفح'), findsOneWidget);
    expect(find.text('البث المباشر (مكة، المدينة، الجزائر)'), findsOneWidget);
    expect(find.text('بوصلة القبلة الدقيقة'), findsNothing);

    // Scroll to reveal lower cards
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();

    expect(find.text('التقويم والمناسبات الإسلامية'), findsOneWidget);
    expect(find.text('البحث عن المساجد وأماكن العبادة'), findsOneWidget);
    expect(find.text('الإعدادات العامة والمظهر'), findsOneWidget);

    // Test Drawer button
    final drawerBtn = find.byIcon(Icons.menu);
    expect(drawerBtn, findsOneWidget);
    await tester.tap(drawerBtn);
    await tester.pump();
    expect(drawerCalled, isTrue);

    // Tap on Share Card Service to navigate to QuranCardCreatorScreen
    await tester.tap(find.text('أنشئ وشارك بطاقات قرآنية'));
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify QuranCardCreatorScreen is visible
    expect(find.text('صانع ومشارك البطاقات القرآنية'), findsOneWidget);
    expect(find.text('مشاركة عبر التطبيقات'), findsOneWidget);
    expect(find.text('نسخ'), findsOneWidget);
  });
}
