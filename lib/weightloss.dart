import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fitnessapp/user_model.dart';
import 'package:fitnessapp/user_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_handler.dart';
import 'idstorge.dart';
import 'lossdashboard.dart';
import 'package:http/http.dart' as http;

class Weightloss extends StatefulWidget {
  @override
  _WeightGainState createState() => _WeightGainState();
}

class _WeightGainState extends State<Weightloss> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController heightFeetController = TextEditingController();
  TextEditingController currentWeightController = TextEditingController();
  TextEditingController goalWeightController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController activityLevelController = TextEditingController();
  TextEditingController idController = TextEditingController();

  String nameError = '';
  String emailError = '';
  String ageError = '';
  String heightFeetError = '';
  String currentWeightError = '';
  String goalWeightError = '';
  bool hasError = false;
  Timer? _debounce;
  Database? _database;
  String genderError = '';
  String? selectedActivityLevel;
  String activityLevelError = '';
  String? selectedGender;
  String idError='';

  @override
  void dispose() {
    idController.dispose();
    heightFeetController.dispose();
    ageController.dispose();
    currentWeightController.dispose();
    goalWeightController.dispose();
    _debounce?.cancel(); // Cancel the timer when disposing the widget
    super.dispose();
    genderController.dispose();
    activityLevelController.dispose();
  }

  String _generateUniqueId() {
    // Ensure this method always returns a valid non-null string
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<bool> _isConnected() async {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    if (!hasConnection) {
      return false;
    }

    try {
      final response = await http.get(Uri.parse('https://www.google.com'))
          .timeout(Duration(seconds: 4));
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error checking internet connection: $e');
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GritFit' ,style: TextStyle(
          color: Colors.white,fontWeight: FontWeight.w900,
          fontSize: 24,
        ), ),
        centerTitle: false,
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText: 'Auto ID',
                errorText: idError.isEmpty ? null : idError, // Display error text
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      idController.text = _generateUniqueId(); // Generate new ID
                      idError = _validateId(idController.text); // Validate after updating
                      idstorage.storeUserId(idController.text); // Store the new ID
                      checkErrors(); // Check for any errors
                    });
                  },
                ),
              ),
              readOnly: true,
              onTap: () {
                setState(() {
                  idController.text = _generateUniqueId(); // Generate new ID on tap
                  idError = _validateId(idController.text); // Validate after updating
                  idstorage.storeUserId(idController.text); // Store the new ID
                  checkErrors(); // Check for any errors
                });
              },
            ),
            SizedBox(height: 25),
            buildTextField(
              'Enter Name',
              nameController,
              nameError,
                  (value) {
                setState(() {
                  nameError = _validateName(value);
                  checkErrors();
                });
              },
              TextInputType.text,
            ),
            SizedBox(height: 25),
            buildTextFieldWithValidation(
              'Enter Email',
              emailController,
              emailError,
                  (value) {
                setState(() {
                  emailError = _validateEmail(value);
                  checkErrors();
                });
              },
                  (value) {
                if (value.isEmpty) {
                  return 'Email is required.';
                }
                return null;
              },
            ),
            SizedBox(height: 25),
            buildAgeField(),
            SizedBox(height: 25),
            buildTextFieldWithValidations(
              'Enter Height (Feet)',
              heightFeetController,
              heightFeetError,
                  (value) {
                setState(() {
                  heightFeetError = _validateHeightFeet(value);
                  checkErrors();
                });
              },
                  (value) {
                if (value.isEmpty) {
                  return 'Height is required.';
                }
                return null;
              },
            ),SizedBox(height: 25),
            Text(
              'Select Gender',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Radio<String>(
                  value: 'Male',
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                      genderController.text = value ?? '';
                      // print(genderController.text.toString());
                      genderError = ''; // Clear gender error when selected
                      checkErrors(); // Check for other errors
                    });
                  },
                ),
                Text('Male'),
                Radio<String>(
                  value: 'Female',
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                      genderController.text = value ?? '';
                      genderError = ''; // Clear gender error when selected
                      checkErrors(); // Check for other errors
                    });
                  },
                ),
                Text('Female'),
              ],
            ),
            if (genderError.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                genderError,
                style: TextStyle(color: Colors.red),
              ),
            ],
            buildActivityLevelField(),
            SizedBox(height: 25),
            buildTextFieldWithValidations(
              'Enter Current Weight (Kgs)',
              currentWeightController,
              currentWeightError,
                  (value) {
                setState(() {
                  currentWeightError = _validateCurrentWeight(value);
                  checkErrors();
                });
              },
                  (value) {
                if (value.isNotEmpty &&
                    !RegExp(r'^\d*$').hasMatch(value)) {
                  return 'Please enter a valid weight in kgs.';
                } else if (value.isNotEmpty &&
                    double.parse(value) <= 0) {
                  return 'Weight must be greater than zero.';
                }
                return null;
              },
            ),
            SizedBox(height: 25),
            buildTextFieldWithValidations(
              'Enter Goal Weight (Kgs)',
              goalWeightController,
              goalWeightError,
                  (value) {
                setState(() {
                  goalWeightError = _validateGoalWeight(value);
                  checkErrors();
                  // Check weight suitability when goal weight is entered
                  if (goalWeightError.isEmpty) {
                    _checkGoalWeightSuitability();
                  }
                });
              },
                  (value) {
                if (value.isNotEmpty &&
                    !RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                  return 'Please enter a valid weight in kgs.';
                } else if (value.isNotEmpty &&
                    double.parse(value) >
                        double.parse(currentWeightController.text)) {
                  return 'Goal weight should be less than current weight.';
                }
                return null;
              },
            ),
            SizedBox(height: 27),
            ElevatedButton(
              onPressed: hasError
                  ? null
                  : () async {
                insertDB();
                bool isConnected = await  _isConnected();
                print("not entered");
                if (!isConnected) {
                  //   _showNoInternetDialog();
                  Fluttertoast.showToast(
                    msg: "No intenet Conection!!!",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 2,
                    backgroundColor: Colors.redAccent,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  return;
                }
                getFromweightlossusers();
                CollectionReference collref= FirebaseFirestore.instance.collection('weight_loss_users');
                collref.add({
                  'name': nameController.text,
                  'email':emailController.text,
                  'age':ageController.text,
                  'height':heightFeetController.text,
                  'gender':genderController.text,
                  'activity_level':activityLevelController.text,
                  'cweight':currentWeightController.text,
                  'gweight':goalWeightController.text,
                   'id':idController.text,
                }).then((value) {
                  print("User Added in firebase");
                }).catchError((error) {
                  print("Failed to add user in firebase: $error");
                });
                String? nameUser=await getNameFromEmail(emailController.text.toString());

                if (_validateFields()) {

                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  await prefs.setString('selectedPage', 'weightloss');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Your goal is set Sucessfully.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (BuildContext context) => lossdashboaard(),
                        settings: RouteSettings(arguments: nameUser)
                    ),
                  );

                }
              },
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                fixedSize: Size(130, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.purple,
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ), foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildActivityLevelField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Activity Level', // Set the labelText here
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purple),
              ),
            ),
            value: selectedActivityLevel,
            onChanged: (value) {
              setState(() {
                selectedActivityLevel = value;
                activityLevelController.text = value ?? '';
                // print(activityLevelController.text.toString());
                activityLevelError = ''; // Clear activity level error when selected
                checkErrors(); // Check for other errors
              });
            },
            items: [
              DropdownMenuItem(
                value: 'Sedentary',
                child: Text('Sedentary'),
              ),
              DropdownMenuItem(
                value: 'Lightly active',
                child: Text('Lightly active'),
              ),
              DropdownMenuItem(
                value: 'Moderately active',
                child: Text('Moderately active'),
              ),
              DropdownMenuItem(
                value: 'Very active',
                child: Text('Very active'),
              ),
              DropdownMenuItem(
                value: 'Extra active',
                child: Text('Extra active'),
              ),
            ],
          ),
          if (activityLevelError.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              activityLevelError,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildAgeField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter Age',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purple),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            ),
            onChanged: (value) {
              setState(() {
                ageError = _validateAge(value); // Validate age as user types
                checkErrors(); // Check for new errors
              });
            },
          ),
          if (ageError.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              ageError,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
  Widget buildTextFieldWithValidations(
      String labelText,
      TextEditingController controller,
      String errorText,
      Function(String) onChanged,
      String? Function(String)? validator,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            onChanged: (value) {
              onChanged(value);
              // Call the validator function when the user types
              setState(() {
                errorText = validator!(controller.text) ?? '';
              });
            },
            decoration: InputDecoration(
              labelText: labelText,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purple),
              ),
              contentPadding:
              EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            ),
            keyboardType: TextInputType.number,
            onSubmitted: (_) {
              // Call the validator function when the user submits
              setState(() {
                errorText = validator!(controller.text) ?? '';
              });
            },
          ),
          if (errorText.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              errorText,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  void _checkGoalWeightSuitability() {
    // Cancel the previous Timer if it's active
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Set a new Timer to call _checkWeightSuitability after 800 milliseconds (adjust as needed)
    _debounce = Timer(Duration(milliseconds: 800), () {
      // Call _checkWeightSuitability after the debounce period
      _checkWeightSuitability();
    });
  }

  void _checkWeightSuitability() {
    // Validate input fields
    if (!_validateFields()) {
      return;
    }

    // Get weight and height in appropriate units
    double weight = double.parse(currentWeightController.text);
    double heightFeet = double.parse(heightFeetController.text);
    double heightInMeters = heightFeet * 0.3048; // Convert feet to meters

    // Validate height
    if (heightInMeters <= 0) {
      _showErrorDialog("Height cannot be zero or negative.");
      return;
    }

    // Calculate BMI using the standard formula
    double bmi = calculateBMI(weight, heightInMeters);

    // Interpret BMI based on standard categories
    String bmiInterpretation;
    if (bmi < 18.5) {
      bmiInterpretation = "Underweight";
      double idealWeightMin = 18.5 * heightInMeters * heightInMeters;
      double idealWeightMax = 24.9 * heightInMeters * heightInMeters;
      _showBMIResultDialog(
          "Your BMI is $bmi ($bmiInterpretation). You are considered underweight. We recommend gaining between ${idealWeightMin.toStringAsFixed(1)} and ${idealWeightMax.toStringAsFixed(1)} kgs.");
    } else if (bmi < 25) {
      bmiInterpretation = "Normal weight";
      double idealWeightMin = 18.5 * heightInMeters * heightInMeters;
      double idealWeightMax = 24.9 * heightInMeters * heightInMeters;
      if (weight < idealWeightMin || weight > idealWeightMax) {
        double suggestedWeight = (idealWeightMin + idealWeightMax) / 2;
        String suggestion =
            'Your goal weight is not within the ideal range for your height and BMI. We suggest aiming for ${suggestedWeight.toStringAsFixed(1)} kgs.';
        _showSuggestionDialog(suggestion);
      } else {
        _showBMIResultDialog("Your BMI is $bmi ($bmiInterpretation). Maintain your current weight as it is already within the normal range.");
      }
    } else if (bmi < 30) {
      bmiInterpretation = "Overweight";
      double idealWeightMin = 18.5 * heightInMeters * heightInMeters;
      double idealWeightMax = 24.9 * heightInMeters * heightInMeters;
      if (weight < idealWeightMin || weight > idealWeightMax) {
        double suggestedWeight = (idealWeightMin + idealWeightMax) / 2;
        String suggestion =
            'Your goal weight is not within the ideal range for your height and BMI. We suggest aiming for ${suggestedWeight.toStringAsFixed(1)} kgs.';
        _showSuggestionDialog(suggestion);
      }
    } else {
      bmiInterpretation = "Obese";
      double idealWeightMin = 18.5 * heightInMeters * heightInMeters;
      double idealWeightMax = 24.9 * heightInMeters * heightInMeters;
      if (weight < idealWeightMin || weight > idealWeightMax) {
        double suggestedWeight = (idealWeightMin + idealWeightMax) / 2;
        String suggestion =
            'Your goal weight is not within the ideal range for your height and BMI. We suggest aiming for ${suggestedWeight.toStringAsFixed(1)} kgs.';
        _showSuggestionDialog(suggestion);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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
  }

  void _showBMIResultDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('BMI Result',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.purple,fontSize: 18,),),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  void _showSuggestionDialog(String suggestion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('BMI Result',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.purple,fontSize: 18,),),
          content: Text(suggestion),
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
  }

  double calculateBMI(double weightInKg, double heightInMeters) {
    return weightInKg / (heightInMeters * heightInMeters);
  }
  Widget buildTextField(
      String labelText,
      TextEditingController controller,
      String errorText,
      Function(String) onChanged,
      TextInputType keyboardType,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            onChanged: (value) {
              onChanged(value);
            },
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
              labelText: labelText,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purple),
              ),
              contentPadding:
              EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            ),
          ),
          if (errorText.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              errorText,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildTextFieldWithValidation(
      String labelText,
      TextEditingController controller,
      String errorText,
      Function(String) onChanged,
      String? Function(String)? validator,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            onChanged: (value) {
              onChanged(value);
              // Call the validator function when the user types
              setState(() {
                errorText = validator!(controller.text) ?? '';
              });
            },
            decoration: InputDecoration(
              labelText: labelText,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purple),
              ),
              contentPadding:
              EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            ),
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) {
              // Call the validator function when the user submits
              setState(() {
                errorText = validator!(controller.text) ?? '';
              });
            },
          ),
          if (errorText.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              errorText,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
  String _validateId(String id) {
    if (id.isEmpty) {
      return 'ID is required.';
    }
    return '';
  }
  String _validateName(String name) {
    if (name.isEmpty) {
      return 'Name is required.';
    } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(name)) {
      return 'Only letters are allowed.';
    }
    return '';
  }

  String _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required.';
    } else {
      if (!RegExp(
          r'^[a-z]+[a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(email)) {
        return 'Invalid email format. Example: john_doe123@gmail.com, alice123@my-mail.com';
      }

    }
    return '';
  }

  String _validateAge(String age) {
    if (age.isEmpty) {
      return 'Age is required.';
    } else {
      int ageValue = int.tryParse(age) ?? 0;
      if (ageValue < 18 || ageValue > 60) {
        return 'Age should be between 18 and 60.';
      }
    }
    return '';
  }


  String _validateHeightFeet(String feet) {
    if (feet.isEmpty) {
      return 'Height is required.';
    } else {
      int feetValue = int.tryParse(feet) ?? 0;
      if (feetValue < 4 || feetValue > 6) {
        return 'Feet should be between 4 and 6.';
      }
    }
    return '';
  }

  String _validateCurrentWeight(String weight) {
    if (weight.isEmpty) {
      return 'Current weight is required.';
    } else if (!RegExp(r'^\d*$').hasMatch(weight)) {
      return 'Please enter a valid weight in kgs.';
    } else if (double.parse(weight) <= 0) {
      return 'Weight must be greater than zero.';
    }
    return '';
  }

  String _validateGoalWeight(String weight) {
    if (weight.isEmpty) {
      return 'Goal weight is required.';
    } else if (!RegExp(r'^\d*\.?\d*$').hasMatch(weight)) {
      return 'Please enter a valid weight in kgs.';
    } else if (double.parse(weight) >
        double.parse(currentWeightController.text)) {
      return 'Goal weight should be less than current weight.';
    }
    return '';
  }

  bool _validateFields() {
    bool isValid = true;

    if (nameController.text.isEmpty) {
      setState(() {
        nameError = 'Name is required.';
        isValid = false;
      });
    } else {
      setState(() {
        nameError = '';
      });
    }
    if (idController.text.isEmpty) {
      setState(() {
        idError = 'ID is required.';
        isValid = false;
      });
    } else {
      setState(() {
        idError = _validateId(idController.text);
      });
    }

    if (emailController.text.isEmpty) {
      setState(() {
        emailError = 'Email is required.';
        isValid = false;
      });
    } else {
      setState(() {
        emailError = _validateEmail(emailController.text);
      });
    }

    if (ageController.text.isEmpty) {
      setState(() {
        ageError = 'Age is required.';
        isValid = false;
      });
    } else {
      setState(() {
        ageError = _validateAge(ageController.text);
      });
    }

    if (heightFeetController.text.isEmpty) {
      setState(() {
        heightFeetError = 'Height is required.';
        isValid = false;
      });
    } else {
      setState(() {
        heightFeetError = '';
      });
    }

    if (currentWeightController.text.isEmpty) {
      setState(() {
        currentWeightError = 'Current weight is required.';
        isValid = false;
      });
    } else if (!RegExp(r'^\d*$').hasMatch(currentWeightController.text)) {
      setState(() {
        currentWeightError = 'Please enter a valid weight in kgs.';
        isValid = false;
      });
    } else if (double.parse(currentWeightController.text) <= 0) {
      setState(() {
        currentWeightError = 'Weight must be greater than zero.';
        isValid = false;
      });
    } else {
      setState(() {
        currentWeightError = '';
      });
    }

    if (goalWeightController.text.isEmpty) {
      setState(() {
        goalWeightError = 'Goal weight is required.';
        isValid = false;
      });
    } else if (!RegExp(r'^\d*\.?\d*$').hasMatch(goalWeightController.text)) {
      setState(() {
        goalWeightError = 'Please enter a valid weight in kgs.';
        isValid = false;
      });
    } else if (double.parse(goalWeightController.text) >
        double.parse(currentWeightController.text)) {
      setState(() {
        goalWeightError =
        'Goal weight should be less than current weight.';
        isValid = false;
      });
    } else {
      setState(() {
        goalWeightError = '';
      });
    }
    if (selectedGender == null) {
      setState(() {
        genderError = 'Gender selection is required.';
        isValid = false;
      });
    } else {
      setState(() {
        genderError = '';
      });
    }
    if (selectedActivityLevel == null) {
      setState(() {
        activityLevelError = 'Activity Level selection is required.';
      });
      return false;
    } else {
      setState(() {
        activityLevelError = '';
      });
    }


    return isValid;
  }

  void checkErrors() {
    setState(() {
      hasError = nameError.isNotEmpty ||
          emailError.isNotEmpty ||
          ageError.isNotEmpty ||
          heightFeetError.isNotEmpty ||
          currentWeightError.isNotEmpty ||
          genderError.isNotEmpty||
          activityLevelError.isNotEmpty||
          goalWeightError.isNotEmpty||
          idError.isNotEmpty;
    });
  }
  Future<Database?> openDB() async{
    _database=await DatabaseHandler().openDB();

    return _database;
  }
  Future<void> insertDB()async {
    _database = await openDB();
    UserRepo userRepo = new UserRepo();
    userRepo.createlTable(_database!);

    UserModel userModel = new UserModel(nameController.text.toString(),
        emailController.text.toString(),
        int.tryParse(ageController.text.toString())!,
        int.tryParse(heightFeetController.text.toString())!,
        genderController.text.toString(),
        activityLevelController.text.toString(),
        int.tryParse(currentWeightController.text.toString())!,
        int.tryParse(goalWeightController.text.toString())!);
    await _database?.insert('WEIGHTLOSSUSER', userModel.toMap());

    //

    if (await EmailExists(emailController.text.toString())) {
      print("email exists!!!!!!!!!!!!!!!!!!!!!!!!!");
    }
    else {


      print('email doesnot exists ...this is new user');
    }
    // await _database?.close();
  }
  Future<void> getFromweightlossusers()async{
    _database=await openDB();
    UserRepo userRepo=new UserRepo();
    await userRepo.getweightlossusers(_database!);

    //   await _database?.close();
  }
  Future<String?> getNameFromEmail(String email) async {
    _database=await openDB();
    List<Map<String, dynamic>> result = await _database!.query(
      'WEIGHTLOSSUSER',
      columns: ['name'],
      where: 'email = ?',
      whereArgs: [email],
    );
    String? name;
    if (result.isNotEmpty) {
      name = result[0]['name'];
    }
    await _database!.close();
    return name;
  }
  Future<bool> EmailExists(String email) async {
    _database=await openDB();
    UserRepo userRepo=new UserRepo();
    if(await userRepo.EmailExists(_database!,email)) {
      return true;
    }
    else{
      return false;
    }
  }

}
