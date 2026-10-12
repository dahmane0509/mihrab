import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mihrab_app/screens/quran_card_creator_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
      return null;
    });
  });

  testWidgets('QuranCardCreatorScreen renders, switches categories, and allows copying', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuranCardCreatorScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & action buttons
    expect(find.text('صانع ومشارك البطاقات القرآنية'), findsOneWidget);
    expect(find.text('مشاركة عبر التطبيقات'), findsOneWidget);
    expect(find.text('نسخ'), findsWidgets);

    // Verify Bismillah and default verse
    expect(find.text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'), findsOneWidget);
    expect(find.textContaining('أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ'), findsWidgets);

    // Tap 'نسخ' button (ensure visible, then pump snackbar)
    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'نسخ'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'نسخ'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('تم نسخ محتوى البطاقة'), findsOneWidget);

    // Scroll to reveal categories
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -300));
    await tester.pumpAndSettle();

    // Tap on category 'أحاديث نبوية'
    await tester.tap(find.text('أحاديث نبوية'));
    await tester.pumpAndSettle();
    expect(find.textContaining('كَلِمَتَانِ خَفِيفَتَانِ'), findsWidgets);

    // Switch to 'اكتب نصك الخاص'
    await tester.tap(find.text('اكتب نصك الخاص'));
    await tester.pumpAndSettle();
    expect(find.text('نص البطاقة الخاص بك:'), findsOneWidget);

    // Enter custom text
    await tester.enterText(find.byType(TextField).first, 'دعاء مبارك للتجربة');
    await tester.pump();

    // Scroll back to top to check preview
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, 400));
    await tester.pumpAndSettle();

    expect(find.text('دعاء مبارك للتجربة'), findsWidgets);
  });
}
