class AuthResponse {
  final bool success;
  final String message;
  final String? error;

  AuthResponse({
    required this.success,
    required this.message,
    this.error,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (error != null) 'error': error,
    };
  }

  @override
  String toString() {
    return 'AuthResponse{success: $success, message: $message, error: $error}';
  }
}
