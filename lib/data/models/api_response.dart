class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  const ApiResponse({required this.success, this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
  }
}

class PaginatedResponse<T> {
  final bool success;
  final List<T> data;
  final PaginationInfo pagination;

  const PaginatedResponse({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      success: json['success'] as bool,
      data: (json['data'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationInfo.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}

class PaginationInfo {
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  const PaginationInfo({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      hasMore: json['hasMore'] as bool,
    );
  }
}
