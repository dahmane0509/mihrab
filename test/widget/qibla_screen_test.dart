import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_app/data/algeria_wilayas.dart';
import 'package:mihrab_app/screens/qibla_screen.dart';
import 'package:mihrab_app/services/language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LanguageService.init();
    await LanguageService.setLanguage('ar');
  });

  testWidgets('QiblaScreen renders compass, Kaaba angle, distance and handles drawer callback', (WidgetTester tester) async {
    final wilaya = AlgeriaWilayas.getWilayaByCode(16); // Alger
    bool drawerTriggered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: QiblaScreen(
          currentWilaya: wilaya,
          onOpenDrawer: () {
            drawerTriggered = true;
          },
        ),
      ),
    );

    await tester.pump();

    // Verify AppBar Title with Wilaya name
    expect(find.text("بوصلة القبلة - ${wilaya.nameAr}"), findsOneWidget);

    // Verify Angle and Distance Information Cards
    expect(find.textContaining("زاوية القبلة"), findsOneWidget);
    expect(find.text("المسافة إلى مكة"), findsOneWidget);
    expect(find.textContaining("كم"), findsOneWidget);

    // Verify Compass Cardinal directions
    expect(find.text("N"), findsOneWidget);
    expect(find.text("S"), findsOneWidget);
    expect(find.text("E"), findsOneWidget);
    expect(find.text("W"), findsOneWidget);

    // Verify Kaaba marker
    expect(find.text("القبلة"), findsOneWidget);
    expect(find.byIcon(Icons.mosque), findsOneWidget);

    // Verify Calibration note at bottom
    expect(find.textContaining("احمل الهاتف أفقياً"), findsOneWidget);

    // Verify Drawer button interaction
    final menuBtn = find.byIcon(Icons.menu);
    expect(menuBtn, findsOneWidget);
    await tester.tap(menuBtn);
    await tester.pump();
    expect(drawerTriggered, isTrue);
  });

  testWidgets('QiblaScreen updates language dynamically to English', (WidgetTester tester) async {
    final wilaya = AlgeriaWilayas.getWilayaByCode(16); // Alger

    await tester.pumpWidget(
      MaterialApp(
        home: QiblaScreen(
          currentWilaya: wilaya,
        ),
      ),
    );

    await tester.pump();

    // Switch to English
    await LanguageService.setLanguage('en');
    await tester.pumpAndSettle();

    // Verify localized elements in English
    expect(find.text("Qibla Compass - ${wilaya.nameFr}"), findsOneWidget);
    expect(find.textContaining("Qibla Angle"), findsOneWidget);
    expect(find.textContaining("° East"), findsOneWidget);
    expect(find.text("Distance to Makkah"), findsOneWidget);
    expect(find.textContaining("km"), findsOneWidget);
    expect(find.text("Qibla"), findsOneWidget);
    expect(find.textContaining("Hold phone flat"), findsOneWidget);
  });
}
