import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_app/data/algeria_wilayas.dart';
import 'package:mihrab_app/screens/monthly_calendar_screen.dart';

void main() {
  testWidgets('MonthlyCalendarScreen renders monthly prayer schedule for selected wilaya', (WidgetTester tester) async {
    final wilaya = AlgeriaWilayas.getWilayaByCode(16); // Alger

    await tester.pumpWidget(
      MaterialApp(
        home: MonthlyCalendarScreen(currentWilaya: wilaya),
      ),
    );

    // Verify AppBar header with month and year
    final now = DateTime.now();
    expect(find.text("مواقيت شهر ${now.month} / ${now.year}"), findsOneWidget);

    // Verify wilaya name and schedule description
    expect(find.text("ولاية ${wilaya.nameAr}"), findsOneWidget);
    expect(find.text("إمساكية ومواقيت كامل الشهر"), findsOneWidget);

    // Verify ListView is rendered with calendar rows
    expect(find.byType(ListView), findsOneWidget);
    expect(find.textContaining("ف:"), findsWidgets);
    expect(find.textContaining("ظ:"), findsWidgets);
    expect(find.textContaining("ع:"), findsWidgets);
    expect(find.textContaining("م:"), findsWidgets);
    expect(find.textContaining("عش:"), findsWidgets);
  });
}
