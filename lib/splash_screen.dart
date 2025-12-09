import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/storage/local_storage.dart';
import '../core/di/injection.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/navigation/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _version = '';
  String _loadingText = 'Memuat...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Get version info
      setState(() => _loadingText = 'Memeriksa versi...');
      await _loadVersionInfo();
      await _updateProgress(0.3);

      // Step 2: Check for updates (simulated)
      setState(() => _loadingText = 'Memeriksa pembaruan...');
      await Future.delayed(const Duration(milliseconds: 500));
      await _updateProgress(0.6);

      // Step 3: Initialize data
      setState(() => _loadingText = 'Menyiapkan aplikasi...');
      await Future.delayed(const Duration(milliseconds: 500));
      await _updateProgress(1.0);

      // Step 4: Navigate
      setState(() => _loadingText = 'Selesai!');
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        _navigateToNext();
      }
    } catch (e) {
      setState(() => _loadingText = 'Terjadi kesalahan');
    }
  }

  Future<void> _loadVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = 'v${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() => _version = 'v1.0.0');
    }
  }

  Future<void> _updateProgress(double value) async {
    for (double i = _progress; i <= value; i += 0.05) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) {
        setState(() => _progress = i);
      }
    }
    setState(() => _progress = value);
  }

  Future<void> _navigateToNext() async {
    final localStorage = getIt<LocalStorage>();
    final isFirstLaunch = await localStorage.isFirstLaunch();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              isFirstLaunch ? const OnboardingScreen() : const MainNavigation(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo with animation
                Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: 1000.ms,
                    )
                    .then()
                    .animate()
                    .fadeIn(duration: 500.ms),

                const SizedBox(height: 32),

                // App name
                Text(
                  'ResepKu',
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Resep Masakan Indonesia',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

                const Spacer(flex: 2),

                // Loading section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      // Progress bar
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                      const SizedBox(height: 16),

                      // Loading text
                      Text(
                        _loadingText,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                    ],
                  ),
                ),

                const Spacer(),

                // Version info
                Text(
                  _version,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 400.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
