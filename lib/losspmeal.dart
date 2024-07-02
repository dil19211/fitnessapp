
import 'dart:async';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'color.dart';
import 'database_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'gainmealcaculation.dart';
import 'notification.dart';

class losspmeal extends StatefulWidget {
  @override
  _MealState createState() => _MealState();
}

class _MealState extends State<losspmeal> {
  int _breakfastCalories = 400;
  int _lunchCalories = 800;
  int _snackCalories = 600;
  int _dinnerCalories = 700;

  int _consumedCalories = 0;
  int _displayedConsumedCalories = 0;
  int _takenBreakfastCalories = 0;
  int _takenLunchCalories = 0;
  int _takenSnackCalories = 0;
  int _takenDinnerCalories = 0;
  late Future<Database> _databaseFuture;
  Database? _database;

  @override
  void initState() {
    super.initState();
    _loadCaloriesFromSharedPreferences();
    _checkAndTriggerReset();
    SharedPreferences.getInstance().then((prefs) {
      bool hasShownDialog = prefs.getBool('hasShownDiseaseDialog') ?? false;
      if (!hasShownDialog) {
        // Show the dialog only if it has not been shown before
        Future.delayed(Duration(seconds: 2), () {
          _showDiseaseDialog(context);
          prefs.setBool('hasShownDiseaseDialog',
              true); // Set flag to indicate the dialog has been shown
          print("called");
        });
      }
    });
    _databaseFuture = openDB();
    loadUserData();
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
    // Register a periodic task to run at 7 PM daily
    Workmanager().registerPeriodicTask(
      "1",
      "show_notification_task",
      frequency: Duration(days: 1), // Repeat daily
      initialDelay: NotificationUtils.calculateInitialDelay(7, 5),
      inputData: {},
    );
    Workmanager().registerPeriodicTask(
      "2",
      "show_notification_830_am_task",
      frequency: Duration(days: 1),
      initialDelay: NotificationUtils.calculateInitialDelay(8, 30), // 8:30 AM
      inputData: {},
    );
    Workmanager().registerPeriodicTask(
      "3",
      "lunch time",
      frequency: Duration(days: 1),
      initialDelay: NotificationUtils.calculateInitialDelay(12, 35), // 12:0 pm
      inputData: {},
    );
    Workmanager().registerPeriodicTask(
      "4",
      "lunch time Reminder",
      frequency: Duration(days: 1),
      initialDelay: NotificationUtils.calculateInitialDelay(14, 15), // 2:15 pm
      inputData: {},
    );
    Workmanager().registerPeriodicTask(
      "5",
      "snack time",
      frequency: Duration(days: 1),
      initialDelay: NotificationUtils.calculateInitialDelay(15, 10), // 3:10pm
      inputData: {},
    );
    Workmanager().registerPeriodicTask(
      "6",
      "snack time Reminder",
      frequency: Duration(days: 1),
      initialDelay: NotificationUtils.calculateInitialDelay(17, 20), // 5:20 pm
      inputData: {},
    );
    Workmanager().registerPeriodicTask(
      "7",
      "dinner time",
      frequency: Duration(days: 1),
      initialDelay: NotificationUtils.calculateInitialDelay(18, 15), // 6:12 pm
      inputData: {},
    );
    Workmanager().registerPeriodicTask(
      "8",
      "dinner time Reminder",
      frequency: Duration(days: 1),
      initialDelay: NotificationUtils.calculateInitialDelay(20, 30), // 8:15 pm
      inputData: {},
    );
    Workmanager().registerPeriodicTask(
      "9",
      "step reminder",
      frequency: Duration(days: 1),
      initialDelay: NotificationUtils.calculateInitialDelay(15, 30), // 8:30 AM
      inputData: {},
    );
    Workmanager().registerPeriodicTask(
      "10",
      "water remindermorning",
      frequency: Duration(days: 1),
      initialDelay: NotificationUtils.calculateInitialDelay(8, 20), // 8:30 AM
      inputData: {},
    );
    Workmanager().registerPeriodicTask(
      "11",
      "water remindermidday",
      frequency: Duration(days: 1),
      initialDelay: NotificationUtils.calculateInitialDelay(14, 20), // 8:30 AM
      inputData: {},
    );
    Workmanager().registerPeriodicTask(
      "12",
      "water reminderevening",
      frequency: Duration(days: 1),
      initialDelay: NotificationUtils.calculateInitialDelay(17, 20), // 8:30 AM
      inputData: {},
    ); Workmanager().registerPeriodicTask(
      "13",
      "water remindernight",
      frequency: Duration(days: 1),
      initialDelay: NotificationUtils.calculateInitialDelay(20, 20), // 8:30 AM
      inputData: {},
    );

  }

  void _showDiseaseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        List<String> selectedDiseases = []; // To store selected diseases
        final List<String> allDiseases = [
          'Diabetes',
          'Hypertension',
          'Heart Disease'
        ];

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Your Diseases if you have any',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.purple),),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: allDiseases.map((disease) {
                  return CheckboxListTile(
                    title: Text(disease),
                    value: selectedDiseases.contains(disease),
                    activeColor: Colors.green, // Set active color to green
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedDiseases.add(disease);
                        } else {
                          selectedDiseases.remove(disease);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // Save selected diseases to SharedPreferences
                    SharedPreferences prefs = await SharedPreferences
                        .getInstance();
                    prefs.setStringList('diseases', selectedDiseases);
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _checkAndTriggerReset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime lastResetDate =
    DateTime.fromMillisecondsSinceEpoch(prefs.getInt('lastResetDate') ?? 0);
    DateTime now = DateTime.now();

    if (!_isSameDay(lastResetDate, now)) {
      // Reset hasn't been done today, trigger reset
      _triggerReset();
      print("after trigger");
      // Update last reset date in SharedPreferences
      prefs.setInt('lastResetDate', now.millisecondsSinceEpoch);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _triggerReset() {
    print("helllo");
    setState(() {
      // Reset the consumed calories
      _takenBreakfastCalories = 0;
      _takenLunchCalories = 0;
      _takenSnackCalories = 0;
      _takenDinnerCalories = 0;
      _consumedCalories = 0;
      // Save the reset values to SharedPreferences
      _saveCaloriesToSharedPreferences();
      print("reset completed");
    });
  }


  void _loadCaloriesFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _consumedCalories = prefs.getInt('consumed_calories') ?? 0;
      _takenBreakfastCalories = prefs.getInt('taken_breakfast_calories') ?? 0;
      _takenLunchCalories = prefs.getInt('taken_lunch_calories') ?? 0;
      _takenSnackCalories = prefs.getInt('taken_snack_calories') ?? 0;
      _takenDinnerCalories = prefs.getInt('taken_dinner_calories') ?? 0;
      _displayedConsumedCalories =
          prefs.getInt('displayed_consumed_calories') ?? _consumedCalories;
    });
  }
  Color getBackgroundColor(double percentage) {
    if (percentage < 0.25) {
      return Colors.green[100]!;
    } else if (percentage < 0.5) {
      return Colors.yellow[100]!;
    } else if (percentage < 0.75) {
      return Colors.orange[100]!;
    } else {
      return Colors.red[100]!;
    }
  }
  void _saveCaloriesToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('consumed_calories', _consumedCalories);
    prefs.setInt('taken_breakfast_calories', _takenBreakfastCalories);
    prefs.setInt('taken_lunch_calories', _takenLunchCalories);
    prefs.setInt('taken_snack_calories', _takenSnackCalories);
    prefs.setInt('taken_dinner_calories', _takenDinnerCalories);
    prefs.setInt('displayed_consumed_calories', _displayedConsumedCalories);
  }

  // Helper function to open the database
  Future<Map<String, dynamic>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final height = prefs.getInt('height') ?? 0;
    final cWeight = prefs.getInt('cweight') ?? 0;
    final gWeight = prefs.getInt('gweight') ?? 0;
    final gender = prefs.getString('gender') ?? 'Male';
    final activityLevel = prefs.getString('activity_level') ?? 'Sedentary';
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

  Future<Database> openDB() async {
    Database _database = await DatabaseHandler().openDB();
    return _database;
  }

  Future<int?> getHeightFromEmail(String email) async {
    int? height;
    if (_database != null) {
      List<Map<String, dynamic>> result = await _database!.query(
        'WEIGHTLOSSUSER',
        columns: ['height'],
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isNotEmpty) {
        height = result[0]['height'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('height', height!);
      }
    }
    return height;
  }

  Future<int?> getCWeightFromEmail(String email) async {
    int? cweight;
    if (_database != null) {
      List<Map<String, dynamic>> result = await _database!.query(
        'WEIGHTLOSSUSER',
        columns: ['cweight'],
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isNotEmpty) {
        cweight = result[0]['cweight'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('cweight', cweight!);
      }
    }
    return cweight;
  }

  Future<int?> getGWeightFromEmail(String email) async {
    int? gweight;
    if (_database != null) {
      List<Map<String, dynamic>> result = await _database!.query(
        'WEIGHTLOSSUSER',
        columns: ['gweight'],
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isNotEmpty) {
        gweight = result[0]['gweight'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('gweight', gweight!);
      }
    }
    return gweight;
  }

  Future<String?> getGenderFromEmail(String email) async {
    String? gender;
    if (_database != null) {
      List<Map<String, dynamic>> result = await _database!.query(
        'WEIGHTLOSSUSER',
        columns: ['gender'],
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isNotEmpty) {
        gender = result[0]['gender'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('gender', gender!);
      }
    }
    return gender;
  }

  Future<String?> getActivityLevelFromEmail(String email) async {
    String? activityLevel;
    if (_database != null) {
      List<Map<String, dynamic>> result = await _database!.query(
        'WEIGHTLOSSUSER',
        columns: ['activity_level'],
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isNotEmpty) {
        activityLevel = result[0]['activity_level'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('activity_level', activityLevel!);
      }
    }
    return activityLevel;
  }

  Future<int?> getAgeFromEmail(String email) async {
    int? age;
    if (_database != null) {
      List<Map<String, dynamic>> result = await _database!.query(
        'WEIGHTLOSSUSER',
        columns: ['age'],
        where: 'email = ?',
        whereArgs: [email],
      );

      if (result.isNotEmpty) {
        age = result[0]['age'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('age', age!);
      }
    }
    return age;
  }

  Future<int> daily_cal(int cweight, int gweight, int height, int age,
      String gender, String activityLevel) async {
    Map<String, dynamic> userData = await loadUserData();

    int cweight = userData['cweight'];
    int gweight = userData['gweight'];
    int height = userData['height'];
    int age = userData['age'];
    String gender = userData['gender'];
    String activityLevel = userData['activityLevel'];
    WeightGainCalculator wg_daily_cal = WeightGainCalculator();

    return await wg_daily_cal.calculateDailyCaloriesNeededTolossWeight(
        cweight, gweight, height, age, gender, activityLevel);
  }

  Future<int> total_cal(int cweight, int gweight, int height, int age,
      String gender, String activityLevel) async {
    Map<String, dynamic> userData = await loadUserData();

    int cweight = userData['cweight'];
    int gweight = userData['gweight'];
    int height = userData['height'];
    int age = userData['age'];
    String gender = userData['gender'];
    String activityLevel = userData['activityLevel'];
    WeightGainCalculator wg_total_cal = WeightGainCalculator();

    return await wg_total_cal.calculateTotalCaloriesTolossWeight(
        cweight, gweight, height, age, gender, activityLevel);
  }

  Future<int> b_cal(int cweight, int gweight, int height, int age,
      String gender, String activityLevel) async {
    Map<String, dynamic> userData = await loadUserData();

    int cweight = userData['cweight'];
    int gweight = userData['gweight'];
    int height = userData['height'];
    int age = userData['age'];
    String gender = userData['gender'];
    String activityLevel = userData['activityLevel'];
    WeightGainCalculator wg_b_cal = WeightGainCalculator();

    return await wg_b_cal.calculateBreakfastCaloriesToGoalloss(
        cweight, gweight, height, age, gender, activityLevel);
  }

  Future<int> l_cal(int cweight, int gweight, int height, int age,
      String gender, String activityLevel) async {
    Map<String, dynamic> userData = await loadUserData();

    int cweight = userData['cweight'];
    int gweight = userData['gweight'];
    int height = userData['height'];
    int age = userData['age'];
    String gender = userData['gender'];
    String activityLevel = userData['activityLevel'];
    WeightGainCalculator wg_l_cal = WeightGainCalculator();

    return await wg_l_cal.calculatelunchfastCaloriesToloss(
        cweight, gweight, height, age, gender, activityLevel);
  }

  Future<int> s_cal(int cweight, int gweight, int height, int age,
      String gender, String activityLevel) async {
    Map<String, dynamic> userData = await loadUserData();

    int cweight = userData['cweight'];
    int gweight = userData['gweight'];
    int height = userData['height'];
    int age = userData['age'];
    String gender = userData['gender'];
    String activityLevel = userData['activityLevel'];
    WeightGainCalculator wg_s_cal = WeightGainCalculator();

    return await wg_s_cal.calculatesnackfastCaloriesToGoalloss(
        cweight, gweight, height, age, gender, activityLevel);
  }

  Future<int> d_cal(int cweight, int gweight, int height, int age,
      String gender, String activityLevel) async {
    Map<String, dynamic> userData = await loadUserData();

    int cweight = userData['cweight'];
    int gweight = userData['gweight'];
    int height = userData['height'];
    int age = userData['age'];
    String gender = userData['gender'];
    String activityLevel = userData['activityLevel'];
    WeightGainCalculator wg_d_cal = WeightGainCalculator();

    return await wg_d_cal.calculatedinnerfastCaloriesToGoalloss(
        cweight, gweight, height, age, gender, activityLevel);
  }

  @override
  Widget build(BuildContext context) {
    final String email = ModalRoute
        .of(context)
        ?.settings
        .arguments as String;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        title: Text(
          'Meal Chart',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      body: FutureBuilder(
        future: _databaseFuture.then((_database) async {
          this._database = _database;
          var initialUserData = await loadUserData();

          var age = await getAgeFromEmail(email) ?? initialUserData['age'];
          print('Age: $age');

          var height = await getHeightFromEmail(email) ??
              initialUserData['height'];
          print('Height: $height');

          var cweight = await getCWeightFromEmail(email) ??
              initialUserData['cweight'];
          print('Current Weight: $cweight');

          var gweight = await getGWeightFromEmail(email) ??
              initialUserData['gweight'];
          print('Goal Weight: $gweight');

          var gender = await getGenderFromEmail(email) ??
              initialUserData['gender'];
          print('Gender: $gender');

          var activityLevel = await getActivityLevelFromEmail(email) ??
              initialUserData['activityLevel'];
          print('Activity Level: $activityLevel');

          return [age, height, cweight, gweight, gender, activityLevel];
        }),

        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available'));
          } else {
            int age = snapshot.data![0] as int;
            int height = snapshot.data![1] as int;
            int cweight = snapshot.data![2] as int;
            int gweight = snapshot.data![3] as int;
            String gender = snapshot.data![4] as String;
            String activityLevel = snapshot.data![5] as String;

            return SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FutureBuilder<int>(
                            future: total_cal(
                                cweight, gweight, height, age, gender,
                                activityLevel),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text("Error/: ${snapshot.error}");
                              } else {
                                int totalCalories = snapshot.data ?? 0;
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Total Calories: ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$totalCalories',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Taken Calories: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                '$_displayedConsumedCalories',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: FutureBuilder<int>(
                        future: daily_cal(cweight, gweight, height, age, gender,
                            activityLevel),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error.: ${snapshot.error}');
                          } else {
                            num dailyCalories = snapshot.data ?? 0.0;
                            double percentage = (dailyCalories > 0) ? (_consumedCalories / dailyCalories) : 0.0;
                            return CircularPercentIndicator(
                              radius: 120,
                              lineWidth: 7,
                              animation: true,
                              curve: Curves.easeInOut,
                              animationDuration: 1000, // in milliseconds
                              circularStrokeCap: CircularStrokeCap.round,
                              backgroundColor:getBackgroundColor(percentage),
                              //  progressColor: Colors.deepPurple,
                              progressColor: percentage >= 1.0 ? Colors.purpleAccent: Colors.deepPurple,
                              percent: percentage.clamp(0.0, 1.0),
                              // percent: _consumedCalories / dailyCalories,
                              startAngle: 170,
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Today Calories',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '$dailyCalories',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Consumed: $_consumedCalories',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    FutureBuilder<int>(
                      future: b_cal(
                          cweight, gweight, height, age, gender, activityLevel),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState
                            .waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error,: ${snapshot.error}');
                        } else {
                          _breakfastCalories = snapshot.data ?? 0;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Breakfast Calories: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$_breakfastCalories',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(height: 30),
                    FutureBuilder<int>(
                      future: l_cal(
                          cweight, gweight, height, age, gender, activityLevel),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState
                            .waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Errorm: ${snapshot.error}');
                        } else {
                          _lunchCalories = snapshot.data ?? 0;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Lunch Calories: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$_lunchCalories',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(height: 30),
                    FutureBuilder<int>(
                      future: s_cal(
                          cweight, gweight, height, age, gender, activityLevel),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState
                            .waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Errorn: ${snapshot.error}');
                        } else {
                          _snackCalories = snapshot.data ?? 0;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Snack Time Calories: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$_snackCalories',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(height: 30),
                    FutureBuilder<int>(
                      future: d_cal(
                          cweight, gweight, height, age, gender, activityLevel),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState
                            .waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Errorb: ${snapshot.error}');
                        } else {
                          _dinnerCalories = snapshot.data ?? 0;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Dinner Calories: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$_dinnerCalories',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSmallSquareBox(
                            Icons.local_dining, 'Breakfast', _breakfastCalories,
                            _takenBreakfastCalories, AppColors.breakfast),
                        _buildSmallSquareBox(
                            Icons.fastfood, 'Lunch', _lunchCalories,
                            _takenLunchCalories, AppColors.lunch),
                        _buildSmallSquareBox(
                            Icons.local_cafe, 'Snack', _snackCalories,
                            _takenSnackCalories, AppColors.snack),
                        _buildSmallSquareBox(
                            Icons.restaurant, 'Dinner', _dinnerCalories,
                            _takenDinnerCalories, AppColors.dinner1),
                      ],
                    ),
                    SizedBox(height: 70),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMealType('Breakfast', context),
                        _buildMealType('Lunch', context),
                        _buildMealType('Snack', context),
                        _buildMealType('Dinner', context),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }


  Widget _buildSmallSquareBox(IconData iconData, String mealType, int calories,
      int takenCalories, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(iconData),
        ),
        SizedBox(height: 4),
        Text(
          mealType,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Kcal: $calories',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        Text(
          'Eaten: $takenCalories',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMealType(String mealType, BuildContext context) {
    DateTime now = DateTime.now();
    bool isButtonEnabled = false;
    String timing = '';
    int calorieRange = 0;

    switch (mealType) {
      case 'Breakfast':
        isButtonEnabled = now.hour >= 7 && now.hour <9;
        timing = '6 AM - 9 AM';
        calorieRange = _breakfastCalories;
        break;
      case 'Lunch':
        isButtonEnabled = now.hour >= 12 && now.hour < 15;
        timing = '12 PM - 3 PM';
        calorieRange = _lunchCalories;
        break;
      case 'Snack':
        isButtonEnabled = now.hour >= 15 && now.hour < 18;
        timing = '3 PM - 6 PM';
        calorieRange = _snackCalories;
        break;
      case 'Dinner':
        isButtonEnabled = now.hour >= 18 && now.hour < 21;
        timing = '6 PM - 9 PM';
        calorieRange = _dinnerCalories;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Row(
        children: [
          Text(
            '$mealType ($timing)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: isButtonEnabled
                ? () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddMealDialog(
                    mealType: mealType,
                    calorieRange: calorieRange,
                    onMealAdded: (int calories) {
                      int totalCalories = 0;
                      if (mealType == 'Breakfast') {
                        totalCalories = _takenBreakfastCalories + calories;
                      } else if (mealType == 'Lunch') {
                        totalCalories = _takenLunchCalories + calories;
                      } else if (mealType == 'Snack') {
                        totalCalories = _takenSnackCalories + calories;
                      } else if (mealType == 'Dinner') {
                        totalCalories = _takenDinnerCalories + calories;
                      }
                      if (totalCalories > calorieRange) {
                        // Show message and prevent adding calories
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Calories exceed the $mealType calorie range!',
                            ),
                          ),
                        );
                      } else {
                        setState(() {
                          if (mealType == 'Breakfast') {
                            _takenBreakfastCalories += calories;
                          } else if (mealType == 'Lunch') {
                            _takenLunchCalories += calories;
                          } else if (mealType == 'Snack') {
                            _takenSnackCalories += calories;
                          } else if (mealType == 'Dinner') {
                            _takenDinnerCalories += calories;
                          }
                          _consumedCalories += calories;
                          _displayedConsumedCalories += calories;
                          _saveCaloriesToSharedPreferences();
                        });
                      }
                    },
                  );
                },
              );
            }
                : () {
              // Show a different message when the button is disabled
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'The $mealType button is only enabled during $timing.',
                  ),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  return isButtonEnabled
                      ? Colors.purple // Background color for enabled state
                      : Colors.grey; // Background color for disabled state
                },
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      10.0), // Square-rounded corners
                ),
              ),
            ),
            child: Text(
              'Add',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Text color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
  class AddMealDialog extends StatefulWidget {
  final Function(int) onMealAdded;
  final String mealType;
  final int calorieRange;

  const AddMealDialog({Key? key, required this.onMealAdded, required this.mealType,  required this.calorieRange,})
      : super(key: key);

  @override
  _AddMealDialogState createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  List<Map<String, dynamic>> _searchResults = [];


  @override
  void initState() {
    super.initState();
    _onSearchChanged();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onSearchChanged() async {
    List<Map<String, dynamic>> results = await _getPredefinedMeals(
        widget.calorieRange);
    setState(() {
      _searchResults = results;
    });
  }


  Future<List<Map<String, dynamic>>> _getPredefinedMeals(
      int calorieRange) async {
    Map<String, List<String>> mealMap = {
      'Breakfast': [
        "1 fried_egg - 100 kcal",
        "1 cupcake - 200 kcal",
        "1 boiled egg - 50 kcal",
        "1 serving oatmeal - 150 kcal",
        "1 toast with peanut butter - 250 kcal",
        "1 bowl congee - 120 kcal",
        "3 pieces dim sum - 180 kcal",
        "1 bowl miso soup - 50 kcal",
        "1 cup yogurt with berries - 200 kcal",
        "1 banana_smoothie - 150 kcal",
        "1 aloo paratha - 300 kcal",
        "1 omelette - 150 kcal",
        "1 cheese omelette - 200 kcal",
        "1 bowl cereal - 180 kcal",
        "2 pancakes - 220 kcal",
        "1 croissant - 230 kcal",
        "1 cup latte - 150 kcal",
        "1 cup black coffee - 5 kcal",
        "1 cup cappuccino - 120 kcal",
        "1 serving kulcha and chola - 350 kcal",
        "1 green smoothie - 100 kcal",
        "1 serving yogurt porridge - 180 kcal",
        "1 serving roti - 72 kcal",
        "1 whitebread_slice - 70 kcal",
        "1 brwonbread_slice - 73 kcal",
        "1 avocado_toast  - 130 kcal",
        "1 egg white omelette - 60 kcal",
        "1 cup_blactea - 2 kcal",
        "1 cup_greentea - 2 kcal",
        "1 cup_herbaltea - 0 kcal",
        "1 Milk_tea - 10 kcal",
        "1 radish_paratha - 150 kcal",
      ],
      'Lunch': [
        "1 burger - 500 kcal",
        "1 bowl soup - 200 kcal",
        "1 serving sushi - 350 kcal",
        "1 serving stir-fried noodles - 400 kcal",
        "1 bowl pho - 350 kcal",
        "1 bento box - 450 kcal",
        "1 serving caesar salad - 350 kcal",
        "1 serving greek salad - 250 kcal",
        "1 serving cobb salad - 400 kcal",
        "1 serving quinoa salad - 300 kcal",
        "1 serving chickpea salad - 350 kcal",
        "1 serving caprese salad - 250 kcal",
        "1 serving tabbouleh - 200 kcal",
        "1 serving pasta salad - 400 kcal",
        "1 serving potato salad - 350 kcal",
        "1 serving pulao - 350 kcal",
        "1 serving biryani - 450 kcal",
        "1 roti - 100 kcal",
        "1 bowl boiled rice - 200 kcal",
        "1 bowl fried rice - 400 kcal",
        "1 serving dal (lentils) - 150 kcal",
        "1 serving chana masala - 250 kcal",
        "1 serving rajma (kidney beans) - 250 kcal",
        "1 serving aloo gobi (potato and cauliflower) - 200 kcal",
        "1 serving palak paneer (spinach and paneer) - 300 kcal",
        "1 serving baingan bharta (eggplant) - 150 kcal",
        "1 serving bhindi masala (okra) - 180 kcal",
        "1 fried_chickenSlice - 150 kcal",
        "1 serving_codfish - 90 kcal ",
        "1 beef_meatball - 60 kcal ",
        "1 chicken_meatball - 60 kcal",
        "1 pork_meatball - 35 kcal",
        "1 cucumber_slice - 16 kcal"
      ],
      'Snack': [
        "1 apple - 80 kcal",
        "1 serving chips - 150 kcal",
        "1 cookie - 100 kcal",
        "1 orange - 60 kcal",
        "1 banana - 90 kcal",
        "1 pear - 100 kcal",
        "1 bowl grapes - 70 kcal",
        "1 bowl strawberries - 50 kcal",
        "1 bowl mixed fruit salad - 150 kcal",
        "1 bowl tomato soup - 100 kcal",
        "1 bowl chicken soup - 150 kcal",
        "1 bowl vegetable soup - 80 kcal",
        "1 bowl lentil soup - 120 kcal",
        "1 strawberry smoothie - 150 kcal",
        "1 banana smoothie - 180 kcal",
        "1 mango smoothie - 160 kcal",
        "1 chocolate shake - 200 kcal",
        "1 vanilla shake - 180 kcal",
        "1 strawberry shake - 160 kcal",
        "1 chocolate cupcake - 200 kcal",
        "1 vanilla cupcake - 180 kcal",
        "1 serving chocolate cake - 250 kcal",
        "1 serving vanilla cake - 220 kcal",
        "1 serving gulab jamun - 150 kcal",
        "1 serving jalebi - 200 kcal",
        "1 serving rasgulla - 180 kcal",
        "1 serving kheer - 250 kcal",
        "1 serving khajr kheer - 250 kcal",
        "1 serving soji halwa - 300 kcal",
        "1 serving khus khus halwa - 250 kcal",
        "1 serving atta halwa - 300 kcal",
        "1 serving gajar halwa - 250 kcal",
        "1 serving chana dal halwa - 250 kcal",
        "1 serving walnut halwa - 300 kcal",
        "1 serving dates halwa - 250 kcal",
        "1 serving badam halwa - 300 kcal",
        "1 serving laddu - 180 kcal",
        "1 serving barfi - 200 kcal",
        "1 serving mixed trail snack - 150 kcal",
        "1 serving chikki - 200 kcal",
        "1 serving dried fruit and nut mix - 180 kcal"
      ],
      'Dinner': [
        "1 serving chicken - 300 kcal",
        "2 slices pizza - 400 kcal",
        "1 palletter_whiteRice - 250 kcal",
        "1 palletter_vegetablesRice - 250 kcal",
        "1 serving kung pao chicken - 350 kcal",
        "1 serving pad thai - 450 kcal",
        "1 bowl fried rice - 400 kcal",
        "1 serving beef and broccoli - 300 kcal",
        "1 serving grilled salmon - 350 kcal",
        "1 serving veggie stir-fry - 250 kcal",
        "1 serving vegetable biryani - 400 kcal",
        "1 serving mutton biryani - 500 kcal",
        "1 serving chicken biryani - 450 kcal",
        "1 serving pulao - 350 kcal",
        "1 serving boiled rice - 200 kcal",
        "1 serving beef steak - 400 kcal",
        "1 serving mutton curry - 500 kcal",
        "1 serving salad - 300 kcal",
        "1 serving lentil soup - 200 kcal",
        "1 serving chana dal - 250 kcal",
        "1 serving rajma (kidney beans) - 250 kcal",
        "1 serving aloo gobi (potato and cauliflower) - 200 kcal",
        "1 serving palak paneer (spinach and paneer) - 300 kcal",
        "1 serving baingan bharta (eggplant) - 150 kcal",
        "1 serving bhindi masala (okra) - 180 kcal",
        "1 serving sushi - 350 kcal",
      ]
    };

    // Example disease impact on meals
    Map<String, List<String>> diseaseImpact = {
      'Diabetes': [
        '1 cupcake - 200 kcal',
        '1 burger - 500 kcal',
        '1 cookie - 100 kcal',
        '2 slices pizza - 400 kcal',
        '3 pieces dim sum - 180 kcal',
        '1 serving sushi - 350 kcal',
        '2 spring rolls - 120 kcal',
        '1 serving kung pao chicken - 350 kcal',
        '1 serving pad thai - 450 kcal',
        '1 croissant - 230 kcal',
        '1 cup latte - 150 kcal',
        '1 cup cappuccino - 120 kcal',
        '2 pancakes - 220 kcal',
        '1 cheese omelette - 200 kcal',
        '1 serving kulcha and chola - 350 kcal',
        '1 cup yogurt with berries - 200 kcal',
        '1 serving biryani - 450 kcal',
        '1 serving fried rice - 400 kcal',
        '1 roti - 100 kcal',
        '1 serving potato salad - 350 kcal',
        '1 serving pasta salad - 400 kcal'
      ],
      'Hypertension': [
        '1 burger - 500 kcal',
        '1 serving chips - 150 kcal',
        '3 pieces dim sum - 180 kcal',
        '1 bowl miso soup - 50 kcal',
        '1 serving sushi - 350 kcal',
        '2 spring rolls - 120 kcal',
        '1 serving kung pao chicken - 350 kcal',
        '1 bowl fried rice - 400 kcal',
        '1 aloo paratha - 300 kcal',
        '1 cheese omelette - 200 kcal',
        '1 cup latte - 150 kcal',
        '1 cup cappuccino - 120 kcal',
        '1 serving kulcha and chola - 350 kcal',
        '2 pancakes - 220 kcal',
        '1 serving pulao - 350 kcal',
        '1 serving biryani - 450 kcal',
        '1 roti - 100 kcal',
        '1 serving potato salad - 350 kcal',
        '1 serving pasta salad - 400 kcal'
      ],
      'Heart Disease': [
        '1 burger - 500 kcal',
        '2 slices pizza - 400 kcal',
        '3 pieces dim sum - 180 kcal',
        '1 serving stir-fried noodles - 400 kcal',
        '1 serving sushi - 350 kcal',
        '1 serving pad thai - 450 kcal',
        '1 bowl fried rice - 400 kcal',
        '1 serving beef and broccoli - 300 kcal',
        '1 croissant - 230 kcal',
        '2 pancakes - 220 kcal',
        '1 cheese omelette - 200 kcal',
        '1 serving kulcha and chola - 350 kcal',
        '1 cup yogurt with berries - 200 kcal',
        '1 serving biryani - 450 kcal',
        '1 serving fried rice - 400 kcal',
        '1 serving potato salad - 350 kcal',
        '1 serving pasta salad - 400 kcal'
      ]
    };
    Map<String, List<String>> allergyImpact = {
      'Egg': [
        "1 fried_egg - 100 kcal",
        "1 boiled egg - 50 kcal",
        "1 serving oatmeal - 150 kcal",
        "1 omelette - 150 kcal",
        "1 cheese omelette - 200 kcal",
        // Add other meals impacting egg allergy
      ],
      'Milk': [ "1 Milk_tea - 10 kcal" ,"1 chocolate shake - 200 kcal",
        "1 vanilla shake - 180 kcal",
        "1 strawberry shake - 160 kcal",],
      'Diary': [
        "1 cup yogurt with berries - 200 kcal",
        "1 serving yogurt porridge - 180 kcal",
        "1 strawberry smoothie - 150 kcal",
        "1 banana smoothie - 180 kcal",
        "1 mango smoothie - 160 kcal",
        "1 toast with peanut butter - 250 kcal",
      ],
      'Wheat':[ "1 roti - 100 kcal", "1 serving khus khus halwa - 250 kcal",
        "1 serving atta halwa - 300 kcal",],
      'Soy':[],
      'Fish':["1 serving sushi - 350 kcal"],
      'Tree Nuts':["1 serving walnut halwa - 300 kcal","1 serving badam halwa - 300 kcal",],
      'Peanuts':[ "1 serving badam halwa - 300 kcal","1 serving walnut halwa - 300 kcal", "1 serving mixed trail snack - 150 kcal", "1 serving dried fruit and nut mix - 180 kcal"],
      'Shellfish':["1 serving sushi - 350 kcal",],



      // Define other allergies and their impacting meals
    };
    List<Map<String, dynamic>> generateWeeklyPlan(List<String> userDiseases, List<String> userAllergies) {
      List<Map<String, dynamic>> weeklyPlan = [];
      List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      Random random = Random();

      daysOfWeek.forEach((day) {
        Map<String, dynamic> dailyPlan = {'day': day, 'meals': {}};
        print('Generating plan for $day');

        ['Breakfast', 'Lunch', 'Snack', 'Dinner'].forEach((mealType) {
          List<String> meals = mealMap[mealType]!;
          List<Map<String, dynamic>> filteredMeals = [];

          meals.forEach((meal) {
            int calories = int.parse(meal.split(' - ')[1].trim().split(' ')[0]);
            if (calories <= calorieRange) { // Adjust calorieRange according to your needs
              int impact = 0;
              bool isAllergic = false;

              if (userDiseases.isNotEmpty) {
                userDiseases.forEach((disease) {
                  if (diseaseImpact[disease]?.contains(meal) ?? false) {
                    impact++;
                  }
                });
              }

              if (userAllergies.isNotEmpty) {
                userAllergies.forEach((allergy) {
                  if (allergyImpact[allergy] != null && allergyImpact[allergy]!.contains(meal)) {
                    impact++;
                    isAllergic = true; // Set flag if meal contains allergen
                  }
                });
              }

              if (!isAllergic) { // Only add non-allergic meals
                filteredMeals.add({'meal': meal, 'impact': impact, 'calories': calories});
                print('Meal: $meal, Impact: $impact');
              }
            }
          });

          if (userDiseases.isNotEmpty || userAllergies.isNotEmpty) {
            filteredMeals.sort((a, b) => a['impact'].compareTo(b['impact']));
          }

          print('Filtered meals for $mealType on $day: $filteredMeals'); // Print statement for filtered meals

          List<Map<String, dynamic>> selectedMeals = [];
          int totalCalories = 0;

          for (int i = 0; i < filteredMeals.length && totalCalories <= calorieRange; i++) { // Adjust calorieRange here too
            String selectedMeal = filteredMeals[i]['meal'];
            int mealCalories = filteredMeals[i]['calories'];
            if (totalCalories + mealCalories <=calorieRange ) { // Adjust calorieRange here too
              selectedMeals.add({'meal': selectedMeal, 'quantity': 1});
              totalCalories += mealCalories;
            }
          }

          dailyPlan['meals'][mealType] = {
            'selectedMeals': selectedMeals,
            'totalCalories': totalCalories
          };

          print('Added $mealType meals - Total Calories: $totalCalories'); // Debug statement for total calories

        });

        weeklyPlan.add(dailyPlan);
      });

      print('Generated weekly plan: $weeklyPlan');
      return weeklyPlan;
    }
    List<Map<String, dynamic>> getCurrentMealsFromWeeklyPlan(
        List<Map<String, dynamic>> weeklyPlan) {
      DateTime now = DateTime.now();
      String currentDay = [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday'
      ][now.weekday % 7];
      int hour = now.hour;
      String currentMealType = '';

      if (hour >= 7 && hour <12) {
        currentMealType = 'Breakfast';
      } else if (hour >= 12 && hour < 15) {
        currentMealType = 'Lunch';
      } else if (hour >= 15 && hour < 18) {
        currentMealType = 'Snack';
      } else if (hour >= 18 && hour < 21) {
        currentMealType = 'Dinner';
      }

      var todayPlan = weeklyPlan.firstWhere(
              (dayPlan) => dayPlan['day'] == currentDay,
          orElse: () => {'day': currentDay, 'meals': {}}
      );

      List<Map<String,
          dynamic>> mealsList = todayPlan['meals'][currentMealType]?['selectedMeals'] ??
          [];

      return mealsList;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> userDiseases = prefs.getStringList('diseases') ?? [];
      List<String>userAllergies = prefs.getStringList('allergies') ?? [];
      print('User diseases: $userDiseases');
      print('User allergies: $userAllergies');

      List<Map<String, dynamic>> weeklyPlan = generateWeeklyPlan(userDiseases,userAllergies);

      List<Map<String, dynamic>> currentMeals = getCurrentMealsFromWeeklyPlan(
          weeklyPlan);
      if (currentMeals.isNotEmpty) {
        print('Current meals: $currentMeals');
        return currentMeals;
      }

      return [];
    } catch (error) {
      print('Error retrieving user diseases: $error');
      return [];
    }
  }


  void _incrementQuantity(int index) {
    setState(() {
      _searchResults[index]['quantity']++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (_searchResults[index]['quantity'] > 1) {
        _searchResults[index]['quantity']--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.9,
        height: MediaQuery
            .of(context)
            .size
            .height * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Text(
                  'Select Meal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 40),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_searchResults.length, (index) {
                    String result = _searchResults[index]['meal'];
                    int quantity = _searchResults[index]['quantity'];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(result, style: TextStyle(fontSize: 11),),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () => _decrementQuantity(index),
                            ),
                            Text('$quantity'), // Display quantity
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => _incrementQuantity(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle),
                              onPressed: () {
                                int calories = int.parse(
                                    result.split(' - ')[1].split(' ')[0]);
                                widget.onMealAdded(calories *
                                    quantity); // Multiply calories by quantity
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          int calories = int.parse(
                              result.split(' - ')[1].split(' ')[0]);
                          widget.onMealAdded(calories *
                              quantity); // Multiply calories by quantity
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


