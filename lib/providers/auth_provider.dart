import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../utils/shared_preferences_helper.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _userId;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get errorMessage => _errorMessage;

  Future<void> loadAuthState() async {
    _isLoading = true;
    notifyListeners();

    _isLoggedIn = await SharedPreferencesHelper.isLoggedIn();
    _userId = await SharedPreferencesHelper.getUserId();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login({
    required String childName,
    required int childAge,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _apiService.loginLocal(
      childName: childName,
      childAge: childAge,
    );

    if (response.success) {
      _isLoggedIn = true;
      _userId = response.userId;

      await SharedPreferencesHelper.saveLoginState(
        isLoggedIn: true,
        userId: response.userId,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    }

    _errorMessage = response.message;
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _apiService.logout();
    await SharedPreferencesHelper.clearAll();

    _isLoggedIn = false;
    _userId = null;
    _errorMessage = null;

    _isLoading = false;
    notifyListeners();
  }
}
