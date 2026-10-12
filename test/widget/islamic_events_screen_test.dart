import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_app/screens/islamic_events_screen.dart';

void main() {
  testWidgets('IslamicEventsScreen renders hijri calendar and expands religious events', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IslamicEventsScreen(),
      ),
    );

    // Verify Title and today badge
    expect(find.text("التقويم والمناسبات الإسلامية"), findsOneWidget);
    expect(find.text("اليوم في التقويم الهجري"), findsOneWidget);
    expect(find.text("الأعياد والمناسبات الإسلامية العظمى"), findsOneWidget);

    // Verify presence of first Islamic holidays
    expect(find.text("رأس السنة الهجرية الجديدة"), findsOneWidget);
    expect(find.text("يوم عاشوراء المبارك"), findsOneWidget);

    // Expand New Hijri Year event
    await tester.tap(find.text("رأس السنة الهجرية الجديدة"));
    await tester.pumpAndSettle();

    // Verify details & virtues shown
    expect(find.textContaining("بداية العام الهجري الجديد"), findsOneWidget);
    expect(find.textContaining("الفضل والعمل المستحب"), findsOneWidget);
  });
}
