import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Water extends StatefulWidget {
  @override
  _WaterState createState() => _WaterState();
}

class _WaterState extends State<Water> {
  DateTime _selectedDate = DateTime.now();
  int _waterCount = 0;
  int _totalWaterCount = 0; // Track total water count
  final int volumePerGlass = 240; // Volume of one glass in milliliters
  int dailyGoal = 8; // Daily goal of glasses
  List<String> drankWaterLogs = [];
  String message = '';

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    _loadWaterCount();
  }
  late SharedPreferences _prefs;

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    bool isFirstTime = _prefs!.getBool('isFirstTime') ?? true;
    if (isFirstTime) {
      // If it's the first time, show the guide dialog
      _showGuideDialog();
    }
  }
  Future<void> _showGuideDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Welcome to GritFit Health!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Here are some tips on how to use the app:'),
              SizedBox(height: 10),
              Text('1. Keep track of your daily water intake by adding glasses using the + button and subtracting them using the - button.'),
              Text('2. Set your daily water intake goal by tapping on the current count and entering a new goal.'),
              Text('3. You can see your progress towards your daily goal in the progress bar at the bottom of the screen.'),
              Text('4. Each day, the default daily water intake goal is set to 8 glasses, but you can adjust it according to your preference.'),
              Text('5. Stay hydrated and healthy!'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _prefs.setBool('isFirstTime', false);
              },
              child: Text('Got it!'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _loadWaterCount() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStoredDate = prefs.getString('lastStoredDate') ?? '';
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastStoredDate != currentDate) {
      // It's a new day, reset water count and total water count to zero, and reset the daily goal
      setState(() {
        _waterCount = 0;
        _totalWaterCount = 0;
         dailyGoal = 8; // Reset daily goal to default value
        prefs.setString('lastStoredDate', currentDate);
        _saveWaterCount();
      });
    } else {
      setState(() {
        _waterCount = prefs.getInt('waterCount') ?? 0;
        _totalWaterCount = prefs.getInt('totalWaterCount') ?? 0;
        drankWaterLogs = prefs.getStringList('drankWaterLogs') ?? [];
        dailyGoal = prefs.getInt('dailyGoal') ?? 8; // Load daily goal from preferences
        _setMessage();
      });
    }
  }


  Future<void> _saveWaterCount() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('waterCount', _waterCount);
    prefs.setInt('totalWaterCount', _totalWaterCount);
    prefs.setStringList('drankWaterLogs', drankWaterLogs);
    prefs.setInt('dailyGoal', dailyGoal); // Save daily goal to preferences
  }

  void _addToTotalCount(int count) {
    setState(() {
      _totalWaterCount += count;
      if (_totalWaterCount < 0) {
        _totalWaterCount = 0;
      }
    });
  }

  void _addToDrankWaterLogs(int count) {
    drankWaterLogs.add(DateFormat('EEEE, dd MMM yyyy').format(_selectedDate));
  }

  void _setMessage() {
    if (_waterCount < 2) {
      message = "You've only had $_waterCount glass${_waterCount == 1
          ? ''
          : 'es'}. Drink more to stay hydrated!";
    } else if (_waterCount >= 2 && _waterCount < dailyGoal) {
      message = "You've had $_waterCount glasses. Keep going!";
    } else if (_waterCount == dailyGoal) {
      message =
      "Congratulations! You've reached your daily goal of $_waterCount glasses.";
    } else {
      message =
      "Be mindful of excessive water intake. You've had $_waterCount glasses today.";
    }
  }


  void _showDailyGoalDialog() async {
    final prefs = await SharedPreferences.getInstance();
    int currentGoal = prefs.getInt('dailyGoal') ?? 8;

    TextEditingController goalController = TextEditingController(text: currentGoal.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Daily Goal'),
          content: SingleChildScrollView(
            child: TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter your daily goal (min 6)'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  int newGoal = int.tryParse(goalController.text) ?? 8;
                  if (newGoal >= 8 && newGoal <= 12) {
                    dailyGoal = newGoal;
                    prefs.setInt('dailyGoal', dailyGoal); // Save the new daily goal
                    _saveWaterCount();
                  } else {

                    // Show a warning if the goal is set below the minimum
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Daily water goal must be between 8 and 12 glasses according to Doctor recommendation.')),
                    );
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    setState(() {
      dailyGoal = prefs.getInt('dailyGoal') ?? 8;
    });
  }


  @override
  Widget build(BuildContext context) {
    int totalMilliliters = _waterCount * volumePerGlass;
    double progress = (dailyGoal > 0) ? (_waterCount / dailyGoal) : 0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom,
          ),
          child: Column(
            children: [
              SizedBox(height: 30),
              Text(
                DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.purple,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.white,
                  BlendMode.dstATop,
                ),
                child: Image.asset(
                  'assets/images/jug.jpg',
                  width: 200,
                  height: 200,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_waterCount > 0) {
                                setState(() {
                                  _waterCount--;
                                  _addToTotalCount(-1); // Decrement total count
                                });
                                _setMessage();
                                _saveWaterCount();
                              }
                            },
                            child: Text(
                              '--',
                              style: TextStyle(
                                fontSize: 35,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                _showDailyGoalDialog(); // Show the dialog box when the text is tapped
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _waterCount.toString(),
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    '/$dailyGoal',
                                    // Show total glasses for the day
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_waterCount < dailyGoal) {
                                setState(() {
                                  _waterCount++;
                                  _addToTotalCount(1); // Increment total count
                                });
                                _setMessage();
                                _saveWaterCount();
                              }
                            },
                            child: Text(
                              '+',
                              style: TextStyle(
                                fontSize: 35,
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'glasses',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              shadows: [
                                Shadow(
                                  blurRadius: 2.0,
                                  color: Colors.purple,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$totalMilliliters ml',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(height: 20),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 320,
                height: 100,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Glasses',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                blurRadius: 2.0,
                                color: Colors.deepPurple,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '$_totalWaterCount/$dailyGoal',
                          // Use total count and daily goal
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 150,
                      height: 10,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 0.3,
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Stack(
                        children: <Widget>[
                          LinearProgressIndicator(
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _totalWaterCount >= dailyGoal
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                            value: _totalWaterCount /
                                dailyGoal, // Use total count and daily goal
                          ),
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${(_totalWaterCount / dailyGoal * 100)
                                      .toStringAsFixed(0)}%',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}