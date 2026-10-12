import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mihrab_app/main.dart';
import 'package:mihrab_app/services/theme_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AlgeriaPrayerApp initializes and launches with active theme', (WidgetTester tester) async {
    await ThemeService.init();
    await tester.pumpWidget(const AlgeriaPrayerApp());

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify main app rendered MaterialApp and SplashScreen with brand name
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('مِـحْـرَابْ'), findsOneWidget);
    expect(find.text('مواقيت الصلاة والقرآن'), findsOneWidget);

    // Clean up
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
