import 'package:fitnessapp/recipe%20page.dart';
import 'package:fitnessapp/splashscreen.dart';
import 'package:fitnessapp/weightgain.dart';
import 'package:fitnessapp/workout.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'chatboat.dart';
import 'consst.dart';
import 'gainmeal.dart';






void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Gemini.init(apiKey: GEMINI_API_KEY,);
  Stripe.publishableKey = 'pk_test_51PJ8UO2Llx6JzMA097s9w7TMcx9twOXtugzhcsIPlfagU8Y5D1GvavzMJ72322b4oRhvjNc38Z0cnd0TQ1lqgoLW00e5vXNMgg';

  await Stripe.instance.applySettings();
  await initializeService();
  await requestNotificationPermission();
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'GritFit notifications',
        channelDescription: 'Notification channel for basic notifications',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.blueAccent,
        importance: NotificationImportance.High,
        playSound: true,
        onlyAlertOnce: true,
      ),
    ],
    //debug: true
  );
  runApp(const MyApp());
  // Initialize WorkManager
  Workmanager().initialize(callbackDispatcher);
  // Register a periodic task to run at 7 PM daily
  Workmanager().registerPeriodicTask(
    "1",
    "show_notification_task",
    frequency: Duration(days: 1), // Repeat daily
    initialDelay: _calculateInitialDelay(7,5),
    inputData: {},
  );
  Workmanager().registerPeriodicTask(
    "2",
    "show_notification_830_am_task",
    frequency: Duration(days: 1),
    initialDelay: _calculateInitialDelay(8, 30), // 8:30 AM
    inputData: {},
  );
  Workmanager().registerPeriodicTask(
    "3",
    "lunch time",
    frequency: Duration(days: 1),
    initialDelay: _calculateInitialDelay(12, 35), // 12:0 pm
    inputData: {},
  );
  Workmanager().registerPeriodicTask(
    "4",
    "lunch time Reminder",
    frequency: Duration(days: 1),
    initialDelay: _calculateInitialDelay(14,15 ), // 2:15 pm
    inputData: {},
  );
  Workmanager().registerPeriodicTask(
    "5",
    "snack time",
    frequency: Duration(days: 1),
    initialDelay: _calculateInitialDelay(15,10), // 3:10pm
    inputData: {},
  );
  Workmanager().registerPeriodicTask(
    "6",
    "snack time Reminder",
    frequency: Duration(days: 1),
    initialDelay: _calculateInitialDelay(17,20), // 5:20 pm
    inputData: {},
  );
  Workmanager().registerPeriodicTask(
    "7",
    "dinner time",
    frequency: Duration(days: 1),
    initialDelay: _calculateInitialDelay(18,15), // 6:12 pm
    inputData: {},
  );
  Workmanager().registerPeriodicTask(
    "8",
    "dinner time Reminder",
    frequency: Duration(days: 1),
    initialDelay: _calculateInitialDelay(20,30), // 8:15 pm
    inputData: {},
  );
}




void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    switch (task) {
      case "show_notification_task":
        print('Background task executed for 12:30 PM');
        showNotification();
        break;
      case "show_notification_830_am_task":
        print('Background task executed for 8:30 AM');
        showSecondNotification();
        break;
      case "lunch time":
        print('Background task executed for 2:0 pM');
        lunchnotification();
        break;
      case "lunch time Reminder":
        print('Background task executed for 2:15 pM');
       lunchnotificationreminder();
        break;
      case "snack time":
        print('Background task executed for 3:0pm');
        snacknotification();
        break;
      case "snack time Reminder":
        print('Background task executed for 5:20pM');
        snacknotificationreminder();
        break;
      case "dinner time":
        print('Background task executed for 6:0 pM');
        dinnernotification();
        break;
      case "dinner time Reminder":
        print('Background task executed for 8:15 pM');
        dinnernotificationreminder();
        break;
    }
    return Future.value(true); // Return a Future to indicate task completion
  });
}
void showSecondNotification() {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 20,
      channelKey: 'basic_channel',
      title: '',
      body: 'Make sure you have take your Breakfast Calories!....',
      color: Colors.cyan,
    ),
  );
}


void lunchnotification() {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 30,
      channelKey: 'basic_channel',
      title: '',
      body: ' Lunch Time!....',
      color: Colors.cyanAccent,
      backgroundColor: Colors.blue,
    ),
  );
}
void lunchnotificationreminder() {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 40,
      channelKey: 'basic_channel',
      title: ' ',
      body: 'Make sure you have take your Lunch Calories !....',
      color: Colors.green,
    ),
  );
}
void snacknotification() {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 50,
      channelKey: 'basic_channel',
      title: '',
      body: 'Its Snack Time!....',
      color:Colors.lime,
    ),
  );
}
void snacknotificationreminder() {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 60,
      channelKey: 'basic_channel',
      title: '',
      body: 'Make sure you have take your snack Calories !....',
      color:Colors.pinkAccent,
    ),
  );
}
void dinnernotification() {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 70,
      channelKey: 'basic_channel',
      title: ' ',
      body: 'Its Time to dinner !....',
      color: Colors.purpleAccent,
    ),
  );
}
void dinnernotificationreminder() {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 80,
      channelKey: 'basic_channel',
      title: ' ',
      body: 'Make sure you have take your dinner Calories !....',
      color:Colors.deepPurple,
    ),
  );
}

Duration _calculateInitialDelay(int hour, int minute) {
  // Calculate the time until the specified hour and minute
  DateTime now = DateTime.now();
  DateTime scheduledTime = DateTime(now.year, now.month, now.day, hour, minute, 0);
  Duration initialDelay = scheduledTime.difference(now);
  if (initialDelay.isNegative) {
    // If the scheduled time has passed for today, schedule for the same time tomorrow
    scheduledTime = scheduledTime.add(Duration(days: 1));
    initialDelay = scheduledTime.difference(now);
  }
  return initialDelay;
}
void showNotification() {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 10,
      channelKey: 'basic_channel',
      title: '',
      body: 'Breakfast Time !...',
      color: Colors.lightBlueAccent,
      backgroundColor: Colors.white70,
    ),
  );
}

Future<void> requestNotificationPermission() async {
  // Request notification permission
  var status = await Permission.notification.request();

  // Check permission status
  if (!status.isGranted) {
    // Permission not granted, show a message or handle it accordingly
    print('Notification permission is not granted.');
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground',
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          888,
          'App service',
          'Awesome ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        service.setForegroundNotificationInfo(
          title: "GritFit service ",
          content: "App ${DateTime.now()}",
        );
      }
    }

    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
      },
    );
  });
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Use the HomePage widget as the home page
    );
  }


// This widget is the home page of your application. It is stateful, meaning
// that it has a State object (defined below) that contains fields that affect
// how it looks.

// This class is the configuration for the state. It holds the values (in this
// case the title) provided by the parent (in this case the App widget) and
// used by the build method of the State. Fields in a Widget subclass are
// always marked "final".

// final String title;



}
