class ApiError {
  final String error;
  final String message;
  final dynamic details;

  ApiError({
    required this.error,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      error: json['error'] ?? 'UnknownError',
      message: json['message'] ?? 'Erro desconhecido',
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'details': details,
    };
  }

  @override
  String toString() {
    return 'ApiError(error: $error, message: $message, details: $details)';
  }
}
