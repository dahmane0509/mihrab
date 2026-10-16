import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/algeria_wilayas.dart';
import '../services/theme_service.dart';
import '../services/location_service.dart';
import '../services/adhan_audio_service.dart';
import '../services/prayer_service.dart';
import '../services/prayer_notification_service.dart';
import '../services/silent_mode_service.dart';
import '../services/auto_adhkar_service.dart';
import '../screens/auto_adhkar_screen.dart';
import '../services/app_feedback.dart';
import 'package:geolocator/geolocator.dart';
import '../services/language_service.dart';

class SettingsScreen extends StatefulWidget {
  final int selectedWilayaCode;
  final void Function(int) onWilayaChanged;

  const SettingsScreen({
    super.key,
    required this.selectedWilayaCode,
    required this.onWilayaChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _wilayaCode;
  String _adhanSound = "algeria_grand_mosque";
  int _advanceReminderMinutes = 15;
  bool _autoSilentMode = true;
  bool _useGpsAuto = false;
  bool _iqamahReminder = true;
  bool _autoAdhkar = false;
  int _adhkarInterval = 15;

  // Calculation method & Madhab
  String _calculationMethod = "algeria";
  String _juristicMethod = "standard";

  // Manual mosque offset adjustments
  int _adjFajr = 0;
  int _adjSunrise = 0;
  int _adjDhuhr = 0;
  int _adjAsr = 0;
  int _adjMaghrib = 0;
  int _adjIsha = 0;

  // Per-prayer adhan customization
  final Map<String, String> _prayerAdhanSounds = {
    'fajr': 'makkah',
    'dhuhr': 'algeria_grand_mosque',
    'asr': 'algeria_grand_mosque',
    'maghrib': 'traditional_algerian',
    'isha': 'madinah',
  };

  List<Map<String, String>> get _adhanSoundsList {
    final lang = LanguageService.languageCode;
    final isAr = lang == 'ar';
    return [
      {
        "id": "algeria_grand_mosque",
        "name": isAr ? "أذان جامع الجزائر (الجامع الأعظم)" : (lang == 'fr' ? "Grande Mosquée d'Alger" : "Algeria Grand Mosque Adhan"),
        "desc": isAr ? "أذان العاصمة والمنارة التاريخية" : (lang == 'fr' ? "Appel officiel de la Grande Mosquée d'Alger" : "Official Adhan of the Grand Mosque of Algiers"),
      },
      {
        "id": "traditional_algerian",
        "name": isAr ? "الأذان الجزائري الأصيل (المقام المغاربي)" : (lang == 'fr' ? "Adhan Traditionnel Algérien" : "Authentic Algerian Adhan"),
        "desc": isAr ? "الأذان التراثي الجزائري العذب" : (lang == 'fr' ? "Style maghrébin traditionnel" : "Traditional Maghrebi style"),
      },
      {
        "id": "waled_mahzas",
        "name": isAr ? "أذان الشيخ وليد مهساس (الجزائر)" : "Sheikh Walid Mehsas (Algeria)",
        "desc": isAr ? "صوت خاشع ومؤثر من الجزائر" : "Touching Algerian Adhan recitation",
      },
      {
        "id": "makkah",
        "name": isAr ? "أذان المسجد الحرام (مكة المكرمة)" : (lang == 'fr' ? "Adhan de La Mecque" : "Makkah Grand Mosque Adhan"),
        "desc": isAr ? "بصوت الشيخ علي بن أحمد ملا" : "Sheikh Ali Ibn Ahmad Mala",
      },
      {
        "id": "madinah",
        "name": isAr ? "أذان المسجد النبوي (المدينة المنورة)" : (lang == 'fr' ? "Adhan de Médine" : "Madinah Prophet's Mosque Adhan"),
        "desc": isAr ? "الأذان المدني الشريف الخاشع" : "Sacred Madinah Al-Munawwarah Adhan",
      },
      {
        "id": "al_aqsa",
        "name": isAr ? "أذان المسجد الأقصى المبارك" : (lang == 'fr' ? "Adhan de la Mosquée Al-Aqsa" : "Al-Aqsa Mosque Adhan"),
        "desc": isAr ? "بصوت مؤذن الأقصى الشريف الشيخ ناجي قزاز" : "Sheikh Najee Qazaz (Jerusalem)",
      },
      {
        "id": "abdulbasit",
        "name": isAr ? "أذان الشيخ عبد الباسط عبد الصمد" : "Sheikh Abdulbasit Abdulsamad",
        "desc": isAr ? "أذان مصر التاريخي الخالد ذو الهيبة" : "Historic Egyptian Adhan",
      },
      {
        "id": "rifat",
        "name": isAr ? "أذان الشيخ محمد رفعت" : "Sheikh Muhammad Refaat",
        "desc": isAr ? "قيثارة السماء والأذان الخالد" : "Classic Cairo Adhan",
      },
      {
        "id": "husary",
        "name": isAr ? "أذان الشيخ محمود خليل الحصري" : "Sheikh Mahmoud Khalil Al-Hussary",
        "desc": isAr ? "أذان رصين متقن بالأحكام والتجويد" : "Precise tajweed Adhan recitation",
      },
      {
        "id": "banna",
        "name": isAr ? "أذان الشيخ محمود علي البنا" : "Sheikh Mahmoud Ali Al-Banna",
        "desc": isAr ? "أداء رفيع وشجي من كبار قراء مصر" : "Renowned Egyptian recitation",
      },
      {
        "id": "shaisha",
        "name": isAr ? "أذان الشيخ أبو العينين شعيشع" : "Sheikh Abul-Ainain Shuaisha",
        "desc": isAr ? "نبرة عذبة من الزمن الجميل" : "Classic golden-era Adhan",
      },
      {
        "id": "afasy",
        "name": isAr ? "أذان الشيخ مشاري راشد العفاسي" : "Sheikh Mishary Rashid Alafasy",
        "desc": isAr ? "أذان الكويت بنبرة روحانية مميزة" : "Kuwait spiritual Adhan",
      },
      {
        "id": "qatami",
        "name": isAr ? "أذان الشيخ ناصر القطامي" : "Sheikh Nasser Al-Qatami",
        "desc": isAr ? "أذان نجد الشجي والمؤثر" : "Melodious Riyadh Adhan",
      },
      {
        "id": "takbeer_only",
        "name": isAr ? "تكبيرات الأذان والعيد (المسجد الحرام)" : "Takbeerat of Eid & Adhan",
        "desc": isAr ? "تكبيرات جماعية مهيبة" : "Harmonious collective Takbeer",
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _wilayaCode = widget.selectedWilayaCode;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _adhanSound = prefs.getString('adhan_sound') ?? "algeria_grand_mosque";
      _advanceReminderMinutes = prefs.getInt('advance_reminder_minutes') ?? 15;
      _autoSilentMode = prefs.getBool('auto_silent_mode') ?? true;
      _useGpsAuto = prefs.getBool('use_gps_auto') ?? false;
      _iqamahReminder = prefs.getBool('iqamah_reminder') ?? true;
      _autoAdhkar = prefs.getBool('auto_adhkar_enabled') ?? AutoAdhkarService.isEnabled;
      _adhkarInterval = prefs.getInt('auto_adhkar_interval') ?? AutoAdhkarService.intervalMinutes;

      _calculationMethod = prefs.getString('calculation_method') ?? "algeria";
      _juristicMethod = prefs.getString('juristic_method') ?? "standard";

      _adjFajr = prefs.getInt('adj_fajr') ?? 0;
      _adjSunrise = prefs.getInt('adj_sunrise') ?? 0;
      _adjDhuhr = prefs.getInt('adj_dhuhr') ?? 0;
      _adjAsr = prefs.getInt('adj_asr') ?? 0;
      _adjMaghrib = prefs.getInt('adj_maghrib') ?? 0;
      _adjIsha = prefs.getInt('adj_isha') ?? 0;

      for (var p in ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']) {
        _prayerAdhanSounds[p] = prefs.getString('adhan_sound_$p') ?? _adhanSound;
      }
    });
  }

  Future<void> _savePreference(String key, dynamic value) async {
    AppFeedback.select();
    final prefs = await SharedPreferences.getInstance();
    if (value is String) await prefs.setString(key, value);
    if (value is int) await prefs.setInt(key, value);
    if (value is bool) await prefs.setBool(key, value);
    await PrayerService.loadSettings();
  }

  void _showPerPrayerAdhanDialog(String prayerKey, String prayerName, AppThemeColor theme) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "${LanguageService.tr('settings_select_adhan_dialog_title')} $prayerName",
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _adhanSoundsList.length,
            separatorBuilder: (_, __) => const Divider(color: Color(0xFF334155), height: 1),
            itemBuilder: (_, index) {
              final sound = _adhanSoundsList[index];
              final isCurrent = _prayerAdhanSounds[prayerKey] == sound['id'];
              return ListTile(
                title: Text(
                  sound['name']!,
                  style: TextStyle(
                    color: isCurrent ? theme.accent : Colors.white,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.volume_up, color: Color(0xFFD4AF37), size: 20),
                  tooltip: LanguageService.tr('listen'),
                  onPressed: () {
                    AdhanAudioService.playAdhan(soundId: sound['id']!);
                  },
                ),
                onTap: () {
                  setState(() {
                    _prayerAdhanSounds[prayerKey] = sound['id']!;
                  });
                  _savePreference('adhan_sound_$prayerKey', sound['id']!);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF065F46),
                      content: Text("${LanguageService.tr('settings_adhan_assigned')} ${sound['name']}"),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AdhanAudioService.stopAdhan();
              Navigator.pop(ctx);
            },
            child: Text(LanguageService.tr('close'), style: TextStyle(color: theme.accent)),
          ),
        ],
      ),
    );
  }

  void _showDndPermissionDialog(AppThemeColor theme) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.notifications_paused, color: Colors.amberAccent, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                LanguageService.tr('dnd_permission_dialog_title'),
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          LanguageService.tr('dnd_permission_dialog_desc'),
          style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(LanguageService.tr('cancel'), style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await SilentModeService.openDndSettings();
            },
            child: Text(LanguageService.tr('grant_permission'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentCounter(String prayerName, int value, ValueChanged<int> onChanged, AppThemeColor theme) {
    final unit = LanguageService.tr('settings_minute_short');
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(prayerName, style: const TextStyle(color: Colors.white, fontSize: 14)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 22),
                onPressed: () => onChanged(value - 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: Text(
                  value == 0 ? "0 $unit" : (value > 0 ? "+$value $unit" : "$value $unit"),
                  style: TextStyle(
                    color: value != 0 ? theme.accent : const Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981), size: 22),
                onPressed: () => onChanged(value + 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(AppThemeColor activeTheme) {
    final activeLang = LanguageService.activeLanguage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(LanguageService.tr('language_selector_title'), Icons.language, activeTheme.accent),
        const SizedBox(height: 8),
        Material(
          color: activeTheme.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: activeTheme.accent.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LanguageService.tr('language_selector_desc'),
                  style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 14),

                // Current Active Language Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: activeTheme.primary.withValues(alpha: 0.6), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: activeTheme.darkPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: activeTheme.accent, width: 1.5),
                        ),
                        child: Text(activeLang.flag, style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              activeLang.nativeName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${activeLang.name} • ${activeLang.isRtl ? 'RTL' : 'LTR'}",
                              style: TextStyle(
                                color: activeTheme.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF065F46),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF34D399), size: 14),
                            SizedBox(width: 4),
                            Text(
                              "نشطة",
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Quick Popular Languages
                const Text(
                  "اللغات الأكثر استخداماً:",
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickLangChip('ar', '🇩🇿 العربية', activeTheme),
                      const SizedBox(width: 6),
                      _buildQuickLangChip('en', '🇬🇧 English', activeTheme),
                      const SizedBox(width: 6),
                      _buildQuickLangChip('fr', '🇫🇷 Français', activeTheme),
                      const SizedBox(width: 6),
                      _buildQuickLangChip('tr', '🇹🇷 Türkçe', activeTheme),
                      const SizedBox(width: 6),
                      _buildQuickLangChip('id', '🇮🇩 Indonesia', activeTheme),
                      const SizedBox(width: 6),
                      _buildQuickLangChip('ur', '🇵🇰 اردو', activeTheme),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Open All 20 Languages Modal Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activeTheme.darkPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: activeTheme.accent, width: 1.2),
                      ),
                      elevation: 2,
                    ),
                    icon: Icon(Icons.public, color: activeTheme.accent, size: 20),
                    label: Text(
                      "تصفح واختيار من جميع اللغات (${LanguageService.supportedLanguages.length} لغة عالمية) 🌐",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _showGlobalLanguageModal(activeTheme),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildQuickLangChip(String code, String label, AppThemeColor activeTheme) {
    final isSelected = LanguageService.languageCode == code;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _applyLanguage(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeTheme.accent : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? activeTheme.accent : const Color(0xFF334155),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Future<void> _applyLanguage(String code) async {
    AppFeedback.select();
    await LanguageService.setLanguage(code);
    if (!mounted) return;
    setState(() {});
    final lang = LanguageService.getLanguageByCode(code);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF065F46),
        duration: const Duration(seconds: 2),
        content: Text("${lang.flag} تم اعتماد لغة التطبيق: ${lang.nativeName} (${lang.name})"),
      ),
    );
  }

  void _showGlobalLanguageModal(AppThemeColor activeTheme) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final filteredList = LanguageService.supportedLanguages.where((l) {
              if (searchQuery.trim().isEmpty) return true;
              final q = searchQuery.toLowerCase().trim();
              return l.name.toLowerCase().contains(q) ||
                  l.nativeName.toLowerCase().contains(q) ||
                  l.code.toLowerCase().contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.public, color: activeTheme.accent, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            "لغات العالم المدعومة",
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: activeTheme.accent.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          "${LanguageService.supportedLanguages.length} لغة",
                          style: TextStyle(color: activeTheme.accent, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Search Field
                  TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onChanged: (val) {
                      setModalState(() {
                        searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "ابحث عن اللغة (مثال: Turkish, اردو, Français)...",
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: activeTheme.accent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFF334155), height: 1),
                  const SizedBox(height: 6),
                  // Languages List
                  Expanded(
                    child: filteredList.isEmpty
                        ? const Center(
                            child: Text(
                              "لم يتم العثور على لغات مطابقة للبحث",
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredList.length,
                            separatorBuilder: (_, __) => const Divider(color: Color(0xFF334155), height: 1),
                            itemBuilder: (context, idx) {
                              final lang = filteredList[idx];
                              final isSelected = LanguageService.languageCode == lang.code;

                              return ListTile(
                                leading: Container(
                                  width: 42,
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? activeTheme.darkPrimary : const Color(0xFF0F172A),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? activeTheme.accent : const Color(0xFF334155),
                                    ),
                                  ),
                                  child: Text(lang.flag, style: const TextStyle(fontSize: 22)),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      lang.nativeName,
                                      style: TextStyle(
                                        color: isSelected ? activeTheme.accent : Colors.white,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (lang.isRtl) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F172A),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.white24),
                                        ),
                                        child: const Text(
                                          "RTL",
                                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Text(
                                  lang.name,
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                                trailing: isSelected
                                    ? Icon(Icons.check_circle, color: activeTheme.accent, size: 22)
                                    : null,
                                onTap: () {
                                  Navigator.pop(ctx);
                                  _applyLanguage(lang.code);
                                },
                              );
                            },
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

  @override
  Widget build(BuildContext context) {
    final currentWilaya = AlgeriaWilayas.getWilayaByCode(_wilayaCode);

    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.currentLocale,
      builder: (context, activeLocale, _) {
        return ValueListenableBuilder<AppThemeColor>(
          valueListenable: ThemeService.currentTheme,
          builder: (context, activeTheme, _) {
            return Scaffold(
              backgroundColor: activeTheme.background,
              appBar: AppBar(
                backgroundColor: activeTheme.darkPrimary,
                elevation: 0,
                title: Text(
                  LanguageService.tr('settings_title'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                centerTitle: true,
              ),
              body: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // 0. Language Selector Section
                  _buildLanguageSelector(activeTheme),

                  // 1. Theme Color Customization Section
                  _buildSectionHeader(LanguageService.tr('settings_theme_header'), Icons.palette, activeTheme.accent),
                  const SizedBox(height: 8),
              Material(
                color: activeTheme.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: activeTheme.accent.withValues(alpha: 0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LanguageService.tr('settings_theme_prompt'),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: ThemeService.availableThemes.map((theme) {
                        final isSelected = theme.id == activeTheme.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: isSelected ? theme.darkPrimary : const Color(0xFF0F172A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? theme.accent : const Color(0xFF334155),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: ListTile(
                            leading: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: theme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                            title: Text(
                              theme.nameAr,
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: theme.accent, size: 20)
                                : null,
                            onTap: () {
                              ThemeService.setTheme(theme);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

              // 2. Location & GPS Settings
              _buildSectionHeader("الموقع والتحديد التلقائي", Icons.location_on, activeTheme.accent),
              const SizedBox(height: 8),
              Material(
                color: activeTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.location_city, color: Color(0xFF10B981)),
                      title: const Text("الولاية المحددة حالياً", style: TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: Text("ولاية ${currentWilaya.code} - ${currentWilaya.nameAr} (${currentWilaya.nameFr})",
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ),
                    const Divider(color: Color(0xFF334155)),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _useGpsAuto,
                      activeThumbColor: activeTheme.primary,
                      title: const Text("التحديد التلقائي للموقع (GPS)", style: TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: const Text("كشف الولاية والبلدية بدقة عبر الأقمار الصناعية وحساب المواقيت آلياً",
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      onChanged: (val) async {
                        setState(() {
                          _useGpsAuto = val;
                        });
                        _savePreference('use_gps_auto', val);
                        if (val) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color(0xFF064E3B),
                              content: Text("جاري كشف موقعك وتحديد ولايتك..."),
                            ),
                          );
                          final detected = await LocationService.detectLocation();
                          if (!context.mounted) return;
                          if (detected != null) {
                            setState(() {
                              _wilayaCode = detected.wilaya.code;
                            });
                            widget.onWilayaChanged(detected.wilaya.code);
                            _savePreference('selected_wilaya', detected.wilaya.code);
                            _savePreference('selected_commune_id', detected.commune.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF064E3B),
                                content: Text("تم تحديد موقعك بدقة: بلدية ${detected.commune.nameAr} (ولاية ${detected.wilaya.nameAr})"),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

              // 3. Calculation Method & Juristic Madhab
              _buildSectionHeader(LanguageService.tr('settings_calc_header'), Icons.calculate, activeTheme.accent),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: activeTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(LanguageService.tr('settings_calc_prompt'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        itemHeight: null,
                        value: _calculationMethod,
                        underline: const SizedBox(),
                        dropdownColor: const Color(0xFF1E293B),
                        selectedItemBuilder: (context) {
                          return CalculationMethod.values.map((method) {
                            return Container(
                              alignment: AlignmentDirectional.centerStart,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                method.localizedName(LanguageService.languageCode),
                                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                                maxLines: 2,
                                softWrap: true,
                              ),
                            );
                          }).toList();
                        },
                        items: CalculationMethod.values.map((method) {
                          return DropdownMenuItem<String>(
                            value: method.id,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                method.localizedName(LanguageService.languageCode),
                                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                                softWrap: true,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _calculationMethod = val);
                            _savePreference('calculation_method', val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(LanguageService.tr('settings_madhab_prompt'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        itemHeight: null,
                        value: _juristicMethod,
                        underline: const SizedBox(),
                        dropdownColor: const Color(0xFF1E293B),
                        selectedItemBuilder: (context) {
                          return JuristicMethod.values.map((jur) {
                            return Container(
                              alignment: AlignmentDirectional.centerStart,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                jur.localizedName(LanguageService.languageCode),
                                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                                maxLines: 2,
                                softWrap: true,
                              ),
                            );
                          }).toList();
                        },
                        items: JuristicMethod.values.map((jur) {
                          return DropdownMenuItem<String>(
                            value: jur.id,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                jur.localizedName(LanguageService.languageCode),
                                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                                softWrap: true,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _juristicMethod = val);
                            _savePreference('juristic_method', val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Mosque Synchronization (Manual Offsets)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mosque, color: activeTheme.accent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      LanguageService.tr('settings_sync_mosque_header'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: activeTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LanguageService.tr('settings_sync_mosque_desc'),
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    _buildAdjustmentCounter("صلاة الفجر", _adjFajr, (v) {
                      setState(() => _adjFajr = v);
                      _savePreference('adj_fajr', v);
                    }, activeTheme),
                    _buildAdjustmentCounter("الشروق", _adjSunrise, (v) {
                      setState(() => _adjSunrise = v);
                      _savePreference('adj_sunrise', v);
                    }, activeTheme),
                    _buildAdjustmentCounter("صلاة الظهر", _adjDhuhr, (v) {
                      setState(() => _adjDhuhr = v);
                      _savePreference('adj_dhuhr', v);
                    }, activeTheme),
                    _buildAdjustmentCounter("صلاة العصر", _adjAsr, (v) {
                      setState(() => _adjAsr = v);
                      _savePreference('adj_asr', v);
                    }, activeTheme),
                    _buildAdjustmentCounter("صلاة المغرب", _adjMaghrib, (v) {
                      setState(() => _adjMaghrib = v);
                      _savePreference('adj_maghrib', v);
                    }, activeTheme),
                    _buildAdjustmentCounter("صلاة العشاء", _adjIsha, (v) {
                      setState(() => _adjIsha = v);
                      _savePreference('adj_isha', v);
                    }, activeTheme),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Per-Prayer Adhan Sound Customization
              _buildSectionHeader(LanguageService.tr('settings_custom_adhan_header'), Icons.music_note, activeTheme.accent),
              const SizedBox(height: 8),
              Material(
                color: activeTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                  children: [
                    for (var entry in [
                      {'key': 'fajr', 'name': 'صلاة الفجر'},
                      {'key': 'dhuhr', 'name': 'صلاة الظهر'},
                      {'key': 'asr', 'name': 'صلاة العصر'},
                      {'key': 'maghrib', 'name': 'صلاة المغرب'},
                      {'key': 'isha', 'name': 'صلاة العشاء'},
                    ])
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Material(
                          color: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFF334155)),
                          ),
                          child: ListTile(
                          title: Text(entry['name']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            AdhanAudioService.adhanNames[_prayerAdhanSounds[entry['key']]] ?? "أذان معتمد",
                            style: TextStyle(color: activeTheme.accent, fontSize: 12),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF94A3B8), size: 14),
                          onTap: () => _showPerPrayerAdhanDialog(entry['key']!, entry['name']!, activeTheme),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

              _buildSectionHeader(LanguageService.tr('settings_default_adhan_header'), Icons.volume_up, activeTheme.accent),
              const SizedBox(height: 8),
              Material(
                color: activeTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                child: RadioGroup<String>(
                  groupValue: _adhanSound,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _adhanSound = val;
                      });
                      _savePreference('adhan_sound', val);
                    }
                  },
                  child: Column(
                    children: _adhanSoundsList.map((sound) {
                      final isSelected = sound['id'] == _adhanSound;
                      return RadioListTile<String>(
                        value: sound['id']!,
                        activeColor: activeTheme.primary,
                        title: Text(
                          sound['name']!,
                          style: TextStyle(
                            color: isSelected ? activeTheme.accent : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          sound['desc']!,
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        ),
                        secondary: IconButton(
                          icon: const Icon(Icons.volume_up, color: Color(0xFFD4AF37)),
                          tooltip: "استماع لعينة الصوت",
                          onPressed: () {
                            AdhanAudioService.playAdhan(soundId: sound['id']!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF064E3B),
                                duration: const Duration(seconds: 4),
                                content: Text("جاري تشغيل عينة ${sound['name']}"),
                                action: SnackBarAction(
                                  label: "إيقاف",
                                  textColor: const Color(0xFFFDE68A),
                                  onPressed: () => AdhanAudioService.stopAdhan(),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 7. Advance Reminder & Iqamah
              _buildSectionHeader("التنبيه المسبق ووقت الإقامة", Icons.alarm, activeTheme.accent),
              const SizedBox(height: 8),
              Material(
                color: activeTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "تنبيه هادئ قبل الأذان للاستعداد والوضوء:",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [0, 5, 10, 15, 20, 30].map((mins) {
                        final isSelected = _advanceReminderMinutes == mins;
                        return ChoiceChip(
                          label: Text(mins == 0 ? "بدون تنبيه" : "$mins دقيقة"),
                          selected: isSelected,
                          selectedColor: activeTheme.primary,
                          backgroundColor: const Color(0xFF0F172A),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _advanceReminderMinutes = mins;
                            });
                            _savePreference('advance_reminder_minutes', mins);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF334155)),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _iqamahReminder,
                      activeThumbColor: activeTheme.primary,
                      title: const Text("تنبيه وقت الإقامة", style: TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: const Text("إشعار لطيف عند حلول وقت إقامة الصلاة في المسجد", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      onChanged: (val) {
                        setState(() => _iqamahReminder = val);
                        _savePreference('iqamah_reminder', val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

              // 8. Smart Mosque Mode & Auto Silent
              _buildSectionHeader(LanguageService.tr('auto_silent_mode'), Icons.volume_off, activeTheme.accent),
              const SizedBox(height: 8),
              Material(
                color: activeTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                child: SwitchListTile(
                  value: _autoSilentMode,
                  activeThumbColor: activeTheme.primary,
                  title: const Text(
                    "كتم صوت الهاتف تلقائياً أثناء الصلاة",
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    "تحويل الهاتف لوضع الصامت تلقائياً بعد الأذان لمدة 25 دقيقة أثناء صلاة الجماعة وإعادته بعدها.",
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                  onChanged: (val) async {
                    if (val) {
                      final hasAccess = await SilentModeService.isDndAccessGranted();
                      if (!hasAccess && context.mounted) {
                        _showDndPermissionDialog(activeTheme);
                      }
                    }
                    setState(() {
                      _autoSilentMode = val;
                    });
                    _savePreference('auto_silent_mode', val);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 9. Auto Adhkar On-Screen Notifications
              _buildSectionHeader("أذكار الشاشة التلقائية", Icons.auto_awesome, activeTheme.accent),
              const SizedBox(height: 8),
              Material(
                color: activeTheme.cardBackground,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _autoAdhkar,
                        activeThumbColor: activeTheme.primary,
                        title: const Text(
                          "تفعيل أذكار الشاشة التلقائية",
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          "إظهار ذكر أو دعاء مأثور على شاشة الهاتف دورياً أثناء استخدام الهاتف لتظل رطباً بذكر الله",
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        ),
                        onChanged: (val) async {
                          setState(() => _autoAdhkar = val);
                          AutoAdhkarService.isEnabled = val;
                          await AutoAdhkarService.saveSettings();
                          if (val && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFF065F46),
                                content: Text("تم تفعيل أذكار الشاشة التلقائية 📿"),
                              ),
                            );
                          }
                        },
                      ),
                      if (_autoAdhkar) ...[
                        const Divider(color: Color(0xFF334155)),
                        const SizedBox(height: 8),
                        const Text(
                          "فترة التكرار الزمني:",
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [5, 10, 15, 30, 60].map((mins) {
                            final isSel = _adhkarInterval == mins;
                            return ChoiceChip(
                              label: Text("كل $mins دقيقة"),
                              selected: isSel,
                              selectedColor: activeTheme.primary,
                              backgroundColor: const Color(0xFF0F172A),
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : const Color(0xFF94A3B8),
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                              onSelected: (_) async {
                                setState(() => _adhkarInterval = mins);
                                AutoAdhkarService.intervalMinutes = mins;
                                await AutoAdhkarService.saveSettings();
                              },
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: activeTheme.accent.withValues(alpha: 0.6)),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: Icon(Icons.settings_suggest, color: activeTheme.accent, size: 18),
                          label: const Text("تخصيص مكتبة الأذكار وإضافة أدعية خاصة"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(builder: (_) => const AutoAdhkarScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Test Adhan & Notification Card
              Material(
                color: const Color(0xFF064E3B).withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_active, color: Color(0xFF34D399), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LanguageService.tr('settings_test_adhan_title'),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  LanguageService.tr('settings_test_adhan_desc'),
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.play_arrow, size: 20),
                              label: Text(LanguageService.tr('settings_test_adhan_btn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              onPressed: () async {
                                await PrayerNotificationService.testAdhanNotification(
                                  prayerName: "الظهر",
                                  prayerKey: "dhuhr",
                                  communeName: currentWilaya.nameAr,
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF064E3B),
                                    content: Text("تم إطلاق إشعار وأذان صلاة الظهر في ${currentWilaya.nameAr} 🕌"),
                                    action: SnackBarAction(
                                      label: "إيقاف",
                                      textColor: const Color(0xFFFDE68A),
                                      onPressed: () => AdhanAudioService.stopAdhan(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            ),
                            icon: const Icon(Icons.stop, size: 18),
                            label: const Text("إيقاف"),
                            onPressed: () => AdhanAudioService.stopAdhan(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Background & Battery Optimization Guidance Card
              Material(
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.battery_charging_full, color: Color(0xFF38BDF8), size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              LanguageService.tr('settings_battery_header'),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        LanguageService.tr('settings_battery_desc'),
                        style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, height: 1.6),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF38BDF8),
                                side: const BorderSide(color: Color(0xFF38BDF8)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.settings, size: 16),
                              label: Text(LanguageService.tr('settings_battery_btn'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: () async {
                                AppFeedback.select();
                                await Geolocator.openAppSettings();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // About Section with New Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.25),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.mosque, color: Colors.white, size: 44),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "تطبيق مِحْراب • مواقيت الصلاة والقرآن",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "الإصدار 1.0.0 (الجزائر) • مجاني 100% وبدون أي إعلانات",
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  },
);
  }

  Widget _buildSectionHeader(String title, IconData icon, Color accentColor) {
    return Row(
      children: [
        Icon(icon, color: accentColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
