import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../network/connectivity_helper.dart';
import '../storage/local_storage.dart';
import '../database/database_helper.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../data/repositories/saved_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/recipe/recipe_bloc.dart';
import '../../presentation/blocs/recipe_detail/recipe_detail_bloc.dart';
import '../../presentation/blocs/saved/saved_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Local Storage
  getIt.registerSingleton<LocalStorage>(
    LocalStorage(getIt<SharedPreferences>()),
  );

  // Database Helper (SQLite)
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper());

  // Connectivity Helper
  getIt.registerSingleton<ConnectivityHelper>(ConnectivityHelper());

  // Dio Client
  getIt.registerSingleton<DioClient>(DioClient(getIt<LocalStorage>()));

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepository(getIt<DioClient>(), getIt<LocalStorage>()),
  );

  getIt.registerSingleton<RecipeRepository>(
    RecipeRepository(
      getIt<DioClient>(),
      getIt<DatabaseHelper>(),
      getIt<ConnectivityHelper>(),
    ),
  );

  getIt.registerSingleton<SavedRepository>(
    SavedRepository(
      getIt<DioClient>(),
      getIt<DatabaseHelper>(),
      getIt<ConnectivityHelper>(),
    ),
  );

  getIt.registerSingleton<ReviewRepository>(
    ReviewRepository(getIt<DioClient>()),
  );

  // BLoCs - Using factories so new instances are created when needed
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));

  getIt.registerFactory<RecipeBloc>(
    () => RecipeBloc(getIt<RecipeRepository>()),
  );

  getIt.registerFactory<RecipeDetailBloc>(
    () => RecipeDetailBloc(
      getIt<RecipeRepository>(),
      getIt<ReviewRepository>(),
      getIt<SavedRepository>(),
    ),
  );

  getIt.registerFactory<SavedBloc>(() => SavedBloc(getIt<SavedRepository>()));
}
