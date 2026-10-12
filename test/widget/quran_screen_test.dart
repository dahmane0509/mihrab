import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_app/screens/quran_screen.dart';

void main() {
  testWidgets('QuranScreen displays reading and listening tabs, search field, surahs list, and reciter options', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuranScreen(),
      ),
    );

    await tester.pump();

    // Verify AppBar Title
    expect(find.text("القرآن الكريم (قراءة واستماع)"), findsOneWidget);

    // Verify Tabs
    expect(find.text("قراءة القرآن"), findsOneWidget);
    expect(find.text("استماع وتلاوة"), findsOneWidget);

    // Verify Search Field
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text("ابحث عن السورة (بالاسم أو الرقم)..."), findsOneWidget);

    // Verify initial Surahs are displayed in Reading list
    expect(find.widgetWithText(ListTile, "الفاتحة"), findsWidgets);
    expect(find.widgetWithText(ListTile, "البقرة"), findsWidgets);

    // Test Search Filtering
    await tester.enterText(find.byType(TextField), "الكهف");
    await tester.pump();

    expect(find.widgetWithText(ListTile, "الكهف"), findsOneWidget);
    expect(find.widgetWithText(ListTile, "البقرة"), findsNothing);

    // Clear search filter
    await tester.enterText(find.byType(TextField), "");
    await tester.pump();

    // Switch to 'استماع وتلاوة' tab
    await tester.tap(find.text("استماع وتلاوة"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify reciter selection section
    expect(find.text("القارئ:"), findsOneWidget);
    expect(find.textContaining("ياسين الجزائري"), findsWidgets);

    // Verify listening buttons in audio list
    expect(find.text("استماع"), findsWidgets);
  });
}
