import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mihrab_app/data/algeria_communes.dart';
import 'package:mihrab_app/data/algeria_wilayas.dart';
import 'package:mihrab_app/widgets/app_drawer.dart';
import 'package:mihrab_app/services/language_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('AppDrawer renders correctly with header and menu options', (WidgetTester tester) async {
    final wilaya = AlgeriaWilayas.getWilayaByCode(16);
    final commune = AlgeriaCommunes.getCommunesByWilaya(16).first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          drawer: AppDrawer(
            currentWilaya: wilaya,
            currentCommune: commune,
            onLocationChanged: (_, __) {},
          ),
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Text('Open Drawer'),
            ),
          ),
        ),
      ),
    );

    // Initial render
    expect(find.text('Open Drawer'), findsOneWidget);

    // Open drawer
    await tester.tap(find.text('Open Drawer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify App Brand Header
    expect(find.text('مِحْرَاب'), findsOneWidget);
    expect(find.text('موقعك الحالي: ${commune.nameAr} (${wilaya.nameAr})'), findsOneWidget);

    // Verify Navigation List Tiles
    expect(find.text('تشغيل صوت الأذان'), findsOneWidget);
    expect(find.text('البث المباشر (مكة، المدينة، الجزائر)'), findsOneWidget);
    expect(find.text('المناسبات الإسلامية والتقويم'), findsOneWidget);
    expect(find.text('المساجد القريبة ودليل المعالم'), findsOneWidget);

    // Scroll to reveal lower items
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('الإعدادات وتخصيص المظهر'), findsOneWidget);
    expect(find.text('عن تطبيق مِحْرَاب'), findsOneWidget);

    // Tap on About option
    await tester.tap(find.text('عن تطبيق مِحْرَاب'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify AboutDialog appeared
    expect(find.byType(AboutDialog), findsOneWidget);
  });

  testWidgets('AppDrawer updates text when switching language to English', (WidgetTester tester) async {
    final wilaya = AlgeriaWilayas.getWilayaByCode(16);
    final commune = AlgeriaCommunes.getCommunesByWilaya(16).first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          drawer: AppDrawer(
            currentWilaya: wilaya,
            currentCommune: commune,
            onLocationChanged: (_, __) {},
          ),
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Text('Open Drawer'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Drawer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Scroll to reveal language chips
    await tester.dragUntilVisible(
      find.text('🇬🇧 EN'),
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.pump(const Duration(milliseconds: 300));

    // Tap English chip
    await tester.tap(find.text('🇬🇧 EN'), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify translated elements in drawer
    expect(find.text('About Mihrab'), findsOneWidget);

    // Scroll up
    await tester.dragUntilVisible(
      find.text('Play Adhan Sound'),
      find.byType(ListView),
      const Offset(0, 100),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Play Adhan Sound'), findsOneWidget);
    expect(find.text('Islamic Events & Calendar'), findsOneWidget);

    // Reset language back to Arabic
    await LanguageService.setLanguage('ar');
  });

}

