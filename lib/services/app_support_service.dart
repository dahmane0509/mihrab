import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';
import '../data/algeria_wilayas.dart';

/// Collected diagnostic information about device and app state
class DeviceDiagnostics {
  final String appVersion;
  final String buildNumber;
  final String osName;
  final String osVersion;
  final String deviceModel;
  final String deviceManufacturer;
  final String activeWilaya;
  final String activeLanguage;

  const DeviceDiagnostics({
    required this.appVersion,
    required this.buildNumber,
    required this.osName,
    required this.osVersion,
    required this.deviceModel,
    required this.deviceManufacturer,
    required this.activeWilaya,
    required this.activeLanguage,
  });

  String toFormattedString() {
    return '''
=============================
معلومات النظام وتطبيق محراب:
• التطبيق: محراب (Mihrab App)
• الإصدار: v$appVersion (Build $buildNumber)
• نظام التشغيل: $osName $osVersion
• الجهاز والمصنع: $deviceManufacturer - $deviceModel
• الولاية / المدينة: $activeWilaya
• لغة الواجهة: $activeLanguage
=============================
''';
  }
}

/// Service providing bug reporting and feature suggestion capabilities
class AppSupportService {
  static const String supportEmail = 'contact@mihrab-app.com';

  /// Retrieves device diagnostics safely across all platforms
  static Future<DeviceDiagnostics> getDeviceDiagnostics() async {
    String appVer = '1.0.2';
    String buildNum = '1';
    try {
      final pkg = await PackageInfo.fromPlatform();
      appVer = pkg.version;
      buildNum = pkg.buildNumber;
    } catch (_) {}

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return DeviceDiagnostics(
        appVersion: appVer,
        buildNumber: buildNum,
        osName: 'Flutter Test',
        osVersion: 'Test Runner',
        deviceModel: 'Mock Device',
        deviceManufacturer: 'Mihrab Test',
        activeWilaya: 'الجزائر العاصمة (16)',
        activeLanguage: LanguageService.languageCode,
      );
    }

    String osName = Platform.operatingSystem;
    String osVer = Platform.operatingSystemVersion;
    String model = 'Unknown';
    String manufacturer = 'Unknown';

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          final android = await deviceInfo.androidInfo;
          model = android.model;
          manufacturer = android.manufacturer;
          osVer = "Android ${android.version.release} (SDK ${android.version.sdkInt})";
        } else if (Platform.isIOS) {
          final ios = await deviceInfo.iosInfo;
          model = ios.utsname.machine;
          manufacturer = 'Apple';
          osVer = "iOS ${ios.systemVersion}";
        } else if (Platform.isWindows) {
          final win = await deviceInfo.windowsInfo;
          model = win.computerName;
          manufacturer = 'PC/Windows';
          osVer = "Windows ${win.productName}";
        }
      }
    } catch (_) {}

    String wilayaName = 'الجزائر العاصمة (16)';
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getInt('selected_wilaya') ?? 16;
      final w = AlgeriaWilayas.getWilayaByCode(code);
      wilayaName = "${w.nameAr} (${w.code})";
    } catch (_) {}

    final lang = LanguageService.languageCode;

    return DeviceDiagnostics(
      appVersion: appVer,
      buildNumber: buildNum,
      osName: osName,
      osVersion: osVer,
      deviceModel: model,
      deviceManufacturer: manufacturer,
      activeWilaya: wilayaName,
      activeLanguage: lang,
    );
  }

  /// Launch email client with pre-filled subject and body
  static Future<bool> sendEmail({
    required String subject,
    required String body,
    String recipient = supportEmail,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: recipient,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return true;
    } catch (_) {}

    try {
      return await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (_) {
      return false;
    }
  }

  /// Displays the interactive "بلّغ عن خطأ" (Report a Bug) modal sheet
  static Future<void> showBugReportSheet(
    BuildContext context, {
    AppThemeColor? theme,
  }) async {
    final activeTheme = theme ?? ThemeService.currentTheme.value;
    final isAr = LanguageService.languageCode == 'ar';
    final diagnostics = await getDeviceDiagnostics();

    if (!context.mounted) return;

    final categories = isAr
        ? [
            "مواقيت الصلاة",
            "صوت الأذان والتنبيهات",
            "القرآن الكريم والأذكار",
            "بوصلة القبلة",
            "الوضع الصامت للمسجد",
            "مشكلة أخرى",
          ]
        : [
            "Prayer Times",
            "Adhan & Audio",
            "Quran & Adhkar",
            "Qibla Compass",
            "Mosque Silent Mode",
            "Other Issue",
          ];

    String selectedCategory = categories.first;
    final descController = TextEditingController();
    bool includeDiagnostics = true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.88,
              decoration: BoxDecoration(
                color: activeTheme.cardBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: activeTheme.primary.withValues(alpha: 0.5), width: 1.2),
              ),
              child: Column(
                children: [
                  // Handle bar
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFB7185).withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.bug_report_rounded, color: Color(0xFFFB7185), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? "الإبلاغ عن خطأ أو مشكلة تقنية" : "Report a Bug or Issue",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isAr ? "نحرص على دقة مواقيتك واستقرار تطبيق محراب" : "Help us improve prayer time accuracy and stability",
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 24),

                  // Form content
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // Category selection
                        Text(
                          isAr ? "قسم المشكلة:" : "Problem Category:",
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categories.map((cat) {
                            final isSel = cat == selectedCategory;
                            return ChoiceChip(
                              label: Text(cat, style: TextStyle(
                                color: isSel ? Colors.black : Colors.white70,
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              )),
                              selected: isSel,
                              selectedColor: activeTheme.primary,
                              backgroundColor: const Color(0xFF0F172A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: isSel ? activeTheme.primary : Colors.white12,
                                ),
                              ),
                              onSelected: (val) {
                                if (val) setState(() => selectedCategory = cat);
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Description
                        Text(
                          isAr ? "وصف المشكلة بالتفصيل:" : "Detailed Description:",
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descController,
                          maxLines: 5,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: isAr
                                ? "يرجى توضيح ما حدث معك، مثلاً: وقت الصلاة المتأخر بدقيقة، أو عدم انطلاق أذان العصر..."
                                : "Describe what happened, e.g. prayer alert timing or audio playback issue...",
                            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: activeTheme.primary, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Device Diagnostics Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: activeTheme.primary, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isAr ? "بيانات الجهاز والنظام المرفقة بالتقرير:" : "Diagnostic details attached to report:",
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Switch(
                                    value: includeDiagnostics,
                                    activeThumbColor: activeTheme.primary,
                                    onChanged: (val) => setState(() => includeDiagnostics = val),
                                  ),
                                ],
                              ),
                              if (includeDiagnostics) ...[
                                const SizedBox(height: 8),
                                Text(
                                  "• ${diagnostics.osName} (${diagnostics.osVersion})\n"
                                  "• الجهاز: ${diagnostics.deviceManufacturer} ${diagnostics.deviceModel}\n"
                                  "• إصدار محراب: v${diagnostics.appVersion} (${diagnostics.buildNumber})\n"
                                  "• الولاية المختارة: ${diagnostics.activeWilaya}",
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, height: 1.5),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // Bottom Action Buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: activeTheme.primary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.email_outlined, size: 20),
                            label: Text(
                              isAr ? "إرسال التقرير عبر البريد" : "Send Report via Email",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            onPressed: () async {
                              final text = descController.text.trim();
                              if (text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.amber[800],
                                    content: Text(isAr ? "يرجى كتابة وصف موجز للمشكلة أولاً" : "Please provide a brief description"),
                                  ),
                                );
                                return;
                              }

                              final subject = "[تقرير خطأ محراب] - $selectedCategory (v${diagnostics.appVersion})";
                              final body = '''
السلام عليكم ورحمة الله،
أود الإبلاغ عن مشكلة في تطبيق محراب:

تصنيف المشكلة: $selectedCategory

وصف المشكلة:
$text

${includeDiagnostics ? diagnostics.toFormattedString() : ''}
''';

                              final sent = await sendEmail(subject: subject, body: body);

                              if (!context.mounted) return;
                              Navigator.pop(sheetContext);

                              if (sent) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Color(0xFF065F46),
                                    content: Text("جاري فتح تطبيق البريد لإرسال تقريرك، جزاكم الله خيراً 📨"),
                                  ),
                                );
                              } else {
                                // Fallback: copy to clipboard
                                await Clipboard.setData(ClipboardData(text: "$subject\n\n$body"));
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF1E293B),
                                    duration: const Duration(seconds: 4),
                                    content: Text(isAr
                                        ? "تم نسخ التقرير إلى الحافظة. يمكنك لصقه وإرساله إلى: $supportEmail"
                                        : "Report copied to clipboard. Send to $supportEmail"),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Displays the interactive "اقترح ميزة جديدة" (Request a Feature) modal
  static Future<void> showFeatureRequestSheet(
    BuildContext context, {
    AppThemeColor? theme,
  }) async {
    final activeTheme = theme ?? ThemeService.currentTheme.value;
    final isAr = LanguageService.languageCode == 'ar';
    final diagnostics = await getDeviceDiagnostics();

    if (!context.mounted) return;

    final categories = isAr
        ? [
            "إضافة صوت أذان جديد",
            "إضافة قارئ للقرآن",
            "مواقيت وإشعارات الصلاة",
            "ويدجت الشاشة الرئيسية",
            "أذكار وأدعية جديدة",
            "فكرة مبتكرة أخرى",
          ]
        : [
            "New Adhan Voice",
            "New Quran Reciter",
            "Prayer Times & Alerts",
            "Home Screen Widget",
            "New Adhkar & Duas",
            "Other Idea",
          ];

    String selectedCategory = categories.first;
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final emailController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.88,
              decoration: BoxDecoration(
                color: activeTheme.cardBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: activeTheme.accent.withValues(alpha: 0.5), width: 1.2),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: activeTheme.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: activeTheme.accent.withValues(alpha: 0.3)),
                          ),
                          child: Icon(Icons.lightbulb_rounded, color: activeTheme.accent, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr ? "اقترح ميزة جديدة لمحراب" : "Suggest a New Feature",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isAr ? "أفكاركم واقتراحاتكم هي أساس تطوير محراب" : "Your suggestions shape the future of Mihrab",
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 24),

                  // Form
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // Category chips
                        Text(
                          isAr ? "مجال الفكرة أو الميزة:" : "Feature Domain:",
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: categories.map((cat) {
                            final isSel = cat == selectedCategory;
                            return ChoiceChip(
                              label: Text(cat, style: TextStyle(
                                color: isSel ? Colors.black : Colors.white70,
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              )),
                              selected: isSel,
                              selectedColor: activeTheme.accent,
                              backgroundColor: const Color(0xFF0F172A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: isSel ? activeTheme.accent : Colors.white12,
                                ),
                              ),
                              onSelected: (val) {
                                if (val) setState(() => selectedCategory = cat);
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        Text(
                          isAr ? "عنوان الفكرة أو الميزة المقترحة:" : "Feature Title:",
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: titleController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: isAr ? "مثلاً: إضافة أذان الشيخ عبد الباسط، أو تنبيه قبل الإقامة..." : "e.g. Add Sheikh Abdulbasit Adhan...",
                            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: activeTheme.accent, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Description
                        Text(
                          isAr ? "تفاصيل الاقتراح وكيف سيفيد مستخدمي التطبيق:" : "Details and benefits for users:",
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descController,
                          maxLines: 4,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: isAr
                                ? "اشرح فكرتك بالتفصيل وروابط أي ملفات صوتية أو مصادر إن توفرت..."
                                : "Describe your idea and any reference links...",
                            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: activeTheme.accent, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Email (Optional)
                        Text(
                          isAr ? "بريدك الإلكتروني (اختياري لمتابعة اقتراحك):" : "Your email address (optional):",
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: "your.email@example.com",
                            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: activeTheme.accent, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // Submit button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: activeTheme.accent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.send_rounded, size: 20),
                            label: Text(
                              isAr ? "إرسال الاقتراح للمطورين" : "Submit Suggestion",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            onPressed: () async {
                              final title = titleController.text.trim();
                              final text = descController.text.trim();
                              final userMail = emailController.text.trim();

                              if (title.isEmpty || text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.amber[800],
                                    content: Text(isAr ? "يرجى كتابة عنوان الاقتراح وتفاصيله أولاً" : "Please provide title and details"),
                                  ),
                                );
                                return;
                              }

                              final subject = "[اقتراح ميزة لمحراب] - $title ($selectedCategory)";
                              final body = '''
السلام عليكم ورحمة الله،
أقترح إضافة الميزة التالية لتطبيق محراب:

المجال: $selectedCategory
عنوان الفكرة: $title

التفاصيل والفائدة المرجوة:
$text

${userMail.isNotEmpty ? "البريد الإلكتروني للمرسل: $userMail\n" : ""}
---
تم الإرسال عبر تطبيق محراب v${diagnostics.appVersion} (${diagnostics.osName})
''';

                              final sent = await sendEmail(subject: subject, body: body);

                              if (!context.mounted) return;
                              Navigator.pop(sheetContext);

                              if (sent) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Color(0xFF065F46),
                                    content: Text("تم فتح تطبيق البريد لإرسال اقتراحك، شكر الله سعيكم 💡"),
                                  ),
                                );
                              } else {
                                await Clipboard.setData(ClipboardData(text: "$subject\n\n$body"));
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF1E293B),
                                    duration: const Duration(seconds: 4),
                                    content: Text(isAr
                                        ? "تم نسخ الاقتراح إلى الحافظة. يمكنك لصقه وإرساله إلى: $supportEmail"
                                        : "Suggestion copied to clipboard. Send to $supportEmail"),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
