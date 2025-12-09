import 'package:dio/dio.dart';

/// Global API error handler to translate error messages to Indonesian
class ApiErrorHandler {
  /// Mapping of English error messages to formal Indonesian translations
  static const Map<String, String> _errorMessages = {
    // Authentication errors (401)
    'Invalid email or password': 'Email atau kata sandi tidak valid',
    'Access denied. No token provided.': 'Akses ditolak. Token tidak tersedia.',
    'Access denied. No token provided': 'Akses ditolak. Token tidak tersedia.',
    'Token has expired. Please login again.':
        'Token telah kedaluwarsa. Silakan masuk kembali.',
    'Token has expired. Please login again':
        'Token telah kedaluwarsa. Silakan masuk kembali.',
    'Invalid token.': 'Token tidak valid.',
    'Invalid token': 'Token tidak valid',

    // Rate limiting errors (429)
    'Too many authentication attempts from this IP, please try again after 15 minutes':
        'Terlalu banyak percobaan autentikasi dari IP ini, silakan coba lagi setelah 15 menit',

    // Common API errors
    'Email already registered': 'Email sudah terdaftar',
    'Email, password, and full name are required':
        'Email, kata sandi, dan nama lengkap wajib diisi',
    'Recipe not found': 'Resep tidak ditemukan',
    'User not found': 'Pengguna tidak ditemukan',
    'Recipe already saved': 'Resep sudah tersimpan',
    'Saved recipe not found': 'Resep tersimpan tidak ditemukan',
    'Rating must be between 1 and 5': 'Rating harus antara 1 dan 5',
    'Search query (q) is required': 'Kata kunci pencarian (q) wajib diisi',
  };

  /// Translate error message to formal Indonesian
  /// Returns original message if no translation found
  static String translate(String? message) {
    if (message == null || message.isEmpty) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }

    // Check for exact match first
    if (_errorMessages.containsKey(message)) {
      return _errorMessages[message]!;
    }

    // Check for partial match (case-insensitive)
    final lowerMessage = message.toLowerCase();
    for (final entry in _errorMessages.entries) {
      if (lowerMessage.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    // Return original message if no translation found
    return message;
  }

  /// Handle DioException and return appropriate Indonesian error message
  static String handleDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // Try to get message from response body
    String? apiMessage;
    if (responseData is Map<String, dynamic>) {
      apiMessage = responseData['message'] as String?;
    }

    // Handle by status code
    switch (statusCode) {
      case 400:
        return translate(apiMessage ?? 'Permintaan tidak valid');
      case 401:
        return translate(apiMessage ?? 'Akses tidak diizinkan');
      case 403:
        return translate(apiMessage ?? 'Akses ditolak');
      case 404:
        return translate(apiMessage ?? 'Data tidak ditemukan');
      case 409:
        return translate(apiMessage ?? 'Data sudah ada');
      case 429:
        return translate(
          apiMessage ??
              'Terlalu banyak percobaan. Silakan coba lagi dalam beberapa saat.',
        );
      case 500:
        return 'Server sedang mengalami masalah. Silakan coba lagi dalam beberapa saat.';
      default:
        // Handle connection errors
        if (error.type == DioExceptionType.connectionTimeout) {
          return 'Koneksi timeout. Periksa koneksi internet Anda.';
        }
        if (error.type == DioExceptionType.receiveTimeout) {
          return 'Koneksi timeout. Periksa koneksi internet Anda.';
        }
        if (error.type == DioExceptionType.connectionError) {
          return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        }
        return translate(apiMessage ?? 'Terjadi kesalahan. Silakan coba lagi.');
    }
  }
}
