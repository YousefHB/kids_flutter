class AuthResponse {
  final bool success;
  final String message;
  final String? userId;
  final String? childName;
  final int? childAge;

  const AuthResponse({
    required this.success,
    required this.message,
    this.userId,
    this.childName,
    this.childAge,
  });

  factory AuthResponse.success({
    required String userId,
    required String childName,
    required int childAge,
  }) {
    return AuthResponse(
      success: true,
      message: 'Connexion réussie',
      userId: userId,
      childName: childName,
      childAge: childAge,
    );
  }

  factory AuthResponse.failure(String message) {
    return AuthResponse(
      success: false,
      message: message,
    );
  }

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      userId: json['userId'] as String?,
      childName: json['childName'] as String?,
      childAge: json['childAge'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'userId': userId,
      'childName': childName,
      'childAge': childAge,
    };
  }
}
