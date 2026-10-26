import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../data/quran_data.dart';
import '../services/app_feedback.dart';

class QuranAudioScreen extends StatefulWidget {
  const QuranAudioScreen({super.key});

  @override
  State<QuranAudioScreen> createState() => _QuranAudioScreenState();
}

class _QuranAudioScreenState extends State<QuranAudioScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _playingSurahNumber;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  late Map<String, String> _selectedReciter;

  final List<Map<String, String>> _reciters = const [
    {
      "id": "jaza",
      "name": "الشيخ ياسين الجزائري (رواية ورش)",
      "cdn": "https://server11.mp3quran.net/qari",
    },
    {
      "id": "sheim",
      "name": "الشيخ عبد العزيز سحيم (الجزائر - ورش)",
      "cdn": "https://server10.mp3quran.net/sheim",
    },
    {
      "id": "kouchi",
      "name": "الشيخ العيون الكوشي (رواية ورش عن نافع)",
      "cdn": "https://server11.mp3quran.net/koshi",
    },
    {
      "id": "kazabri",
      "name": "الشيخ عمر القزابري (رواية ورش عن نافع)",
      "cdn": "https://server9.mp3quran.net/omar_warsh",
    },
    {
      "id": "husr",
      "name": "الشيخ محمود خليل الحصري (ورش عن نافع)",
      "cdn": "https://server13.mp3quran.net/husr",
    },
    {
      "id": "hudhaifi",
      "name": "الشيخ علي بن عبد الرحمن الحذيفي",
      "cdn": "https://server9.mp3quran.net/hthfi",
    },
    {
      "id": "shatri",
      "name": "الشيخ أبو بكر الشاطري",
      "cdn": "https://server11.mp3quran.net/shatri",
    },
    {
      "id": "islam_sobhi",
      "name": "القارئ إسلام صبحي",
      "cdn": "https://server14.mp3quran.net/islam/Rewayat-Hafs-A-n-Assem",
    },
    {
      "id": "basit",
      "name": "الشيخ عبد الباسط عبد الصمد (مرتل)",
      "cdn": "https://server7.mp3quran.net/basit",
    },
    {
      "id": "minsh",
      "name": "الشيخ محمد صديق المنشاوي",
      "cdn": "https://server10.mp3quran.net/minsh",
    },
    {
      "id": "maher",
      "name": "الشيخ ماهر المعيقلي",
      "cdn": "https://server12.mp3quran.net/maher",
    },
    {
      "id": "s_gmd",
      "name": "الشيخ سعد الغامدي",
      "cdn": "https://server7.mp3quran.net/s_gmd",
    },
    {
      "id": "dosari",
      "name": "الشيخ ياسر الدوسري",
      "cdn": "https://server11.mp3quran.net/yasser",
    },
    {
      "id": "shur",
      "name": "الشيخ سعود الشريم",
      "cdn": "https://server7.mp3quran.net/shur",
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedReciter = _reciters[0];

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (_isPlaying) _isLoading = false;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
          _playingSurahNumber = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _playSurah(Surah surah) {
    AppFeedback.tap();
    if (_playingSurahNumber == surah.number) {
      _audioPlayer.stop().catchError((_) {});
      setState(() {
        _playingSurahNumber = null;
        _isPlaying = false;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF064E3B),
          duration: const Duration(seconds: 2),
          content: Text("تم إيقاف تلاوة سورة ${surah.nameAr}"),
        ),
      );
      return;
    }

    setState(() {
      _playingSurahNumber = surah.number;
      _isPlaying = true;
      _isLoading = false;
      _position = Duration.zero;
      _duration = Duration.zero;
    });

    final paddedNum = surah.number.toString().padLeft(3, '0');
    final streamUrl = "${_selectedReciter['cdn']}/$paddedNum.mp3";

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF065F46),
        duration: const Duration(seconds: 3),
        content: Text("جاري تشغيل سورة ${surah.nameAr} بصوت ${_selectedReciter['name']} 🎧"),
      ),
    );

    _audioPlayer.stop().then((_) {
      _audioPlayer.play(UrlSource(streamUrl)).catchError((_) {});
    }).catchError((_) {});
  }

  Future<void> _stopAudio() async {
    AppFeedback.tap();
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _isLoading = false;
        _playingSurahNumber = null;
        _position = Duration.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSurah = _playingSurahNumber != null
        ? QuranData.surahs.firstWhere((s) => s.number == _playingSurahNumber)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF064E3B),
        title: const Text("القرآن الكريم (استماع)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Reciter Selector Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(bottom: BorderSide(color: Color(0xFF334155))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.record_voice_over, color: Color(0xFF10B981), size: 20),
                    SizedBox(width: 8),
                    Text("القارئ:", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                DropdownButton<String>(
                  value: _selectedReciter['id'],
                  dropdownColor: const Color(0xFF1E293B),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF10B981)),
                  items: _reciters.map((r) {
                    return DropdownMenuItem<String>(
                      value: r['id'],
                      child: Text(r['name']!, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final newReciter = _reciters.firstWhere((r) => r['id'] == val);
                      setState(() {
                        _selectedReciter = newReciter;
                      });
                      if (_playingSurahNumber != null && currentSurah != null) {
                        _playSurah(currentSurah);
                      }
                    }
                  },
                ),
              ],
            ),
          ),

          // Active Player Banner (if playing or paused)
          if (currentSurah != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B),
                border: const Border(bottom: BorderSide(color: Color(0xFFD4AF37), width: 1.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: _isLoading
                            ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Icon(
                                _isPlaying ? Icons.pause_circle : Icons.play_circle_filled,
                                color: const Color(0xFFFDE68A),
                                size: 38,
                              ),
                        onPressed: () => _playSurah(currentSurah),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "سورة ${currentSurah.nameAr} • ${_selectedReciter['name']}",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${_formatDuration(_position)} / ${_formatDuration(_duration)}",
                              style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop_circle_outlined, color: Colors.white70, size: 28),
                        tooltip: "إيقاف",
                        onPressed: _stopAudio,
                      ),
                    ],
                  ),
                  if (_duration.inSeconds > 0)
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                        activeTrackColor: const Color(0xFFFDE68A),
                        inactiveTrackColor: Colors.white24,
                        thumbColor: const Color(0xFFFDE68A),
                      ),
                      child: Slider(
                        value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()),
                        max: _duration.inSeconds.toDouble(),
                        onChanged: (val) {
                          _audioPlayer.seek(Duration(seconds: val.toInt()));
                        },
                      ),
                    ),
                ],
              ),
            ),

          // Surahs List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: QuranData.surahs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final surah = QuranData.surahs[index];
                final isThisSurah = _playingSurahNumber == surah.number;
                final isThisPlaying = isThisSurah && _isPlaying;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isThisSurah ? const Color(0xFF0F3B2E) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isThisSurah ? const Color(0xFFD4AF37) : const Color(0xFF334155),
                      width: isThisSurah ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: isThisSurah && _isLoading
                            ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(color: Color(0xFF10B981), strokeWidth: 2),
                              )
                            : Icon(
                                isThisPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                color: isThisSurah ? const Color(0xFFFDE68A) : const Color(0xFF10B981),
                                size: 36,
                              ),
                        onPressed: () => _playSurah(surah),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "سورة ${surah.nameAr}",
                              style: TextStyle(
                                color: isThisSurah ? const Color(0xFFFDE68A) : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${surah.typeAr} • ${surah.versesCount} آية",
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0F172A),
                          border: Border.all(color: isThisSurah ? const Color(0xFFD4AF37) : const Color(0xFF10B981)),
                        ),
                        child: Text(
                          "${surah.number}",
                          style: TextStyle(
                            color: isThisSurah ? const Color(0xFFFDE68A) : const Color(0xFF34D399),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
