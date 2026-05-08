import 'package:flutter/foundation.dart';

class ProgressProvider extends ChangeNotifier {
  int _currentMissionStep = 0;

  int get currentMissionStep => _currentMissionStep;

  final List<String> missionSteps = const [
    'Tracé',
    'Scan',
    'Mots',
    'Récompense',
  ];

  void setStep(int step) {
    if (step < 0 || step >= missionSteps.length) return;
    _currentMissionStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (_currentMissionStep < missionSteps.length - 1) {
      _currentMissionStep++;
      notifyListeners();
    }
  }

  void reset() {
    _currentMissionStep = 0;
    notifyListeners();
  }
}
