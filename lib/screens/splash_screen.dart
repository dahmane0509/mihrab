import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

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

  // Continuous breathing / floating controller
  late AnimationController _breathingController;
  late Animation<double> _breathingScale;
  late Animation<double> _glowAnimation;

  // Rotating subtle halo ring controller
  late AnimationController _rotationController;

  // Shimmer / light sheen controller
  late AnimationController _sheenController;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (1200 ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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

    // Start entrance
    _entranceController.forward();

    // Navigate to home screen smoothly after 2.3 seconds
    _navigationTimer = Timer(const Duration(milliseconds: 2300), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            pageBuilder: (_, __, ___) => const MainHomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _entranceController.dispose();
    _breathingController.dispose();
    _rotationController.dispose();
    _sheenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071224), // Royal deep navy matching logo background
      body: Stack(
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

          // Central Animated Logo and Typography
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Icon with Multi-layer Effects
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
                          // 1. Slow Rotating White Spiritual Halo Ring
                          Transform.rotate(
                            angle: _rotationController.value * 2 * pi,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          // 2. Secondary Decorative Ring
                          Transform.rotate(
                            angle: -_rotationController.value * 2 * pi,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),

                          // 3. The Royal Blue Diamond Logo Container with White Border & Glow
                          Container(
                            width: 168,
                            height: 168,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(36),
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
                                width: 2.5,
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
                              borderRadius: BorderRadius.circular(30),
                              child: Stack(
                                children: [
                                  // The Real Logo Image
                                  Image.asset(
                                    'assets/icon/app_icon.png',
                                    fit: BoxFit.cover,
                                    width: 168,
                                    height: 168,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.mosque, color: Colors.white, size: 75),
                                    ),
                                  ),

                                  // Shimmer Sheen Light Sweep across the logo
                                  Positioned.fill(
                                    child: Transform.translate(
                                      offset: Offset((sheenProgress * 340) - 170, 0),
                                      child: Transform.rotate(
                                        angle: pi / 4,
                                        child: Container(
                                          width: 35,
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

                const SizedBox(height: 34),

                // Animated App Name and Subtitle
                AnimatedBuilder(
                  animation: _entranceController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Column(
                          children: [
                            // Modern Sans / Cairo Minimalist Title (خالٍ من التشكيل والزخارف)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "محراب",
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),

                            // English Brand Name Underneath in modern sans
                            Text(
                              "M I H R A B",
                              style: GoogleFonts.cairo(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 5,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Subtitle with White Border Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F254E).withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "مواقيت الصلاة والقرآن",
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 13,
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

                const SizedBox(height: 48),

                // Elegant Loading Spinner
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
