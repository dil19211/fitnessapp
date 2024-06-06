import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class notify {
final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin();
final AndroidInitializationSettings _androidInitializationSettings=AndroidInitializationSettings("@mipmap");
void init() async{
  InitializationSettings initializationSettings=InitializationSettings(android: _androidInitializationSettings);
  await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void scdulenotification(String title,String body) async{
   AndroidNotificationDetails androidNotificationDetails=const AndroidNotificationDetails('channelId', 'channelName',priority: Priority.high,importance: Importance.max,);
  NotificationDetails notificationDetails=NotificationDetails(android: androidNotificationDetails,);
  // int id = DateTime.now().millisecondsSinceEpoch;
  await _flutterLocalNotificationsPlugin.periodicallyShow(0, title, body,RepeatInterval.everyMinute, notificationDetails);
}
}

