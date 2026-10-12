import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_app/screens/adhkar_screen.dart';

void main() {
  testWidgets('AdhkarScreen renders category tabs, lists dhikr, and tests counter increment', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdhkarScreen(),
      ),
    );

    await tester.pump();

    // Verify Screen Title
    expect(find.text('حصن المسلم والسبحة الإلكترونية'), findsOneWidget);

    // Verify TabBar categories
    expect(find.text('أذكار الصباح'), findsOneWidget);
    expect(find.text('أذكار المساء'), findsOneWidget);
    expect(find.text('السبحة الإلكترونية 📿'), findsOneWidget);

    // Verify at least one Dhikr item is displayed
    expect(find.textContaining('أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ'), findsOneWidget);

    // Find first Dhikr counter increment button
    final countButton = find.text('0 / 1').first;
    expect(countButton, findsOneWidget);

    // Tap to increment count
    await tester.tap(countButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify item completion status
    expect(find.text('اكتمل ✔'), findsOneWidget);

    // Reset button
    final resetBtn = find.byTooltip('إعادة العداد').first;
    await tester.tap(resetBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify reset back to 0 / 1
    expect(find.text('0 / 1'), findsNWidgets(2));

    // Switch to 'أذكار المساء' tab (adjacent visible tab)
    await tester.tap(find.text('أذكار المساء'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify evening dhikr items appear
    expect(find.textContaining('أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ'), findsOneWidget);

    // Scroll TabBar to reach the last tab 'السبحة الإلكترونية 📿'
    await tester.drag(find.byType(TabBar), const Offset(-500, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('السبحة الإلكترونية 📿'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Tasbeeh screen elements
    expect(find.text('انقر للتسبيح'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
  });
}
