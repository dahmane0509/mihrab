import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/quran_data.dart';
import '../data/quran_texts.dart';
import '../services/theme_service.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = "";

  // Audio Player State
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int? _currentPlayingSurahNumber;
  String _currentReciterId = "jaza";
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  final List<Map<String, String>> _reciters = [
    {"id": "jaza", "name": "الشيخ ياسين الجزائري (رواية ورش)", "server": "https://cdn.mp3quran.net/audio/yassen-jazairi/r1"},
    {"id": "basit", "name": "الشيخ عبد الباسط عبد الصمد (مرتل)", "server": "https://cdn.mp3quran.net/audio/abdulbasit-abdulsamad/r3"},
    {"id": "minsh", "name": "الشيخ محمد صديق المنشاوي", "server": "https://cdn.mp3quran.net/audio/muhammad-minshawi/r1"},
    {"id": "husr", "name": "الشيخ محمود خليل الحصري (ورش عن نافع)", "server": "https://cdn.mp3quran.net/audio/mahmoud-husary/r3"},
    {"id": "sds", "name": "الشيخ عبد الرحمن السديس", "server": "https://server11.mp3quran.net/sds"},
    {"id": "shur", "name": "الشيخ سعود الشريم", "server": "https://server7.mp3quran.net/shur"},
    {"id": "maher", "name": "الشيخ ماهر المعيقلي", "server": "https://cdn.mp3quran.net/audio/maher-muaiqly/r1"},
    {"id": "s_gmd", "name": "الشيخ سعد الغامدي", "server": "https://cdn.mp3quran.net/audio/saad-ghamdi/r1"},
    {"id": "shatri", "name": "الشيخ أبو بكر الشاطري", "server": "https://server11.mp3quran.net/shatri"},
    {"id": "dosari", "name": "الشيخ ياسر الدوسري", "server": "https://server11.mp3quran.net/yasser"},
  ];

  int? _savedBookmarkSurah;
  String? _savedBookmarkName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookmark();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
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
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _savedBookmarkSurah = prefs.getInt('quran_bookmark_surah');
        _savedBookmarkName = prefs.getString('quran_bookmark_surah_name');
      });
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _playSurah(int surahNum) async {
    final reciter = _reciters.firstWhere((r) => r['id'] == _currentReciterId);
    final paddedNum = surahNum.toString().padLeft(3, '0');
    final url = "${reciter['server']}/$paddedNum.mp3";
    final surahObj = QuranData.surahs.firstWhere((s) => s.number == surahNum);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF065F46),
        duration: const Duration(seconds: 4),
        content: Text("جاري تشغيل سورة ${surahObj.nameAr} بصوت ${reciter['name']}"),
        action: SnackBarAction(
          label: "إيقاف",
          textColor: const Color(0xFFFDE68A),
          onPressed: _stopAudio,
        ),
      ),
    );

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _currentPlayingSurahNumber = surahNum;
        _isPlaying = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentPlayingSurahNumber = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF991B1B),
            content: Text("تعذر تشغيل التلاوة، يرجى التأكد من اتصال الإنترنت ⚠️"),
          ),
        );
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF1E293B),
          duration: Duration(seconds: 2),
          content: Text("تم إيقاف التلاوة مؤقتاً ⏸️"),
        ),
      );
    } else {
      if (_currentPlayingSurahNumber != null) {
        await _audioPlayer.resume();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF065F46),
            duration: Duration(seconds: 2),
            content: Text("تم استئناف التلاوة ▶️"),
          ),
        );
      } else {
        _playSurah(1); // Play Al-Fatihah by default
      }
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _currentPlayingSurahNumber = null;
      _position = Duration.zero;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF1E293B),
        duration: Duration(seconds: 2),
        content: Text("تم إيقاف مشغل القرآن ⏹️"),
      ),
    );
  }

  void _nextSurah() {
    if (_currentPlayingSurahNumber != null && _currentPlayingSurahNumber! < 114) {
      _playSurah(_currentPlayingSurahNumber! + 1);
    } else {
      _playSurah(1);
    }
  }

  void _prevSurah() {
    if (_currentPlayingSurahNumber != null && _currentPlayingSurahNumber! > 1) {
      _playSurah(_currentPlayingSurahNumber! - 1);
    } else {
      _playSurah(114);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSurahs = QuranData.surahs.where((s) {
      return s.nameAr.contains(_searchQuery) ||
          s.nameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.number.toString() == _searchQuery;
    }).toList();

    return ValueListenableBuilder<AppThemeColor>(
      valueListenable: ThemeService.currentTheme,
      builder: (context, theme, _) {
        return Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            backgroundColor: theme.darkPrimary,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "القرآن الكريم (قراءة واستماع)",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: theme.accent,
              indicatorWeight: 3,
              labelColor: theme.accent,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              tabs: const [
                Tab(icon: Icon(Icons.menu_book), text: "قراءة القرآن"),
                Tab(icon: Icon(Icons.headphones), text: "استماع وتلاوة"),
              ],
            ),
          ),
          body: Column(
            children: [
              // Search input
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.cardBackground,
                    hintText: "ابحث عن السورة (بالاسم أو الرقم)...",
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    prefixIcon: Icon(Icons.search, color: theme.primary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white54),
                            onPressed: () => setState(() => _searchQuery = ""),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Saved Bookmark Quick Resume
              if (_savedBookmarkSurah != null && _searchQuery.isEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF065F46).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.accent),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark, color: Color(0xFFD4AF37), size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "متابعة القراءة: سورة ${_savedBookmarkName ?? ''}",
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          final match = QuranData.surahs.firstWhere(
                            (s) => s.number == _savedBookmarkSurah,
                            orElse: () => QuranData.surahs[0],
                          );
                          await Navigator.push(context, MaterialPageRoute<void>(builder: (_) => SurahReaderView(surah: match)));
                          _loadBookmark();
                        },
                        child: const Text("متابعة الآن", style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Reading (قراءة)
                    _buildReadingList(filteredSurahs, theme),

                    // Tab 2: Listening (استماع)
                    _buildListeningView(filteredSurahs, theme),
                  ],
                ),
              ),

              // Floating Audio Player Banner (if active)
              if (_currentPlayingSurahNumber != null) _buildMiniPlayer(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReadingList(List<Surah> surahs, AppThemeColor theme) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: surahs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tileColor: theme.cardBackground,
          leading: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.background,
              shape: BoxShape.circle,
              border: Border.all(color: theme.primary, width: 1.5),
            ),
            child: Text(
              "${surah.number}",
              style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            surah.nameAr,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            "${surah.typeAr} • ${surah.versesCount} آية",
            textDirection: TextDirection.rtl,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.play_circle_fill, color: theme.accent, size: 28),
                tooltip: "استماع للسورة",
                onPressed: () {
                  _playSurah(surah.number);
                },
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
            ],
          ),
          onTap: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: theme.darkPrimary,
                duration: const Duration(seconds: 1),
                content: Text("فتح سورة ${surah.nameAr} للقراءة"),
              ),
            );
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SurahReaderView(surah: surah),
              ),
            );
            _loadBookmark();
          },
        );
      },
    );
  }

  Widget _buildListeningView(List<Surah> surahs, AppThemeColor theme) {
    return Column(
      children: [
        // Reciter Selection Header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: theme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.mic, color: theme.accent),
              const SizedBox(width: 12),
              const Text(
                "القارئ:",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: _currentReciterId,
                  dropdownColor: theme.cardBackground,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(Icons.arrow_drop_down, color: theme.accent),
                  items: _reciters.map((r) {
                    return DropdownMenuItem<String>(
                      value: r['id'],
                      child: Text(
                        r['name']!,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (newId) {
                    if (newId != null) {
                      setState(() {
                        _currentReciterId = newId;
                      });
                      final chosen = _reciters.firstWhere((r) => r['id'] == newId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: theme.darkPrimary,
                          duration: const Duration(seconds: 2),
                          content: Text("تم اختيار القارئ: ${chosen['name']}"),
                        ),
                      );
                      if (_isPlaying && _currentPlayingSurahNumber != null) {
                        _playSurah(_currentPlayingSurahNumber!);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Surahs List for Audio
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: surahs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final surah = surahs[index];
              final isCurrent = _currentPlayingSurahNumber == surah.number;

              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isCurrent ? BorderSide(color: theme.accent, width: 1.5) : BorderSide.none,
                ),
                tileColor: isCurrent ? theme.darkPrimary.withValues(alpha: 0.7) : theme.cardBackground,
                leading: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrent ? theme.accent : theme.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCurrent && _isPlaying ? Icons.graphic_eq : Icons.play_arrow,
                    color: isCurrent ? Colors.black : theme.primary,
                  ),
                ),
                title: Text(
                  surah.nameAr,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: isCurrent ? theme.accent : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                subtitle: Text(
                  "${surah.typeAr} • ${surah.versesCount} آية",
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
                trailing: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrent ? theme.accent : theme.primary.withValues(alpha: 0.2),
                    foregroundColor: isCurrent ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: Icon(isCurrent && _isPlaying ? Icons.pause : Icons.play_arrow, size: 18),
                  label: Text(isCurrent && _isPlaying ? "إيقاف" : "استماع"),
                  onPressed: () {
                    if (isCurrent && _isPlaying) {
                      _togglePlayPause();
                    } else {
                      _playSurah(surah.number);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMiniPlayer(AppThemeColor theme) {
    final surahObj = QuranData.surahs.firstWhere(
      (s) => s.number == _currentPlayingSurahNumber,
      orElse: () => QuranData.surahs[0],
    );
    final reciter = _reciters.firstWhere((r) => r['id'] == _currentReciterId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.darkPrimary,
        border: Border(top: BorderSide(color: theme.accent, width: 2)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, -3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                onPressed: _stopAudio,
                tooltip: "إغلاق المشغل",
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "سورة ${surahObj.nameAr}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      reciter['name']!,
                      style: TextStyle(color: theme.accent, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: _prevSurah,
                tooltip: "السورة السابقة",
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: theme.accent, size: 38),
                onPressed: _togglePlayPause,
                tooltip: _isPlaying ? "إيقاف مؤقت" : "تشغيل",
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: _nextSurah,
                tooltip: "السورة التالية",
              ),
            ],
          ),
          if (_duration > Duration.zero) ...[
            Row(
              children: [
                Text(_formatDuration(_position), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                Expanded(
                  child: Slider(
                    value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()),
                    max: _duration.inSeconds.toDouble(),
                    activeColor: theme.accent,
                    inactiveColor: Colors.white24,
                    onChanged: (val) {
                      _audioPlayer.seek(Duration(seconds: val.toInt()));
                    },
                  ),
                ),
                Text(_formatDuration(_duration), style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class SurahReaderView extends StatefulWidget {
  final Surah surah;

  const SurahReaderView({super.key, required this.surah});

  @override
  State<SurahReaderView> createState() => _SurahReaderViewState();
}

class _SurahReaderViewState extends State<SurahReaderView> {
  List<String> _verses = [];
  bool _isLoading = true;
  double _fontSize = 19.0;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadSurahVerses();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkSurah = prefs.getInt('quran_bookmark_surah');
    if (bookmarkSurah == widget.surah.number) {
      setState(() {
        _isBookmarked = true;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    if (_isBookmarked) {
      await prefs.setInt('quran_bookmark_surah', widget.surah.number);
      await prefs.setString('quran_bookmark_surah_name', widget.surah.nameAr);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF065F46),
          content: Text("تم حفظ علامة التوقف عند سورة ${widget.surah.nameAr} 🔖"),
        ),
      );
    } else {
      await prefs.remove('quran_bookmark_surah');
      await prefs.remove('quran_bookmark_surah_name');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF1E293B),
          content: Text("تمت إزالة علامة التوقف"),
        ),
      );
    }
  }

  Future<void> _loadSurahVerses() async {
    setState(() {
      _isLoading = true;
    });

    // 1. Check local pre-bundled offline repository if complete
    if (QuranTexts.offlineSurahs.containsKey(widget.surah.number)) {
      final offlineList = QuranTexts.offlineSurahs[widget.surah.number]!;
      if (offlineList.length >= widget.surah.versesCount) {
        setState(() {
          _verses = offlineList;
          _isLoading = false;
        });
        return;
      }
    }

    // 2. Check local SharedPreferences cache if complete
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getStringList('surah_text_${widget.surah.number}');
      if (cached != null && cached.length >= widget.surah.versesCount) {
        setState(() {
          _verses = cached;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // 3. Auto-fetch complete Surah from Quran Cloud API and save locally
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(
        Uri.parse('https://api.alquran.cloud/v1/surah/${widget.surah.number}/editions/quran-uthmani'),
      );
      final response = await request.close();

      if (response.statusCode == 200) {
        final jsonString = await response.transform(utf8.decoder).join();
        final dynamic decoded = json.decode(jsonString);
        if (decoded is Map<String, dynamic> && decoded['data'] is List && (decoded['data'] as List).isNotEmpty) {
          final dynamic firstEdition = (decoded['data'] as List)[0];
          if (firstEdition is Map<String, dynamic> && firstEdition['ayahs'] is List) {
            final List<dynamic> ayahsList = firstEdition['ayahs'] as List<dynamic>;
            final List<String> fetched = ayahsList
                .map((dynamic a) => (a is Map<String, dynamic>) ? (a['text']?.toString() ?? '') : '')
                .where((s) => s.isNotEmpty)
                .toList();

            if (fetched.isNotEmpty) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setStringList('surah_text_${widget.surah.number}', fetched);

              if (mounted) {
                setState(() {
                  _verses = fetched;
                  _isLoading = false;
                });
              }
              return;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("API fetch error: $e");
    }

    // 4. Fallback: if we have pre-bundled partial verses, show them
    if (QuranTexts.offlineSurahs.containsKey(widget.surah.number)) {
      final partial = QuranTexts.offlineSurahs[widget.surah.number]!;
      if (partial.isNotEmpty) {
        setState(() {
          _verses = partial;
          _isLoading = false;
        });
        return;
      }
    }

    // Comprehensive Fallback Overview if offline and not in bundle
    setState(() {
      _isLoading = false;
      _verses = [
        "سورة ${widget.surah.nameAr} من السور الـ ${widget.surah.typeAr} في كتاب الله عز وجل، وعدد آياتها ${widget.surah.versesCount} آية مباركة.",
        "قال رسول الله ﷺ: «اقْرَءُوا القُرْآنَ فإنَّه يَأْتي يَومَ القِيامَةِ شَفِيعًا لأَصْحابِهِ».",
        "يمكنك الاستماع للتلاوة العطرة لهذه السورة بصوت كبار القراء عبر تبويب «استماع وتلاوة» أعلاه في أي وقت.",
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeColor>(
      valueListenable: ThemeService.currentTheme,
      builder: (context, theme, _) {
        return Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            backgroundColor: theme.darkPrimary,
            title: Text("سورة ${widget.surah.nameAr}"),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: theme.accent),
                tooltip: "حفظ العلامة المرجعية",
                onPressed: _toggleBookmark,
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in, color: Colors.white),
                tooltip: "تكبير الخط",
                onPressed: () {
                  setState(() {
                    if (_fontSize < 30) _fontSize += 2;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      duration: Duration(milliseconds: 600),
                      content: Text("تم تكبير الخط"),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.zoom_out, color: Colors.white),
                tooltip: "تصغير الخط",
                onPressed: () {
                  setState(() {
                    if (_fontSize > 14) _fontSize -= 2;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      duration: Duration(milliseconds: 600),
                      content: Text("تم تصغير الخط"),
                    ),
                  );
                },
              ),
            ],
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator(color: theme.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header card
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.darkPrimary.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.accent.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "سورة ${widget.surah.nameAr}",
                              style: TextStyle(
                                color: theme.accent,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${widget.surah.typeAr} • عدد آياتها: ${widget.surah.versesCount} آية",
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Basmalah
                      if (widget.surah.number != 9 && widget.surah.number != 1) ...[
                        Center(
                          child: Text(
                            "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                            style: TextStyle(
                              color: theme.accent,
                              fontSize: _fontSize + 4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Verses container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Column(
                          children: List.generate(_verses.length, (i) {
                            final verseNum = i + 1;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.darkPrimary,
                                      border: Border.all(color: theme.accent, width: 1),
                                    ),
                                    child: Text(
                                      "$verseNum",
                                      style: TextStyle(
                                        color: theme.accent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      _verses[i],
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: _fontSize,
                                        height: 2.1,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
