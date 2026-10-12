import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_app/screens/live_broadcast_screen.dart';

void main() {
  testWidgets('LiveBroadcastScreen renders all Islamic radio channels and reacts to play interaction', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LiveBroadcastScreen(),
      ),
    );

    await tester.pump();

    // Verify Screen Title
    expect(find.text("البث المباشر الإسلامي"), findsOneWidget);

    // Verify Header Banner
    expect(find.text("إذاعات وقنوات حية"), findsOneWidget);
    expect(find.text("مباشر 24/7"), findsOneWidget);

    // Verify Core Channels in the list
    expect(find.text("إذاعة القرآن الكريم الجزائرية"), findsOneWidget);
    expect(find.text("قناة القرآن الكريم - مكة المكرمة"), findsOneWidget);

    // Verify Action button "بث حي"
    final playButtons = find.text("بث حي");
    expect(playButtons, findsWidgets);

    // Tap first channel to start broadcast
    await tester.tap(playButtons.first);
    await tester.pump();

    // Verify feedback SnackBar appears
    expect(find.textContaining("جاري الاتصال بالبث المباشر"), findsOneWidget);
    expect(find.text("إيقاف"), findsOneWidget);
  });
}
