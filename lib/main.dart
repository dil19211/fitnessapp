
import 'package:firebase_core/firebase_core.dart';
import 'package:fitnessapp/adminpanel.dart';
import 'package:fitnessapp/gainmeal.dart';
import 'package:fitnessapp/getstarted%20page.dart';
import 'package:fitnessapp/login.dart';
import 'package:fitnessapp/pgainmeal.dart';
import 'package:fitnessapp/splashscreen.dart';
import 'package:fitnessapp/stepcounter.dart';
import 'package:fitnessapp/workout.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
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
import 'consst.dart';
import 'notification.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Gemini.init(
    apiKey: GEMINI_API_KEY,
  );
  Stripe.publishableKey =
  'pk_test_51PJ8UO2Llx6JzMA097s9w7TMcx9twOXtugzhcsIPlfagU8Y5D1GvavzMJ72322b4oRhvjNc38Z0cnd0TQ1lqgoLW00e5vXNMgg';
  Platform.isAndroid ?
  await Firebase.initializeApp(options: const FirebaseOptions(
    apiKey: "AIzaSyCkJnZAee2hzxEy7mvdZPj9ZHe9ZxV-XAI",
    appId: "1:996311167987:android:1d96a17080801f097b9886",
    messagingSenderId: "996311167987",
    projectId:
    "fitnessapp-a46d2"
    ,)) : await Firebase.initializeApp();
  await Stripe.instance.applySettings();
  await initializeService();
  await requestNotificationPermission();
  Workmanager().initialize(callbackDispatcher);
  runApp(const MyApp());
}
  // Initialize WorkManager
  void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) {
      switch (task) {
        case "show_notification_task":
          print('Background task executed for 7:5 AM');
          NotificationUtils.showNotification();
          break;
        case "show_notification_830_am_task":
          print('Background task executed for 8:30 AM');
          NotificationUtils.showSecondNotification();
          break;
        case "lunch time":
          print('Background task executed for 2:0 pM');
          NotificationUtils.lunchnotification();
          break;
        case "lunch time Reminder":
          print('Background task executed for 2:15 pM');
          NotificationUtils.lunchnotificationreminder();
          break;
        case "snack time":
          print('Background task executed for 3:0pm');
          NotificationUtils.snacknotification();
          break;
        case "snack time Reminder":
          print('Background task executed for 5:20pM');
          NotificationUtils.snacknotificationreminder();
          break;
        case "dinner time":
          print('Background task executed for 6:0 pM');
          NotificationUtils.dinnernotification();
          break;
        case "dinner time Reminder":
          print('Background task executed for pM');
          NotificationUtils.dinnernotificationreminder();
          break;
        case "step reminder":
          print('Background task executed for  pM');
          NotificationUtils.stepreminder();
          break;
      }
      return Future.value(true); // Return a Future to indicate task completion
    });
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