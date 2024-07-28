import 'package:shared_preferences/shared_preferences.dart';
 class idstorage {

   static Future<void> storeUserId(String userId) async {
     final SharedPreferences prefs = await SharedPreferences.getInstance();
     print('Storing userId: $userId');
     await prefs.setString('userId', userId);
   }

   static Future<String?> getUserId() async {
     final SharedPreferences prefs = await SharedPreferences.getInstance();
     String? userId = prefs.getString('userId');
     print('Retrieved userId: $userId');
     return userId;
   }


 }