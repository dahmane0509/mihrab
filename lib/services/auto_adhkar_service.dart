import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'adhan_audio_service.dart';
import 'audio_coordinator.dart';
import 'verse_audio_service.dart';

class AdhkarItem {
  final String id;
  final String text;
  final String category;
  final String virtue;
  final bool isCustom;
  bool isEnabled;

  AdhkarItem({
    required this.id,
    required this.text,
    required this.category,
    this.virtue = '',
    this.isCustom = false,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'category': category,
    'virtue': virtue,
    'isCustom': isCustom,
    'isEnabled': isEnabled,
  };

  factory AdhkarItem.fromJson(Map<String, dynamic> json) => AdhkarItem(
    id: json['id'] as String,
    text: json['text'] as String,
    category: json['category'] as String? ?? 'أدعية مخصصة',
    virtue: json['virtue'] as String? ?? '',
    isCustom: json['isCustom'] as bool? ?? false,
    isEnabled: json['isEnabled'] as bool? ?? true,
  );
}

class AutoAdhkarService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  // Settings (disabled by default to prevent unexpected popups)
  static bool isEnabled = false;
  static int intervalMinutes = 15;
  static bool soundEnabled = false;

  static const String channelId = 'auto_adhkar_channel';
  static const String channelName = 'أذكار الشاشة التلقائية';
  static const String channelDesc = 'إظهار الأذكار والأدعية على الشاشة أثناء تصفح الهاتف';

  // Default Authentic Adhkar Library
  static final List<AdhkarItem> _defaultAdhkar = [
    AdhkarItem(
      id: 'dhikr_1',
      text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      category: 'تسبيح وتحميد',
      virtue: 'كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، حبيبتان إلى الرحمن',
    ),
    AdhkarItem(
      id: 'dhikr_2',
      text: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
      category: 'استغفار وتوبة',
      virtue: 'موجب لمغفرة الذنوب وتفريج الهموم وزيادة الرزق',
    ),
    AdhkarItem(
      id: 'dhikr_3',
      text: 'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      category: 'الصلاة على النبي',
      virtue: 'من صلى عليّ صلاة واحدة صلى الله عليه بها عشراً',
    ),
    AdhkarItem(
      id: 'dhikr_4',
      text: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
      category: 'حوقلة وتوكل',
      virtue: 'كنز من كنوز الجنة ودواء لتسعة وتسعين داء أيسرها الهم',
    ),
    AdhkarItem(
      id: 'dhikr_5',
      text: 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      category: 'تفريج الكرب',
      virtue: 'دعوة ذي النون ما دعا بها مكروب إلا فرج الله كربه',
    ),
    AdhkarItem(
      id: 'dhikr_6',
      text: 'سُبْحَانَ اللَّهِ ، وَالْحَمْدُ لِلَّهِ ، وَلَا إِلَهَ إِلَّا اللَّهُ ، وَاللَّهُ أَكْبَرُ',
      category: 'الباقيات الصالحات',
      virtue: 'أحب الكلام إلى الله وأحب مما طلعت عليه الشمس',
    ),
    AdhkarItem(
      id: 'dhikr_7',
      text: 'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      category: 'حوقلة وتوكل',
      virtue: 'من قالها حين يصبح وحين يمسي سبع مرات كفاه الله ما أهمه',
    ),
    AdhkarItem(
      id: 'dhikr_8',
      text: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
      category: 'أدعية نبوية',
      virtue: 'دعاء شامل لتيسير كافة الأمور والالتجاء التام إلى الله',
    ),
    AdhkarItem(
      id: 'dhikr_9',
      text: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      category: 'أدعية جامعة',
      virtue: 'أكثر دعاء كان يدعو به النبي صلى الله عليه وسلم',
    ),
    AdhkarItem(
      id: 'dhikr_10',
      text: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
      category: 'أدعية نبوية',
      virtue: 'ما سئل الله شيئاً أحب إليه من أن يسأل العافية',
    ),
    AdhkarItem(
      id: 'dhikr_11',
      text: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      category: 'حفظ وتحصين',
      virtue: 'حماية وحصن من كل سوء ومكروه وفجأة بلاء',
    ),
    AdhkarItem(
      id: 'dhikr_12',
      text: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
      category: 'أدعية نبوية',
      virtue: 'وصية رسول الله لمعاذ بن جبل دبر كل صلاة',
    ),
    AdhkarItem(
      id: 'dhikr_13',
      text: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ كَرِيمٌ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
      category: 'استغفار وتوبة',
      virtue: 'دعاء ليلة القدر ومغفرة الذنوب',
    ),
    AdhkarItem(
      id: 'dhikr_14',
      text: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِنْ لِسَانِي يَفْقَهُوا قَوْلِي',
      category: 'تيسير الأمور',
      virtue: 'دعاء نبي الله موسى عليه السلام لانشراح الصدر وتيسير المهمات',
    ),
    AdhkarItem(
      id: 'dhikr_15',
      text: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ ، وَالْعَجْزِ وَالْكَسَلِ ، وَالْبُخْلِ وَالْجُبْنِ',
      category: 'تفريج الكرب',
      virtue: 'استعاذة نبوية من موانع الإنجاز والضيق النفسي',
    ),
  ];

  static List<AdhkarItem> _customAdhkar = [];

  static List<AdhkarItem> get allAdhkar => [..._defaultAdhkar, ..._customAdhkar];

  static List<AdhkarItem> get enabledAdhkar =>
      allAdhkar.where((item) => item.isEnabled).toList();

  static Timer? _activeTimer;
  static const int _baseScheduledNotifId = 8000;
  static const int _scheduleBatchSize = 24;

  /// Initialize local notification channels and load preferences
  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      await _notificationsPlugin.initialize(settings: initSettings);

      // Ensure notification channel is created for auto adhkar with HIGH importance for heads-up display
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );

        // Request notification permission on Android 13+
        await androidPlugin.requestNotificationsPermission();
      }

      tz.initializeTimeZones();
      _isInitialized = true;
    } catch (e) {
      debugPrint("AutoAdhkarService initialization warning: $e");
    }

    await loadSettings();
    if (isEnabled) {
      await startScheduler();
    }
  }

  /// Start scheduled background timer & OS notifications
  static Future<void> startScheduler() async {
    await stopScheduler();
    if (!isEnabled) return;

    // 1. In-process periodic timer while app process is alive
    _activeTimer = Timer.periodic(Duration(minutes: intervalMinutes), (timer) {
      if (isEnabled) {
        showFloatingDhikrNotification();
      } else {
        timer.cancel();
      }
    });

    // 2. Schedule upcoming OS-level notifications via timezone
    if (!_isInitialized) return;

    try {
      tz.initializeTimeZones();
      final now = tz.TZDateTime.now(tz.local);
      final activeList = enabledAdhkar;
      if (activeList.isEmpty) return;

      for (int i = 1; i <= _scheduleBatchSize; i++) {
        final scheduledTime = now.add(Duration(minutes: intervalMinutes * i));
        final item = activeList[Random().nextInt(activeList.length)];
        final notifId = _baseScheduledNotifId + i;

        final androidDetails = AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ذكر ودعاء',
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            item.text,
            contentTitle: '📿 ${item.category}',
            summaryText: item.virtue.isNotEmpty ? item.virtue : 'تطبيق مِحْراب',
          ),
          playSound: soundEnabled &&
            !AudioCoordinator.isBusy &&
            !AdhanAudioService.isPlayingNotifier.value &&
            !VerseAudioService.isPlayingNotifier.value,
          enableVibration: true,
        );

        try {
          await _notificationsPlugin.zonedSchedule(
            id: notifId,
            title: '📿 ${item.category}',
            body: item.text,
            scheduledDate: scheduledTime,
            notificationDetails: NotificationDetails(android: androidDetails),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
        } catch (e) {
          debugPrint("Failed to schedule adhkar item $notifId: $e");
        }
      }
    } catch (e) {
      debugPrint("Adhkar scheduling note: $e");
    }
  }

  /// Stop scheduler and cancel all pending scheduled notifications
  static Future<void> stopScheduler() async {
    _activeTimer?.cancel();
    _activeTimer = null;
    if (!_isInitialized) return;
    try {
      for (int i = 1; i <= _scheduleBatchSize; i++) {
        await _notificationsPlugin.cancel(id: _baseScheduledNotifId + i);
      }
    } catch (_) {}
  }

  /// Load persisted user settings and custom adhkar
  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isEnabled = prefs.getBool('auto_adhkar_enabled') ?? false;
    intervalMinutes = prefs.getInt('auto_adhkar_interval_minutes') ?? 15;
    soundEnabled = prefs.getBool('auto_adhkar_sound_enabled') ?? false;

    // Load enabled IDs for default adhkar
    final enabledIds = prefs.getStringList('auto_adhkar_enabled_ids');
    if (enabledIds != null) {
      for (var item in _defaultAdhkar) {
        item.isEnabled = enabledIds.contains(item.id);
      }
    }

    // Load custom adhkar
    final customJson = prefs.getString('auto_adhkar_custom_items');
    if (customJson != null && customJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(customJson) as List<dynamic>;
        _customAdhkar = list.map((e) => AdhkarItem.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint("Error loading custom adhkar: $e");
      }
    }
  }

  /// Save settings to SharedPreferences and update scheduler
  static Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_adhkar_enabled', isEnabled);
    await prefs.setInt('auto_adhkar_interval_minutes', intervalMinutes);
    await prefs.setBool('auto_adhkar_sound_enabled', soundEnabled);

    // Save enabled IDs
    final enabledIds = allAdhkar.where((e) => e.isEnabled).map((e) => e.id).toList();
    await prefs.setStringList('auto_adhkar_enabled_ids', enabledIds);

    // Save custom items
    final customJson = jsonEncode(_customAdhkar.map((e) => e.toJson()).toList());
    await prefs.setString('auto_adhkar_custom_items', customJson);

    // Update active schedule
    if (isEnabled) {
      await startScheduler();
    } else {
      await stopScheduler();
    }
  }

  /// Toggle dhikr enabled status
  static Future<void> toggleDhikr(String id, bool enabled) async {
    for (var item in allAdhkar) {
      if (item.id == id) {
        item.isEnabled = enabled;
        break;
      }
    }
    await saveSettings();
  }

  /// Add user-customized dhikr or dua
  static Future<AdhkarItem> addCustomDhikr({
    required String text,
    String virtue = 'دعاء شخصي مضاف',
    String category = 'أدعية مخصصة',
  }) async {
    final newItem = AdhkarItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      category: category,
      virtue: virtue.trim(),
      isCustom: true,
      isEnabled: true,
    );
    _customAdhkar.add(newItem);
    await saveSettings();
    return newItem;
  }

  /// Delete a custom dhikr
  static Future<void> deleteCustomDhikr(String id) async {
    _customAdhkar.removeWhere((item) => item.id == id);
    await saveSettings();
  }

  /// Get random or next enabled Dhikr
  static AdhkarItem? getRandomEnabledDhikr() {
    final active = enabledAdhkar;
    if (active.isEmpty) return null;
    final index = Random().nextInt(active.length);
    return active[index];
  }

  /// Trigger a heads-up floating notification displaying the dhikr on the screen
  static Future<void> showFloatingDhikrNotification({AdhkarItem? specificItem}) async {
    if (!isEnabled && specificItem == null) return;
    if (!_isInitialized) return;

    final item = specificItem ?? getRandomEnabledDhikr();
    if (item == null) return;

    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ذكر ودعاء',
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(
          item.text,
          contentTitle: '📿 ${item.category}',
          summaryText: item.virtue.isNotEmpty ? item.virtue : 'تطبيق مِحْراب',
        ),
        playSound: soundEnabled &&
            !AudioCoordinator.isBusy &&
            !AdhanAudioService.isPlayingNotifier.value &&
            !VerseAudioService.isPlayingNotifier.value,
        enableVibration: true,
        fullScreenIntent: false,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      final notificationId = 1000 + Random().nextInt(9000);
      await _notificationsPlugin.show(
        id: notificationId,
        title: '📿 ${item.category}',
        body: item.text,
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      debugPrint("Could not show dhikr notification: $e");
    }
  }
}
