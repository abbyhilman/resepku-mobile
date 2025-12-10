import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/recipe/recipe_bloc.dart';
import '../../blocs/recipe/recipe_state.dart';
import '../../blocs/recipe/recipe_event.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/resepku_refresh_indicator.dart';
import '../../widgets/shimmer_widgets.dart';
import '../recipes/all_recipes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _homePageLimit = 5;

  @override
  void initState() {
    super.initState();
    // Load only 5 recipes for home screen
    context.read<RecipeBloc>().add(const RecipeLoadAll(limit: _homePageLimit));
  }

  Future<void> _onRefresh() async {
    context.read<RecipeBloc>().add(const RecipeLoadAll(limit: _homePageLimit));
    // Wait for state to change
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResepkuRefreshIndicatorStateful(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                    'Selamat Datang! 👋',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 400.ms)
                                  .slideX(begin: -0.2, end: 0),
                              const SizedBox(height: 4),
                              Text(
                                    'ResepKu',
                                    style: AppTextStyles.h1.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 100.ms, duration: 400.ms)
                                  .slideX(begin: -0.2, end: 0),
                            ],
                          ),
                          Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.restaurant_menu,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 400.ms)
                              .scale(begin: const Offset(0.8, 0.8)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Welcome banner
                      Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mau masak apa hari ini?',
                                  style: AppTextStyles.h3.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Temukan resep lezat dan mudah dibuat',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 500.ms)
                          .slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),
              ),

              // Popular Recipes Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Resep Populer', style: AppTextStyles.h3),
                      TextButton(
                        onPressed: () {
                          final recipeBloc = context.read<RecipeBloc>();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: recipeBloc,
                                child: const AllRecipesScreen(),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Lihat Semua',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                ),
              ),

              // Recipe List
              BlocBuilder<RecipeBloc, RecipeState>(
                builder: (context, state) {
                  if (state is RecipeLoading) {
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const ShimmerRecipeCard(),
                          childCount: 5,
                        ),
                      ),
                    );
                  }

                  if (state is RecipeError) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: AppColors.error,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.message,
                                style: AppTextStyles.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<RecipeBloc>().add(
                                    const RecipeLoadAll(),
                                  );
                                },
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  if (state is RecipeLoaded) {
                    if (state.recipes.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  size: 64,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada resep',
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // Limit to 5 recipes on home screen
                    final displayRecipes = state.recipes
                        .take(_homePageLimit)
                        .toList();

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final recipe = displayRecipes[index];
                          return RecipeCard(recipe: recipe)
                              .animate()
                              .fadeIn(
                                delay: Duration(milliseconds: 100 * index),
                                duration: 400.ms,
                              )
                              .slideX(begin: 0.2, end: 0);
                        }, childCount: displayRecipes.length),
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}
