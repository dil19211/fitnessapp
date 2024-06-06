import 'dart:async';
import 'dart:math';
import 'package:async/async.dart';
import 'package:fitnessapp/stepcounter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class weightloss extends StatefulWidget {
  @override
  _weightlossState createState() => _weightlossState();
}

class _weightlossState extends State<weightloss> {

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController heightFeetController = TextEditingController();
  TextEditingController heightInchesController = TextEditingController();
  TextEditingController currentWeightController = TextEditingController();
  TextEditingController goalWeightController = TextEditingController();

  String nameError = '';
  String emailError = '';
  String ageError = '';
  String heightFeetError = '';
  String heightInchesError = '';
  String currentWeightError = '';
  String goalWeightError = '';
  String suitabilityRecommendation = '';

  bool hasError = false;
  Timer? _debounce;
  @override
  void dispose() {
    heightFeetController.dispose();
    heightInchesController.dispose();
    ageController.dispose();
    currentWeightController.dispose();
    goalWeightController.dispose();
    _debounce?.cancel(); // Cancel the timer when disposing the widget
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My FitnessPlanner'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            buildTextField(
              'Enter Age',
              ageController,
              ageError,
                  (value) {
                setState(() {
                  ageError = _validateAge(value);
                  checkErrors();
                });
              },
              TextInputType.number,
            ),
            SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: buildTextFieldWithValidation(
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
                  ),
                ),
                SizedBox(width: 25),
                Expanded(
                  child: buildTextFieldWithValidation(
                    'Enter Height (Inches)',
                    heightInchesController,
                    heightInchesError,
                        (value) {
                      setState(() {
                        heightInchesError = _validateHeightInches(value);
                        checkErrors();
                      });
                    },
                        (value) {
                      if (value.isEmpty) {
                        return 'Height is required.';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            buildTextFieldWithValidation(
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
            buildTextFieldWithValidation(
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
                    !RegExp(r'^\d*$').hasMatch(value)) {
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
                if (_validateFields()) {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  await prefs.setString('selectedPage', 'weightloss');
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (BuildContext context) => step(),
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
                backgroundColor: Colors.purple, // Use backgroundColor instead of primary
                textStyle:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                foregroundColor: Colors.white,              ),
            ),
          ],
        ),
      ),
    );
  }
  void _checkGoalWeightSuitability() {
    // Cancel the previous Timer if it's active
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Set a new Timer to call _checkWeightSuitability after 500 milliseconds (adjust as needed)
    _debounce = Timer(Duration(milliseconds: 600), () {
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
    double heightInches = double.parse(heightInchesController.text);
    double heightInMeters = ((heightFeet * 12) + heightInches) * 0.0254;

    // Validate height
    if (heightInMeters <= 0) {
      _showErrorDialog("Height cannot be zero or negative.");
      return;
    }

    // Calculate BMI using the standard formula
    double bmi = calculateBMI(weight, heightInMeters);
    bool underweightSuggestionShown = false;

// Interpret BMI based on standard categories
    String bmiInterpretation;
    if (bmi < 18.5) {
      bmiInterpretation = "Underweight";
      if (!underweightSuggestionShown) {
        double idealWeightMin = 18.5 * heightInMeters * heightInMeters;
        double weightDifference = idealWeightMin - weight;
        if (weight < idealWeightMin) {
          _showBMIResultDialog(
              "Your BMI is $bmi ($bmiInterpretation). You are considered underweight. We recommend gaining ${weightDifference
                  .toStringAsFixed(1)} kgs.");
          underweightSuggestionShown =true;
          // Set the flag to true after showing the suggestion
        }
      }
    }
    else if (bmi < 25) {

      bmiInterpretation = "Normal weight";
      // Check if the current weight is within the ideal range
      double idealWeightMin = 18.5 * heightInMeters * heightInMeters;
      double idealWeightMax = 24.9 * heightInMeters * heightInMeters;
      if (weight >= idealWeightMin && weight <= idealWeightMax) {
        // Current weight is within the ideal range, suggest maintaining it
        _showBMIResultDialog("Your BMI is $bmi ($bmiInterpretation). You are within the normal weight range. We recommend maintaining your weight.");
        return; // No need to proceed further
      }
      // Check if the goal weight is within the ideal range
      double goalWeight = double.parse(goalWeightController.text);
      if (goalWeight < idealWeightMin || goalWeight > idealWeightMax) {
        // Goal weight is not within the ideal range, suggest aiming for the calculated ideal weight range
        double suggestedWeight = (idealWeightMin + idealWeightMax) / 2;
        String suggestion = 'Your goal weight is not within the ideal range for your height and BMI. We suggest aiming for ${suggestedWeight.toStringAsFixed(1)} kgs for healthy weight gain.';
        _showSuggestionDialog(suggestion);
      } else {
        // Goal weight is within the ideal range
        _showBMIResultDialog("Your BMI is $bmi ($bmiInterpretation). We recommend consulting a healthcare professional for guidance on healthy weight loss.");
      }
    } else if (bmi < 30) {
      bmiInterpretation = "Overweight";
      // Check if the current weight is within the ideal range
      double idealWeightMin = 18.5 * heightInMeters * heightInMeters;
      double idealWeightMax = 24.9 * heightInMeters * heightInMeters;
      if (weight >= idealWeightMin && weight <= idealWeightMax) {
        // Current weight is within the ideal range, suggest maintaining it
        _showBMIResultDialog("Your BMI is $bmi ($bmiInterpretation). You are overweight but your current weight is within the ideal range. We recommend maintaining your weight.");
        return; // No need to proceed further
      }
      // Check if the goal weight is within the ideal range
      double goalWeight = double.parse(goalWeightController.text);
      if (goalWeight < idealWeightMin || goalWeight > idealWeightMax) {
        // Goal weight is not within the ideal range, suggest aiming for the calculated ideal weight range
        double suggestedWeight = (idealWeightMin + idealWeightMax) / 2;
        String suggestion = 'Your goal weight is not within the ideal range for your height and BMI. We suggest aiming for ${suggestedWeight.toStringAsFixed(1)} kgs for healthy weight loss.';
        _showSuggestionDialog(suggestion);
      }
    } else {
      bmiInterpretation = "Obese";
      // Check if the current weight is within the ideal range
      double idealWeightMin = 18.5 * heightInMeters * heightInMeters;
      double idealWeightMax = 24.9 * heightInMeters * heightInMeters;
      if (weight >= idealWeightMin && weight <= idealWeightMax) {
        // Current weight is within the ideal range, suggest maintaining it
        _showBMIResultDialog("Your BMI is $bmi ($bmiInterpretation). You are obese but your current weight is within the ideal range. We recommend maintaining your weight.");
        return; // No need to proceed further
      }
      // Check if the goal weight is within the ideal range
      double goalWeight = double.parse(goalWeightController.text);
      if (goalWeight < idealWeightMin || goalWeight > idealWeightMax) {
        // Goal weight is not within the ideal range, suggest aiming for the calculated ideal weight range
        double suggestedWeight = (idealWeightMin + idealWeightMax) / 2;
        String suggestion = 'Your goal weight is not within the ideal range for your height and BMI. We suggest aiming for ${suggestedWeight.toStringAsFixed(1)} kgs for healthy weight loss.';
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
          title: Text('BMI Result'),
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

  void _showSuggestionDialog(String suggestion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Weight Suggestion'),
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

  double calculateWeightGain(double weight, double height, double currentBMI) {
    return ((18.5 * height * height) - weight);
  }
/////


  // Validation functions, text field builders, and other methods remain unchanged.

  Widget buildTextField(
      String labelText,
      TextEditingController controller,
      String errorText,
      Function(String) onChanged,
      TextInputType keyboardType) {
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
            keyboardType: keyboardType,
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
      String? Function(String) validator) {
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
                errorText = validator(controller.text) ?? '';
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
                errorText = validator(controller.text) ?? '';
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
        return ' Email format. Example: john_doe123@gmail.com,alice123@my-mail.com';
      }
    }
    return '';
  }

  String _validateAge(String age) {
    if (age.isEmpty) {
      return 'Age is required.';
    } else {
      int ageValue = int.tryParse(age) ?? 0;
      if (ageValue < 16 || ageValue > 60) {
        return 'Age should be between 16 and 60.';
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

  String _validateHeightInches(String inches) {
    if (inches.isEmpty) {
      return 'Height is required.';
    } else {
      int inchesValue = int.tryParse(inches) ?? 0;
      if (inchesValue < 1 || inchesValue > 10) {
        return 'Inches should be between 1 and 6.';
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

    if (heightFeetController.text.isEmpty &&
        heightInchesController.text.isEmpty) {
      setState(() {
        heightFeetError = 'Height is required.';
        heightInchesError = 'Height is required.';
        isValid = false;
      });
    } else {
      setState(() {
        heightFeetError = '';
        heightInchesError = '';
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

    return isValid;
  }

  void checkErrors() {
    setState(() {
      hasError = nameError.isNotEmpty ||
          emailError.isNotEmpty ||
          ageError.isNotEmpty ||
          heightFeetError.isNotEmpty ||
          heightInchesError.isNotEmpty ||
          currentWeightError.isNotEmpty ||
          goalWeightError.isNotEmpty;
    });
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Home Page'),
      ),
      body: Center(
        child: Text('Welcome to Home Page!'),
      ),
    );
  }
}


