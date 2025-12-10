import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'resepku.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Recipes table
    await db.execute('''
      CREATE TABLE recipes (
        recipe_id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        prep_time_min INTEGER,
        image_url TEXT,
        average_rating REAL,
        created_at TEXT,
        cached_at TEXT NOT NULL
      )
    ''');

    // Recipe ingredients table
    await db.execute('''
      CREATE TABLE recipe_ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        quantity TEXT,
        unit TEXT,
        FOREIGN KEY (recipe_id) REFERENCES recipes (recipe_id) ON DELETE CASCADE
      )
    ''');

    // Recipe steps table
    await db.execute('''
      CREATE TABLE recipe_steps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER NOT NULL,
        step_number INTEGER NOT NULL,
        instruction TEXT NOT NULL,
        FOREIGN KEY (recipe_id) REFERENCES recipes (recipe_id) ON DELETE CASCADE
      )
    ''');

    // Saved recipes table
    await db.execute('''
      CREATE TABLE saved_recipes (
        id INTEGER PRIMARY KEY,
        recipe_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        prep_time_min INTEGER,
        image_url TEXT,
        average_rating REAL,
        created_at TEXT,
        saved_at TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');
  }

  // Recipe operations
  Future<void> cacheRecipes(List<Map<String, dynamic>> recipes) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    for (final recipe in recipes) {
      batch.insert('recipes', {
        ...recipe,
        'cached_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedRecipes({
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      'recipes',
      limit: limit,
      offset: offset,
      orderBy: 'cached_at DESC',
    );
  }

  Future<void> cacheRecipeDetail(
    Map<String, dynamic> recipe,
    List<Map<String, dynamic>> ingredients,
    List<Map<String, dynamic>> steps,
  ) async {
    final db = await database;
    final recipeId = recipe['recipe_id'];
    final now = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      // Insert/update recipe
      await txn.insert('recipes', {
        ...recipe,
        'cached_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // Delete old ingredients and steps
      await txn.delete(
        'recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [recipeId],
      );
      await txn.delete(
        'recipe_steps',
        where: 'recipe_id = ?',
        whereArgs: [recipeId],
      );

      // Insert ingredients
      for (final ingredient in ingredients) {
        await txn.insert('recipe_ingredients', {
          'recipe_id': recipeId,
          'name': ingredient['name'],
          'quantity': ingredient['quantity'],
          'unit': ingredient['unit'],
        });
      }

      // Insert steps
      for (final step in steps) {
        await txn.insert('recipe_steps', {
          'recipe_id': recipeId,
          'step_number': step['step_number'],
          'instruction': step['instruction'],
        });
      }
    });
  }

  Future<Map<String, dynamic>?> getCachedRecipeById(int recipeId) async {
    final db = await database;

    final recipes = await db.query(
      'recipes',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );

    if (recipes.isEmpty) return null;

    final recipe = Map<String, dynamic>.from(recipes.first);

    // Get ingredients
    final ingredients = await db.query(
      'recipe_ingredients',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );

    // Get steps
    final steps = await db.query(
      'recipe_steps',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
      orderBy: 'step_number ASC',
    );

    recipe['ingredients'] = ingredients;
    recipe['steps'] = steps;

    return recipe;
  }

  // Saved recipes operations
  Future<void> cacheSavedRecipes(
    List<Map<String, dynamic>> savedRecipes,
  ) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    // Clear old saved recipes
    await db.delete('saved_recipes');

    final batch = db.batch();
    for (final saved in savedRecipes) {
      batch.insert('saved_recipes', {...saved, 'cached_at': now});
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getCachedSavedRecipes() async {
    final db = await database;
    return await db.query('saved_recipes', orderBy: 'saved_at DESC');
  }

  // Clear cache
  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('recipes');
    await db.delete('recipe_ingredients');
    await db.delete('recipe_steps');
    await db.delete('saved_recipes');
  }
}
