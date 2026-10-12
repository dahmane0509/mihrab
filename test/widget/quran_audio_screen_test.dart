import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_app/screens/quran_audio_screen.dart';

void main() {
  testWidgets('QuranAudioScreen renders reciter selector and handles playback toggling', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuranAudioScreen(),
      ),
    );

    // Verify Title
    expect(find.text("القرآن الكريم (استماع)"), findsOneWidget);

    // Verify Reciter dropdown label and default reciter
    expect(find.text("القارئ:"), findsOneWidget);
    expect(find.textContaining("ياسين الجزائري"), findsOneWidget);

    // Verify Surahs list is populated
    expect(find.text("سورة الفاتحة"), findsOneWidget);
    expect(find.text("سورة البقرة"), findsOneWidget);

    // Tap play button on the first surah (Al-Fatiha)
    final playBtn = find.byIcon(Icons.play_circle_fill).first;
    expect(playBtn, findsOneWidget);
    await tester.tap(playBtn);
    await tester.pump();

    // Verify SnackBar shown and icon changed to pause
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining("جاري تشغيل سورة الفاتحة"), findsOneWidget);
    expect(find.byIcon(Icons.pause_circle_filled), findsOneWidget);

    // Tap pause button
    await tester.tap(find.byIcon(Icons.pause_circle_filled));
    await tester.pumpAndSettle();

    // Verify stop SnackBar shown
    expect(find.textContaining("تم إيقاف تلاوة سورة الفاتحة"), findsOneWidget);
  });
}
