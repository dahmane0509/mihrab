import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/adhan_audio_service.dart';
import '../services/verse_audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/quran_data.dart';
import '../data/quran_texts.dart';
import '../data/quran_reciters_catalog.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';
import '../services/quran_audio_reciters_service.dart';

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

  int? _savedBookmarkSurah;
  String? _savedBookmarkName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _currentReciterId = QuranAudioRecitersService.activeReciterId;
    QuranAudioRecitersService.activeReciterNotifier.addListener(_onReciterChanged);
    QuranAudioRecitersService.recitersVersionNotifier.addListener(_onRecitersListChanged);
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

  void _onReciterChanged() {
    if (mounted) {
      setState(() {
        _currentReciterId = QuranAudioRecitersService.activeReciterId;
      });
      if (_isPlaying && _currentPlayingSurahNumber != null) {
        _playSurah(_currentPlayingSurahNumber!);
      }
    }
  }

  void _onRecitersListChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    QuranAudioRecitersService.activeReciterNotifier.removeListener(_onReciterChanged);
    QuranAudioRecitersService.recitersVersionNotifier.removeListener(_onRecitersListChanged);
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
    final reciter = QuranAudioRecitersService.getReciterById(_currentReciterId);
    final url = reciter.getSurahUrl(surahNum);
    final surahObj = QuranData.surahs.firstWhere((s) => s.number == surahNum);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF065F46),
        duration: const Duration(seconds: 4),
        content: Text("جاري تشغيل سورة ${surahObj.nameAr} بصوت ${reciter.name}"),
        action: SnackBarAction(
          label: "إيقاف",
          textColor: const Color(0xFFFDE68A),
          onPressed: _stopAudio,
        ),
      ),
    );

    try {
      await VerseAudioService.stopVerse();
      await AdhanAudioService.stopAdhan();
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

              // Smart Reciter Search prompt when searching
              if (_searchQuery.isNotEmpty)
                Builder(
                  builder: (context) {
                    final matchingCatalog = QuranAudioRecitersService.searchCatalogAvailableToAdd(_searchQuery);
                    final matchingCurrent = QuranAudioRecitersService.searchCurrentReciters(_searchQuery);
                    final totalMatches = matchingCatalog.length + matchingCurrent.length;
                    final isReciterQuery = totalMatches > 0 ||
                        _searchQuery.contains('قارئ') ||
                        _searchQuery.contains('الشيخ') ||
                        _searchQuery.contains('شيخ');
                    if (!isReciterQuery) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0369A1).withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF38BDF8), width: 0.8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mic, color: Color(0xFF38BDF8), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              totalMatches > 0
                                  ? "وجدنا $totalMatches قارئ يطابق «$_searchQuery»"
                                  : "هل تبحث عن القارئ «$_searchQuery»؟",
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _showRecitersModal(theme, initialQuery: _searchQuery),
                            child: const Text("عرض وإضافة القراء", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
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
    final activeReciter = QuranAudioRecitersService.activeReciter;

    return Column(
      children: [
        // Active Reciter Card & Change / Add button
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.primary.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.accent, width: 1.2),
                ),
                child: Center(
                  child: Text(
                    activeReciter.countryFlag,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "القارئ:",
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            activeReciter.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (activeReciter.isCustom)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "مخصص",
                              style: TextStyle(color: Color(0xFF38BDF8), fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${activeReciter.riwayah} • ${activeReciter.subtext}",
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.search, size: 16),
                label: const Text(
                  "تغيير / إضافة",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _showRecitersModal(theme),
              ),
            ],
          ),
        ),

        // Surahs List for Audio
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

  void _showRecitersModal(AppThemeColor theme, {String initialQuery = ""}) {
    final searchCtrl = TextEditingController(text: initialQuery);
    String query = initialQuery.trim();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final currentReciters = QuranAudioRecitersService.searchCurrentReciters(query);
          final catalogAvailable = QuranAudioRecitersService.searchCatalogAvailableToAdd(query);

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 16,
              top: 16,
              left: 16,
              right: 16,
            ),
            child: SizedBox(
              height: MediaQuery.of(modalCtx).size.height * 0.78,
              child: Column(
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.mic_external_on, color: theme.accent, size: 24),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "اختيار وإضافة قراء القرآن الكريم 🎙️",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Search field inside modal
                  TextField(
                    controller: searchCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    textDirection: TextDirection.rtl,
                    onChanged: (val) {
                      setModalState(() {
                        query = val.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "ابحث عن أي قارئ (مثل: عبد الباسط، العفاسي، المنشاوي، مهساس)...",
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      prefixIcon: Icon(Icons.search, color: theme.primary, size: 20),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                              onPressed: () {
                                searchCtrl.clear();
                                setModalState(() => query = "");
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Content list
                  Expanded(
                    child: ListView(
                      children: [
                        // Section 1: Active Reciters
                        if (currentReciters.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: theme.accent, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "القراء المتاحون حالياً (${currentReciters.length}):",
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...currentReciters.map((r) {
                            final isSel = r.id == QuranAudioRecitersService.activeReciterId;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: isSel ? theme.primary.withValues(alpha: 0.25) : const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSel ? theme.accent : const Color(0xFF334155),
                                  width: isSel ? 1.5 : 0.8,
                                ),
                              ),
                              child: ListTile(
                                dense: true,
                                leading: Text(r.countryFlag, style: const TextStyle(fontSize: 20)),
                                title: Text(
                                  r.name,
                                  style: TextStyle(
                                    color: isSel ? theme.accent : Colors.white,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13.5,
                                  ),
                                ),
                                subtitle: Text(
                                  "${r.riwayah} • ${r.subtext}",
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSel)
                                      Icon(Icons.check_circle, color: theme.accent, size: 20)
                                    else
                                      const Icon(Icons.circle_outlined, color: Colors.white30, size: 18),
                                    if (r.isCustom) ...[
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                        tooltip: "حذف القارئ",
                                        onPressed: () async {
                                          await QuranAudioRecitersService.removeCustomReciter(r.id);
                                          setModalState(() {});
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                                onTap: () async {
                                  await QuranAudioRecitersService.setActiveReciter(r.id);
                                  if (modalCtx.mounted) Navigator.pop(modalCtx);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(0xFF065F46),
                                        content: Text("تم اختيار القارئ: ${r.name}"),
                                      ),
                                    );
                                    if (_isPlaying && _currentPlayingSurahNumber != null) {
                                      _playSurah(_currentPlayingSurahNumber!);
                                    }
                                  }
                                },
                              ),
                            );
                          }),
                          const SizedBox(height: 14),
                        ],

                        // Section 2: Catalog Reciters
                        if (catalogAvailable.isNotEmpty) ...[
                          const Row(
                            children: [
                              Icon(Icons.cloud_download_outlined, color: Color(0xFF38BDF8), size: 18),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "قراء متاحون للإضافة من المكتبة العالمية (أكثر من 40 قارئ):",
                                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...catalogAvailable.map((item) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF1E293B)),
                              ),
                              child: Row(
                                children: [
                                  Text(item.countryFlag, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "${item.riwayah} • ${item.subtext}",
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
                                      minimumSize: Size.zero,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.add, size: 14),
                                    label: const Text("إضافة واستماع", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    onPressed: () async {
                                      await QuranAudioRecitersService.addReciter(item, activateNow: true);
                                      if (modalCtx.mounted) Navigator.pop(modalCtx);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: const Color(0xFF065F46),
                                            content: Text("تمت إضافة القارئ ${item.name} وتفعيله بنجاح!"),
                                          ),
                                        );
                                        if (_isPlaying && _currentPlayingSurahNumber != null) {
                                          _playSurah(_currentPlayingSurahNumber!);
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 14),
                        ],

                        // Section 3: Custom Reciter Addition
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.amberAccent,
                            side: const BorderSide(color: Colors.amberAccent),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.add_link, size: 18),
                          label: const Text(
                            "+ إضافة قارئ مخصص برابط صوتي",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          onPressed: () {
                            _showAddCustomReciterDialog(theme);
                          },
                        ),
                        const SizedBox(height: 16),
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

  void _showAddCustomReciterDialog(AppThemeColor theme) {
    final nameCtrl = TextEditingController();
    final riwayahCtrl = TextEditingController(text: "حفص عن عاصم");
    final urlCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: theme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.person_add_alt_1, color: Colors.amberAccent, size: 22),
            SizedBox(width: 8),
            Text(
              "إضافة قارئ مخصص",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: "اسم القارئ / الشيخ *",
                  hintText: "مثال: الشيخ فلان الفلاني",
                  labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: riwayahCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: "الرواية",
                  labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: urlCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: "رابط السيرفر الصوتي (Base URL) *",
                  hintText: "https://serverX.mp3quran.net/name/",
                  helperText: "يدعم إضافة أرقام السور تلقائياً مثل 001.mp3",
                  labelStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  helperStyle: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("إلغاء", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final url = urlCtrl.text.trim();
              if (name.isEmpty || url.isEmpty) return;

              final customId = "custom_${DateTime.now().millisecondsSinceEpoch}";
              final newReciter = QuranReciter(
                id: customId,
                name: name,
                riwayah: riwayahCtrl.text.trim().isNotEmpty ? riwayahCtrl.text.trim() : "حفص عن عاصم",
                server: url,
                country: "🎙️",
                isCustom: true,
              );

              await QuranAudioRecitersService.addReciter(newReciter, activateNow: true);
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF065F46),
                    content: Text("تمت إضافة القارئ «$name» بنجاح!"),
                  ),
                );
              }
            },
            child: const Text("إضافة وحفظ"),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer(AppThemeColor theme) {
    final surahObj = QuranData.surahs.firstWhere(
      (s) => s.number == _currentPlayingSurahNumber,
      orElse: () => QuranData.surahs[0],
    );
    final reciter = QuranAudioRecitersService.getReciterById(_currentReciterId);

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
                      reciter.name,
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

class QuranTranslationInfo {
  final String id;
  final String langCode;
  final String authorName;
  final String languageName;
  final String flag;
  final bool isRtl;

  const QuranTranslationInfo({
    required this.id,
    required this.langCode,
    required this.authorName,
    required this.languageName,
    required this.flag,
    this.isRtl = false,
  });
}

const List<QuranTranslationInfo> verifiedTranslations = [
  QuranTranslationInfo(
    id: 'it.piccardo',
    langCode: 'it',
    authorName: 'Hamza Roberto Piccardo (UCOII)',
    languageName: 'Italiano',
    flag: '🇮🇹',
  ),
  QuranTranslationInfo(
    id: 'en.sahih',
    langCode: 'en',
    authorName: 'Saheeh International (King Fahd standard)',
    languageName: 'English',
    flag: '🇬🇧',
  ),
  QuranTranslationInfo(
    id: 'fr.hamidullah',
    langCode: 'fr',
    authorName: 'Muhammad Hamidullah (مجمع الملك فهد)',
    languageName: 'Français',
    flag: '🇫🇷',
  ),
  QuranTranslationInfo(
    id: 'es.cortes',
    langCode: 'es',
    authorName: 'Julio Cortés',
    languageName: 'Español',
    flag: '🇪🇸',
  ),
  QuranTranslationInfo(
    id: 'de.bubenheim',
    langCode: 'de',
    authorName: 'A. S. F. Bubenheim & N. Elyas (مجمع الملك فهد)',
    languageName: 'Deutsch',
    flag: '🇩🇪',
  ),
  QuranTranslationInfo(
    id: 'tr.diyanet',
    langCode: 'tr',
    authorName: 'Diyanet İşleri Başkanlığı',
    languageName: 'Türkçe',
    flag: '🇹🇷',
  ),
  QuranTranslationInfo(
    id: 'id.indonesian',
    langCode: 'id',
    authorName: 'Kementerian Agama RI',
    languageName: 'Bahasa Indonesia',
    flag: '🇮🇩',
  ),
  QuranTranslationInfo(
    id: 'ur.jalandhry',
    langCode: 'ur',
    authorName: 'فاتح محمد جالندھری (مجمع الملك فهد)',
    languageName: 'اردو',
    flag: '🇵🇰',
    isRtl: true,
  ),
  QuranTranslationInfo(
    id: 'ru.kuliev',
    langCode: 'ru',
    authorName: 'Эльмир Кулиев (مجمع الملك فهد)',
    languageName: 'Русский',
    flag: '🇷🇺',
  ),
];

const Map<String, List<String>> offlineFatihaTranslations = {
  'it.piccardo': [
    'In nome di Allah, il Compassionevole, il Misericordioso.',
    'La lode appartiene ad Allah, Signore dei mondi,',
    'il Compassionevole, il Misericordioso,',
    'Re del Giorno del Giudizio.',
    'Te noi adoriamo e a Te chiediamo aiuto.',
    'Guidaci sulla retta via,',
    'la via di coloro che hai colmato di grazia, non di coloro che [sono incorsi] nella [Tua] ira, né degli sviati.',
  ],
  'en.sahih': [
    'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
    '[All] praise is [due] to Allah, Lord of the worlds -',
    'The Entirely Merciful, the Especially Merciful,',
    'Sovereign of the Day of Recompense.',
    'It is You we worship and You we ask for help.',
    'Guide us to the straight path -',
    'The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.',
  ],
  'fr.hamidullah': [
    'Au nom d\'Allah, le Tout Miséricordieux, le Très Miséricordieux.',
    'Louange à Allah, Seigneur de l\'univers.',
    'Le Tout Miséricordieux, le Très Miséricordieux,',
    'Maître du Jour de la rétribution.',
    'C\'est Toi [Seul] que nous adorons, et c\'est Toi [Seul] dont nous implorons le secours.',
    'Guide-nous dans le droit chemin,',
    'Le chemin de ceux que Tu as comblés de faveurs, non pas de ceux qui ont encouru Ta colère, ni des égarés.',
  ],
  'es.cortes': [
    'En el nombre de Alá, el Compasivo, el Misericordioso.',
    'Alabado sea Alá, Señor del universo,',
    'el Compasivo, el Misericordioso,',
    'Dueño del día del Juicio.',
    'A Ti solo servimos y a Ti solo imploramos ayuda.',
    'Dirígenos por la vía recta,',
    'la vía de los que Tú has agraciado, no de los que han incurrido en la ira, ni de los extraviados.',
  ],
  'de.bubenheim': [
    'Im Namen Allahs, des Allerbarmers, des Barmherzigen.',
    'Alles Lob gebührt Allah, dem Herrn der Welten,',
    'dem Allerbarmer, dem Barmherzigen,',
    'dem Herrscher am Tage des Gerichts.',
    'Dir allein dienen wir, und zu Dir allein flehen wir um Hilfe.',
    'Leite uns den geraden Weg,',
    'den Weg derer, denen Du Gnade erwiesen hast, nicht derer, die Zorn erregt haben, und nicht der Irregehenden.',
  ],
};

class SurahReaderView extends StatefulWidget {
  final Surah surah;

  const SurahReaderView({super.key, required this.surah});

  @override
  State<SurahReaderView> createState() => _SurahReaderViewState();
}

class _SurahReaderViewState extends State<SurahReaderView> {
  List<String> _verses = [];
  List<String> _translations = [];
  bool _isLoading = true;
  double _fontSize = 19.0;
  bool _isBookmarked = false;
  bool _showTranslation = false;
  late QuranTranslationInfo _currentTranslation;

  @override
  void initState() {
    super.initState();
    _initTranslationSetting();
    _loadSurahVerses();
    _checkBookmark();
  }

  void _initTranslationSetting() {
    final currentLang = LanguageService.languageCode;
    _currentTranslation = verifiedTranslations.firstWhere(
      (t) => t.langCode == currentLang,
      orElse: () => verifiedTranslations[1], // default Saheeh International
    );
    // Non-Arabic users get translation shown automatically
    if (currentLang != 'ar') {
      _showTranslation = true;
    }
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

  void _toggleTranslation() async {
    setState(() {
      _showTranslation = !_showTranslation;
    });
    if (_showTranslation && _translations.isEmpty) {
      await _loadSurahVerses();
    }
  }

  void _showTranslationSelectorDialog(AppThemeColor theme) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: theme.accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.translate, color: theme.accent, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "ترجمات معاني القرآن المعتمدة عالمياً",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: verifiedTranslations.length,
                separatorBuilder: (_, __) => const Divider(color: Color(0xFF334155), height: 1),
                itemBuilder: (context, index) {
                  final t = verifiedTranslations[index];
                  final isSelected = t.id == _currentTranslation.id;
                  return ListTile(
                    leading: Text(t.flag, style: const TextStyle(fontSize: 22)),
                    title: Text(
                      t.languageName,
                      style: TextStyle(
                        color: isSelected ? theme.accent : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      t.authorName,
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    trailing: isSelected ? Icon(Icons.check_circle, color: theme.accent) : null,
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _currentTranslation = t;
                        _showTranslation = true;
                        _translations = [];
                      });
                      _loadSurahVerses();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadSurahVerses() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();

    // 1. Check local Arabic verses
    List<String> loadedVerses = [];
    if (QuranTexts.offlineSurahs.containsKey(widget.surah.number)) {
      final offlineList = QuranTexts.offlineSurahs[widget.surah.number]!;
      if (offlineList.length >= widget.surah.versesCount) {
        loadedVerses = offlineList;
      }
    }
    if (loadedVerses.isEmpty) {
      final cached = prefs.getStringList('surah_text_${widget.surah.number}');
      if (cached != null && cached.length >= widget.surah.versesCount) {
        loadedVerses = cached;
      }
    }

    // 2. Check local Translation verses
    List<String> loadedTrans = [];
    if (widget.surah.number == 1 && offlineFatihaTranslations.containsKey(_currentTranslation.id)) {
      loadedTrans = offlineFatihaTranslations[_currentTranslation.id]!;
    }
    if (loadedTrans.isEmpty) {
      final cachedTrans = prefs.getStringList('surah_trans_${widget.surah.number}_${_currentTranslation.id}');
      if (cachedTrans != null && cachedTrans.length >= widget.surah.versesCount) {
        loadedTrans = cachedTrans;
      }
    }

    // Fast-path: if both are ready, use immediately
    if (loadedVerses.isNotEmpty && (!_showTranslation || loadedTrans.isNotEmpty)) {
      if (mounted) {
        setState(() {
          _verses = loadedVerses;
          _translations = loadedTrans;
          _isLoading = false;
        });
      }
      return;
    }

    // 3. Fetch from AlQuran Cloud API (Uthmani + verified translation edition)
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final editionsParam = _showTranslation
          ? 'quran-uthmani,${_currentTranslation.id}'
          : 'quran-uthmani';

      final request = await client.getUrl(
        Uri.parse('https://api.alquran.cloud/v1/surah/${widget.surah.number}/editions/$editionsParam'),
      );
      final response = await request.close();

      if (response.statusCode == 200) {
        final jsonString = await response.transform(utf8.decoder).join();
        final dynamic decoded = json.decode(jsonString);
        if (decoded is Map<String, dynamic> && decoded['data'] is List && (decoded['data'] as List).isNotEmpty) {
          final editionsList = decoded['data'] as List<dynamic>;

          // Arabic edition
          final firstEdition = editionsList[0];
          if (firstEdition is Map<String, dynamic> && firstEdition['ayahs'] is List) {
            final List<dynamic> ayahsList = firstEdition['ayahs'] as List<dynamic>;
            loadedVerses = ayahsList
                .map((dynamic a) => (a is Map<String, dynamic>) ? (a['text']?.toString() ?? '') : '')
                .where((s) => s.isNotEmpty)
                .toList();

            if (loadedVerses.isNotEmpty) {
              await prefs.setStringList('surah_text_${widget.surah.number}', loadedVerses);
            }
          }

          // Translation edition
          if (editionsList.length > 1) {
            final transEdition = editionsList[1];
            if (transEdition is Map<String, dynamic> && transEdition['ayahs'] is List) {
              final List<dynamic> ayahsList = transEdition['ayahs'] as List<dynamic>;
              loadedTrans = ayahsList
                  .map((dynamic a) => (a is Map<String, dynamic>) ? (a['text']?.toString() ?? '') : '')
                  .where((s) => s.isNotEmpty)
                  .toList();

              if (loadedTrans.isNotEmpty) {
                await prefs.setStringList(
                  'surah_trans_${widget.surah.number}_${_currentTranslation.id}',
                  loadedTrans,
                );
              }
            }
          }

          if (mounted && loadedVerses.isNotEmpty) {
            setState(() {
              _verses = loadedVerses;
              _translations = loadedTrans;
              _isLoading = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("Quran API fetch error: $e");
    }

    // 4. Fallback if offline
    if (loadedVerses.isEmpty && QuranTexts.offlineSurahs.containsKey(widget.surah.number)) {
      loadedVerses = QuranTexts.offlineSurahs[widget.surah.number]!;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _verses = loadedVerses.isNotEmpty
            ? loadedVerses
            : [
                "سورة ${widget.surah.nameAr} من السور الـ ${widget.surah.typeAr} في كتاب الله عز وجل، وعدد آياتها ${widget.surah.versesCount} آية مباركة.",
                "قال رسول الله ﷺ: «اقْرَءُوا القُرْآنَ فإنَّه يَأْتي يَومَ القِيامَةِ شَفِيعًا لأَصْحابِهِ».",
              ];
        _translations = loadedTrans;
      });
    }
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
                icon: Icon(
                  _showTranslation ? Icons.translate : Icons.g_translate_outlined,
                  color: _showTranslation ? theme.accent : Colors.white70,
                ),
                tooltip: LanguageService.tr('quran_translation_toggle'),
                onPressed: _toggleTranslation,
              ),
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
                },
              ),
              IconButton(
                icon: const Icon(Icons.zoom_out, color: Colors.white),
                tooltip: "تصغير الخط",
                onPressed: () {
                  setState(() {
                    if (_fontSize > 14) _fontSize -= 2;
                  });
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
                            if (_showTranslation) ...[
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () => _showTranslationSelectorDialog(theme),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A).withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: theme.accent.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(_currentTranslation.flag, style: const TextStyle(fontSize: 16)),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          "${_currentTranslation.languageName} • ${_currentTranslation.authorName}",
                                          style: TextStyle(
                                            color: theme.accent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(Icons.keyboard_arrow_down, color: theme.accent, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
                            final hasTranslation = _showTranslation &&
                                i < _translations.length &&
                                _translations[i].isNotEmpty;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
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
                                  if (hasTranslation) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      margin: const EdgeInsets.only(left: 36),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A).withValues(alpha: 0.65),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF334155)),
                                      ),
                                      child: Text(
                                        _translations[i],
                                        textDirection: _currentTranslation.isRtl
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        style: TextStyle(
                                          color: const Color(0xFFCBD5E1),
                                          fontSize: (_fontSize * 0.74).clamp(13.0, 20.0),
                                          height: 1.6,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
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

