import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_app/screens/tasbih_screen.dart';

void main() {
  testWidgets('TasbihScreen renders phrases, counts taps, switches targets, and resets', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TasbihScreen(),
      ),
    );

    // Initial state
    expect(find.text("المسبحة الإلكترونية الذكية"), findsOneWidget);
    expect(find.text("سُبْحَانَ اللَّهِ"), findsWidgets);
    expect(find.text("0"), findsOneWidget);
    expect(find.text("من 33"), findsOneWidget);
    expect(find.text("0 تسبيحة"), findsOneWidget);

    // Tap circle to increment count
    await tester.tap(find.text("0"));
    await tester.pump();

    // Verify counter incremented to 1
    expect(find.text("1"), findsOneWidget);
    expect(find.text("1 تسبيحة"), findsOneWidget);

    // Switch target to 100
    await tester.tap(find.text("100"));
    await tester.pump();

    expect(find.text("من 100"), findsOneWidget);
    expect(find.text("0"), findsOneWidget); // counter reset on target switch

    // Tap twice
    await tester.tap(find.text("0"));
    await tester.pump();
    await tester.tap(find.text("1"));
    await tester.pump();

    expect(find.text("2"), findsOneWidget);

    // Tap reset button in AppBar
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    // Verify reset to 0
    expect(find.text("0"), findsOneWidget);
  });
}
