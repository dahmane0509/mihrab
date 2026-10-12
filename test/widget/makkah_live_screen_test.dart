import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_app/screens/makkah_live_screen.dart';

void main() {
  testWidgets('MakkahLiveScreen renders live broadcast cards and handles interaction', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MakkahLiveScreen(),
      ),
    );

    // Initial render
    expect(find.text("مكة والمدينة مباشر"), findsOneWidget);
    expect(find.textContaining("المسجد الحرام"), findsOneWidget);
    expect(find.textContaining("المسجد النبوي"), findsWidgets);
    expect(find.text("مباشر LIVE"), findsNWidgets(2));
    expect(find.text("مشاهدة البث الآن"), findsNWidgets(2));

    // Tap first watch broadcast button
    await tester.tap(find.text("مشاهدة البث الآن").first);
    await tester.pump();

    // Verify SnackBar shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining("جاري فتح البث المباشر"), findsOneWidget);
  });
}
