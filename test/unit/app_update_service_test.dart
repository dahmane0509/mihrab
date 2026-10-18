import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mihrab_app/services/app_update_service.dart';

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
  });

  group('AppUpdateService Version Comparison Tests', () {
    test('isVersionNewer correctly identifies newer versions', () {
      expect(AppUpdateService.isVersionNewer('1.1.0', '1.0.0'), isTrue);
      expect(AppUpdateService.isVersionNewer('1.0.1', '1.0.0'), isTrue);
      expect(AppUpdateService.isVersionNewer('2.0.0', '1.9.9'), isTrue);
      expect(AppUpdateService.isVersionNewer('v1.2.0', '1.1.0'), isTrue);
      expect(AppUpdateService.isVersionNewer('v2.1.0', 'v2.0.9'), isTrue);
    });

    test('isVersionNewer returns false for equal or older versions', () {
      expect(AppUpdateService.isVersionNewer('1.0.0', '1.0.0'), isFalse);
      expect(AppUpdateService.isVersionNewer('0.9.9', '1.0.0'), isFalse);
      expect(AppUpdateService.isVersionNewer('v1.0.0', '1.0.0'), isFalse);
      expect(AppUpdateService.isVersionNewer('1.0.0', '1.1.0'), isFalse);
    });
  });

  group('AppUpdateService Remote Endpoint Tests', () {
    test('checkForUpdates detects new release when remote version is higher', () async {
      final mockClient = MockClient((request) async {
        final body = jsonEncode({
          'tag_name': 'v1.2.0',
          'name': 'محراب v1.2.0 - أصوات أذان جديدة',
          'body': '• إضافة أذان جامع الجزائر بجودة عالية\n• تحسين حساب مواقيت الصلاة',
          'html_url': 'https://github.com/amir0509/mihrab/releases/tag/v1.2.0',
          'published_at': '2026-10-18T12:00:00Z',
        });
        return http.Response(body, 200, headers: {'content-type': 'application/json'});
      });

      final result = await AppUpdateService.checkForUpdates(
        endpoint: 'https://api.github.com/repos/amir0509/mihrab/releases/latest',
        client: mockClient,
      );

      expect(result.isSuccess, isTrue);
      expect(result.hasUpdate, isTrue);
      expect(result.latestVersion, equals('1.2.0'));
      expect(result.currentVersion, equals('1.0.0'));
      expect(result.releaseTitle, contains('v1.2.0'));
      expect(result.releaseNotes, contains('جامع الجزائر'));
      expect(result.downloadUrl, contains('v1.2.0'));
    });

    test('checkForUpdates reports up-to-date when version matches', () async {
      final mockClient = MockClient((request) async {
        final body = jsonEncode({
          'tag_name': 'v1.0.0',
          'name': 'الإصدار الأولي',
          'body': 'النسخة الحالية',
          'html_url': 'https://github.com/amir0509/mihrab/releases/tag/v1.0.0',
        });
        return http.Response(body, 200, headers: {'content-type': 'application/json'});
      });

      final result = await AppUpdateService.checkForUpdates(
        endpoint: 'https://api.github.com/repos/amir0509/mihrab/releases/latest',
        client: mockClient,
      );

      expect(result.isSuccess, isTrue);
      expect(result.hasUpdate, isFalse);
      expect(result.latestVersion, equals('1.0.0'));
    });

    test('checkForUpdates handles 404 gracefully when no releases are published', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"message": "Not Found"}', 404);
      });

      final result = await AppUpdateService.checkForUpdates(
        endpoint: 'https://api.github.com/repos/amir0509/mihrab/releases/latest',
        client: mockClient,
      );

      expect(result.isSuccess, isTrue);
      expect(result.hasUpdate, isFalse);
    });

    test('checkForUpdates handles network exceptions gracefully', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Connection failed');
      });

      final result = await AppUpdateService.checkForUpdates(
        endpoint: 'https://invalid-host-mihrab.org/version',
        client: mockClient,
      );

      expect(result.isSuccess, isFalse);
      expect(result.hasUpdate, isFalse);
      expect(result.errorMessage, isNotNull);
    });
  });
}
