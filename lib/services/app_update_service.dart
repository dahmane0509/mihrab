// Updated v1.0.1
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';

/// Information regarding app version and remote updates
class AppUpdateInfo {
  final bool hasUpdate;
  final String currentVersion;
  final String currentBuildNumber;
  final String latestVersion;
  final String? releaseTitle;
  final String? releaseNotes;
  final String? downloadUrl;
  final DateTime? releaseDate;
  final bool isSuccess;
  final String? errorMessage;

  const AppUpdateInfo({
    required this.hasUpdate,
    required this.currentVersion,
    required this.currentBuildNumber,
    required this.latestVersion,
    this.releaseTitle,
    this.releaseNotes,
    this.downloadUrl,
    this.releaseDate,
    required this.isSuccess,
    this.errorMessage,
  });
}

/// Service to check current app version against remote releases/endpoints
class AppUpdateService {
  static const String defaultReleaseEndpoint =
      'https://api.github.com/repos/dahmane0509/mihrab/releases/latest';
  static const String defaultFallbackEndpoint =
      'https://raw.githubusercontent.com/dahmane0509/mihrab/main/version.json';
  static const String defaultWebReleaseUrl =
      'https://github.com/dahmane0509/mihrab/releases';

  /// Compare two semantic version strings (e.g. "1.1.0" > "1.0.2")
  static bool isVersionNewer(String latest, String current) {
    try {
      final cleanLatest = latest.replaceAll(RegExp(r'[^0-9.]'), '');
      final cleanCurrent = current.replaceAll(RegExp(r'[^0-9.]'), '');

      final latestParts = cleanLatest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final currentParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLength = latestParts.length > currentParts.length ? latestParts.length : currentParts.length;
      while (latestParts.length < maxLength) {
        latestParts.add(0);
      }
      while (currentParts.length < maxLength) {
        currentParts.add(0);
      }

      for (int i = 0; i < maxLength; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Get current package info securely
  static Future<PackageInfo> getPackageInfo() async {
    try {
      return await PackageInfo.fromPlatform();
    } catch (_) {
      return PackageInfo(
        appName: 'مِحْراب',
        packageName: 'com.mihrab.algeria.mihrab_app',
        version: '1.0.4',
        buildNumber: '1',
        buildSignature: '',
      );
    }
  }

  /// Check whether an update is available on GitHub or remote version endpoint
  static Future<AppUpdateInfo> checkForUpdates({
    String endpoint = defaultReleaseEndpoint,
    http.Client? client,
  }) async {
    final packageInfo = await getPackageInfo();
    final currentVer = packageInfo.version;
    final currentBuild = packageInfo.buildNumber;

    final httpClient = client ?? http.Client();

    try {
      final uri = Uri.parse(endpoint);
      final response = await httpClient.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Mihrab-Islamic-App',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tagName = (data['tag_name'] ?? data['version'] ?? '') as String;
        final cleanTag = tagName.replaceAll(RegExp(r'^[vV]'), '').trim();
        final releaseName = (data['name'] ?? 'تحديث محراب الجديد') as String;
        final body = (data['body'] ?? data['notes'] ?? 'تحسينات جديدة في الأداء ودقة مواقيت الصلاة.') as String;
        final htmlUrl = (data['html_url'] ?? data['download_url'] ?? defaultWebReleaseUrl) as String;

        DateTime? pubDate;
        if (data['published_at'] != null) {
          pubDate = DateTime.tryParse(data['published_at'] as String);
        }

        final hasNewer = isVersionNewer(cleanTag, currentVer);

        return AppUpdateInfo(
          hasUpdate: hasNewer,
          currentVersion: currentVer,
          currentBuildNumber: currentBuild,
          latestVersion: cleanTag.isNotEmpty ? cleanTag : currentVer,
          releaseTitle: releaseName,
          releaseNotes: body,
          downloadUrl: htmlUrl,
          releaseDate: pubDate,
          isSuccess: true,
        );
      } else if (response.statusCode == 404) {
        // No published releases yet on this repository: up to date!
        return AppUpdateInfo(
          hasUpdate: false,
          currentVersion: currentVer,
          currentBuildNumber: currentBuild,
          latestVersion: currentVer,
          releaseTitle: 'أحدث إصدار',
          releaseNotes: 'أنت تعمل على أحدث نسخة مستقرة من محراب.',
          downloadUrl: defaultWebReleaseUrl,
          isSuccess: true,
        );
      } else {
        return AppUpdateInfo(
          hasUpdate: false,
          currentVersion: currentVer,
          currentBuildNumber: currentBuild,
          latestVersion: currentVer,
          isSuccess: false,
          errorMessage: 'رمز الاستجابة: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AppUpdateInfo(
        hasUpdate: false,
        currentVersion: currentVer,
        currentBuildNumber: currentBuild,
        latestVersion: currentVer,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  /// Launch update link in external browser
  static Future<bool> launchUpdateUrl(String? url) async {
    final target = Uri.parse(url ?? defaultWebReleaseUrl);
    try {
      return await launchUrl(target, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        return await launchUrl(target, mode: LaunchMode.platformDefault);
      } catch (_) {
        return false;
      }
    }
  }

  /// Displays interactive update dialog to user
  static Future<void> showUpdateDialog(
    BuildContext context, {
    AppThemeColor? theme,
  }) async {
    final activeTheme = theme ?? ThemeService.currentTheme.value;
    final isAr = LanguageService.languageCode == 'ar';

    // 1. Show loading indicator dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: activeTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: activeTheme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(activeTheme.primary),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                LanguageService.tr('settings_checking_updates'),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    // 2. Perform check
    final result = await checkForUpdates();

    // 3. Dismiss loading dialog
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (!context.mounted) return;

    // 4. Show result dialog
    showDialog<void>(
      context: context,
      builder: (dlgContext) {
        if (!result.isSuccess) {
          // Offline or unreachable
          return AlertDialog(
            backgroundColor: activeTheme.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.amber.withValues(alpha: 0.4), width: 1.2),
            ),
            title: Row(
              children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.amber, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isAr ? "تعذر فحص التحديثات" : "Unable to Check Updates",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr
                      ? "تعذر الاتصال بخادم التحديثات في الوقت الحالي. يرجى التحقق من اتصالك بالإنترنت والمحاولة لاحقاً."
                      : "Could not reach the update server. Please check your internet connection and try again.",
                  style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: activeTheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${LanguageService.tr('settings_current_version')}: v${result.currentVersion} (${result.currentBuildNumber})",
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dlgContext),
                child: Text(isAr ? "إغلاق" : "Close", style: const TextStyle(color: Colors.white70)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeTheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(isAr ? "إعادة المحاولة" : "Retry"),
                onPressed: () {
                  Navigator.pop(dlgContext);
                  showUpdateDialog(context, theme: activeTheme);
                },
              ),
            ],
          );
        }

        if (result.hasUpdate) {
          // New update available!
          return AlertDialog(
            backgroundColor: activeTheme.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: activeTheme.primary, width: 1.5),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: activeTheme.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.system_update_rounded, color: activeTheme.primary, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LanguageService.tr('settings_update_available_title'),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "v${result.latestVersion} (الحالي: v${result.currentVersion})",
                        style: TextStyle(color: activeTheme.accent, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? "ما الجديد في هذا التحديث:" : "What's new in this update:",
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 180),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      result.releaseNotes ?? (isAr ? "تحسينات عامة على مواقيت الصلاة والأذان." : "General improvements."),
                      style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12, height: 1.6),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dlgContext),
                child: Text(LanguageService.tr('settings_later_btn'), style: const TextStyle(color: Colors.white60)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeTheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(
                  LanguageService.tr('settings_update_now_btn'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(dlgContext);
                  launchUpdateUrl(result.downloadUrl);
                },
              ),
            ],
          );
        }

        // Up to date!
        return AlertDialog(
          backgroundColor: activeTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: activeTheme.primary.withValues(alpha: 0.5), width: 1.2),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  LanguageService.tr('settings_latest_version_dialog_title'),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LanguageService.tr('settings_latest_version_dialog_msg'),
                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.smartphone_rounded, color: Color(0xFF34D399), size: 18),
                    const SizedBox(width: 10),
                    Text(
                      "${LanguageService.tr('settings_current_version')}: v${result.currentVersion} (${result.currentBuildNumber})",
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: activeTheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () => Navigator.pop(dlgContext),
              child: Text(isAr ? "تم، شكراً لك" : "OK"),
            ),
          ],
        );
      },
    );
  }
}
