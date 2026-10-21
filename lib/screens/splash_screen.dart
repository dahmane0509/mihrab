import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../services/verse_audio_service.dart';
import '../services/language_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Main entrance controller
  late AnimationController _entranceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Dedicated Verse fade & slide animation
  late Animation<double> _verseFadeAnimation;
  late Animation<Offset> _verseSlideAnimation;

  // Continuous breathing / floating controller
  late AnimationController _breathingController;
  late Animation<double> _breathingScale;
  late Animation<double> _glowAnimation;

  // Rotating subtle halo ring controller
  late AnimationController _rotationController;

  // Shimmer / light sheen controller
  late AnimationController _sheenController;

  StreamSubscription<void>? _playerCompleteSub;
  bool _navigated = false;
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (1400 ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<double>(begin: 25.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Verse Smooth Fade & Slide Animation
    _verseFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.85, curve: Curves.easeIn),
    );

    _verseSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // 2. Breathing / Glow animation (loops continuously)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _breathingScale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 18.0, end: 38.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // 3. Subtle slow rotating halo
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    // 4. Shimmer light sheen across the logo
    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Start entrance animations
    _entranceController.forward();

    // Play Sheikh Abdul Basit recitation of Surah Ali 'Imran verse 39
    _playVerseAudio();
  }

  Future<void> _playVerseAudio() async {
    // Start local recitation audio
    await VerseAudioService.playVerse();

    // Listen for completion: when recitation finishes naturally, transition to home smoothly
    _playerCompleteSub = VerseAudioService.player.onPlayerComplete.listen((_) {
      _navigateToHome(stopAudio: false);
    });

    // High upper-bound safety timer (35 seconds) in case of silent or muted device
    _safetyTimer = Timer(const Duration(seconds: 35), () {
      _navigateToHome(stopAudio: false);
    });
  }

  /// Transition to MainHomeScreen.
  /// Note: [stopAudio] defaults to false so the Quran recitation continues smoothly
  /// into the Home Screen without abrupt cut-off!
  void _navigateToHome({bool stopAudio = false}) {
    if (_navigated) return;
    _navigated = true;

    _safetyTimer?.cancel();
    _playerCompleteSub?.cancel();

    if (stopAudio) {
      VerseAudioService.stopVerse();
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, __, ___) => const MainHomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _playerCompleteSub?.cancel();
    _entranceController.dispose();
    _breathingController.dispose();
    _rotationController.dispose();
    _sheenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isFr = LanguageService.languageCode == 'fr';
    final skipLabel = isFr ? "Passer ❯" : "تخطي ❯";

    return Scaffold(
      backgroundColor: const Color(0xFF071224), // Royal deep navy matching logo
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _navigateToHome(stopAudio: false), // Tap anywhere to proceed without cutting audio
        child: Stack(
          children: [
            // Background ambient radial lights
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF1D4ED8).withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Central Animated Content (Verse + Halo Logo + Typography)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: topPadding + 58,
                          bottom: 24,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 1. The Quranic Verse displayed ABOVE the logo with smooth Fade-in
                            FadeTransition(
                              opacity: _verseFadeAnimation,
                              child: SlideTransition(
                                position: _verseSlideAnimation,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B192E).withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Islamic decorative header line
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 26,
                                            height: 1,
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.transparent, Color(0xFFD4AF37)],
                                              ),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 7),
                                            child: Icon(Icons.mosque_rounded, color: Color(0xFFD4AF37), size: 14),
                                          ),
                                          Container(
                                            width: 26,
                                            height: 1,
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Color(0xFFD4AF37), Colors.transparent],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),

                                      // Holy Quran Verse in beautiful Uthmani Arabic script with full Tashkeel
                                      Text(
                                        "﴿فَنَادَتْهُ الْمَلَائِكَةُ وَهُوَ قَائِمٌ يُصَلِّي فِي الْمِحْرَابِ أَنَّ اللَّهَ يُبَشِّرُكَ بِيَحْيَىٰ﴾",
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.rtl,
                                        style: GoogleFonts.amiri(
                                          color: const Color(0xFFFDE68A),
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.bold,
                                          height: 1.68,
                                          shadows: [
                                            Shadow(
                                              color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 3),

                                      // Surah Reference
                                      Text(
                                        isFr ? "[Sourate Âl-'Imrân : 39]" : "[سورة آل عمران: 39]",
                                        style: GoogleFonts.cairo(
                                          color: const Color(0xFF94A3B8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                      // 2. Animated Icon with Multi-layer Effects
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _entranceController,
                          _breathingController,
                          _rotationController,
                          _sheenController,
                        ]),
                        builder: (context, child) {
                          final entranceScale = _scaleAnimation.value;
                          final breathing = _breathingScale.value;
                          final currentScale = entranceScale * breathing;
                          final glowBlur = _glowAnimation.value;
                          final sheenProgress = _sheenController.value;

                          return Transform.scale(
                            scale: currentScale,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Slow Rotating Spiritual Halo Ring
                                Transform.rotate(
                                  angle: _rotationController.value * 2 * pi,
                                  child: Container(
                                    width: 195,
                                    height: 195,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),

                                // Secondary Decorative Ring
                                Transform.rotate(
                                  angle: -_rotationController.value * 2 * pi,
                                  child: Container(
                                    width: 178,
                                    height: 178,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                ),

                                // Royal Blue Diamond Logo Container with White Border & Glow
                                Container(
                                  width: 150,
                                  height: 150,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1E3A8A),
                                        Color(0xFF0F172A),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.2,
                                    ),
                                    boxShadow: [
                                      // Pure White Pulse Glow
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.35),
                                        blurRadius: glowBlur,
                                        spreadRadius: 3,
                                      ),
                                      // Deep Royal Blue Ambient Drop Shadow
                                      BoxShadow(
                                        color: const Color(0xFF1E40AF).withValues(alpha: 0.5),
                                        blurRadius: 25,
                                        spreadRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: Stack(
                                      children: [
                                        // The Real Logo Image
                                        Image.asset(
                                          'assets/icon/app_icon.png',
                                          fit: BoxFit.cover,
                                          width: 150,
                                          height: 150,
                                          errorBuilder: (_, __, ___) => const Center(
                                            child: Icon(Icons.mosque, color: Colors.white, size: 70),
                                          ),
                                        ),

                                        // Shimmer Sheen Light Sweep across the logo
                                        Positioned.fill(
                                          child: Transform.translate(
                                            offset: Offset((sheenProgress * 300) - 150, 0),
                                            child: Transform.rotate(
                                              angle: pi / 4,
                                              child: Container(
                                                width: 32,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.white.withValues(alpha: 0.25),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // 3. Animated App Name and Subtitle
                      AnimatedBuilder(
                        animation: _entranceController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: Column(
                                children: [
                                  // Brand Title
                                  Text(
                                    "محراب",
                                    style: GoogleFonts.alexandria(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w200,
                                      letterSpacing: 3.5,
                                      shadows: const [
                                        Shadow(
                                          color: Color(0x8000E5FF),
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  // English Brand Name
                                  Text(
                                    "M I H R A B",
                                    style: GoogleFonts.cairo(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 5,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Subtitle with White Border Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F254E).withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      isFr ? "Horaires de Prière & Coran" : "مواقيت الصلاة والقرآن",
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 36),

                      // 4. Subtle Loading Spinner
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // Top Header: Audio Info & Skip Button (placed last in Stack for clear, un-overlapped display)
      Positioned(
        top: topPadding + 10,
        left: 18,
        right: 18,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Audio status badge
            ValueListenableBuilder<bool>(
              valueListenable: VerseAudioService.isPlayingNotifier,
              builder: (context, isPlaying, _) {
                return GestureDetector(
                  onTap: () {
                    VerseAudioService.toggleVerse();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1E36).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPlaying
                            ? const Color(0xFFD4AF37)
                            : Colors.white24,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPlaying ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                          color: isPlaying ? const Color(0xFFD4AF37) : Colors.white60,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isFr ? "Cheikh Abdul Basit" : "الشيخ عبد الباسط عبد الصمد",
                          style: GoogleFonts.cairo(
                            color: const Color(0xFFE2E8F0),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Skip Button (تخطي / Passer)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _navigateToHome(stopAudio: false),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    skipLabel,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
);
  }
}
