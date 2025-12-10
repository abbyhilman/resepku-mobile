import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/recipe/recipe_bloc.dart';
import '../../blocs/recipe/recipe_state.dart';
import '../../blocs/recipe/recipe_event.dart';
import '../../widgets/recipe_card.dart';
import '../../widgets/shimmer_widgets.dart';

class AllRecipesScreen extends StatefulWidget {
  const AllRecipesScreen({super.key});

  @override
  State<AllRecipesScreen> createState() => _AllRecipesScreenState();
}

class _AllRecipesScreenState extends State<AllRecipesScreen> {
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 5;
  bool _hasLoadedInitialData = false;

  @override
  void initState() {
    super.initState();
    // Setup scroll listener for infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load initial recipes only once
    if (!_hasLoadedInitialData) {
      context.read<RecipeBloc>().add(const RecipeLoadAll(limit: _pageSize));
      _hasLoadedInitialData = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<RecipeBloc>().add(RecipeLoadMore());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onRefresh() async {
    context.read<RecipeBloc>().add(const RecipeLoadAll(limit: _pageSize));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Semua Resep',
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<RecipeBloc, RecipeState>(
        builder: (context, state) {
          if (state is RecipeLoading) {
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 5,
              itemBuilder: (context, index) => const ShimmerRecipeCard(),
            );
          }

          if (state is RecipeError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<RecipeBloc>().add(
                          const RecipeLoadAll(limit: _pageSize),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is RecipeLoaded) {
            if (state.recipes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
              );
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: state.recipes.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show loading indicator at the bottom
                  if (index >= state.recipes.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: state.isLoadingMore
                            ? const CircularProgressIndicator(
                                color: AppColors.primary,
                              )
                            : ElevatedButton.icon(
                                onPressed: () {
                                  context.read<RecipeBloc>().add(
                                    RecipeLoadMore(),
                                  );
                                },
                                icon: const Icon(Icons.expand_more),
                                label: const Text('Muat Lebih Banyak'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                      ),
                    );
                  }

                  final recipe = state.recipes[index];
                  return RecipeCard(recipe: recipe)
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 50 * (index % 5)),
                        duration: 400.ms,
                      )
                      .slideX(begin: 0.2, end: 0);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
