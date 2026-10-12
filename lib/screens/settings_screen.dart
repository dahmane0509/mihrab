import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/algeria_wilayas.dart';
import '../services/theme_service.dart';
import '../services/location_service.dart';
import '../services/adhan_audio_service.dart';
import '../services/prayer_service.dart';
import '../services/prayer_notification_service.dart';
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

  final List<Map<String, String>> _adhanSoundsList = [
    {"id": "algeria_grand_mosque", "name": "أذان جامع الجزائر (الجامع الأعظم)", "desc": "الأذان الرسمي لجامع الجزائر"},
    {"id": "traditional_algerian", "name": "الأذان الجزائري الأصيل (المقام المغاربي)", "desc": "أذان الإذاعة والتلفزيون الجزائري"},
    {"id": "makkah", "name": "أذان المسجد الحرام (مكة المكرمة)", "desc": "الشيخ علي ملا"},
    {"id": "madinah", "name": "أذان المسجد النبوي (المدينة المنورة)", "desc": "الشيخ عصام بخاري"},
    {"id": "al_aqsa", "name": "أذان المسجد الأقصى المبارك", "desc": "القدس الشريف - الشيخ ناجي قزاز"},
    {"id": "abdulbasit", "name": "أذان الشيخ عبد الباسط عبد الصمد", "desc": "أذان مصر التاريخي النادر"},
    {"id": "rifat", "name": "أذان الشيخ محمد رفعت", "desc": "قيثارة السماء"},
    {"id": "husary", "name": "أذان الشيخ محمود خليل الحصري", "desc": "شيخ عموم المقارئ المصرية"},
    {"id": "banna", "name": "أذان الشيخ محمود علي البنا", "desc": "أداء خاشع ومؤثر"},
    {"id": "shaisha", "name": "أذان الشيخ أبو العينين شعيشع", "desc": "التسجيل المصري العريق"},
    {"id": "takbeer_only", "name": "تكبيرات الأذان والعيد", "desc": "المسجد الحرام - تكبيرات الحرم المكي"},
  ];

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

  void _showPerPrayerAdhanDialog(String prayerKey, String prayerNameAr, AppThemeColor theme) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "اختر صوت أذان $prayerNameAr",
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
                  tooltip: "استماع",
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
                      content: Text("تم اعتماد ${sound['name']} لصلاة $prayerNameAr"),
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
            child: Text("إغلاق", style: TextStyle(color: theme.accent)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentCounter(String prayerName, int value, ValueChanged<int> onChanged, AppThemeColor theme) {
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
                  value == 0 ? "0 د" : (value > 0 ? "+$value د" : "$value د"),
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
    final currentLang = LanguageService.languageCode;
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
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildLanguageButton(
                      langCode: 'ar',
                      title: "العربية",
                      flag: "🇩🇿",
                      subtitle: "الافتراضية",
                      isSelected: currentLang == 'ar',
                      activeTheme: activeTheme,
                    ),
                    const SizedBox(width: 8),
                    _buildLanguageButton(
                      langCode: 'en',
                      title: "English",
                      flag: "🇬🇧",
                      subtitle: "Global",
                      isSelected: currentLang == 'en',
                      activeTheme: activeTheme,
                    ),
                    const SizedBox(width: 8),
                    _buildLanguageButton(
                      langCode: 'fr',
                      title: "Français",
                      flag: "🇫🇷",
                      subtitle: "Mondial",
                      isSelected: currentLang == 'fr',
                      activeTheme: activeTheme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLanguageButton({
    required String langCode,
    required String title,
    required String flag,
    required String subtitle,
    required bool isSelected,
    required AppThemeColor activeTheme,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          AppFeedback.select();
          await LanguageService.setLanguage(langCode);
          if (mounted) {
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF065F46),
                duration: const Duration(seconds: 2),
                content: Text(
                  langCode == 'ar'
                      ? "تم تحويل لغة التطبيق إلى العربية بنجاح"
                      : (langCode == 'fr'
                          ? "Langue de l'application changée en Français"
                          : "App language switched to English successfully"),
                ),
              ),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeTheme.darkPrimary : const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeTheme.accent : const Color(0xFF334155),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeTheme.accent.withValues(alpha: 0.25),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isSelected ? activeTheme.accent : const Color(0xFF64748B),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
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
                  onChanged: (val) {
                    setState(() {
                      _autoSilentMode = val;
                    });
                    _savePreference('auto_silent_mode', val);
                  },
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
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
