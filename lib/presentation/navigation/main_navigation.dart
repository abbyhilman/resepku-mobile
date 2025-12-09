import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/di/injection.dart';
import '../blocs/recipe/recipe_bloc.dart';
import '../blocs/recipe/recipe_event.dart';
import '../blocs/saved/saved_bloc.dart';
import '../blocs/saved/saved_event.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/saved/saved_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final NotchBottomBarController _controller = NotchBottomBarController(
    index: 0,
  );

  late final RecipeBloc _recipeBloc;
  late final SavedBloc _savedBloc;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _recipeBloc = getIt<RecipeBloc>();
    _savedBloc = getIt<SavedBloc>();
    _pageController = PageController(initialPage: 0);

    // Load initial recipes
    _recipeBloc.add(const RecipeLoadAll());
  }

  @override
  void dispose() {
    _recipeBloc.close();
    _savedBloc.close();
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> get _screens => [
    BlocProvider.value(value: _recipeBloc, child: const HomeScreen()),
    BlocProvider.value(value: _recipeBloc, child: const SearchScreen()),
    BlocProvider.value(value: _savedBloc, child: const SavedScreen()),
    const ProfileScreen(),
  ];

  void _onTabChanged(int index) {
    _pageController.jumpToPage(index);

    // Load saved recipes when switching to saved tab
    if (index == 2) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        _savedBloc.add(SavedLoad());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Container(
        color: AppColors.surface,
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: AnimatedNotchBottomBar(
          notchBottomBarController: _controller,
          color: AppColors.surface,
          showLabel: true,
          textOverflow: TextOverflow.visible,
          maxLine: 1,
          shadowElevation: 8,
          kBottomRadius: 20.0,
          notchColor: AppColors.primary,
          removeMargins: false,
          bottomBarWidth: MediaQuery.of(context).size.width,
          showShadow: true,
          durationInMilliSeconds: 300,
          elevation: 2,
          bottomBarItems: [
            BottomBarItem(
              inActiveItem: Icon(
                Icons.home_outlined,
                color: AppColors.textTertiary,
              ),
              activeItem: Icon(Icons.home_rounded, color: Colors.white),
              itemLabel: 'Beranda',
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.search_outlined,
                color: AppColors.textTertiary,
              ),
              activeItem: Icon(Icons.search_rounded, color: Colors.white),
              itemLabel: 'Cari',
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.bookmark_outline,
                color: AppColors.textTertiary,
              ),
              activeItem: Icon(Icons.bookmark_rounded, color: Colors.white),
              itemLabel: 'Simpan',
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.person_outline,
                color: AppColors.textTertiary,
              ),
              activeItem: Icon(Icons.person_rounded, color: Colors.white),
              itemLabel: 'Profil',
            ),
          ],
          onTap: _onTabChanged,
          kIconSize: 24.0,
        ),
      ),
    );
  }
}
