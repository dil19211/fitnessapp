import 'package:shared_preferences/shared_preferences.dart';

class FirstRunHelper {
  static const _keyFirstRun = 'isFirstRununing';

  static Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstRun) ?? true;
  }

  static Future<void> markFirstRunComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstRun, false);
  }
}
