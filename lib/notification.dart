import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
class NotificationUtils {

  static void showSecondNotification() {
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


  static void lunchnotification() {
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

 static void lunchnotificationreminder() {
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

  static void snacknotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 50,
        channelKey: 'basic_channel',
        title: '',
        body: 'Its Snack Time!....',
        color: Colors.lime,
      ),
    );
  }

  static void snacknotificationreminder() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 60,
        channelKey: 'basic_channel',
        title: '',
        body: 'Make sure you have take your snack Calories !....',
        color: Colors.pinkAccent,
      ),
    );
  }

  static void dinnernotification() {
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

  static void dinnernotificationreminder() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 80,
        channelKey: 'basic_channel',
        title: ' ',
        body: 'Make sure you have take your dinner Calories !....',
        color: Colors.deepPurple,
      ),
    );
  }


  static void showNotification() {
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
 static Duration calculateInitialDelay(int hour, int minute) {
    // Calculate the time until the specified hour and minute
    DateTime now = DateTime.now();
    DateTime scheduledTime = DateTime(
        now.year, now.month, now.day, hour, minute, 0);
    Duration initialDelay = scheduledTime.difference(now);
    if (initialDelay.isNegative) {
      // If the scheduled time has passed for today, schedule for the same time tomorrow
      scheduledTime = scheduledTime.add(Duration(days: 1));
      initialDelay = scheduledTime.difference(now);
    }
    return initialDelay;
  }
  static void stepreminder(){AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 90,
      channelKey: 'basic_channel',
      title: '',
      body: 'Mkae Sure you have taken your Today"s steps!!!!',
      color: Colors.lightBlueAccent,
      backgroundColor: Colors.white70,
    ),
  );
  }

}