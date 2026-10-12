import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mihrab_app/services/auto_adhkar_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AutoAdhkarService.loadSettings();
  });

  group('AutoAdhkarService Tests', () {
    test('Default authentic adhkar library is populated and enabled by default', () {
      expect(AutoAdhkarService.allAdhkar.length, greaterThanOrEqualTo(15));
      expect(AutoAdhkarService.enabledAdhkar.isNotEmpty, isTrue);

      final first = AutoAdhkarService.allAdhkar.first;
      expect(first.text, contains('سُبْحَانَ اللَّهِ'));
      expect(first.isEnabled, isTrue);
    });

    test('Can toggle dhikr item enabled and disabled state', () async {
      final first = AutoAdhkarService.allAdhkar.first;
      final originalState = first.isEnabled;

      await AutoAdhkarService.toggleDhikr(first.id, !originalState);
      expect(first.isEnabled, equals(!originalState));

      // Restore
      await AutoAdhkarService.toggleDhikr(first.id, originalState);
      expect(first.isEnabled, equals(originalState));
    });

    test('Can add a user-customized dhikr or dua and persist it', () async {
      const customText = 'اللَّهُمَّ بَارِكْ لَنَا فِي أَوْقَاتِنَا وَأَعْمَالِنَا';
      const customVirtue = 'دعاء البركة والتوفيق';

      final newItem = await AutoAdhkarService.addCustomDhikr(
        text: customText,
        virtue: customVirtue,
        category: 'تيسير الأمور',
      );

      expect(newItem.isCustom, isTrue);
      expect(newItem.text, equals(customText));
      expect(newItem.virtue, equals(customVirtue));
      expect(AutoAdhkarService.allAdhkar.any((i) => i.id == newItem.id), isTrue);

      // Verify removal
      await AutoAdhkarService.deleteCustomDhikr(newItem.id);
      expect(AutoAdhkarService.allAdhkar.any((i) => i.id == newItem.id), isFalse);
    });

    test('Settings changes (enabled, interval, sound) persist to SharedPreferences', () async {
      AutoAdhkarService.isEnabled = false;
      AutoAdhkarService.intervalMinutes = 30;
      AutoAdhkarService.soundEnabled = true;

      await AutoAdhkarService.saveSettings();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('auto_adhkar_enabled'), isFalse);
      expect(prefs.getInt('auto_adhkar_interval_minutes'), equals(30));
      expect(prefs.getBool('auto_adhkar_sound_enabled'), isTrue);

      // Reload
      await AutoAdhkarService.loadSettings();
      expect(AutoAdhkarService.isEnabled, isFalse);
      expect(AutoAdhkarService.intervalMinutes, equals(30));
      expect(AutoAdhkarService.soundEnabled, isTrue);
    });

    test('getRandomEnabledDhikr returns an enabled dhikr', () {
      final dhikr = AutoAdhkarService.getRandomEnabledDhikr();
      expect(dhikr, isNotNull);
      expect(dhikr!.isEnabled, isTrue);
    });
  });
}
