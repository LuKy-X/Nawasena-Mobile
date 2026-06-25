/// Model generik untuk semua response API Nawasena.
/// Format standar: { "success": bool, "message": str, "data": T? }
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(dynamic)? fromData,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: fromData != null ? fromData(json['data']) : null,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  /// Ambil pesan error pertama dari field 'errors' (untuk validasi 422)
  String? get firstError {
    if (errors == null || errors!.isEmpty) return null;
    final firstList = errors!.values.first;
    if (firstList is List && firstList.isNotEmpty) {
      return firstList.first.toString();
    }
    return null;
  }

  bool get hasError => !success;
}

/// Exception custom untuk error API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  String? get firstError {
    if (errors == null || errors!.isEmpty) return null;
    final firstList = errors!.values.first;
    if (firstList is List && firstList.isNotEmpty) {
      return firstList.first.toString();
    }
    return message;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
