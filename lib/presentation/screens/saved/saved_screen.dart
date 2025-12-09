import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/saved/saved_bloc.dart';
import '../../blocs/saved/saved_state.dart';
import '../../blocs/saved/saved_event.dart';
import '../../widgets/recipe_card.dart';
import '../auth/login_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthAuthenticated) {
              return _buildLoginPrompt(context);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Resep Tersimpan', style: AppTextStyles.h1),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.2, end: 0),

                // Content
                Expanded(
                  child: BlocBuilder<SavedBloc, SavedState>(
                    builder: (context, state) {
                      if (state is SavedLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      if (state is SavedError) {
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
                                  onPressed: () {
                                    context.read<SavedBloc>().add(SavedLoad());
                                  },
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is SavedLoaded) {
                        if (state.savedRecipes.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                        Icons.bookmark_border_rounded,
                                        size: 64,
                                        color: AppColors.textTertiary,
                                      )
                                      .animate()
                                      .fadeIn(duration: 400.ms)
                                      .scale(begin: const Offset(0.8, 0.8)),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada resep tersimpan',
                                    style: AppTextStyles.h4.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Simpan resep favorit Anda dari halaman resep',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: state.savedRecipes.length,
                          itemBuilder: (context, index) {
                            final saved = state.savedRecipes[index];
                            return Dismissible(
                              key: Key('saved_${saved.recipe.recipeId}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.delete_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) {
                                context.read<SavedBloc>().add(
                                  SavedRemove(saved.recipe.recipeId),
                                );
                              },
                              child: RecipeCard(recipe: saved.recipe)
                                  .animate()
                                  .fadeIn(
                                    delay: Duration(milliseconds: 100 * index),
                                    duration: 400.ms,
                                  )
                                  .slideX(begin: 0.2, end: 0),
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bookmark_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 32),
            Text(
              'Masuk untuk Menyimpan Resep',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 12),
            Text(
              'Simpan resep favorit Anda dan akses kapan saja',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            const SizedBox(height: 32),
            SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('Masuk'),
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
