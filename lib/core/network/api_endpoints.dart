class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // Recipes (read-only for users)
  static const String recipes = '/recipes';
  static String recipeById(int id) => '/recipes/$id';
  static String recipeReviews(int id) => '/recipes/$id/reviews';

  // Search
  static const String search = '/search';

  // Saved Recipes
  static const String savedRecipes = '/users/saved';
  static String removeSavedRecipe(int recipeId) => '/users/saved/$recipeId';
}
