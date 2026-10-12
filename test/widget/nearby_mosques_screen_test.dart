import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_app/data/algeria_wilayas.dart';
import 'package:mihrab_app/screens/nearby_mosques_screen.dart';

void main() {
  testWidgets('NearbyMosquesScreen renders nearest mosques search and grand landmarks', (WidgetTester tester) async {
    final wilaya = AlgeriaWilayas.getWilayaByCode(16); // Alger

    await tester.pumpWidget(
      MaterialApp(
        home: NearbyMosquesScreen(currentWilaya: wilaya),
      ),
    );

    // Verify Title and buttons
    expect(find.text("البحث عن المساجد والأماكن القريبة"), findsOneWidget);
    expect(find.text("المساجد القريبة 🗺️"), findsOneWidget);
    expect(find.text("أكل حلال 🍽️"), findsOneWidget);

    // Verify prominent Algerian landmarks
    expect(find.text("جامع الجزائر (الجامع الأعظم)"), findsOneWidget);
    expect(find.text("جامع كتشاوة التاريخي"), findsOneWidget);

    // Tap nearby mosques button
    await tester.tap(find.text("المساجد القريبة 🗺️"));
    await tester.pump();

    // Verify SnackBar shown
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining("جاري فتح الخريطة للبحث عن"), findsOneWidget);
  });
}
