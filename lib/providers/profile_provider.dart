import 'package:flutter/foundation.dart';
import '../models/child_profile.dart';
import '../utils/shared_preferences_helper.dart';
import '../constants.dart';

class ProfileProvider extends ChangeNotifier {
  ChildProfile? _profile;
  bool _isLoading = false;

  ChildProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _profile != null;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    _profile = await SharedPreferencesHelper.getProfile();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> initProfile(String name, int age, String mascotId) async {
    _profile = ChildProfile.newChild(name, age, mascotId);
    await SharedPreferencesHelper.saveProfile(_profile!);
    notifyListeners();
  }

  Future<void> markLetterCompleted(String letter) async {
    if (_profile == null) return;

    final updatedLetters = Map<String, bool>.from(_profile!.lettersCompleted);
    updatedLetters[letter] = true;

    _profile = _profile!.copyWith(
      lettersCompleted: updatedLetters,
    );

    await SharedPreferencesHelper.saveProfile(_profile!);
    notifyListeners();
  }

  Future<void> addStars(int count) async {
    if (_profile == null) return;

    _profile = _profile!.copyWith(
      totalStars: _profile!.totalStars + count,
    );

    await SharedPreferencesHelper.saveProfile(_profile!);
    notifyListeners();
  }

  Future<void> completeLetterWithStars(String letter) async {
    if (_profile == null) return;

    final alreadyCompleted = isLetterCompleted(letter);

    final updatedLetters = Map<String, bool>.from(_profile!.lettersCompleted);
    updatedLetters[letter] = true;

    _profile = _profile!.copyWith(
      lettersCompleted: updatedLetters,
      totalStars: alreadyCompleted
          ? _profile!.totalStars
          : _profile!.totalStars + STARS_PER_LETTER,
    );

    await SharedPreferencesHelper.saveProfile(_profile!);
    notifyListeners();
  }

  bool isLetterCompleted(String letter) {
    return _profile?.lettersCompleted[letter] ?? false;
  }

  Future<void> resetProfile() async {
    await SharedPreferencesHelper.clearAll();
    _profile = null;
    notifyListeners();
  }
}
