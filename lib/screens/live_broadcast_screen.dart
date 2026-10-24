// Updated v1.0.1
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/theme_service.dart';
import '../services/app_feedback.dart';

class LiveChannel {
  final String id;
  final String title;
  final String subtitle;
  final String location;
  final String audioStreamUrl;
  final String videoWebUrl;
  final IconData icon;

  const LiveChannel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.audioStreamUrl,
    required this.videoWebUrl,
    required this.icon,
  });
}

class LiveBroadcastScreen extends StatefulWidget {
  const LiveBroadcastScreen({super.key});

  @override
  State<LiveBroadcastScreen> createState() => _LiveBroadcastScreenState();
}

class _LiveBroadcastScreenState extends State<LiveBroadcastScreen> {
  final AudioPlayer _livePlayer = AudioPlayer();
  String? _activeChannelId;
  bool _isPlaying = false;
  bool _isLoading = false;

  final List<LiveChannel> _channels = const [
    LiveChannel(
      id: "algeria_coran",
      title: "إذاعة القرآن الكريم الجزائرية",
      subtitle: "البوابة الرسمية للبث المباشر لإذاعة القرآن الجزائرية والتلاوات",
      location: "الجزائر العاصمة 🇩🇿",
      audioStreamUrl: "https://qurango.net/radio/salma",
      videoWebUrl: "https://qurango.net/radio/salma",
      icon: Icons.radio,
    ),
    LiveChannel(
      id: "makkah_live",
      title: "قناة القرآن الكريم - مكة المكرمة",
      subtitle: "بث حي ومباشر من المسجد الحرام بمكة المكرمة على مدار الساعة 🕋",
      location: "مكة المكرمة 🕋",
      audioStreamUrl: "https://qurango.net/radio/mix",
      videoWebUrl: "https://www.youtube.com/@MakkahLiveTV",
      icon: Icons.videocam,
    ),
    LiveChannel(
      id: "general_quran",
      title: "إذاعة القرآن الكريم العامة",
      subtitle: "تلاوات متواصلة على مدار 24 ساعة بأصوات كبار قراء العالم الإسلامي",
      location: "العالم الإسلامي 🕌",
      audioStreamUrl: "https://qurango.net/radio/mix",
      videoWebUrl: "https://qurango.net/radio/mix",
      icon: Icons.headphones,
    ),
    LiveChannel(
      id: "minshawi_radio",
      title: "إذاعة الشيخ محمد صديق المنشاوي",
      subtitle: "تلاوات خاشعة ومجودة على مدار الساعة للصوت الباكي",
      location: "مصر والعالم الإسلامي 🎙️",
      audioStreamUrl: "https://qurango.net/radio/mohammed_siddiq_alminshawi",
      videoWebUrl: "https://qurango.net/radio/mix",
      icon: Icons.record_voice_over,
    ),
    LiveChannel(
      id: "hussary_radio",
      title: "إذاعة الشيخ محمود خليل الحصري",
      subtitle: "تلاوات محكمة ومتقنة على مدار الساعة لشيخ المقارئ المصرية",
      location: "مصر والعالم الإسلامي 🎙️",
      audioStreamUrl: "https://qurango.net/radio/mahmoud_khalil_alhussary",
      videoWebUrl: "https://qurango.net/radio/mix",
      icon: Icons.menu_book,
    ),
    LiveChannel(
      id: "maher_radio",
      title: "إذاعة الشيخ ماهر المعيقلي",
      subtitle: "تلاوات ندية خاشعة لإمام وخطيب المسجد الحرام",
      location: "مكة المكرمة 🕋",
      audioStreamUrl: "https://qurango.net/radio/maher",
      videoWebUrl: "https://qurango.net/radio/mix",
      icon: Icons.mosque,
    ),
    LiveChannel(
      id: "alajmy_radio",
      title: "إذاعة الشيخ أحمد العجمي",
      subtitle: "تلاوات مرتلة عذبة متواصلة على مدار اليوم",
      location: "العالم الإسلامي 🎙️",
      audioStreamUrl: "https://qurango.net/radio/ahmad_alajmy",
      videoWebUrl: "https://qurango.net/radio/mix",
      icon: Icons.auto_awesome,
    ),
    LiveChannel(
      id: "albaqarah_radio",
      title: "إذاعة سورة البقرة المباركة",
      subtitle: "بث متواصل لسورة البقرة لطرد الشياطين وبركة البيوت",
      location: "بث متواصل 📖",
      audioStreamUrl: "https://qurango.net/radio/albaqarah",
      videoWebUrl: "https://qurango.net/radio/mix",
      icon: Icons.star_border,
    ),
    LiveChannel(
      id: "roqiah_radio",
      title: "إذاعة الرقية الشرعية",
      subtitle: "آيات الرقية الشرعية والأدعية النبوية للشفاء والحفظ",
      location: "بث متواصل 🛡️",
      audioStreamUrl: "https://qurango.net/radio/roqiah",
      videoWebUrl: "https://qurango.net/radio/mix",
      icon: Icons.health_and_safety,
    ),
    LiveChannel(
      id: "athkar_radio",
      title: "إذاعة أذكار الصباح والمساء",
      subtitle: "حصن المسلم وأذكار اليوم والليلة بأصوات ندية",
      location: "بث متواصل 📿",
      audioStreamUrl: "https://qurango.net/radio/athkar_sabah",
      videoWebUrl: "https://qurango.net/radio/mix",
      icon: Icons.wb_sunny,
    ),
    LiveChannel(
      id: "tafsir_radio",
      title: "إذاعة تفسير القرآن الكريم",
      subtitle: "المختصر في تفسير القرآن الكريم وتوضيح معاني الآيات",
      location: "الإذاعة التعليمية 📖",
      audioStreamUrl: "https://qurango.net/radio/mukhtasartafsir",
      videoWebUrl: "https://qurango.net/radio/mix",
      icon: Icons.library_books,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _livePlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (_isPlaying) _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _livePlayer.dispose();
    super.dispose();
  }

  Future<void> _launchVideoUrl(String url, String channelTitle) async {
    AppFeedback.tap();
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F254E),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(Icons.live_tv, color: Colors.amber, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "جاري فتح البث المرئي المباشر لـ $channelTitle... 📺",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );

    final uri = Uri.parse(url);
    bool launched = false;

    // 1. Try launching in external application (YouTube app or default browser)
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}

    // 2. If external application failed, try platformDefault
    if (!launched) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }

    // 3. If still failed, try inAppBrowserView
    if (!launched) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {}
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 4),
          content: const Text(
            "تعذر فتح البث تلقائياً. يرجى التأكد من توفر تطبيق YouTube أو متصفح إنترنت.",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  Future<void> _playLiveChannel(LiveChannel channel) async {
    AppFeedback.tap();
    if (_activeChannelId == channel.id && _isPlaying) {
      await _stopLiveChannel();
      return;
    }

    setState(() {
      _activeChannelId = channel.id;
      _isLoading = true;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF065F46),
        duration: const Duration(seconds: 4),
        content: Text("جاري الاتصال بالبث المباشر: ${channel.title}... 🔴"),
        action: SnackBarAction(
          label: "إيقاف",
          textColor: const Color(0xFFFDE68A),
          onPressed: _stopLiveChannel,
        ),
      ),
    );

    try {
      await _livePlayer.stop();
      await _livePlayer.play(UrlSource(channel.audioStreamUrl));
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPlaying = false;
          _activeChannelId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF991B1B),
            content: Text("تعذر الاتصال بالبث المباشر حالياً، يرجى التحقق من اتصال الإنترنت ⚠️"),
          ),
        );
      }
    }
  }

  Future<void> _stopLiveChannel() async {
    AppFeedback.tap();
    await _livePlayer.stop();
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _isLoading = false;
      _activeChannelId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF1E293B),
        duration: Duration(seconds: 2),
        content: Text("تم إيقاف البث المباشر ⏹️"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeColor>(
      valueListenable: ThemeService.currentTheme,
      builder: (context, theme, _) {
        final activeChannel = _channels.firstWhere(
          (c) => c.id == _activeChannelId,
          orElse: () => _channels[0],
        );

        return Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            backgroundColor: theme.darkPrimary,
            elevation: 0,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "البث المباشر الإسلامي",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Live Header Banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.darkPrimary, theme.cardBackground],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.accent.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 14),
                              SizedBox(width: 4),
                              Text("مباشر 24/7", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Text(
                          "إذاعات وقنوات حية",
                          style: TextStyle(color: theme.accent, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "استمع مباشرة إلى إذاعة القرآن الكريم الجزائرية وبث الحرم المكي والحرم النبوي الشريف بأعلى جودة صوت نقية.",
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),

              // Channels List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: _channels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final channel = _channels[index];
                    final isCurrent = _activeChannelId == channel.id;

                    return Container(
                      decoration: BoxDecoration(
                        color: isCurrent ? theme.darkPrimary.withValues(alpha: 0.8) : theme.cardBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isCurrent ? theme.accent : const Color(0xFF334155),
                          width: isCurrent ? 2 : 1,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: theme.accent.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isCurrent ? theme.accent : theme.background,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                channel.icon,
                                color: isCurrent ? Colors.black : theme.primary,
                                size: 26,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    channel.title,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      color: isCurrent ? theme.accent : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  channel.subtitle,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  channel.location,
                                  style: TextStyle(color: theme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            trailing: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCurrent && _isPlaying ? Colors.redAccent : theme.accent,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              icon: _isLoading && isCurrent
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                                    )
                                  : Icon(
                                      isCurrent && _isPlaying ? Icons.stop : Icons.play_arrow,
                                      size: 20,
                                    ),
                              label: Text(
                                isCurrent && _isPlaying ? "إيقاف" : "بث حي",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => _playLiveChannel(channel),
                            ),
                          ),
                          if (channel.id.contains("makkah") || channel.id.contains("madinah") || channel.id.contains("algeria"))
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(color: Colors.redAccent),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  icon: const Icon(Icons.live_tv, size: 18),
                                  label: const Text(
                                    "مشاهدة البث المرئي المباشر (فيديو 24/7) 📺",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  onPressed: () => _launchVideoUrl(channel.videoWebUrl, channel.title),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Active Playing Mini-Bar
              if (_activeChannelId != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.darkPrimary,
                    border: Border(top: BorderSide(color: theme.accent, width: 2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _isPlaying ? Colors.redAccent : Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeChannel.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _isPlaying ? "البث المباشر يعمل الآن 🔴" : "جاري الاتصال بالبث...",
                              style: TextStyle(color: theme.accent, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.stop_circle : Icons.play_circle_fill,
                            color: theme.accent, size: 36),
                        onPressed: _stopLiveChannel,
                        tooltip: "إيقاف البث",
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
