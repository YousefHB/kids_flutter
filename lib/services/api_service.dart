import '../models/auth_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  Future<AuthResponse> loginLocal({
    required String childName,
    required int childAge,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (childName.trim().isEmpty) {
      return AuthResponse.failure('Le prénom est obligatoire.');
    }

    if (childAge < 2 || childAge > 12) {
      return AuthResponse.failure('L’âge doit être entre 2 et 12 ans.');
    }

    return AuthResponse.success(
      userId: 'local_user_${DateTime.now().millisecondsSinceEpoch}',
      childName: childName.trim(),
      childAge: childAge,
    );
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
