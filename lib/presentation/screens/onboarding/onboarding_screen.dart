import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/di/injection.dart';
import '../../navigation/main_navigation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.restaurant_menu,
      title: 'Temukan Resep Lezat',
      description:
          'Jelajahi ribuan resep masakan Indonesia yang mudah dibuat di rumah.',
      color: AppColors.primary,
    ),
    OnboardingPage(
      icon: Icons.bookmark_added,
      title: 'Simpan Favorit',
      description:
          'Simpan resep favorit Anda dan akses kapan saja dengan mudah.',
      color: AppColors.secondary,
    ),
    OnboardingPage(
      icon: Icons.share,
      title: 'Bagikan Resep',
      description:
          'Bagikan resep Anda sendiri dan dapatkan ulasan dari komunitas.',
      color: AppColors.primaryDark,
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    final localStorage = getIt<LocalStorage>();
    await localStorage.setFirstLaunchComplete();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Lewati',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], index);
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  activeDotColor: AppColors.primary,
                  dotColor: AppColors.primary.withOpacity(0.3),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),

            // Next/Get Started button
            Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Mulai Sekarang'
                            : 'Selanjutnya',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                )
                .animate(target: _currentPage.toDouble())
                .fadeIn()
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [page.color, page.color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: page.color.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Icon(page.icon, size: 80, color: Colors.white),
              )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.8, 0.8))
              .then()
              .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.3)),

          const SizedBox(height: 48),

          // Title
          Text(
                page.title,
                style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 16),

          // Description
          Text(
                page.description,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
