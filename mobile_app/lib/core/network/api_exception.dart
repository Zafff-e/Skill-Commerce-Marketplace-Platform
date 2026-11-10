class ApiException implements Exception {
  final int statusCode;
  final String errorCode;
  final String title;
  final String detail;
  final Map<String, dynamic>? rawResponse;

  ApiException({
    required this.statusCode,
    required this.errorCode,
    required this.title,
    required this.detail,
    this.rawResponse,
  });

  factory ApiException.fromProblemDetails(int statusCode, Map<String, dynamic> json) {
    return ApiException(
      statusCode: statusCode,
      errorCode: json['errorCode']?.toString() ?? 'server.error',
      title: json['title']?.toString() ?? 'Request Failed',
      detail: json['detail']?.toString() ?? 'An unexpected error occurred.',
      rawResponse: json,
    );
  }

  factory ApiException.unexpected(dynamic error) {
    return ApiException(
      statusCode: 500,
      errorCode: 'client.unexpected_error',
      title: 'Connection Error',
      detail: error.toString(),
    );
  }

  @override
  String toString() => 'ApiException [$statusCode | $errorCode]: $title - $detail';
}

