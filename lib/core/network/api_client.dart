import 'package:dio/dio.dart';
import 'package:nawasena/core/constants/app_constants.dart';
import 'package:nawasena/core/models/api_response.dart';
import 'package:nawasena/core/storage/secure_storage.dart';

/// HTTP client terpusat menggunakan Dio.
///
/// Fitur:
/// - Auto-inject Bearer token ke setiap request
/// - Parsing error menjadi ApiException yang konsisten
/// - Logging di debug mode
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  late final Dio _dio = _createDio();

  Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // ── Interceptor: Token Injector ────────────────────────────────────────
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.instance.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));

    // ── Interceptor: Logger (hanya di debug) ──────────────────────────────
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('[HTTP] $obj'),
    ));

    return dio;
  }

  // ── Generic Request Methods ────────────────────────────────────────────────

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _parse<T>(response.data, parser);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return _parse<T>(response.data, parser);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.patch(path, data: data);
      return _parse<T>(response.data, parser);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<T> delete<T>(
    String path, {
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.delete(path);
      return _parse<T>(response.data, parser);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  T _parse<T>(dynamic responseData, T Function(dynamic)? parser) {
    if (parser != null) return parser(responseData);
    return responseData as T;
  }

  ApiException _handleDioError(DioException e) {
    final response = e.response;

    if (response == null) {
      return const ApiException(
        message: 'Tidak dapat terhubung ke server. Periksa koneksi internetmu.',
        statusCode: 0,
      );
    }

    final data = response.data;
    final statusCode = response.statusCode ?? 0;

    if (data is Map<String, dynamic>) {
      return ApiException(
        message: data['message'] as String? ?? 'Terjadi kesalahan.',
        statusCode: statusCode,
        errors: data['errors'] as Map<String, dynamic>?,
      );
    }

    return ApiException(
      message: _defaultMessage(statusCode),
      statusCode: statusCode,
    );
  }

  String _defaultMessage(int code) => switch (code) {
    401 => 'Sesi kamu sudah berakhir. Silakan login kembali.',
    403 => 'Kamu tidak memiliki akses ke halaman ini.',
    404 => 'Data yang kamu cari tidak ditemukan.',
    422 => 'Data yang kamu masukkan tidak valid.',
    500 => 'Server sedang bermasalah. Coba lagi nanti.',
    _   => 'Terjadi kesalahan. Coba lagi.',
  };
}

// Agar bisa dipakai tanpa import Flutter di file non-widget
void debugPrint(String msg) {
  // ignore: avoid_print
  print(msg);
}
