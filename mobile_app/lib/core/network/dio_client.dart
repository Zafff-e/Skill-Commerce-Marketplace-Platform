import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../constants/api_endpoints.dart';
import 'api_exception.dart';

class DioClient {
  late final Dio dio;
  final FlutterSecureStorage secureStorage;
  static const _uuid = Uuid();

  static const String keyAccessToken = 'sc_access_token';
  static const String keyRefreshToken = 'sc_refresh_token';

  DioClient({
    String? baseUrl,
    FlutterSecureStorage? storage,
  }) : secureStorage = storage ?? const FlutterSecureStorage() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiEndpoints.defaultBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json, application/problem+json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. Bearer Token Injection
          final token = await secureStorage.read(key: keyAccessToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // 2. Idempotency-Key Injection on Critical State Modifications (Bookings, Payments)
          final isBookingPost = options.method.toUpperCase() == 'POST' &&
              options.path.contains('/bookings');
          final isPaymentPost = options.method.toUpperCase() == 'POST' &&
              options.path.contains('/payments');

          if ((isBookingPost || isPaymentPost) && !options.headers.containsKey('Idempotency-Key')) {
            options.headers['Idempotency-Key'] = _uuid.v4();
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // 3. Automatic Token Rotation on 401 Unauthorized
          if (error.response?.statusCode == 401) {
            final refreshToken = await secureStorage.read(key: keyRefreshToken);
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                final refreshResponse = await dio.post(
                  ApiEndpoints.refresh,
                  data: {'refreshToken': refreshToken},
                  options: Options(headers: {'Authorization': null}),
                );

                if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
                  final newAccessToken = refreshResponse.data['accessToken'];
                  final newRefreshToken = refreshResponse.data['refreshToken'];

                  await secureStorage.write(key: keyAccessToken, value: newAccessToken);
                  if (newRefreshToken != null) {
                    await secureStorage.write(key: keyRefreshToken, value: newRefreshToken);
                  }

                  // Retry the original failed request with the new access token
                  final retryOptions = error.requestOptions;
                  retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                  final retryResponse = await dio.fetch(retryOptions);
                  return handler.resolve(retryResponse);
                }
              } catch (_) {
                // Token refresh failed, clear tokens
                await secureStorage.deleteAll();
              }
            }
          }

          // 4. RFC 9457 Problem Details Translation
          if (error.response?.data is Map<String, dynamic>) {
            final json = error.response!.data as Map<String, dynamic>;
            final apiEx = ApiException.fromProblemDetails(
              error.response?.statusCode ?? 500,
              json,
            );
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                error: apiEx,
                type: error.type,
              ),
            );
          }

          return handler.next(error);
        },
      ),
    );
  }

  // Token management helpers
  Future<void> saveAuthSession({
    required String accessToken,
    required String refreshToken,
  }) async {
    await secureStorage.write(key: keyAccessToken, value: accessToken);
    await secureStorage.write(key: keyRefreshToken, value: refreshToken);
  }

  Future<void> clearAuthSession() async {
    await secureStorage.delete(key: keyAccessToken);
    await secureStorage.delete(key: keyRefreshToken);
  }

  Future<String?> getAccessToken() => secureStorage.read(key: keyAccessToken);
}

