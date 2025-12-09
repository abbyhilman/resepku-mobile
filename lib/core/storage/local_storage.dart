import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../data/models/user_model.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  // Token methods
  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    return _prefs.getString(AppConstants.tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(AppConstants.tokenKey);
  }

  // User methods
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final userJson = _prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> removeUser() async {
    await _prefs.remove(AppConstants.userKey);
  }

  // First launch methods
  Future<bool> isFirstLaunch() async {
    return _prefs.getBool(AppConstants.isFirstLaunchKey) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    await _prefs.setBool(AppConstants.isFirstLaunchKey, false);
  }

  // Clear all auth data
  Future<void> clearAuth() async {
    await removeToken();
    await removeUser();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
