import 'dart:async';
import 'package:fitnessapp/user_repo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'color.dart';
import 'database_handler.dart';
import 'gainmealcaculation.dart';
import 'notification.dart';

class meal extends StatefulWidget {
  @override
  _MealState createState() => _MealState();
}

class _MealState extends State<meal> {
  // Inside meal class
  final GlobalKey<_MealState> mealStateKey = GlobalKey<_MealState>();


  int _breakfastCalories = 500;
  int _lunchCalories = 1000;
  int _snackCalories = 600;
  int _dinnerCalories = 1700;

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
    _databaseFuture = openDB();
    loadUserData();

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

  void _saveCaloriesToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('consumed_calories', _consumedCalories);
    prefs.setInt('taken_breakfast_calories', _takenBreakfastCalories);
    prefs.setInt('taken_lunch_calories', _takenLunchCalories);
    prefs.setInt('taken_snack_calories', _takenSnackCalories);
    prefs.setInt('taken_dinner_calories', _takenDinnerCalories);
    prefs.setInt('displayed_consumed_calories', _displayedConsumedCalories);
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
        'WEIGHTGAINUSER',
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
        'WEIGHTGAINUSER',
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
        'WEIGHTGAINUSER',
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
        'WEIGHTGAINUSER',
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
        'WEIGHTGAINUSER',
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
        'WEIGHTGAINUSER',
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

  Future<int> daily_cal(int cweight, int gweight, int height, int age, String gender, String activityLevel) async {
    Map<String, dynamic> userData = await loadUserData();

    int cweight = userData['cweight'];
    int gweight = userData['gweight'];
    int height = userData['height'];
    int age = userData['age'];
    String gender = userData['gender'];
    String activityLevel = userData['activityLevel'];
    WeightGainCalculator wg_daily_cal = WeightGainCalculator();

    return await wg_daily_cal.calculateDailyCaloriesNeededToGainWeight(
        cweight, gweight, height, age, gender, activityLevel);
  }

  Future<int> total_cal(int cweight, int gweight, int height, int age, String gender, String activityLevel) async {
    Map<String, dynamic> userData = await loadUserData();

    int cweight = userData['cweight'];
    int gweight = userData['gweight'];
    int height = userData['height'];
    int age = userData['age'];
    String gender = userData['gender'];
    String activityLevel = userData['activityLevel'];
    WeightGainCalculator wg_total_cal = WeightGainCalculator();

    return await wg_total_cal.calculateTotalCaloriesToGainWeight(
        cweight, gweight, height, age, gender, activityLevel);
  }

  Future<int> b_cal(int cweight, int gweight, int height, int age, String gender, String activityLevel) async {
    Map<String, dynamic> userData = await loadUserData();

    int cweight = userData['cweight'];
    int gweight = userData['gweight'];
    int height = userData['height'];
    int age = userData['age'];
    String gender = userData['gender'];
    String activityLevel = userData['activityLevel'];
    WeightGainCalculator wg_b_cal = WeightGainCalculator();

    return await wg_b_cal.calculateBreakfastCaloriesToGoal(
        cweight, gweight, height, age, gender, activityLevel);
  }

  Future<int> l_cal(int cweight, int gweight, int height, int age, String gender, String activityLevel) async {
    Map<String, dynamic> userData = await loadUserData();

    int cweight = userData['cweight'];
    int gweight = userData['gweight'];
    int height = userData['height'];
    int age = userData['age'];
    String gender = userData['gender'];
    String activityLevel = userData['activityLevel'];
    WeightGainCalculator wg_l_cal = WeightGainCalculator();

    return await wg_l_cal.calculatelunchfastCaloriesToGoal(
        cweight, gweight, height, age, gender, activityLevel);
  }

  Future<int> s_cal(int cweight, int gweight, int height, int age, String gender, String activityLevel) async {
    Map<String, dynamic> userData = await loadUserData();

    int cweight = userData['cweight'];
    int gweight = userData['gweight'];
    int height = userData['height'];
    int age = userData['age'];
    String gender = userData['gender'];
    String activityLevel = userData['activityLevel'];
    WeightGainCalculator wg_s_cal = WeightGainCalculator();

    return await wg_s_cal.calculatesnackfastCaloriesToGoal(
        cweight, gweight, height, age, gender, activityLevel);
  }

  Future<int> d_cal(int cweight, int gweight, int height, int age, String gender, String activityLevel) async {
    Map<String, dynamic> userData = await loadUserData();

    int cweight = userData['cweight'];
    int gweight = userData['gweight'];
    int height = userData['height'];
    int age = userData['age'];
    String gender = userData['gender'];
    String activityLevel = userData['activityLevel'];
    WeightGainCalculator wg_d_cal = WeightGainCalculator();

    return await wg_d_cal.calculatedinnerfastCaloriesToGoal(
        cweight, gweight, height, age, gender, activityLevel);
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final String email = ModalRoute.of(context)?.settings.arguments as String;
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

          var height = await getHeightFromEmail(email) ?? initialUserData['height'];
          print('Height: $height');

          var cweight = await getCWeightFromEmail(email) ?? initialUserData['cweight'];
          print('Current Weight: $cweight');

          var gweight = await getGWeightFromEmail(email) ?? initialUserData['gweight'];
          print('Goal Weight: $gweight');

          var gender = await getGenderFromEmail(email) ?? initialUserData['gender'];
          print('Gender: $gender');

          var activityLevel = await getActivityLevelFromEmail(email) ?? initialUserData['activityLevel'];
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
              //scrollDirection: Axis.horizontal,
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
                                return Text("Error: ${snapshot.error}");
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
                            return Text('Error: ${snapshot.error}');
                          } else {
                            num dailyCalories = snapshot.data ?? 0.0;
                            return CircularPercentIndicator(
                              radius: 100,
                              lineWidth: 10,
                              circularStrokeCap: CircularStrokeCap.round,
                              backgroundColor: Colors.transparent,
                              progressColor: Colors.deepPurple,
                              percent: _consumedCalories / dailyCalories,
                              startAngle: 218,
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
                          return Text('Error: ${snapshot.error}');
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
                          return Text('Error: ${snapshot.error}');
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
                          return Text('Error: ${snapshot.error}');
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
                          return Text('Error: ${snapshot.error}');
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
                    SingleChildScrollView(
                     // scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSmallSquareBox(Icons.local_dining, 'Breakfast',
                              _breakfastCalories, _takenBreakfastCalories,
                              AppColors.breakfast),
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
        }
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
        SizedBox(height: 12),
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
        isButtonEnabled = now.hour >= 6 && now.hour < 12;
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
        isButtonEnabled = now.hour >= 18 && now.hour < 23;
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
                : null,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.disabled)) {
                      // Square rounded corners
                    return Colors
                        .deepPurple; // Background color for disabled state
                  }
                  return Colors.purple; // Background color for enabled state
                },
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Square-rounded corners
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

  const AddMealDialog({Key? key, required this.onMealAdded, required this.mealType, required int calorieRange})
      : super(key: key);

  @override
  _AddMealDialogState createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  List<Map<String, dynamic>> _searchResults = [];
  TextEditingController _searchController = TextEditingController();

  Future<Database> openDB() async {
    Database _database = await DatabaseHandler().openDB();
    return _database;
  }

  Future<List<Map<String, dynamic>>> getmeal(String query) async {
    Database _database = await openDB();
    UserRepo userRepo = UserRepo();
    await userRepo.createTable_wg_meal(_database);
    await userRepo.insert(_database);
    List<Map<String, dynamic>> meals = await userRepo.get_wg_meal(_database);
    List<Map<String, dynamic>> filteredMeals = meals
        .where((meal) =>
    meal['item'] != null &&
        meal['item'].toString().toLowerCase().contains(query.toLowerCase()))
        .map((meal) =>
    {
      'meal': '${meal['item'] ?? 'Unknown'} - ${meal['calories'] ??
          0} kcal',
      'quantity': 0
    })
        .toList();
    return filteredMeals;


  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();

  }

  void _onSearchChanged() async {
    String query = _searchController.text;
    List<Map<String, dynamic>> results = await getmeal(query);
    setState(() {
      _searchResults = results;
    });
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
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
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
                  'Search:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 40),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
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
                        title: Text(result,style: TextStyle(fontSize: 9),),
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
                                int calories = int.parse(result.split(' - ')[1].split(' ')[0]);
                                widget.onMealAdded(calories * quantity); // Multiply calories by quantity
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          int calories = int.parse(result.split(' - ')[1].split(' ')[0]);
                          widget.onMealAdded(calories * quantity); // Multiply calories by quantity
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
