import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Workout extends StatefulWidget {
  @override
  _WorkoutState createState() => _WorkoutState();
}
class _WorkoutState extends State<Workout> {
  String? selectedExercise;
  Future<void>? _initialization;
  List<Map<String, String>> weeklyPlan = [];
  Map<String, String>? currentDayPlan;

  @override
  void initState() {
    super.initState();
    _initialization = initialize();
  }
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasShownDialog = prefs.getBool('_showDisabilityDialog') ?? false;
    if (!hasShownDialog) {
      await Future.delayed(Duration(seconds: 2));
      showUserForminfo(context);
      prefs.setBool('_showDisabilityDialog', true); // Set flag to indicate the dialog has been shown
    } else{fetchUserDataAndGeneratePlan();}
    }

  Future<void> showUserForminfo(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

    // Variables to store user input
    int age = 0;
    String gender = '';
    String? disability; // Changed to nullable to handle uninitialized state

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          int ageInput = int.tryParse(value) ?? 0;
                          if (ageInput < 18 || ageInput > 60) {
                            return 'Age should be between 18 and 60';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              age = int.parse(value);
                            });
                          }
                        },
                      ),
                      Row(
                        children: [
                          Text('Gender: '),
                          Radio<String>(
                            value: 'male',
                            groupValue: gender,
                            onChanged: (value) {
                              setState(() {
                                gender = value!;
                              });
                            },
                          ),
                          Text('Male'),
                          Radio<String>(
                            value: 'female',
                            groupValue: gender,
                            onChanged: (value) {
                              setState(() {
                                gender = value!;
                              });
                            },
                          ),
                          Text('Female'),
                        ],
                      ),
                      if (_autoValidateMode == AutovalidateMode.always &&
                          gender.isEmpty)
                        Text(
                          'Please select a gender',
                          style: TextStyle(color: Colors.red),
                        ),
                      Row(
                        children: [
                          Text('Do you have a disability? '),
                          Checkbox(
                            value: disability != null,
                            onChanged: (value) async {
                              if (value!) {
                                // Show disability selection dialog
                                String? selectedDisability = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Select Disability Type'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            title: Text('Back'),
                                            onTap: () =>
                                                Navigator.of(context).pop(
                                                    'Back'),
                                          ),
                                          ListTile(
                                            title: Text('Hand'),
                                            onTap: () =>
                                                Navigator.of(context).pop(
                                                    'Hand'),
                                          ),
                                          ListTile(
                                            title: Text('Feet'),
                                            onTap: () =>
                                                Navigator.of(context).pop(
                                                    'Feet'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                                if (selectedDisability != null) {
                                  setState(() {
                                    disability = selectedDisability;
                                  });
                                }
                              } else {
                                setState(() {
                                  disability = null;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          // Set autovalidate mode to always when submitting the form
                          setState(() {
                            _autoValidateMode = AutovalidateMode.always;
                          });

                          if (_formKey.currentState!.validate() &&
                              gender.isNotEmpty) {
                            // Save form state to trigger onSaved callbacks
                            _formKey.currentState!.save();

                            // Save form data to shared preferences
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setInt('age', age);
                            print('age: $age'); // Debugging print statement
                            await prefs.setString('gender', gender);
                            await prefs.setString(
                                'disability', disability ?? '');


                            // Dismiss the dialog
                            Navigator.of(context).pop();
                            // Generate the weekly plan after form submission
                            fetchUserDataAndGeneratePlan();
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

  Future<void> fetchUserDataAndGeneratePlan() async {
    final prefs = await SharedPreferences.getInstance();
    int age = prefs.getInt('age') ?? 0;
    String gender = prefs.getString('gender') ?? '';
    String disability = prefs.getString('disability') ?? '';
    generateWeeklyPlan(age, gender, disability);
    setState(() {
      // Update the current day's plan
      currentDayPlan = weeklyPlan[DateTime
          .now()
          .weekday - 1];
    });
  }





  void generateWeeklyPlan(int age, String gender, String disability) {
    // Default plan for users without any disabilities
    List<Map<String, String>> MdefaultPlan = [
      {
        'Day': 'Day 1',
        'Exercise 1': 'Running',
        'Time 1': '30 mins',
        'Exercise 2': 'Push-ups',
        'Time 2': '15 mins'
      },
      {
        'Day': 'Day 2',
        'Exercise 1': 'Cycling',
        'Time 1': '45 mins',
        'Exercise 2': 'Push-ups',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 3',
        'Exercise 1': 'Yoga Pose 1',
        'Time 1': '20 mins',
        'Exercise 2': 'Criss cross',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 4',
        'Exercise 1': 'Squats',
        'Time 1': '30 mins',
        'Exercise 2': 'Lunges',
        'Time 2': '25 mins'
      },
      {
        'Day': 'Day 5',
        'Exercise 1': 'High Knees',
        'Time 1': '25 mins',
        'Exercise 2': 'Burpees',
        'Time 2': '15 mins'
      },
      {
        'Day': 'Day 6',
        'Exercise 1': 'Child\'s Pose',
        'Time 1': '15 mins',
        'Exercise 2': 'Jumping Jacks',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 7',
        'Exercise 1': 'Yoga Pose 2',
        'Time 1': '20 mins',
        'Exercise 2': 'Jumping Jacks',
        'Time 2': '15 mins'
      },
    ];
    List<Map<String, String>> fdefaultPlan = [
      {
        'Day': 'Day 1',
        'Exercise 1': 'Running',
        'Time 1': '30 mins',
        'Exercise 2': 'tree pose',
        'Time 2': '15 mins'
      },
      {
        'Day': 'Day 2',
        'Exercise 1': 'Cycling',
        'Time 1': '45 mins',
        'Exercise 2': 'pilates Exercise 2',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 3',
        'Exercise 1': 'Yoga Pose 2',
        'Time 1': '20 mins',
        'Exercise 2': 'Criss cross',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 4',
        'Exercise 1': 'Squats',
        'Time 1': '30 mins',
        'Exercise 2': 'Lunges',
        'Time 2': '25 mins'
      },
      {
        'Day': 'Day 5',
        'Exercise 1': 'High Knees',
        'Time 1': '25 mins',
        'Exercise 2': 'Burpees',
        'Time 2': '15 mins'
      },
      {
        'Day': 'Day 6',
        'Exercise 1': 'chair yoga',
        'Time 1': '15 mins',
        'Exercise 2': 'pilates Exercise 2',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 7',
        'Exercise 1': 'chair yoga',
        'Time 1': '15 mins',
        'Exercise 2': 'yoga pose 1',
        'Time 2': '20'
      },
    ];

    // Plan for users with feet disability (age between 18 and 45)
    List<Map<String, String>> feetDisabilityPlan = [
      {
        'Day': 'Day 1',
        'Exercise 1': 'Seated Upper Body Strength',
        'Time 1': '30 mins',
        'Exercise 2': 'Seated Arm Circles',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 2',
        'Exercise 1': 'Seated Side Bends',
        'Time 1': '20 mins',
        'Exercise 2': 'Seated Arm Circles',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 3',
        'Exercise 1': 'chair yoga',
        'Time 1': '20 mins',
        'Exercise 2': 'Seated Side Bends',
        'Time 2': '30 mins'
      },
      {
        'Day': 'Day 4',
        'Exercise 1': 'Seated Arm Circles',
        'Time 1': '30 mins',
        'Exercise 2': 'chair yoga',
        'Time 2': '25 mins'
      },
      {
        'Day': 'Day 5',
        'Exercise 1': 'Seated Side Bends',
        'Time 1': '25 mins',
        'Exercise 2': 'Chair Stretching',
        'Time 2': '15 mins'
      },
      {
        'Day': 'Day 6',
        'Exercise 1': 'Chair Stretching',
        'Time 1': '15 mins',
        'Exercise 2': 'Rest',
        'Time 2': ''
      },
      {'Day': 'Day 7', 'Exercise': 'Rest', 'Time': ''},
    ];

    // Plan for users with feet disability ( age between 45 and 60)
    List<Map<String, String>> ffeetDisabilityPlan = [
      {
        'Day': 'Day 1',
        'Exercise 1': 'Seated Upper Body Strength',
        'Time 1': '30 mins',
        'Exercise 2': 'Seated Side Bends',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 2',
        'Exercise 1': 'Seated Arm Circles',
        'Time 1': '20 mins',
        'Exercise 2': 'Seated Resistance Band',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 3',
        'Exercise 1': 'Chair Stretching',
        'Time 1': '20 mins',
        'Exercise 2': 'chair yoga',
        'Time 2': '30 mins'
      },
      {
        'Day': 'Day 4',
        'Exercise 1': 'Chair Stretching',
        'Time 1': '30 mins',
        'Exercise 2': 'chair yoga',
        'Time 2': '25 mins'
      },
      {
        'Day': 'Day 5',
        'Exercise 1': 'Seated Resistance Band',
        'Time 1': '25 mins',
        'Exercise 2': 'Seated Arm Circles',
        'Time 2': '15 mins'
      },
      {
        'Day': 'Day 6',
        'Exercise 1': 'Child\'s Pose',
        'Time 1': '15 mins',
        'Exercise 2': 'Rest',
        'Time 2': ''
      },
      {'Day': 'Day 7', 'Exercise': 'Rest', 'Time': ''},
    ];

    // Plan for users with hand disability
    List<Map<String, String>> handDisabilityPlan = [
      {
        'Day': 'Day 1',
        'Exercise 1': 'Squats',
        'Time 1': '30 mins',
        'Exercise 2': 'Leg Curl',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 2',
        'Exercise 1': 'Leg Raises',
        'Time 1': '20 mins',
        'Exercise 2': 'Walking',
        'Time 2': '30 mins'
      },
      {
        'Day': 'Day 3',
        'Exercise 1': 'Child\'s Pose',
        'Time 1': '30 mins',
        'Exercise 2': 'Leg Raises',
        'Time 2': '25 mins'
      },
      {
        'Day': 'Day 4',
        'Exercise 1': 'Leg Curl',
        'Time 1': '25 mins',
        'Exercise 2': 'Walking',
        'Time 2': '30 mins'
      },
      {
        'Day': 'Day 5',
        'Exercise 1': 'Squats',
        'Time 1': '30 mins',
        'Exercise 2': 'Child\'s Pose',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 6',
        'Exercise 1': 'Leg Curl',
        'Time 1': '20 mins',
        'Exercise 2': 'Rest',
        'Time 2': ''
      },
      {'Day': 'Day 7', 'Exercise': 'Rest', 'Time': ''},
    ];
    List<Map<String, String>> fhandDisabilityPlan = [
      {
        'Day': 'Day 1',
        'Exercise 1': 'Walking',
        'Time 1': '30 mins',
        'Exercise 2': 'Leg Curl',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 2',
        'Exercise 1': 'tree pose',
        'Time 1': '20 mins',
        'Exercise 2': 'Lunges',
        'Time 2': '30 mins'
      },
      {
        'Day': 'Day 3',
        'Exercise 1': 'Leg Raises',
        'Time 1': '30 mins',
        'Exercise 2': '',
        'Time 2': '25 mins'
      },
      {
        'Day': 'Day 4',
        'Exercise 1': 'Squats',
        'Time 1': '25 mins',
        'Exercise 2': 'Walking',
        'Time 2': '30 mins'
      },
      {
        'Day': 'Day 5',
        'Exercise 1': 'Walking',
        'Time 1': '30 mins',
        'Exercise 2': 'Child\'s Pose',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 6',
        'Exercise 1': 'Child\'s Pose',
        'Time 1': '20 mins',
        'Exercise 2': 'Rest',
        'Time 2': ''
      },
      {'Day': 'Day 7', 'Exercise': 'Rest', 'Time': ''},
    ];

    // Plan for users with back disability(female 18 to 45)
    List<Map<String, String>> backDisabilityPlan = [
      {
        'Day': 'Day 1',
        'Exercise 1': 'Single Leg Stretch',
        'Time 1': '20 mins',
        'Exercise 2': 'Child\'s Pose',
        'Time 2': '15 mins'
      },
      {
        'Day': 'Day 2',
        'Exercise 1': 'Double Leg Stretch',
        'Time 1': '15 mins',
        'Exercise 2': 'tree pose',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 3',
        'Exercise 1': 'Pelvic Tilts',
        'Time 1': '20 mins',
        'Exercise 2': 'Burpees',
        'Time 2': '25 mins'
      },
      {
        'Day': 'Day 4',
        'Exercise 1': 'Burpees',
        'Time 1': '25 mins',
        'Exercise 2': 'Squats',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 5',
        'Exercise 1': 'tree pose',
        'Time 1': '20 mins',
        'Exercise 2': 'Walking',
        'Time 2': '30 mins'
      },
      {
        'Day': 'Day 6',
        'Exercise 1': 'Walking',
        'Time 1': '30 mins',
        'Exercise 2': 'Rest',
        'Time 2': ''
      },
      {'Day': 'Day 7', 'Exercise': 'Rest', 'Time': ''},
    ];
    // female 45 to 60
    List<Map<String, String>> fbackDisabilityPlan = [
      {
        'Day': 'Day 1',
        'Exercise 1': 'tree pose',
        'Time 1': '20 mins',
        'Exercise 2': 'Double Leg Stretch',
        'Time 2': '15 mins'
      },
      {
        'Day': 'Day 2',
        'Exercise 1': 'Single Leg Stretch',
        'Time 1': '15 mins',
        'Exercise 2': 'Walking',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 3',
        'Exercise 1': 'Pelvic Tilts',
        'Time 1': '20 mins',
        'Exercise 2': 'Pilates Exercise 1',
        'Time 2': '25 mins'
      },
      {
        'Day': 'Day 4',
        'Exercise 1': 'Pilates Exercise 1',
        'Time 1': '25 mins',
        'Exercise 2': 'Child\'s Pose',
        'Time 2': '20 mins'
      },
      {
        'Day': 'Day 5',
        'Exercise 1': 'Double Leg Stretch',
        'Time 1': '20 mins',
        'Exercise 2': 'Walking',
        'Time 2': '30 mins'
      },
      {
        'Day': 'Day 6',
        'Exercise 1': 'Walking',
        'Time 1': '30 mins',
        'Exercise 2': 'Rest',
        'Time 2': ''
      },
      {'Day': 'Day 7', 'Exercise': 'Rest', 'Time': ''},
    ];

    // Debugging prints
    print('Age: $age, Gender: $gender, Disability: $disability');

    // Choose the appropriate plan based on disability and other criteria
    List<Map<String, String>> selectedPlan;
    if (disability.toLowerCase() == 'feet' &&
        (gender.toLowerCase() == 'female' || gender.toLowerCase() == 'male') &&
        age >= 18 && age <= 45) {
      selectedPlan = feetDisabilityPlan;
      print('Selected feetDisabilityPlan for  between 18 and 45');
    } else if (disability.toLowerCase() == 'feet' &&
        (gender.toLowerCase() == 'female' || gender.toLowerCase() == 'male') &&
        age >= 45 && age <= 60) {
      selectedPlan = ffeetDisabilityPlan;
      print('Selected ffeetDisabilityPlan for  between 45 and 60');
    } else if (disability.toLowerCase() == 'hand' &&
        (gender.toLowerCase() == 'female' || gender.toLowerCase() == 'male') &&
        age >= 45 && age <= 60) {
      selectedPlan = fhandDisabilityPlan;
      print('Selected handDisabilityPlan between 45 to 60');
    } else if (disability.toLowerCase() == 'hand' &&
        (gender.toLowerCase() == 'female' || gender.toLowerCase() == 'male') &&
        age >= 18 && age <= 45) {
      selectedPlan = handDisabilityPlan;
      print('Selected handDisabilityPlan between 18 to 45');
    } else if (disability.toLowerCase() == 'back' &&
        (gender.toLowerCase() == 'female' || gender.toLowerCase() == 'male') &&
        age >= 45 && age <= 60) {
      selectedPlan = fbackDisabilityPlan;
      print('Selected backDisabilityPlan age between 45 to 60');
    } else if (disability.toLowerCase() == 'back' &&
        (gender.toLowerCase() == 'female' || gender.toLowerCase() == 'male') &&
        age >= 18 && age <= 45) {
      selectedPlan = backDisabilityPlan;
      print('Selected backDisabilityPlan age between 18  to 45');
    } else if (age >= 18 && age <= 60 && gender.toLowerCase() == 'male') {
      selectedPlan = MdefaultPlan;
      print('Selected  male defaultPlan for age between 18 and 60');
    } else if (age >= 18 && age <= 60 && gender.toLowerCase() == 'male') {
      selectedPlan = fdefaultPlan;
      print('Selected female defaultPlan for age between 18 and 60');
    } else {
      selectedPlan = MdefaultPlan;
      print('Selected defaultPlan');
    }

    // Set the selected plan
    setState(() {
      weeklyPlan = selectedPlan;
    });
    print(selectedPlan);
  }

  final Map<String, String> exerciseImages = {
    'Running': 'assets/images/runn.png',
    'Cycling': 'assets/images/cycling.png',
    'Jumping Jacks': 'assets/images/jum.png',
    'High Knees': 'assets/images/knee.png',
    'Burpees': 'assets/images/burep.png',
    'Pilates Exercise 1': 'assets/images/pe.png',
    'Single Leg Stretch': 'assets/images/sleg.jpg',
    'Double Leg Stretch': 'assets/images/dleg.png',
    'Criss-cross': 'assets/images/cross.png',
    'Squats': 'assets/images/squats.jpg',
    'Deadlifts': 'assets/images/deadlifts.png',
    'Bench Press': 'assets/images/bench press.jpg',
    'Pull-ups': 'assets/images/pull ups.png',
    'Lunges': 'assets/images/lungess.jpg',
    'Yoga Pose 1': 'assets/images/yoga.png',
    'Yoga Pose 2': 'assets/images/yoga2.jpg',
    'tree pose': 'assets/images/tree.jpg',
    'Child\'s Pose': 'assets/images/child.jpg',
    'Cat-Cow Stretch': 'assets/images/cat.png',
    'Seated Arm Circles': 'assets/images/seated.jpg',
    ' Chair Stretching': 'assets/images/strectch.jpg',
    'Seated Side Bends': 'assets/images/seated side.png',
    'Leg Raises': 'assets/images/leg raise.jpg',
    'Seated Upper Body Strength': 'assets/images/upper body.png',
    ' Seated Resistance Band ': 'assets/images/bnds.png',
    'Leg Curl': 'assets/images/legcurl.jpg',
    'chair yoga': 'assets/images/chair.jpg',
    'Pelvic Tilts': 'assets/images/pelvit.jpg',
    'Push-ups':'assets/images/pushup.png',
    'Walking':'assets/images/walked.png',

    // Add image paths for other exercises as needed
  };
  final Map<String, String> exerciseVideos = {
    'Running': 'https://youtu.be/c1mBu4tK90k?si=xW_5EZHv4Q2BeVvc',
    'Cycling': 'https://youtu.be/4Hl1WAGKjMc?si=5PTuRFq8e1hGxmeu',
    'Jumping Jacks': 'https://youtu.be/aWVoLpRFaTY?si=2XyF-enwwb4s0KYj',
    'High Knees': 'https://youtu.be/8Mzm52VdXkM?si=buHbl_VscBBRk4ge',
    'Burpees': 'https://youtu.be/xQdyIrSSFnE?si=HjpyDVJ4TcSuaw1r',
    'Pilates Exercise 1': 'https://youtu.be/44HquH6QyXc?si=TCape8Md810ZqmuS',
    'Single Leg Stretch': 'https://youtu.be/Ad4lgW4ieAM?si=b_oFhAkkTEgBwjQ8',
    'Double Leg Stretch': 'https://youtu.be/N-jZas9tMSU?si=o3xzqfdbBoQfQkdx',
    'Criss-cross': 'https://youtu.be/gzaCxDVQL90?si=HsnVu48Sr-mUZMQe',
    'Squats': 'https://youtu.be/4KmY44Xsg2w?si=qARDmfm4kUUD_lNV',
    'Deadlifts': 'https://youtu.be/1ZXobu7JvvE?si=4ui12nAySGyY6qMj',
    'Bench Press': 'https://youtu.be/KjYak5vZO9s?si=Ej8jbrrbQhpOFPOl',
    'Pull-ups': 'https://youtu.be/19xCfAZmMWg?si=yRuNqf3CzS3fUUS5',
    'Lunges': 'https://youtu.be/uVwNVEQS_uo?si=C11vzCiInpoUUmoq',
    'Yoga Pose 1': 'https://youtu.be/rt1bsoOukjI?si=yythdPetioqihhM9',
    'Yoga Pose 2': 'https://youtu.be/Mn6RSIRCV3w?si=DtiY2jL4bWRY6OyX',
    'tree pose': 'https://youtu.be/wdln9qWYloU?si=c_KS6EUqRm7HlS34',
    'Child\'s Pose': 'https://youtu.be/qYvYsFrTI0U?si=uZj41eyBX_1uBSKt',
    'Cat-Cow Stretch': 'https://youtu.be/tT00XNqJ3uA?si=I2ZYQw09lW-7UDbr',
    'Seated Upper Body Strength':'https://youtu.be/xjhO9JpJJd4?si=nZoLJ99uwahL2b3V',
    'Walking':'https://youtu.be/enYITYwvPAQ?si=ye7362la88OLsYaH',
    'chair yoga':'https://youtu.be/U_jdXFfegKE?si=ErGpPFmLrPv1HMeh',
    'Seated Side Bends':'https://youtu.be/WWdwDfQCvJ4?si=LLP-HZ3I_eNuIeKD',
    'Chair Stretching':'https://youtu.be/LdW4i3KXXIk?si=aB8xLA6YoerZC5fR',
    ' Seated Resistance Band ': 'https://youtu.be/1xSj2KOwHs8?si=T6WX6gMuCslpiiG0',
    'Leg Curl': 'https://youtu.be/oWu8RxtWdGE?si=auNbiDWM3awO1jxq',
    'Pelvic Tilts': 'https://youtu.be/NKl8ImI3OVE?si=PbI3qhHPMWTBPim2',
    'Push-ups':'https://youtu.be/tWjBnQX3if0?si=HSdRKQPiGhGG7Jxl',
    'Leg Raises': 'https://youtu.be/gz-VmPNR2VQ?si=P5scufvEWCQOdckC',


  };
  final Map<String, List<String>> exercises = {
    'Cardio': [
      'Running',
      'Walking',
      'Cycling',
      'Jumping Jacks',
      'High Knees',
      'Burpees',
    ],
    'Pilates': [
      'Pilates Exercise 1',
      'Single Leg Stretch',
      'Double Leg Stretch',
      ' Chair Stretching',
          'Criss-cross',
      'Seated Side Bends',
      'Leg Raises',
      'Pelvic Tilts',

    ],
    'Strength': [
      'Seated Upper Body Strength',
      'Squats',
      'Deadlifts',
      'Bench Press',
      'Pull-ups',
      'Lunges',
      'Seated Arm Circles',
      ' Seated Resistance Band ',
      'Leg Curl',
      'Push-ups',

    ],
    'Yoga': [
      'Yoga Pose 1',
      'Yoga Pose 2',
      'tree pose',
      'Child\'s Pose',
      'Cat-Cow Stretch',
      'Chair Yoga'


    ],
  };


  void _selectCategory(BuildContext context, List<String> exercises, List<Map<String, String>> weeklyPlan, bool isDefaultPlan) {
    // Create a set to store the exercises included in the selected plan
    Set<String> includedExercises = {};

    // Extract all exercises from the selected plan and add them to the set
    for (var dayPlan in weeklyPlan) {
      includedExercises.addAll(dayPlan.values.where((value) => value.isNotEmpty));
    }

    // Show modal bottom sheet with all exercises
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
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
                    // Determine if the exercise is enabled based on whether it's included in the selected plan
                    bool isEnabled = includedExercises.contains(exercise);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          // Only navigate if the exercise is enabled
                          if (isEnabled) {
                            Navigator.pop(context); // Close the bottom sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExerciseDetailPage(
                                  exerciseName: exercise,
                                  exerciseImage: exerciseImages[exercise] ?? '',
                                  videoUrl: exerciseVideos[exercise] ?? '',
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          exercise,
                          style: TextStyle(
                            fontSize: 18,
                            color: isEnabled ? Colors.black : Colors.grey, // Disable text color if not enabled
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
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
      body: SingleChildScrollView(
        child: Padding(
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
                        _selectCategory(context, exercises['Cardio']!,weeklyPlan,false);
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
                        _selectCategory(context, exercises['Pilates']!,weeklyPlan,false);
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
                        _selectCategory(context, exercises['Strength']!,weeklyPlan,false);
                      },
                      //
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
                        _selectCategory(context, exercises['Yoga']!,weeklyPlan,false);
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
              SizedBox(height: 50),
              Text(
                'Weekly Plan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: weeklyPlan.length,
                itemBuilder: (context, index) {
                  final dayPlan = weeklyPlan[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayPlan['Day'] ?? '', // Null check for 'Day'
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Exercise 1:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    dayPlan['Exercise 1'] ?? '', // Null check for 'Exercise 1'
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    dayPlan['Time 1'] ?? '', // Null check for 'Time 1'
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Exercise 2:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    dayPlan['Exercise 2'] ?? '', // Null check for 'Exercise 2'
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    dayPlan['Time 2'] ?? '', // Null check for 'Time 2'
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
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
    'Seated Upper Body Strength':3.0,
    'Walking':3.0,
    'chair yoga':2.0,
    'Seated Side Bends':2.0,
    'Chair Stretching':3.0,
    ' Seated Resistance Band ': 4.0,
    'Leg Curl': 2.0,
    'Pelvic Tilts': 3.0,
    'Push-ups':5.0,
    'Leg Raises': 8.0,
  };

  final Map<String, List<int>> exerciseTimeRange = {
    'Running': [5,25],
    'Cycling': [5,30],
    'Jumping Jacks': [5,15],
    'High Knees': [5,20],
    'Burpees': [5,30],
    'Pilates Exercise 1': [5,15],
    'Single Leg Stretch': [5,25],
    'Double Leg Stretch': [5,25],
    'Criss-cross': [5,35],
    'Squats': [5,20],
    'Deadlifts': [5,15],
    'Bench Press': [5,20],
    'Pull-ups': [5,15],
    'Lunges':[5,20],
    'Yoga Pose 1': [5,25],
    'Yoga Pose 2': [5,25],
    'tree pose': [5,20],
    'Child\'s Pose': [5,15],
    'Cat-Cow Stretch': [5,15],
    'Seated Upper Body Strength':[5,15],
    'Walking':[5,30],
    'chair yoga':[5,25],
    'Seated Side Bends':[5,25],
    'Chair Stretching':[5,20],
    ' Seated Resistance Band ': [5,25],
    'Leg Curl': [5,15],
    'Pelvic Tilts': [5,20],
    'Push-ups':[5,20],
    'Leg Raises': [5,15],
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
                      (_timeInMinutes < timeRange[0] ||
                          _timeInMinutes > timeRange[1])) {
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
        _caloriesBurned =
            currentCalories.roundToDouble(); // Round to the nearest integer
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
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    foregroundColor: Colors.white,
                    minimumSize: Size(70, 40),
                  ),
                  child: Text('Set Timer'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    showUserForm(context, widget.videoUrl);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                  backgroundColor: Colors.grey[500],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: Colors.white,
                ),
              ),
            SizedBox(height: 10),
            if (_timerSet)
              Text(
                'Time Left: ${_timeInSeconds ~/ 60}:${(_timeInSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black38),
              ),
            SizedBox(height: 10),
            if (_timerSet)
              Text(
                'Calories Burned: $_caloriesBurned',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black38),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _resetState,
        tooltip: 'Reset Timer and Calories',
        backgroundColor: Colors.purple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
    );
  }

  void showUserForm(BuildContext context, String videoUrl) {
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
                            icon: Icon(Icons.cancel),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'example@gmail.com',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$')
                              .hasMatch(value)) {
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
                            showInternetConnectionDialog(context, videoUrl);
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
//piad workout
  void showInternetConnectionDialog(BuildContext context, String videoUrl) {
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
              onPressed: () {
                Navigator.of(context).pop();
                // Play the video
                launchVideo(context, videoUrl);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void launchVideo(BuildContext context, String url) async {
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
}

