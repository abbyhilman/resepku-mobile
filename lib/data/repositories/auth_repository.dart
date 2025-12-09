import '../models/user_model.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/storage/local_storage.dart';

class AuthRepository {
  final DioClient _dioClient;
  final LocalStorage _localStorage;

  AuthRepository(this._dioClient, this._localStorage);

  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.register,
      data: {'email': email, 'password': password, 'full_name': fullName},
    );

    if (response.data['success'] == true) {
      return UserModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Registrasi gagal');
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final token = response.data['data']['token'] as String;
      final user = UserModel.fromJson(response.data['data']['user']);

      // Save token and user to local storage
      await _localStorage.saveToken(token);
      await _localStorage.saveUser(user);

      return user;
    } else {
      throw Exception(response.data['message'] ?? 'Login gagal');
    }
  }

  Future<void> logout() async {
    await _localStorage.clearAuth();
  }

  Future<bool> isLoggedIn() async {
    return await _localStorage.isLoggedIn();
  }

  Future<UserModel?> getCurrentUser() async {
    return await _localStorage.getUser();
  }

  Future<String?> getToken() async {
    return await _localStorage.getToken();
  }
}
