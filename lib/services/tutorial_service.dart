// services/tutorial_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const _orientationShownKey = 'orientation_shown';
  static const _informativeTutorialCompletedKey = 'informative_tutorial_completed';
  static const _practicalTutorialCompletedKey = 'practical_tutorial_completed';
  static const _practicalTutorial2CompletedKey = 'practical_tutorial_2_completed';

  Future<bool> isOrientationShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_orientationShownKey) ?? false;
  }

  Future<void> markOrientationAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_orientationShownKey, true);
  }

  Future<bool> isInformativeTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_informativeTutorialCompletedKey) ?? false;
  }

  Future<void> completeInformativeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_informativeTutorialCompletedKey, true);
  }

  Future<bool> isPracticalTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_practicalTutorialCompletedKey) ?? false;
  }

  Future<void> completePracticalTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_practicalTutorialCompletedKey, true);
  }

  Future<bool> isPracticalTutorial2Completed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_practicalTutorial2CompletedKey) ?? false;
  }

  Future<void> completePracticalTutorial2() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_practicalTutorial2CompletedKey, true);
  }
}