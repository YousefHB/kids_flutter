// Provider : gère la mission du jour
import 'package:flutter/foundation.dart';
import '../models/daily_mission.dart';
import '../constants.dart';

class MissionProvider extends ChangeNotifier {
  late DailyMission _mission;
  int _currentStep = 0; // 0: draw, 1: scan, 2: words, 3: audio

  DailyMission get mission => _mission;
  int get currentStep => _currentStep;

  void initTodayMission(String letter) {
    _mission = DailyMission.today(letter);
    _currentStep = 0;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  void completeMission() {
    _mission = _mission.copyWith(
      isCompleted: true,
      starsEarned: STARS_PER_LETTER,
    );
    notifyListeners();
  }

  void resetMission() {
    _currentStep = 0;
    notifyListeners();
  }
}
