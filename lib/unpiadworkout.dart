import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
class uWorkout extends StatefulWidget {
  @override
  _WorkoutState createState() => _WorkoutState();
}

class _WorkoutState extends State<uWorkout> {
  String? selectedExercise;

  final Map<String, String> exerciseImages = {
    'Running': 'assets/images/runn.png',
    'Cycling': 'assets/images/cycling.png',
    'Jumping Jacks': 'assets/images/jum.png',
    'High Knees':'assets/images/knee.png',
    'Burpees':  'assets/images/burep.png',
    'Pilates Exercise 1': 'assets/images/pe.png',
    'Single Leg Stretch': 'assets/images/sleg.jpg',
    'Double Leg Stretch': 'assets/images/dleg.png',
    'Criss-Cross': 'assets/images/cross.png',
    'Squats': 'assets/images/squats.jpg',
    'Deadlifts' :'assets/images/deadlifts.png',
    'Bench Press':'assets/images/bench press.jpg',
    'Pull-ups':'assets/images/pull ups.png',
    'Lunges':'assets/images/lungess.jpg',
    'Yoga Pose 1':'assets/images/yoga.png',
    'Yoga Pose 2':'assets/images/yoga2.jpg',
    'Tree Pose':'assets/images/tree.jpg',
    'Child\'s Pose':'assets/images/child.jpg',
    'Cat-Cow Stretch':'assets/images/cat.png',


    // Add image paths for other exercises as needed
  };

  final Map<String, String> exerciseVideos = {
    'Running': 'https://youtu.be/c1mBu4tK90k?si=xW_5EZHv4Q2BeVvc',
    'Cycling': 'https://youtu.be/4Hl1WAGKjMc?si=5PTuRFq8e1hGxmeu',
    'Jumping Jacks': 'https://youtu.be/aWVoLpRFaTY?si=2XyF-enwwb4s0KYj',
    'High Knees':  'https://youtu.be/8Mzm52VdXkM?si=buHbl_VscBBRk4ge',
    'Burpees': 'https://youtu.be/xQdyIrSSFnE?si=HjpyDVJ4TcSuaw1r',
    'Pilates Exercise 1': 'https://youtu.be/44HquH6QyXc?si=TCape8Md810ZqmuS',
    'Single Leg Stretch': 'https://youtu.be/Ad4lgW4ieAM?si=b_oFhAkkTEgBwjQ8',
    'Double Leg Stretch': 'https://youtu.be/N-jZas9tMSU?si=o3xzqfdbBoQfQkdx',
    'Criss-Cross': 'https://youtu.be/gzaCxDVQL90?si=HsnVu48Sr-mUZMQe',
    'Squats': 'https://youtu.be/4KmY44Xsg2w?si=qARDmfm4kUUD_lNV',
    'Deadlifts' :'https://youtu.be/1ZXobu7JvvE?si=4ui12nAySGyY6qMj',
    'Bench Press':'https://youtu.be/KjYak5vZO9s?si=Ej8jbrrbQhpOFPOl',
    'Pull-ups':'https://youtu.be/19xCfAZmMWg?si=yRuNqf3CzS3fUUS5',
    'Lunges':'https://youtu.be/uVwNVEQS_uo?si=C11vzCiInpoUUmoq',
    'Yoga Pose 1':'https://youtu.be/rt1bsoOukjI?si=yythdPetioqihhM9',
    'Yoga Pose 2':'https://youtu.be/Mn6RSIRCV3w?si=DtiY2jL4bWRY6OyX',
    'Tree Pose':'https://youtu.be/wdln9qWYloU?si=c_KS6EUqRm7HlS34',
    'Child\'s Pose':'https://youtu.be/qYvYsFrTI0U?si=uZj41eyBX_1uBSKt',
    'Cat-Cow Stretch':'https://youtu.be/tT00XNqJ3uA?si=I2ZYQw09lW-7UDbr',
  };


  final Map<String, List<String>> exercises = {
    'Cardio': [
      'Running',
      'Cycling',
      'Jumping Jacks',
      'High Knees',
      'Burpees',
    ],
    'Pilates': [
      'Pilates Exercise 1',
      'Single Leg Stretch',
      'Double Leg Stretch',
      'Criss-Cross',
    ],
    'Strength': [
      'Squats',
      'Deadlifts',
      'Bench Press',
      'Pull-ups',
      'Lunges',
    ],
    'Yoga': [
      'Yoga Pose 1',
      'Yoga Pose 2',
      'Tree Pose',
      'Child\'s Pose',
      'Cat-Cow Stretch',
    ],
  };


  void _selectCategory(BuildContext context, List<String> exercises) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: 500,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exercises',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Column(
                children: exercises.map((exercise) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Close the bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseDetailPage(exerciseName: exercise,  exerciseImage: exerciseImages[exercise] ?? '',videoUrl: exerciseVideos[exercise] ?? '',),
                          ),
                        );
                      },
                      child: Text(
                        exercise,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text('GritFit Workout'),
      ),
      body: selectedExercise == null ? _buildCategorySelection(context) : Container(),
    );
  }

  Widget _buildCategorySelection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'GritFit Workout',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          SizedBox(height: 70),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      SizedBox(width: 100),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Build',
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: SizedBox(width: 8),
                                  ),
                                  TextSpan(
                                    text: 'Your',
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: SizedBox(width: 8),
                                  ),
                                  TextSpan(
                                    text: 'Body',
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: SizedBox(width: 30),
                                  ),
                                  TextSpan(
                                    text: 'With',
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: SizedBox(width: 10),
                                  ),
                                  TextSpan(
                                    text: 'us',
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.purple,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -60,
                left: 6,
                child: Image.asset(
                  'assets/images/wor.jpg',
                  height: 140,
                  width: 110,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          SizedBox(height: 50),
          Text(
            'Categories',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 50.0),
                child: GestureDetector(
                  onTap: () {
                    _selectCategory(context, exercises['Cardio']!);
                  },
                  child: CategoryCard(
                    animationPath: 'assets/images/cardio.json',
                    categoryName: 'Cardio',
                    color: Colors.cyan[100]!,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 50.0),
                child: GestureDetector(
                  onTap: () {
                    _selectCategory(context, exercises['Pilates']!);
                  },
                  child: CategoryCard(
                    animationPath: 'assets/images/pilates.json',
                    categoryName: 'Pilates',
                    color: Colors.blue[100]!,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 50.0),
                child: GestureDetector(
                  onTap: () {
                    _selectCategory(context, exercises['Strength']!);
                  },
                  child: CategoryCard(
                    animationPath: 'assets/images/strength.json',
                    categoryName: 'Strength',
                    color: Colors.green[100]!,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 50.0),
                child: GestureDetector(
                  onTap: () {
                    _selectCategory(context, exercises['Yoga']!);
                  },
                  child: CategoryCard(
                    animationPath: 'assets/images/yoga.json',
                    categoryName: 'Yoga',
                    color: Colors.purple[100]!,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String animationPath;
  final String categoryName;
  final Color color;

  const CategoryCard({
    required this.animationPath,
    required this.categoryName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Lottie.asset(
              repeat: true,
              reverse: true,
              animationPath,
              height: 60,
              width: 60,
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          categoryName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
class ExerciseDetailPage extends StatefulWidget {
  final String exerciseName;
  final String exerciseImage;
  final String videoUrl;

  ExerciseDetailPage({
    required this.exerciseName,
    required this.exerciseImage,
    required this.videoUrl,
  });

  @override
  _ExerciseDetailPageState createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  Map<String, dynamic>? paymentIntentData;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController(text: '+923');
  TextEditingController emailController = TextEditingController();
  int _timeInMinutes = 0;
  bool _timerSet = false;
  bool _timerRunning = false;
  int _timeInSeconds = 0;
  bool _disposing = false;
  Timer? _timer;

  final Map<String, double> exerciseCalories = {
    'Running': 7.0,
    'Cycling':5.0 ,
    'Jumping Jacks': 5.0,
    'High Knees':5.0,
    'Burpees':6.0,
    'Pilates Exercise 1': 3.0,
    'Single Leg Stretch': 3.0,
    'Double Leg Stretch': 3.0,
    'Criss-cross':3.0,
    'Squats': 4.0,
    'Deadlifts': 5.0,
    'Bench Press':4.0,
    'Pull-ups': 4.0,
    'Lunges': 4.0,
    'Yoga Pose 1': 3.0,
    'Yoga Pose 2': 3.0,
    'tree pose': 3.0,
    'Child\'s Pose':2.0,
    'Cat-Cow Stretch': 2.0,
  };
  final Map<String, List<int>> exerciseTimeRange = {
    'Running': [5, 30],
    'Cycling': [10, 30],
    'Jumping Jacks': [1, 20],
    'High Knees': [1, 20],
    'Burpees': [1, 30],
    'Pilates Exercise 1': [10, 30],
    'Single Leg Stretch': [5, 30],
    'Double Leg Stretch': [5, 30],
    'Criss-Cross': [5, 30],
    'Squats': [5, 60],
    'Deadlifts': [5, 60],
    'Bench Press': [5, 60],
    'Pull-ups': [5, 60],
    'Lunges': [5, 60],
    'Yoga Pose 1': [5, 30],
    'Yoga Pose 2': [5, 30],
    'Tree Pose': [5, 30],
    'Child\'s Pose': [5, 20],
    'Cat-Cow Stretch': [5, 20],
  };

  double _caloriesBurned = 0.0;

  @override
  void dispose() {
    _disposing = true; // Set disposing flag to true
    _timer?.cancel(); // Cancel any active timer
    super.dispose();
  }

  void _resetState() {
    setState(() {
      _timeInMinutes = 0;
      _timerSet = false;
      _timerRunning = false;
      _timeInSeconds = 0;
      _caloriesBurned = 0.0;
    });
  }

  void _setTimer() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Set Timer (in minutes)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Minutes',
                ),
                onChanged: (value) {
                  _timeInMinutes = int.tryParse(value) ?? 0;
                },
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  List<int>? timeRange = exerciseTimeRange[widget.exerciseName];
                  if (timeRange != null &&
                      (_timeInMinutes < timeRange[0] || _timeInMinutes > timeRange[1])) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Invalid Time'),
                          content: Text(
                              'Please enter a time between ${timeRange[0]} and ${timeRange[1]} minutes for ${widget.exerciseName}.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    setState(() {
                      _timerSet = true;
                      _timeInSeconds = _timeInMinutes * 60;
                    });
                  }
                },
                child: Text('Set'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startTimer() {
    print('Timer started');
    setState(() {
      _timerRunning = true;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeInSeconds > 0) {
        setState(() {
          _timeInSeconds--;
          _calculateCaloriesBurned();
        });
      } else {
        timer.cancel();
        setState(() {
          _timerRunning = false;
        });
      }
      print('Timer running: $_timeInSeconds seconds left');
    });
  }

  void _toggleTimer() {
    print('_toggleTimer called');
    if (_timerRunning) {
      print('Stopping timer');
      _timer?.cancel();
      setState(() {
        _timerRunning = false;
      });
    } else {
      print('Starting timer');
      _startTimer();
    }
  }

  void _calculateCaloriesBurned() {
    // Check if the timer is running and the exercise name exists in the map
    if (_timerRunning && exerciseCalories.containsKey(widget.exerciseName)) {
      // Get the calories burned per minute for the specific exercise
      double caloriesPerMinute = exerciseCalories[widget.exerciseName]!;

      // Calculate the elapsed time in minutes
      double elapsedMinutes = (_timeInMinutes - (_timeInSeconds / 60.0));

      // Calculate the current calories burned
      double currentCalories = caloriesPerMinute * elapsedMinutes;

      // Update the state with the new calories burned value
      setState(() {
        _caloriesBurned = currentCalories.roundToDouble(); // Round to the nearest integer
      });
    } else {
      // Reset calories burned if conditions are not met
      setState(() {
        _caloriesBurned = 0.0;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.exerciseName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Image.asset(
              widget.exerciseImage,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 70),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _setTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple, // Set button color to purple
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Set border radius for square shape
                    ),
                    foregroundColor: Colors.white,
                    minimumSize: Size(70, 40),
                  ),
                  child: Text('Set Timer'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    showUserForm(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple, // Set button color to purple
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Set border radius for square shape
                    ),
                    foregroundColor: Colors.white,
                    minimumSize: Size(70, 40),
                  ),
                  child: Text('Watch Video'),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_timerSet)
              ElevatedButton(
                onPressed: _toggleTimer,
                child: Text(_timerRunning ? 'Stop' : 'Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[500], // Set button color to purple
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Set border radius for square shape
                  ),
                  foregroundColor: Colors.white,
                ),
              ),
            SizedBox(height: 10),
            if (_timerSet)
              Text(
                'Time Left: ${_timeInSeconds ~/ 60}:${(_timeInSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black38),
              ),
            SizedBox(height: 10),
            if (_timerSet)
              Text(
                'Calories Burned: $_caloriesBurned',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black38),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetState,
        tooltip: 'Reset Timer and Calories',
        backgroundColor: Colors.purple,
        // Set background color to purple
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              10), // Set border radius for square shape
        ),
        child: Icon(
          Icons.refresh,
          color: Colors.white, // Set text color to white
        ),
      ),
    );
  }

  //unpiad workut dilog
  void showUserForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 120.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidateMode,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.cancel_outlined),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            fontSize: 18.0, // Set the font size for the label text
                          ),
                          hintText: 'example@gmail.com',
                          hintStyle: TextStyle(
                            fontSize: 16.0, // Set the font size for the hint text
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 16.0, // Set the font size for the input text
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(value)) {
                            return 'Please enter a valid Gmail address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          // Set autovalidate mode to always when submitting the form
                          setState(() {
                            _autoValidateMode = AutovalidateMode.always;
                          });

                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop();
                            showInternetConnectionDialog(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Colors.purple[500],
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }



  void showInternetConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            'Make sure you have an internet connection',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                await makePayment((paymentSuccessful) {
                  if (paymentSuccessful) {
                    //  launchVideo(recipe['videoUrl']!);
                    sendEmail(
                      emailController.text,
                      'Payment Successful',
                      'Welcome! you have subscribed the premium package of GritFit.',
                    );
                    launchVideo(widget.videoUrl);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Payment Failed'),
                          content: Text('Payment failed. Please try again.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                });
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

  }
  Future<void> makePayment(Function(bool) onPaymentResult) async {
    try {
      paymentIntentData = await createPaymentIntent('20', 'USD');
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Sif',
        ),
      );
      await displayPaymentSheet(onPaymentResult);
    } catch (e) {
      print('Error initializing payment sheet: $e');
      onPaymentResult(false);
    }
  }

  Future<void> displayPaymentSheet(Function(bool) onPaymentResult) async {
    try {
      await stripe.Stripe.instance.presentPaymentSheet();
      paymentIntentData = null;
      onPaymentResult(true);
    } catch (e) {
      if (e is stripe.StripeException) {
        print('Error presenting payment sheet: ${e.error.localizedMessage}');
      } else {
        print('Error presenting payment sheet: $e');
      }
      onPaymentResult(false);
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount('20'),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
            'Bearer sk_test_51PJ8UO2Llx6JzMA0EMn75x40L6Zkw0cmMxXJlwfLUER3knmNbfz7vq33eEkN0NulpE5WjQ2WwwWyHou6ltiezaFz00is1lBIBe',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      return jsonDecode(response.body.toString());
    }
    catch (e) {
      print("error $e");
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }

  void launchVideo(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not launch the video.'),
      ));
    }
  }
  Future<void> sendEmail(String recipient, String subject, String message) async {
    // Replace with your email and password
    String username = 'agritfit@gmail.com';
    String password = 'dmehtpvtnacfuhpm';

    final smtpServer = gmail(username, password);

    final emailMessage = Message()
      ..from = Address(username, 'GritFit')
      ..recipients.add(recipient)
      ..subject = subject
      ..text = message;

    try {
      final sendReport = await send(emailMessage, smtpServer);
      print('Message sent: ' + sendReport.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment Succesfull E-mail is sent on your account.'),
        ),
      );
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong ,cant send email'),
          ),
        );
      }
    }
  }
}




