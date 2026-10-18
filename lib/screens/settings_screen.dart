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
import '../services/app_update_service.dart';
import '../services/app_support_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  late int _wilayaCode;
  String _adhanSound = "algeria_grand_mosque";
  int _advanceReminderMinutes = 15;
  bool _autoSilentMode = true;
  bool _useGpsAuto = false;
  bool _iqamahReminder = true;
  bool _autoAdhkar = false;
  int _adhkarInterval = 15;
  String _appVersionString = "1.0.0";

  // Mosque silent mode settings
  bool _isDndGranted = false;
  String _mosqueSilentType = 'silent'; // 'silent' or 'vibrate'
  int _mosqueSilentDuration = 25;
  bool _isTestingSilent = false;
  List<AdhanSoundItem> _customAdhansList = [];

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
    final list = <Map<String, String>>[
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

    for (final custom in _customAdhansList) {
      list.add({
        "id": custom.id,
        "name": custom.name,
        "desc": custom.desc.isNotEmpty ? custom.desc : (isAr ? "أذان مخصص مضاف" : "Custom added Adhan"),
        "isCustom": "true",
      });
    }

    return list;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _wilayaCode = widget.selectedWilayaCode;
    _checkDndPermission();
    _loadPreferences();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDndPermission();
    }
  }

  Future<void> _checkDndPermission() async {
    final granted = await SilentModeService.isDndAccessGranted();
    if (mounted) {
      setState(() {
        _isDndGranted = granted;
      });
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final dndOk = await SilentModeService.isDndAccessGranted();
    final customAdhans = await AdhanAudioService.getCustomAdhans();

    var savedAdhan = prefs.getString('adhan_sound') ?? "algeria_grand_mosque";
    if (savedAdhan == 'afasy') {
      savedAdhan = 'algeria_grand_mosque';
      await prefs.setString('adhan_sound', 'algeria_grand_mosque');
    }

    setState(() {
      _isDndGranted = dndOk;
      _customAdhansList = customAdhans;
      _adhanSound = savedAdhan;
      _mosqueSilentType = prefs.getString('mosque_silent_type') ?? 'silent';
      _mosqueSilentDuration = prefs.getInt('mosque_silent_duration') ?? 25;

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
        var pSound = prefs.getString('adhan_sound_$p') ?? _adhanSound;
        if (pSound == 'afasy') {
          pSound = 'algeria_grand_mosque';
          prefs.setString('adhan_sound_$p', 'algeria_grand_mosque');
        }
        _prayerAdhanSounds[p] = pSound;
      }
    });

    try {
      final pkg = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersionString = pkg.version;
        });
      }
    } catch (_) {}
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

  void _showAddAdhanModal(AppThemeColor theme) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final availableCatalog = AdhanAudioService.catalogAdhans.where((c) {
            return !_customAdhansList.any((a) => a.id == c.id);
          }).toList();

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.library_music, color: theme.accent, size: 24),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "إضافة صوت أذان آخر 🕌",
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () {
                          AdhanAudioService.stopAdhan();
                          Navigator.pop(modalCtx);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "اختر من أصوات الأذان التراثية المقترحة من مختلف ربوع العالم الإسلامي، أو أضف رابط أذان مخصص:",
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // Section 1: Catalog Adhans
                  if (availableCatalog.isNotEmpty) ...[
                    const Text(
                      "أذانات مقترحة جاهزة للإضافة بنقرة واحدة:",
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...availableCatalog.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155), width: 0.8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.volume_up, color: Color(0xFFD4AF37), size: 22),
                              tooltip: "استماع للعينة",
                              onPressed: () {
                                AdhanAudioService.playAdhan(soundId: item.id);
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    item.desc,
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text("إضافة", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: () async {
                                await AdhanAudioService.addAdhan(item);
                                await _loadPreferences();
                                if (modalCtx.mounted) {
                                  Navigator.pop(modalCtx);
                                }
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: const Color(0xFF064E3B),
                                      content: Text("تمت إضافة «${item.name}» إلى قائمة أصوات الأذان!"),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],

                  // Section 2: Custom URL Form
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: availableCatalog.isEmpty,
                      tilePadding: EdgeInsets.zero,
                      title: const Text(
                        "إضافة أذان مخصص برابط صوتي (MP3) 🔗",
                        style: TextStyle(color: Colors.amberAccent, fontSize: 13.5, fontWeight: FontWeight.bold),
                      ),
                      children: [
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: "اسم الأذان أو المؤذن *",
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            hintText: "مثال: أذان مسجد النور",
                            hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: "الوصف أو المدينة (اختياري)",
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            hintText: "مثال: بصوت مؤذن حينا",
                            hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: urlCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: "رابط ملف الصوت المباشر (URL .mp3) *",
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            hintText: "https://example.com/audio/adhan.mp3",
                            hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text("حفظ وإضافة الأذان", style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              final name = nameCtrl.text.trim();
                              final url = urlCtrl.text.trim();
                              if (name.isEmpty || url.isEmpty) {
                                ScaffoldMessenger.of(modalCtx).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Colors.redAccent,
                                    content: Text("يرجى إدخال اسم الأذان ورابط الصوت."),
                                  ),
                                );
                                return;
                              }
                              final customId = "custom_${DateTime.now().millisecondsSinceEpoch}";
                              final customAdhan = AdhanSoundItem(
                                id: customId,
                                name: name,
                                desc: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : "أذان مخصص",
                                url: url,
                                isCustom: true,
                              );
                              await AdhanAudioService.addAdhan(customAdhan);
                              await _loadPreferences();
                              if (modalCtx.mounted) {
                                Navigator.pop(modalCtx);
                              }
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF064E3B),
                                    content: Text("تمت إضافة «$name» بنجاح!"),
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
            ),
          );
        },
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
            final activeFiltered = LanguageService.supportedLanguages.where((l) {
              if (searchQuery.trim().isEmpty) return true;
              final q = searchQuery.toLowerCase().trim();
              return l.name.toLowerCase().contains(q) ||
                  l.nativeName.toLowerCase().contains(q) ||
                  l.code.toLowerCase().contains(q) ||
                  l.nameAr.toLowerCase().contains(q);
            }).toList();

            final catalogAvailable = LanguageService.searchAvailableGlobalLanguages(searchQuery);

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.88,
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
                      Row(
                        children: [
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
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.add_circle, color: activeTheme.accent, size: 24),
                            tooltip: "إضافة لغة مخصصة",
                            onPressed: () => _showAddCustomLanguageDialog(ctx, activeTheme, setModalState),
                          ),
                        ],
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
                      hintText: "ابحث عن اللغة (مثال: Turkish, يابانية, Español)...",
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                              onPressed: () {
                                setModalState(() {
                                  searchQuery = "";
                                });
                              },
                            )
                          : null,
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
                    child: (activeFiltered.isEmpty && catalogAvailable.isEmpty)
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.language, color: Colors.white24, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  "لم يتم العثور على لغة باسم «$searchQuery»",
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: activeTheme.accent,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: Text("إضافة «$searchQuery» كلغة مخصصة الآن"),
                                  onPressed: () => _showAddCustomLanguageDialog(
                                    ctx,
                                    activeTheme,
                                    setModalState,
                                    initialName: searchQuery,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            children: [
                              // 1. Available to add from Global Catalog
                              if (catalogAvailable.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  margin: const EdgeInsets.only(bottom: 6),
                                  decoration: BoxDecoration(
                                    color: activeTheme.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: activeTheme.primary.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_circle_outline, color: activeTheme.accent, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "لغات عالمية متوفرة للإضافة المباشرة (${catalogAvailable.length})",
                                          style: TextStyle(
                                            color: activeTheme.accent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...catalogAvailable.map((lang) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF334155)),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: 38,
                                        height: 38,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E293B),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFF334155)),
                                        ),
                                        child: Text(lang.flag, style: const TextStyle(fontSize: 20)),
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              lang.nativeName,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (lang.isRtl) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1E293B),
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
                                        "${lang.name} ${lang.nameAr.isNotEmpty ? '• ${lang.nameAr}' : ''}",
                                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                      ),
                                      trailing: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: activeTheme.accent,
                                          foregroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        icon: const Icon(Icons.add, size: 16),
                                        label: const Text("إضافة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        onPressed: () async {
                                          await LanguageService.addLanguage(lang, activateNow: true);
                                          setModalState(() {});
                                          if (mounted) setState(() {});
                                          if (ctx.mounted) Navigator.pop(ctx);
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              backgroundColor: const Color(0xFF065F46),
                                              duration: const Duration(seconds: 3),
                                              content: Text("${lang.flag} تمت إضافة وتفعيل لغة: ${lang.nativeName} (${lang.name})"),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(height: 10),
                                const Divider(color: Color(0xFF334155), height: 1),
                                const SizedBox(height: 10),
                              ],

                              // 2. Active Supported Languages
                              if (activeFiltered.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  child: Text(
                                    "اللغات المفعلة حالياً (${activeFiltered.length}):",
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ...activeFiltered.map((lang) {
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
                                        if (lang.isCustom) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF064E3B),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              "مخصصة",
                                              style: TextStyle(color: Color(0xFF34D399), fontSize: 9, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    subtitle: Text(
                                      "${lang.name} ${lang.nameAr.isNotEmpty ? '• ${lang.nameAr}' : ''}",
                                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSelected)
                                          Icon(Icons.check_circle, color: activeTheme.accent, size: 22),
                                        if (lang.isCustom)
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                                            tooltip: "حذف هذه اللغة المخصصة",
                                            onPressed: () async {
                                              await LanguageService.removeCustomLanguage(lang.code);
                                              setModalState(() {});
                                              if (mounted) setState(() {});
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text("تم حذف اللغة المخصصة: ${lang.name}"),
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      _applyLanguage(lang.code);
                                    },
                                  );
                                }),
                              ],
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

  void _showAddCustomLanguageDialog(
    BuildContext bottomSheetContext,
    AppThemeColor activeTheme,
    StateSetter setModalState, {
    String initialName = "",
  }) {
    final codeCtrl = TextEditingController(text: initialName.length >= 2 ? initialName.substring(0, 2).toLowerCase() : "");
    final nameCtrl = TextEditingController(text: initialName);
    final nativeCtrl = TextEditingController(text: initialName);
    final flagCtrl = TextEditingController(text: "🌐");
    bool isRtl = false;

    showDialog<void>(
      context: context,
      builder: (dlgContext) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.add_circle, color: activeTheme.accent, size: 24),
                  const SizedBox(width: 8),
                  const Text("إضافة لغة مخصصة جديدة", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: codeCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: "رمز اللغة (مثال: es, ber, ko, ja)",
                        labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: "اسم اللغة بالإنجليزية (English Name)",
                        labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nativeCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: "الاسم الأصلي للغة (Native Name)",
                        labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: flagCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              labelText: "العلم",
                              labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text("اتجاه RTL (من اليمين)", style: TextStyle(color: Colors.white, fontSize: 12)),
                            value: isRtl,
                            activeThumbColor: activeTheme.accent,
                            onChanged: (val) {
                              setDlgState(() => isRtl = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dlgContext),
                  child: const Text("إلغاء", style: TextStyle(color: Colors.white60)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeTheme.accent,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    final code = codeCtrl.text.trim().toLowerCase();
                    final name = nameCtrl.text.trim();
                    final nativeName = nativeCtrl.text.trim().isEmpty ? name : nativeCtrl.text.trim();
                    final flag = flagCtrl.text.trim().isEmpty ? "🌐" : flagCtrl.text.trim();

                    if (code.isEmpty || name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("يرجى ملء رمز اللغة واسمها على الأقل")),
                      );
                      return;
                    }

                    final newLang = AppLanguage(
                      code: code,
                      name: name,
                      nativeName: nativeName,
                      flag: flag,
                      isRtl: isRtl,
                      isCustom: true,
                    );

                    final messenger = ScaffoldMessenger.of(context);
                    await LanguageService.addLanguage(newLang, activateNow: true);
                    setModalState(() {});
                    if (mounted) setState(() {});

                    if (dlgContext.mounted) Navigator.pop(dlgContext);
                    if (bottomSheetContext.mounted) Navigator.pop(bottomSheetContext);

                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF065F46),
                        duration: const Duration(seconds: 3),
                        content: Text("$flag تمت إضافة وتفعيل لغة: $nativeName ($name) بنجاح!"),
                      ),
                    );
                  },
                  child: const Text("حفظ وإضافة الآن"),
                ),
              ],
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
                child: Column(
                  children: [
                    RadioGroup<String>(
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
                          final isCustom = sound['isCustom'] == "true";
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
                            secondary: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
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
                                if (isCustom)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    tooltip: "حذف هذا الأذان",
                                    onPressed: () async {
                                      await AdhanAudioService.deleteAdhan(sound['id']!);
                                      await _loadPreferences();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: const Color(0xFF7F1D1D),
                                            content: Text("تم حذف «${sound['name']}» من القائمة."),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(color: Color(0xFF334155), height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: activeTheme.accent,
                            side: BorderSide(color: activeTheme.primary.withValues(alpha: 0.6)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.add_circle_outline, size: 20),
                          label: const Text(
                            "إضافة صوت أذان آخر ➕",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                          onPressed: () => _showAddAdhanModal(activeTheme),
                        ),
                      ),
                    ),
                  ],
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _autoSilentMode,
                        activeThumbColor: activeTheme.primary,
                        title: const Text(
                          "كتم صوت الهاتف تلقائياً أثناء الصلاة",
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          "تحويل الهاتف لوضع الصامت تلقائياً بعد الأذان أثناء صلاة الجماعة في المسجد وإعادته بعدها.",
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

                      if (_autoSilentMode) ...[
                        const SizedBox(height: 8),
                        // DND Permission Alert or Badge
                        if (!_isDndGranted)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0x28EF4444),
                              border: Border.all(color: const Color(0xFFEF4444), width: 1.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.error_outline_rounded, color: Color(0xFFF87171), size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "إذن كتم الصوت غير ممنوح في نظام أندرويد",
                                        style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "لكي يعمل الكتم التلقائي بنجاح، يجب منح التطبيق إذن «الوصول إلى عدم الإزعاج» من إعدادات الهاتف.",
                                  style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11.5, height: 1.4),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFDC2626),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    icon: const Icon(Icons.settings, size: 16),
                                    label: const Text(
                                      "منح إذن كتم الصوت في إعدادات النظام ⚙️",
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () async {
                                      await SilentModeService.openDndSettings();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0x1F10B981),
                              border: Border.all(color: const Color(0xFF10B981), width: 0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "إذن كتم الصوت مفعّل في النظام - الوضع الصامت جاهز للعمل.",
                                    style: TextStyle(color: Color(0xFF10B981), fontSize: 11.5),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 14),
                        const Divider(color: Color(0xFF334155), height: 1),
                        const SizedBox(height: 12),

                        // Mode selection: Silent or Vibrate
                        const Text(
                          "نوع الوضع أثناء الصلاة:",
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text("صامت تماماً 🔕")),
                                selected: _mosqueSilentType == 'silent',
                                selectedColor: activeTheme.primary,
                                backgroundColor: const Color(0xFF0F172A),
                                labelStyle: TextStyle(
                                  color: _mosqueSilentType == 'silent' ? Colors.white : const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                onSelected: (_) {
                                  setState(() => _mosqueSilentType = 'silent');
                                  _savePreference('mosque_silent_type', 'silent');
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text("اهتزاز فقط 📳")),
                                selected: _mosqueSilentType == 'vibrate',
                                selectedColor: activeTheme.primary,
                                backgroundColor: const Color(0xFF0F172A),
                                labelStyle: TextStyle(
                                  color: _mosqueSilentType == 'vibrate' ? Colors.white : const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                onSelected: (_) {
                                  setState(() => _mosqueSilentType = 'vibrate');
                                  _savePreference('mosque_silent_type', 'vibrate');
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        // Duration selection: 15, 20, 25, 30 min
                        const Text(
                          "مدة كتم الصوت بعد الأذان:",
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [15, 20, 25, 30].map((mins) {
                            final isSel = _mosqueSilentDuration == mins;
                            return ChoiceChip(
                              label: Text("$mins دقيقة"),
                              selected: isSel,
                              selectedColor: activeTheme.primary,
                              backgroundColor: const Color(0xFF0F172A),
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : const Color(0xFF94A3B8),
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                              onSelected: (_) {
                                setState(() => _mosqueSilentDuration = mins);
                                _savePreference('mosque_silent_duration', mins);
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),
                        // Test silent mode button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF38BDF8),
                              side: const BorderSide(color: Color(0xFF0284C7)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: _isTestingSilent
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF38BDF8)),
                                  )
                                : const Icon(Icons.phonelink_ring_rounded, size: 18),
                            label: Text(
                              _isTestingSilent
                                  ? "جاري التجربة (الهاتف مكتوم الآن)..."
                                  : "تجربة كتم الصوت الآن (لمدة 5 ثوانٍ) 🧪",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                            ),
                            onPressed: _isTestingSilent
                                ? null
                                : () async {
                                    final granted = await SilentModeService.isDndAccessGranted();
                                    if (!granted) {
                                      if (context.mounted) _showDndPermissionDialog(activeTheme);
                                      return;
                                    }
                                    setState(() => _isTestingSilent = true);
                                    final success = await SilentModeService.testSilentMode(durationSeconds: 5);
                                    if (context.mounted) {
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Color(0xFF064E3B),
                                            duration: Duration(seconds: 5),
                                            content: Text("🔕 تم كتم الهاتف بنجاح! سيتم إرجاع الصوت تلقائياً بعد 5 ثوانٍ..."),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Color(0xFF7F1D1D),
                                            content: Text("⚠️ تعذر كتم الصوت، يرجى التحقق من إذن عدم الإزعاج في إعدادات الهاتف."),
                                          ),
                                        );
                                      }
                                    }
                                    await Future<void>.delayed(const Duration(seconds: 5));
                                    if (mounted) setState(() => _isTestingSilent = false);
                                  },
                          ),
                        ),
                      ],
                    ],
                  ),
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

              // Updates, Feedback & Support Section
              _buildSectionHeader(
                LanguageService.tr('settings_support_header'),
                Icons.volunteer_activism_rounded,
                activeTheme.accent,
              ),
              const SizedBox(height: 14),

              // Feature 1: Check for Updates
              _buildSupportTile(
                icon: Icons.system_update_alt_rounded,
                iconColor: const Color(0xFF38BDF8),
                title: LanguageService.tr('settings_check_updates_title'),
                subtitle: activeLocale.languageCode == 'ar'
                    ? "الإصدار الحالي: v$_appVersionString • فحص أحدث إصدار وتحديثات الأذان"
                    : "${LanguageService.tr('settings_current_version')}: v$_appVersionString • ${LanguageService.tr('settings_check_updates_subtitle')}",
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh_rounded, color: Color(0xFF38BDF8), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        LanguageService.tr('settings_check_now_btn'),
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  AppFeedback.select();
                  await AppUpdateService.showUpdateDialog(context, theme: activeTheme);
                },
              ),
              const SizedBox(height: 12),

              // Feature 2: Report a Bug
              _buildSupportTile(
                icon: Icons.bug_report_rounded,
                iconColor: const Color(0xFFF43F5E),
                title: LanguageService.tr('settings_report_bug_title'),
                subtitle: LanguageService.tr('settings_report_bug_subtitle'),
                trailing: Icon(
                  LanguageService.isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                  color: Colors.white38,
                  size: 22,
                ),
                onTap: () async {
                  AppFeedback.select();
                  await AppSupportService.showBugReportSheet(context, theme: activeTheme);
                },
              ),
              const SizedBox(height: 12),

              // Feature 3: Request a Feature
              _buildSupportTile(
                icon: Icons.lightbulb_outline_rounded,
                iconColor: activeTheme.accent,
                title: LanguageService.tr('settings_suggest_feature_title'),
                subtitle: LanguageService.tr('settings_suggest_feature_subtitle'),
                trailing: Icon(Icons.auto_awesome_rounded, color: activeTheme.accent, size: 20),
                onTap: () async {
                  AppFeedback.select();
                  await AppSupportService.showFeatureRequestSheet(context, theme: activeTheme);
                },
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
                    Text(
                      "الإصدار $_appVersionString (الجزائر) • مجاني 100% وبدون أي إعلانات",
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
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

  Widget _buildSupportTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: iconColor.withValues(alpha: 0.35), width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
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
