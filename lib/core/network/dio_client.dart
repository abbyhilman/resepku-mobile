import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';

class DioClient {
  late final Dio _dio;
  final LocalStorage _localStorage;

  DioClient(this._localStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([_authInterceptor(), _retryInterceptor()]);
  }

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _localStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print(
          '🌐 API Request: ${options.method} ${options.baseUrl}${options.path}',
        );
        print('📦 Headers: ${options.headers}');
        if (options.data != null) {
          print('📤 Request Data: ${options.data}');
        }
        if (options.queryParameters.isNotEmpty) {
          print('🔍 Query Params: ${options.queryParameters}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        print(
          '✅ Response [${response.statusCode}]: ${response.requestOptions.path}',
        );
        print('📥 Response Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) async {
        print(
          '❌ Error [${error.response?.statusCode}]: ${error.requestOptions.path}',
        );
        print('🔴 Error Message: ${error.message}');
        print('🔴 Error Response: ${error.response?.data}');
        print('🔴 Error Headers: ${error.response?.headers}');

        if (error.response?.statusCode == 401) {
          // Token expired, clear storage
          await _localStorage.clearAuth();
        }
        handler.next(error);
      },
    );
  }

  Interceptor _retryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        final retryCount = error.requestOptions.extra['retryCount'] ?? 0;

        // Retry up to 3 times for 500 errors (Vercel cold start/function issues)
        if (error.response?.statusCode == 500 && retryCount < 3) {
          print('🔄 Retrying request (attempt ${retryCount + 1}/3)...');
          error.requestOptions.extra['retryCount'] = retryCount + 1;

          // Exponential backoff: 1s, 2s, 4s
          await Future.delayed(Duration(seconds: 1 << retryCount));

          try {
            final response = await _dio.fetch(error.requestOptions);
            print('✅ Retry successful!');
            return handler.resolve(response);
          } catch (e) {
            print('❌ Retry ${retryCount + 1} failed');
            // If retry also fails, continue to next error handler
            if (e is DioException) {
              return handler.next(e);
            }
          }
        }
        handler.next(error);
      },
    );
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
