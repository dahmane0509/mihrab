import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mihrab_app/services/app_support_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'محراب',
      packageName: 'com.mihrab.algeria.mihrab_app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({
      'selected_wilaya': 16,
      'app_language': 'ar',
    });
  });

  group('AppSupportService Diagnostics Tests', () {
    test('getDeviceDiagnostics populates valid metadata', () async {
      final diag = await AppSupportService.getDeviceDiagnostics();

      expect(diag.appVersion, equals('1.0.0'));
      expect(diag.buildNumber, equals('1'));
      expect(diag.osName, isNotEmpty);
      expect(diag.activeWilaya, contains('16'));
      expect(diag.activeLanguage, equals('ar'));
    });

    test('toFormattedString returns structured report with arabic headers', () {
      const diag = DeviceDiagnostics(
        appVersion: '1.0.0',
        buildNumber: '1',
        osName: 'android',
        osVersion: 'Android 14',
        deviceModel: 'Pixel 8',
        deviceManufacturer: 'Google',
        activeWilaya: 'الجزائر (16)',
        activeLanguage: 'ar',
      );

      final formatted = diag.toFormattedString();

      expect(formatted, contains('معلومات النظام وتطبيق محراب:'));
      expect(formatted, contains('v1.0.0'));
      expect(formatted, contains('Android 14'));
      expect(formatted, contains('Pixel 8'));
      expect(formatted, contains('Google'));
      expect(formatted, contains('الجزائر (16)'));
    });
  });
}
