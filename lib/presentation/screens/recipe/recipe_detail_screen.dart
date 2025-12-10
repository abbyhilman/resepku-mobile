import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../blocs/recipe_detail/recipe_detail_bloc.dart';
import '../../blocs/recipe_detail/recipe_detail_event.dart';
import '../../blocs/recipe_detail/recipe_detail_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/shimmer_widgets.dart';
import '../auth/login_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late RecipeDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<RecipeDetailBloc>();
    _bloc.add(RecipeDetailLoad(widget.recipeId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<RecipeDetailBloc, RecipeDetailState>(
          builder: (context, state) {
            if (state is RecipeDetailLoading) {
              return const ShimmerRecipeDetail();
            }

            if (state is RecipeDetailError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                        onPressed: () =>
                            _bloc.add(RecipeDetailLoad(widget.recipeId)),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is RecipeDetailLoaded) {
              final recipe = state.recipe;
              return CustomScrollView(
                slivers: [
                  // App Bar with Image
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    backgroundColor: AppColors.surface,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: AppColors.textPrimary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            return IconButton(
                              icon: Icon(
                                state.isSaved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                color: state.isSaved
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                              onPressed: () {
                                if (authState is AuthAuthenticated) {
                                  _bloc.add(
                                    RecipeDetailToggleSave(
                                      recipeId: recipe.recipeId,
                                      isSaved: state.isSaved,
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background:
                          recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: recipe.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.surfaceVariant,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.surfaceVariant,
                                child: const Icon(
                                  Icons.restaurant,
                                  size: 64,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.surfaceVariant,
                              child: const Icon(
                                Icons.restaurant,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                            ),
                    ),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and rating
                          Text(recipe.title, style: AppTextStyles.h2)
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideX(begin: -0.2, end: 0),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildInfoChip(
                                Icons.timer_outlined,
                                '${recipe.prepTimeMin} menit',
                                AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              _buildInfoChip(
                                Icons.star_rounded,
                                recipe.averageRating.toStringAsFixed(1),
                                AppColors.starYellow,
                              ),
                            ],
                          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                          const SizedBox(height: 20),

                          // Description
                          Text(
                            recipe.description,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                          const SizedBox(height: 24),

                          // Ingredients
                          if (recipe.ingredients != null &&
                              recipe.ingredients!.isNotEmpty) ...[
                            _buildSectionTitle(
                              'Bahan-bahan',
                              Icons.shopping_basket_outlined,
                            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                            const SizedBox(height: 12),
                            ...recipe.ingredients!.asMap().entries.map((entry) {
                              final index = entry.key;
                              final ingredient = entry.value;
                              return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            ingredient.name,
                                            style: AppTextStyles.bodyMedium,
                                          ),
                                        ),
                                        Text(
                                          '${ingredient.quantity} ${ingredient.unit}',
                                          style: AppTextStyles.labelMedium
                                              .copyWith(
                                                color: AppColors.primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(
                                    delay: Duration(
                                      milliseconds: 250 + (index * 50),
                                    ),
                                    duration: 400.ms,
                                  )
                                  .slideX(begin: 0.2, end: 0);
                            }),
                            const SizedBox(height: 24),
                          ],

                          // Steps
                          if (recipe.steps != null &&
                              recipe.steps!.isNotEmpty) ...[
                            _buildSectionTitle(
                              'Langkah-langkah',
                              Icons.format_list_numbered_rounded,
                            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                            const SizedBox(height: 12),
                            ...recipe.steps!.asMap().entries.map((entry) {
                              final index = entry.key;
                              final step = entry.value;
                              return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            gradient: AppColors.primaryGradient,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${step.stepNumber ?? (index + 1)}',
                                              style: AppTextStyles.labelLarge
                                                  .copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            step.instruction,
                                            style: AppTextStyles.bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(
                                    delay: Duration(
                                      milliseconds: 350 + (index * 50),
                                    ),
                                    duration: 400.ms,
                                  )
                                  .slideX(begin: 0.2, end: 0);
                            }),
                            const SizedBox(height: 24),
                          ],

                          // Reviews
                          if (state.reviews.isNotEmpty) ...[
                            _buildSectionTitle(
                              'Ulasan (${state.reviews.length})',
                              Icons.rate_review_outlined,
                            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                            const SizedBox(height: 12),
                            ...state.reviews.take(3).map((review) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              review.fullName.isNotEmpty
                                                  ? review.fullName[0]
                                                        .toUpperCase()
                                                  : 'U',
                                              style: AppTextStyles.labelLarge
                                                  .copyWith(
                                                    color: AppColors.primary,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                review.fullName,
                                                style: AppTextStyles.labelLarge,
                                              ),
                                              Row(
                                                children: List.generate(5, (
                                                  index,
                                                ) {
                                                  return Icon(
                                                    index < review.rating
                                                        ? Icons.star_rounded
                                                        : Icons
                                                              .star_border_rounded,
                                                    size: 16,
                                                    color: AppColors.starYellow,
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (review.comment != null &&
                                        review.comment!.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        review.comment!,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),
                          ],

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppTextStyles.h4),
      ],
    );
  }
}
