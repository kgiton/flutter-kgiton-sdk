/// Base API response model
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final dynamic details;

  ApiResponse({required this.success, required this.message, this.data, this.details});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: (json['success'] as bool?) ?? true,
      message: (json['message'] as String?) ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : (json['data'] as T?),
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson(dynamic Function(T)? toJsonT) {
    return {
      'success': success,
      'message': message,
      if (data != null) 'data': toJsonT != null ? toJsonT(data as T) : data,
      if (details != null) 'details': details,
    };
  }
}

/// Pagination model
class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({required this.total, required this.page, required this.limit, required this.totalPages});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'page': page, 'limit': limit, 'totalPages': totalPages};
  }
}
