import 'package:shared_preferences/shared_preferences.dart';const String GEMINI_API_KEY="AIzaSyCv6Deejcu6_aIJvaGwc1qef1yBU8s1Euk";



class UserDataManager {
  Future<Map<String, dynamic>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final height = prefs.getInt('height') ?? 0;
    final cWeight = prefs.getInt('cweight') ?? 0;
    final gWeight = prefs.getInt('gweight') ?? 0;
    final gender = prefs.getString('gender') ?? 'Male';
    final activityLevel = prefs.getString('activityLevel') ?? 'Sedentary';
    final age = prefs.getInt('age') ?? 0;

    return {
      'height': height,
      'cweight': cWeight,
      'gweight': gWeight,
      'gender': gender,
      'activityLevel': activityLevel,
      'age': age,
    };
  }
}
