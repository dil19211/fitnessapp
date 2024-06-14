import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';


import 'color.dart';
import 'database_handler.dart';
import 'gainmealcaculation.dart';

class pmeal extends StatefulWidget {
  @override
  _MealState createState() => _MealState();
}

class _MealState extends State<pmeal> {
  int _breakfastCalories = 400;
  int _lunchCalories = 800;
  int _snackCalories = 600;
  int _dinnerCalories =1700;

  int _consumedCalories = 0;
  int _displayedConsumedCalories = 0;
  int _takenBreakfastCalories = 0;
  int _takenLunchCalories = 0;
  int _takenSnackCalories = 0;
  int _takenDinnerCalories = 0;


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
          prefs.setBool('hasShownDiseaseDialog', true); // Set flag to indicate the dialog has been shown
        });
      }
    });
  }
  void _showDiseaseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        List<String> selectedDiseases = []; // To store selected diseases
        final List<String> allDiseases = ['Diabetes', 'Hypertension', 'Heart Disease'];

        return AlertDialog(
          title: Text('Select Your Diseases if you have any'),
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
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setStringList('diseases', selectedDiseases);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
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

  void _saveCaloriesToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('consumed_calories', _consumedCalories);
    prefs.setInt('taken_breakfast_calories', _takenBreakfastCalories);
    prefs.setInt('taken_lunch_calories', _takenLunchCalories);
    prefs.setInt('taken_snack_calories', _takenSnackCalories);
    prefs.setInt('taken_dinner_calories', _takenDinnerCalories);
    prefs.setInt('displayed_consumed_calories', _displayedConsumedCalories);
  }

  @override
  Widget build(BuildContext context) {
    _consumedCalories = _takenBreakfastCalories + _takenLunchCalories + _takenSnackCalories + _takenDinnerCalories;

    final String email= ModalRoute.of(context)?.settings.arguments as String;
    Future<Database> openDB() async{
      Database _database=await DatabaseHandler().openDB();
      if(_database!=null)
        return _database;
      else{
        print('null db');
        return _database;
      }
      //print('open fun is called in mwg');
    }
    Future<int> getAgeFromEmail(String email) async {
      Database _database=await openDB();
      var age;
      if( _database!=null){
        List<Map<String, dynamic>> result = await _database.query(
          'WEIGHTGAINUSER',
          columns: ['age'],
          where: 'email = ?',
          whereArgs: [email],
        );

        if (result.isNotEmpty) {
          age = result[0]['age'];
        }
        await _database.close();

      }
      return age;

    }// add ? with int
    Future<int> getHeightFromEmail(String email) async {
      Database _database=await openDB();
      var height;
      if (_database != null) {

        List<Map<String, dynamic>> result = await _database.query(
          'WEIGHTGAINUSER',
          columns: ['height'],
          where: 'email = ?',
          whereArgs: [email],
        );


        if (result.isNotEmpty) {
          height = result[0]['height'];
        }
        await _database.close();
      }
      return height;
    }
    Future<int> get_cweight_FromEmail(String email) async {
      Database _database=await openDB();
      var cweight;
      if (_database != null) {
        List<Map<String, dynamic>> result = await _database.query(
          'WEIGHTGAINUSER',
          columns: ['cweight'],
          where: 'email = ?',
          whereArgs: [email],
        );

        if (result.isNotEmpty) {
          cweight = result[0]['cweight'];
        }

        await _database.close();

      }
      return cweight;
    }
    Future<int> get_gweight_FromEmail(String email) async {
      Database _database=await openDB();
      var gweight;
      if (_database != null) {
        List<Map<String, dynamic>> result = await _database.query(
          'WEIGHTGAINUSER',
          columns: ['gweight'],
          where: 'email = ?',
          whereArgs: [email],
        );

        if (result.isNotEmpty) {
          gweight = result[0]['gweight'];
        }

        await _database.close();
      }
      return gweight;
    }
    Future<String> getGenderFromEmail(String email) async {
      Database _database=await openDB();
      String gender='Male';
      if (_database != null) {
        List<Map<String, dynamic>> result = await _database.query(
          'WEIGHTGAINUSER',
          columns: ['gender'],
          where: 'email = ?',
          whereArgs: [email],
        );

        if (result.isNotEmpty) {
          gender = result[0]['gender'];
        }

        await _database.close();
      }
      return gender;
    }
    Future<String> getActivityLevelFromEmail(String email) async {
      Database _database=await openDB();
      String activity_level='Sedentary';
      if (_database != null) {
        List<Map<String, dynamic>> result = await _database.query(
          'WEIGHTGAINUSER',
          columns: ['activity_level'],
          where: 'email = ?',
          whereArgs: [email],
        );

        if (result.isNotEmpty) {
          activity_level = result[0]['activity_level'];
        }

        await _database.close();
      }
      return activity_level;
    }

    Future<int> fage = getAgeFromEmail(email) ;
    int age=30;
    fage.then((value) {
      if (value != null) {
        age = value.toInt();
        print(age);
      }
    });
    Future<int> fheight = getHeightFromEmail(email) ;
    int height=6;
    fheight.then((value) {
      if (value != null) {
        height = value.toInt();
        print(height);
      }
    });
    Future<int> fcweight = get_cweight_FromEmail(email);
    int cweight=50;
    fcweight.then((value) {
      if (value != null) {
        cweight = value.toInt();
        print(cweight);
      }
    });
    Future<int> fgweight = get_gweight_FromEmail(email);
    int gweight=60;
    fgweight.then((value) {
      if (value != null) {
        gweight = value.toInt();
        print(gweight);
      }
    });
    Future<String> fgender= getGenderFromEmail(email);
    String gender='Male';
    fgender.then((value) {
      if (value != null) {
        gender = value.toString();
        print(gender);
      }
    });
    Future<String> factivity_level= getActivityLevelFromEmail(email);
    String activity_level='Sedentary';
    factivity_level.then((value) {
      if (value != null) {
        activity_level = value.toString();
        print(activity_level);
      }
    });
    Future<int> daily_cal() async{
      int monthsToReach = 2;
      WeightGainCalculator wg_daily_cal=new WeightGainCalculator();
      int daily_calories = await wg_daily_cal.calculateDailyCaloriesNeededToGainWeight
        (cweight, gweight , height ,age,gender,activity_level) ;
      return daily_calories;
    }
    Future<int> total_cal() async{
      int monthsToReach = 2;
      WeightGainCalculator wg_total_cal=new WeightGainCalculator();
      int total_calories = await wg_total_cal.calculateTotalCaloriesToGainWeight(cweight ,gweight,height ,age ,gender,activity_level);
      return total_calories;
    }
    Future<int> b_cal() async{
      int monthsToReach = 2;
      WeightGainCalculator wg_b_cal=new WeightGainCalculator();
      int b_calories = await wg_b_cal.calculateBreakfastCaloriesToGoal(cweight ,gweight,height ,age ,gender,activity_level);
      return b_calories;
    }
    Future<int> l_cal() async{
      int monthsToReach = 2;
      WeightGainCalculator wg_l_cal=new WeightGainCalculator();
      int l_calories = await wg_l_cal.calculatelunchfastCaloriesToGoal(cweight ,gweight,height ,age ,gender,activity_level);
      return l_calories;
    }
    Future<int> s_cal() async{
      int monthsToReach = 2;
      WeightGainCalculator wg_s_cal=new WeightGainCalculator();
      int s_calories = await wg_s_cal.calculatesnackfastCaloriesToGoal(cweight ,gweight,height ,age ,gender,activity_level);
      return s_calories;
    }
    Future<int> d_cal() async{
      int monthsToReach = 2;
      WeightGainCalculator wg_d_cal=new WeightGainCalculator();
      int d_calories = await wg_d_cal.calculatedinnerfastCaloriesToGoal(cweight ,gweight,height ,age ,gender,activity_level);
      return d_calories;
    }
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
      body: SingleChildScrollView(
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
                      future: total_cal(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
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
                  future: daily_cal(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                        percent: 0.8,
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
                future: b_cal(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$_breakfastCalories',
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
              SizedBox(height: 30),
              FutureBuilder<int>(
                future: l_cal(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$_lunchCalories',
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
              SizedBox(height: 30),
              FutureBuilder<int>(
                future: s_cal(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$_snackCalories',
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
              SizedBox(height: 30),
              FutureBuilder<int>(
                future: d_cal(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$_dinnerCalories',
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
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSmallSquareBox(Icons.local_dining, 'Breakfast',
                      _breakfastCalories, _takenBreakfastCalories,
                      AppColors.breakfast),
                  _buildSmallSquareBox(Icons.fastfood, 'Lunch', _lunchCalories,
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
        SizedBox(height: 8),
        Text(
          mealType,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Calories: $calories',
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
                    return Colors
                        .deepPurple; // Background color for disabled state
                  }
                  return Colors.purple; // Background color for enabled state
                },
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
    List<Map<String, dynamic>> results = await _getPredefinedMeals(widget.calorieRange);
    setState(() {
      _searchResults = results;
    });
  }


  Future<List<Map<String, dynamic>>> _getPredefinedMeals(int calorieRange) async {
    Map<String, List<String>> mealMap = {
      'Breakfast': ["egg - 100 kcal", "cupcake - 200 kcal", "boiled egg - 50 kcal", "oatmeal - 150 kcal", "toast with peanut butter - 250 kcal"],
      'Lunch': ["salad - 300 kcal", "burger - 500 kcal", "soup - 200 kcal"],
      'Snack': ["apple - 80 kcal", "chips - 150 kcal", "cookie - 100 kcal"],
      'Dinner': ["chicken - 300 kcal", "pizza - 400 kcal", "rice - 250 kcal"]
    };

    // Example disease impact on meals
    Map<String, List<String>> diseaseImpact = {
      'Diabetes': [
        'cupcake - 200 kcal',
        'burger - 500 kcal',
        'cookie - 100 kcal',
        'pizza - 400 kcal'
      ],
      'Hypertension': ['burger - 500 kcal', 'chips - 150 kcal'],
      'Heart Disease': ['burger - 500 kcal', 'pizza - 400 kcal']
    };

    // Determine the current meal type based on the current hour
    DateTime now = DateTime.now();
    int hour = now.hour;

    String currentMealType = '';
    if (hour >= 4 && hour < 9) {
      currentMealType = 'Breakfast';
    } else if (hour >= 12 && hour < 15) {
      currentMealType = 'Lunch';
    } else if (hour >= 15 && hour < 18) {
      currentMealType = 'Snack';
    } else if (hour >= 18 && hour < 21) {
      currentMealType = 'Dinner';
    }

    // Get user diseases from shared preferences
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> userDiseases = prefs.getStringList('diseases') ?? [];
      print("$userDiseases");

      // Initialize variables to track the best meal candidate
      String? bestMeal;
      int minImpact = mealMap[currentMealType]!.length; // Initialize with max impact

      List<Map<String, dynamic>> filteredMeals = [];

      // Iterate over meals for the current meal type
      mealMap[currentMealType]!.forEach((meal) {
        int calories = int.parse(meal.split(' - ')[1].trim().split(' ')[0]);

        // Check if the meal is within the calorie range
        if (calories <= calorieRange) {
          // Count the impact of diseases on the meal
          int impact = 0;
          userDiseases.forEach((disease) {
            if (diseaseImpact[disease]?.contains(meal) == true) {
              impact++;
            }
          });

          // If the meal has lower impact, update the best meal candidate
          if (impact < minImpact) {
            bestMeal = meal;
            minImpact = impact;
            filteredMeals.clear(); // Clear the list since we found a better meal
            filteredMeals.add({'meal': bestMeal, 'quantity': 1}); // Add the new best meal
          } else if (impact == minImpact) {
            filteredMeals.add({'meal': meal, 'quantity': 1}); // Add meals with equal impact
          }
        }
      });

      return filteredMeals;
    } catch (error) {
      print('Error retrieving user diseases: $error');
      return []; // Return an empty list in case of an error
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
                        title: Text(result),
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