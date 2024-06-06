import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

class step extends StatefulWidget {
  const step({Key? key}) : super(key: key);

  @override
  _StepCounterState createState() => _StepCounterState();
}

class _StepCounterState extends State<step> {
  late StreamSubscription<StepCount> _stepCountStreamSubscription;
  int _stepCount = 0;
  int _goalSteps = 10000; // Example goal steps
  int _totalMinutesWalked = 0;
  double _caloriesBurned = 0.0;
  double _goalPercentage = 0.0;
  double _lastStepTimestamp = 0; // To track the timestamp of the last step

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  void checkPermissions() async {
    PermissionStatus status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      initializePedometer();
    } else if (status.isDenied) {
      showPermissionDialog();
    } else {
      // Handle if permission is denied
    }
  }

  void initializePedometer() {
    _loadStats();
    _stepCountStreamSubscription = Pedometer.stepCountStream.listen((StepCount event) {
      setState(() {
        double currentTimestamp = DateTime.now().millisecondsSinceEpoch / 1000;
        double timeDifference = currentTimestamp - _lastStepTimestamp;
        if (timeDifference > 2) {
          _stepCount++;
          _totalMinutesWalked = calculateMinutesWalked(_stepCount);
          _caloriesBurned = calculateCaloriesBurned(_stepCount);
          _lastStepTimestamp = currentTimestamp;
          _goalPercentage = (_stepCount / _goalSteps) * 100;
          _saveStats(); // Save the stats when they change
        }
      });
    });
  }

  void _loadStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _stepCount = prefs.getInt('stepCount') ?? 0;
      _totalMinutesWalked = prefs.getInt('totalMinutesWalked') ?? 0;
      _caloriesBurned = prefs.getDouble('caloriesBurned') ?? 0;
      _lastStepTimestamp = prefs.getDouble('lastStepTimestamp') ?? 0;
      _goalPercentage = prefs.getDouble('goalPercentage') ?? 0;
    });
  }

  void _saveStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('stepCount', _stepCount);
    prefs.setInt('totalMinutesWalked', _totalMinutesWalked);
    prefs.setDouble('caloriesBurned', _caloriesBurned);
    prefs.setDouble('lastStepTimestamp', _lastStepTimestamp);
    prefs.setDouble('goalPercentage', _goalPercentage);
  }

  int calculateMinutesWalked(int steps) {
    // Assuming an average walking speed of 100 steps per minute
    return (steps / 5).floor();
  }

  double calculateCaloriesBurned(int steps) {
    // Assuming 0.05 calories burned per step
    return steps * 0.05;
  }

  Color getAppBarColor(double goalPercentage) {
    if (goalPercentage >= 100) {
      return Colors.green;
    } else if (goalPercentage >= 1) {
      return Colors.lightBlue;
    } else {
      return Colors.white; // Change color to grey for less than 75%
    }
  }

  void showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission Required"),
          content: Text("This app requires permission to track your physical activity."),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Allow"),
              onPressed: () {
                openAppSettings();
              },
            ),
          ],
        );
      },
    ).then((value) {
      // Check permission again after returning from settings
      checkPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    Color appBarColor = getAppBarColor(_goalPercentage);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'GritFit Health',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 70),
                        _buildCircleWithText(
                          'assets/images/running-shoes.png',
                          '$_stepCount',
                          'steps',
                          Colors.purpleAccent,
                        ),
                        SizedBox(height: 10),
                        _buildCircleWithText(
                          Icons.timer,
                          '$_totalMinutesWalked',
                          'mins',
                          Colors.lightBlueAccent,
                        ),
                        SizedBox(height: 10),
                        _buildCircleWithText(
                          Icons.whatshot,
                          _caloriesBurned.toStringAsFixed(2),
                          'kcal',
                          Colors.pinkAccent,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Padding(
                    padding: EdgeInsets.only(top: 70, right: 1),
                    child: _buildLottieAnimation(),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 10,
              top: 250,
              child: Container(
                height: 140,
                width: 340,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_stepCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '/$_goalSteps steps',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 150,
                            height: 30,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${_goalPercentage.toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  height: 5,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: appBarColor,
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _goalPercentage / 100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleWithText(dynamic image, String value, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: image is String
              ? Image.asset(
            image,
            color: Colors.white,
            width: 7,
            height: 7,
          )
              : Icon(
            image,
            color: Colors.white,
            size: 15,
          ),
        ),
        SizedBox(width: 20),
        Text(
          '$value ',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildLottieAnimation() {
    return Container(
      width: 130,
      height: 100,
      child: Lottie.asset(
        'assets/images/health.json',
        repeat: true,
        reverse: true,
      ),
    );
  }
}
