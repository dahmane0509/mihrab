import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mihrab_app/services/silent_mode_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.mihrab.algeria.mihrab_app/settings');
  String currentMode = 'normal';
  bool dndGranted = true;
  bool dndSettingsOpened = false;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'isDndAccessGranted':
          return dndGranted;
        case 'openDndSettings':
          dndSettingsOpened = true;
          return true;
        case 'setRingerMode':
          final args = methodCall.arguments as Map<dynamic, dynamic>?;
          currentMode = args?['mode'] as String? ?? 'silent';
          return true;
        case 'getRingerMode':
          return currentMode;
        default:
          return null;
      }
    });

    SharedPreferences.setMockInitialValues({
      'auto_silent_mode': true,
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('SilentModeService queries DND access and opens settings correctly', () async {
    dndGranted = true;
    final granted = await SilentModeService.isDndAccessGranted();
    expect(granted, isTrue);

    dndSettingsOpened = false;
    final opened = await SilentModeService.openDndSettings();
    expect(opened, isTrue);
    expect(dndSettingsOpened, isTrue);
  });

  test('SilentModeService changes and retrieves ringer modes', () async {
    await SilentModeService.setRingerMode('silent');
    expect(await SilentModeService.getRingerMode(), equals('silent'));

    await SilentModeService.setRingerMode('vibrate');
    expect(await SilentModeService.getRingerMode(), equals('vibrate'));

    await SilentModeService.setRingerMode('normal');
    expect(await SilentModeService.getRingerMode(), equals('normal'));
  });

  test('enableMosqueSilentMode and restoreNormalMode toggle silent state', () async {
    expect(SilentModeService.isSilentActive, isFalse);

    final success = await SilentModeService.enableMosqueSilentMode(durationMinutes: 25);
    expect(success, isTrue);
    expect(SilentModeService.isSilentActive, isTrue);
    expect(await SilentModeService.getRingerMode(), equals('silent'));

    final restored = await SilentModeService.restoreNormalMode();
    expect(restored, isTrue);
    expect(SilentModeService.isSilentActive, isFalse);
    expect(await SilentModeService.getRingerMode(), equals('normal'));
  });

  test('enableMosqueSilentMode respects user preference when disabled', () async {
    SharedPreferences.setMockInitialValues({
      'auto_silent_mode': false,
    });

    final success = await SilentModeService.enableMosqueSilentMode(durationMinutes: 25);
    expect(success, isFalse);
    expect(SilentModeService.isSilentActive, isFalse);
  });
}
