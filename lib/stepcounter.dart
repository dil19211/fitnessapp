import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import "package:pedometer/pedometer.dart";
import 'package:lottie/lottie.dart';
import 'package:sqflite/sqflite.dart';
import 'database_handler.dart';
import 'gainmealcaculation.dart';

class step extends StatefulWidget {
  @override
  _StepCounterState createState() => _StepCounterState();
}
class _StepCounterState extends State<step> {
  late StreamSubscription<StepCount> _stepCountStreamSubscription;
  int _dailyexpectedsteps = 0;
  int _stepCount = 0;
  int _dailySteps = 0;
  int _todaysSteps = 0; // New variable to store steps without resetting
  int _goalSteps = 0; // Example goal steps
  int _totalMinutesWalked = 0;
  double _caloriesBurned = 0.0;
  double _goalPercentage = 0.0;
  double _lastStepTimestamp = 0; // To track the timestamp of the last step
  bool _hasDisability = false; // Flag to track user's disability status
  Database? _database;
  late String email;
  Future<void>? _initialization;

  @override
  void initState() {
    super.initState();
    _initialization= initialize();
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasShownDialog = prefs.getBool('_showDisabilityDialog') ?? false;
    if (!hasShownDialog) {
      await Future.delayed(Duration(seconds: 2));
      _showDisabilityDialog(context);
      prefs.setBool('_showDisabilityDialog', true); // Set flag to indicate the dialog has been shown
    } else if (!_hasDisability) {
     // _showDisabilityDialog(context);
      checkPermissions();
    }

    _database = await openDB();
    //loadUserData();
    await fetchStepData();
  }

  Future<Database> openDB() async {
    Database _database = await DatabaseHandler().openDB();
    return _database;
  }

  Future<void> fetchStepData() async {
    var  data= await loadUserData();
    var activityLevel = await getActivityLevelFromEmail(email) ?? data['activityLevel'];
    print('Activity Level in fetch data: $activityLevel' );
    _dailyexpectedsteps = await dailystep(activityLevel);
    _goalSteps = await totalstep(activityLevel);

    setState(() {
      _goalPercentage = (_dailySteps / _goalSteps) * 100;
    });
  }







  Future<String?> getActivityLevelFromEmail(String email) async {
    String? activityLevel;
    if (_database != null) {
      List<Map<String, dynamic>> result = await _database!.query(
        'WEIGHTGAINUSER',
        columns: ['activity_level'],
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isNotEmpty) {
        activityLevel = result[0]['activity_level'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('activity_level', activityLevel!);
        print("$activityLevel in set ");
      }
    }
    return activityLevel;
  }


  Future<Map<String, dynamic>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final activityLevel = prefs.getString('activity_level') ?? 'Sedentary';
    print("$activityLevel  in load user data");
    return {
      'activityLevel': activityLevel,
    };

  }


  Future<int> getAgeFromEmail(String email) async {
    int? age;
    if (_database != null) {
      List<Map<String, dynamic>> result = await _database!.query(
        'WEIGHTGAINUSER',
        columns: ['age'],
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isNotEmpty) {
        age = result[0]['age'];
      }
    }
    return age ?? 0;
  }

  Future<int> totalstep(String activityLevel) async {
    Map<String, dynamic> userData = await loadUserData();
    String activityLevel = userData['activityLevel'];
    WeightGainCalculator wg_totalstep = WeightGainCalculator();
    return await wg_totalstep.calculateTotalStepsInPeriod(activityLevel);
  }

  Future<int> dailystep(String activityLevel) async {
    Map<String, dynamic> userData = await loadUserData();
    String activityLevel = userData['activityLevel'];
    WeightGainCalculator wg_dailystep = WeightGainCalculator();
    return await wg_dailystep.calculateTotalStepsInPerioddaily(activityLevel);
  }

  void _showDisabilityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Disability Confirmation",style: TextStyle(fontSize: 16,fontWeight:FontWeight.w600,color: Colors.purple),),
          content: Text("Do you have a disability that prevents you from using the step counter feature?"),
          actions: <Widget>[
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _hasDisability = false;
                });
                _saveStats(); // Save updated _hasDisability and _isFirstRun
                checkPermissions();
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _hasDisability = true;
                });
                _saveStats(); // Save updated _hasDisability and _isFirstRun
              },
            ),
          ],
        );
      },
    );
  }

  void checkPermissions() async {
    PermissionStatus status = await Permission.activityRecognition.request();
    print("checkPermissions: status=$status");
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
          _dailySteps++;
          _todaysSteps++; // Accumulate today's steps
          _totalMinutesWalked = calculateMinutesWalked(_dailySteps);
          _caloriesBurned = calculateCaloriesBurned(_dailySteps);
          _lastStepTimestamp = currentTimestamp;
          _goalPercentage = (_dailySteps / _goalSteps) * 100;
          _saveStats(); // Save the stats when they change
        }
      });
    });
  }

  Future<void> _loadStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _stepCount = prefs.getInt('stepCount') ?? 0;
      _dailySteps = prefs.getInt('dailySteps') ?? 0;
      _todaysSteps = prefs.getInt('todaysSteps') ?? _todaysSteps;
      _totalMinutesWalked = prefs.getInt('totalMinutesWalked') ?? 0;
      _caloriesBurned = prefs.getDouble('caloriesBurned') ?? 0;
      _lastStepTimestamp = prefs.getDouble('lastStepTimestamp') ?? 0;
      _goalPercentage = prefs.getDouble('goalPercentage') ?? 0;
      _hasDisability = prefs.getBool('hasDisability') ?? false;

      // Check if the date has changed
      String lastSavedDate = prefs.getString('lastSavedDate') ?? '';
      String currentDate = DateTime.now().toIso8601String().split('T')[0];

      if (lastSavedDate != currentDate) {
        _todaysSteps += _dailySteps; // Accumulate daily steps to today's steps
        _dailySteps = 0; // Reset daily steps
        prefs.setString('lastSavedDate', currentDate);
      }
    });
  }

  void _saveStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('stepCount', _stepCount);
    prefs.setInt('dailySteps', _dailySteps);
    prefs.setInt('todaysSteps', _todaysSteps); // Save the accumulated today's steps
    prefs.setInt('totalMinutesWalked', _totalMinutesWalked);
    prefs.setDouble('caloriesBurned', _caloriesBurned);
    prefs.setDouble('lastStepTimestamp', _lastStepTimestamp);
    prefs.setDouble('goalPercentage', _goalPercentage);
    prefs.setBool('hasDisability', _hasDisability);
  }

  int calculateMinutesWalked(int steps) {
    // Assuming an average walking speed of 100 steps per minute
    return (steps / 5).floor();
  }

  double calculateCaloriesBurned(int steps) {
    // Assuing 0.05 calories burned per step
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
    email = ModalRoute.of(context)?.settings.arguments as String;

    return FutureBuilder<void>(
      future:_initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text("Loading...")),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text("Error")),
            body: Center(child: Text("An error occurred: ${snapshot.error}")),
          );
        } else {
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
                                '$_dailySteps/$_dailyexpectedsteps',
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
                                      '$_dailySteps',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '/$_goalSteps',
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
      },
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
      width: 100,
      height: 100,
      child: Lottie.asset(
        'assets/images/health.json',
        repeat: true,
        reverse: true,
      ),
    );
  }
}
