import 'dart:math';
import 'package:sqflite/sqflite.dart';
class WeightGainCalculator {

  static int steps = 0;
  ///The code uses the Harris-Benedict equation to calculate Basal Metabolic Rate (BMR)
  static double calculateTDEE(double weight, double height, int age,
      String gender, String activityLevel) {
    // Implement TDEE calculation based on weight, height, age, gender, and activity level
    double bmr = 0;
    print('$age!!!!!!!!!!!!!!!!');
    if (gender.toLowerCase() == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else if (gender.toLowerCase() == 'female') {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    double tdee = 0;
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        tdee = bmr * 1.2;
        break;
      case 'lightly active':
        tdee = bmr * 1.375;
        break;
      case 'moderately active':
        tdee = bmr * 1.55;
        break;
      case 'very active':
        tdee = bmr * 1.725;
        break;
      case 'extra active':
        tdee = bmr * 1.9;
        break;
      default:
        tdee = bmr;
    }
    print('$tdee is a TDEE value...........');
    return tdee;

  }

  static double calculateSurplusCalories(double tdee, double goalWeight,
      double weightGainRate) {
    // Calculate surplus calories needed for weight gain based on TDEE, goal weight, and weight gain rate
    double surplusCaloriesPerDay = (goalWeight - tdee) * 7700 /
        (365 * weightGainRate);
    return surplusCaloriesPerDay;
  }

  static double calculateWaterIntake(double totalCalories) {
    // Calculate recommended water intake based on total calories consumed
    double waterIntake = totalCalories / 1000; // 1 ml per 1 calorie
    return waterIntake;
  }

  static int calculateSteps(String activityLevel, double goalSteps) {
    // Determine the number of steps required based on activity level and goals
    int steps = 0;
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        steps = (goalSteps * 0.8).toInt();
        break;
      case 'lightly active':
        steps = goalSteps.toInt();
        break;
      case 'moderately active':
        steps = (goalSteps * 1.2).toInt();
        break;
      case 'very active':
        steps = (goalSteps * 1.5).toInt();
        break;
      case 'extra active':
        steps = (goalSteps * 1.8).toInt();
        break;
      default:
        steps = goalSteps.toInt();
    }
    WeightGainCalculator.steps = steps; // Update the static variable
    return steps;
  }

  static List<String> suggestExercises(String gender, String activityLevel) {
    // Suggest exercises based on gender and activity level
    List<String> suggestedExercises = [];

    if (gender.toLowerCase() == 'male') {
      switch (activityLevel.toLowerCase()) {
        case 'sedentary':
          suggestedExercises.addAll(['Weightlifting', 'Bodyweight exercises']);
          break;
        case 'lightly active':
          suggestedExercises.addAll(['Weightlifting', 'Running']);
          break;
        case 'moderately active':
          suggestedExercises.addAll(['Resistance training', 'Cycling']);
          break;
        case 'very active':
          suggestedExercises.addAll(
              ['High-intensity interval training', 'Swimming']);
          break;
        case 'extra active':
          suggestedExercises.addAll(['CrossFit', 'Boxing']);
          break;
        default:
          suggestedExercises.addAll(['Weightlifting', 'Bodyweight exercises']);
      }
    } else if (gender.toLowerCase() == 'female') {
      switch (activityLevel.toLowerCase()) {
        case 'sedentary':
          suggestedExercises.addAll(['Pilates', 'Yoga']);
          break;
        case 'lightly active':
          suggestedExercises.addAll(['Pilates', 'Running']);
          break;
        case 'moderately active':
          suggestedExercises.addAll(['Resistance training', 'Cycling']);
          break;
        case 'very active':
          suggestedExercises.addAll(
              ['High-intensity interval training', 'Swimming']);
          break;
        case 'extra active':
          suggestedExercises.addAll(['CrossFit', 'Boxing']);
          break;
        default:
          suggestedExercises.addAll(['Pilates', 'Yoga']);
      }
    } else {
      // If gender is not specified or unrecognized, provide general exercise suggestions
      switch (activityLevel.toLowerCase()) {
        case 'sedentary':
          suggestedExercises.addAll(['Yoga', 'Walking']);
          break;
        case 'lightly active':
          suggestedExercises.addAll(['Running', 'Cycling']);
          break;
        case 'moderately active':
          suggestedExercises.addAll(['Swimming', 'Resistance training']);
          break;
        case 'very active':
          suggestedExercises.addAll(
              ['High-intensity interval training', 'CrossFit']);
          break;
        case 'extra active':
          suggestedExercises.addAll(['Marathon running', 'Triathlon']);
          break;
        default:
          suggestedExercises.addAll(['Yoga', 'Walking']);
      }
    }

    return suggestedExercises;
  }

  static double calculateAdditionalWaterIntakeForWeightGainGoal(
      double totalCalories, double totalCaloriesGoal) {
    // Calculate additional water intake to support weight gain goal
    double additionalWaterIntake = (totalCaloriesGoal - totalCalories) /
        1000; // 1 ml per 1 calorie
    return additionalWaterIntake;
  }

  static int calculateAdditionalWaterIntakeInGlassesForWeightGainGoal(
      double totalCalories, double totalCaloriesGoal) {
    // Calculate additional water intake to support weight gain goal
    double additionalWaterIntakeInMilliliters = (totalCaloriesGoal -
        totalCalories) / 1000; // 1 ml per 1 calorie

    // Calculate the number of glasses needed, assuming a standard glass holds 250 milliliters
    int additionalWaterIntakeInGlasses = (additionalWaterIntakeInMilliliters /
        250).ceil();

    return additionalWaterIntakeInGlasses;
  }
  static int calculateExerciseTimePerDay(double currentWeight, double goalWeight, double surplusCaloriesPerDay, double weightGainRate, int desiredFrequencyPerWeek) {
    // Calculate the total time for exercises per day based on exercise frequency and type
    int exerciseFrequency = calculateExerciseFrequency(currentWeight, goalWeight, surplusCaloriesPerDay, weightGainRate, desiredFrequencyPerWeek);

    // Assuming each exercise session lasts for a certain duration, let's say 1 hour for this example
    int exerciseDurationPerSessionInHours = 1;

    // Calculate total time for exercises per day
    int exerciseTimePerDay = (exerciseFrequency * exerciseDurationPerSessionInHours);

    return exerciseTimePerDay;
  }
  static int calculateExerciseFrequency(double currentWeight, double goalWeight, double surplusCaloriesPerDay, double weightGainRate, int desiredFrequencyPerWeek) {
    // Calculate the frequency of exercise (number of times per week) required to reach the goal weight
    int daysToReachGoal = calculateDaysToReachGoal(currentWeight, goalWeight, surplusCaloriesPerDay, weightGainRate);
    int exerciseFrequency = (daysToReachGoal / 7 * desiredFrequencyPerWeek).ceil();
    return exerciseFrequency;
  }

  static int calculateDaysToReachGoal(double currentWeight, double goalWeight, double surplusCaloriesPerDay, double weightGainRate) {
    // Calculate the number of days it will take to reach the goal weight
    double totalWeightGain = goalWeight - currentWeight;
    int daysToReachGoal = (totalWeightGain * 7700 / surplusCaloriesPerDay / weightGainRate * 7).ceil();
    return daysToReachGoal;
  }
  // cacaulate total steps i take until i reached my goal weight
  static int calculateTotalSteps(double currentWeight, double goalWeight, double surplusCaloriesPerDay, double weightGainRate, String activityLevel, double goalSteps) {
    int daysToReachGoal = calculateDaysToReachGoal(currentWeight, goalWeight, surplusCaloriesPerDay, weightGainRate);
    int totalSteps = calculateSteps(activityLevel, goalSteps) * daysToReachGoal;
    return totalSteps;
  }
  Future<double> calculateCalories(int age,int height,int cweight,int gweight,String gender,String activity_level) async { //
    // Await the completion of future objects
    int ageValue = await age;
    int heightValue = await height;
    int cweightValue = await cweight;
    int gweightValue = await gweight;

    // Convert cweightValue and gweightValue to double
    double cweightDouble = cweightValue.toDouble();
    double gweightDouble = gweightValue.toDouble();

    // Calculate BMR
    double bmr;
    if (gender == 'Male') {
      bmr = 10 * cweightDouble + 6.25 * heightValue - 5 * ageValue + 5;
    } else {
      bmr = 10 * cweightDouble + 6.25 * heightValue - 5 * ageValue - 161;
    }

    // Apply activity level multiplier
    double activityMultiplier;
    switch (activity_level) {
      case 'Sedentary':
        activityMultiplier = 1.2;
        break;
      case 'Lightly active':
        activityMultiplier = 1.375;
        break;
      case 'Moderately active':
        activityMultiplier = 1.55;
        break;
      case 'Very active':
        activityMultiplier = 1.725;
        break;
      case 'Extra active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.0;
        break;
    }

    // Calculate TDEE
    double tdee = bmr * activityMultiplier;

    // Calculate calorie deficit or surplus needed to reach goal weight
    double calorieDifferencePerDay = (gweightDouble - cweightDouble) * 7700 / 112; // 7700 calories = 1 kg
    double caloriesForGoalWeight = tdee + calorieDifferencePerDay;

    return caloriesForGoalWeight;
  }
  int calculateTotalCaloriesToGainWeight(int currentWeight, int goalWeight, int height, int age, String gender, String activityLevel, {int monthsToReach = 2}) {
    double bmr;
    double heightCm = height * 30.48; // 1 foot = 30.48 centimeters

    // Calculate Basal Metabolic Rate (BMR) based on gender
    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) - (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) - (4.330 * age);
    } else {
      throw ArgumentError("Invalid gender. Please specify 'male' or 'female'.");
    }

    // Determine activity level multiplier
    double selectedActivityLevel;
    if (activityLevel.toLowerCase() == 'sedentary') {
      selectedActivityLevel = 1.2;
    } else if (activityLevel.toLowerCase() == 'lightly active') {
      selectedActivityLevel = 1.375;
    } else if (activityLevel.toLowerCase() == 'moderately active') {
      selectedActivityLevel = 1.55;
    } else if (activityLevel.toLowerCase() == 'very active') {
      selectedActivityLevel = 1.725;
    } else if (activityLevel.toLowerCase() == 'extra active') {
      selectedActivityLevel = 1.9;
    } else {
      throw ArgumentError("Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    // Calculate total calories needed to reach the goal weight
    double bmrGoal = bmr + ((goalWeight - currentWeight) * 7700 / 365);
    double caloriesToGoal = bmrGoal * selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieSurplus = (goalWeight - currentWeight) * 7700;

    double totalCaloriesNeeded = (caloriesToGoal * daysInPeriod) + totalCalorieSurplus;

    return totalCaloriesNeeded.round();
  }


// Calculate daily calories needed to gain weight
  int calculateDailyCaloriesNeededToGainWeight(int currentWeight, int goalWeight,int height, int age, String gender, String activityLevel, {int monthsToReach = 2}) {
    double bmr;
    double dailyCaloriesNeeded;
    double totalCaloriesNeeded;
    double heightCm = height * 30.48; // 1 foot = 30.48 centimeters

    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) - (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) - (4.330 * age);
    } else {
      throw ArgumentError("Invalid gender. Please specify 'male' or 'female'.");
    }

    double selectedActivityLevel;
    if (activityLevel.toLowerCase() == 'sedentary') {
      selectedActivityLevel = 1.2;
    } else if (activityLevel.toLowerCase() == 'lightly active') {
      selectedActivityLevel = 1.375;
    } else if (activityLevel.toLowerCase() == 'moderately active') {
      selectedActivityLevel = 1.55;
    } else if (activityLevel.toLowerCase() == 'very active') {
      selectedActivityLevel = 1.725;
    } else if (activityLevel.toLowerCase() == 'extra active') {
      selectedActivityLevel = 1.9;
    } else {
      throw ArgumentError("Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    double bmrGoal = bmr + ((goalWeight - currentWeight) * 7700 / 365);
    double caloriesToGoal = bmrGoal * selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieSurplus = (goalWeight - currentWeight) * 7700;

    totalCaloriesNeeded = (caloriesToGoal * daysInPeriod) + totalCalorieSurplus;
    dailyCaloriesNeeded = totalCaloriesNeeded / daysInPeriod;

    return dailyCaloriesNeeded.round();
  }



  int calculateBreakfastCaloriesToGoal(int currentWeight, int goalWeight, int height, int age, String gender, String activityLevel, {int monthsToReach = 2}) {
    double bmr;
    double totalCaloriesNeeded;
    double breakfastCaloriesNeeded;
    double heightCm = height * 30.48; // 1 foot = 30.48 centimeters

    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) - (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) - (4.330 * age);
    } else {
      throw ArgumentError("Invalid gender. Please specify 'male' or 'female'.");
    }
    // Adjust activity level
    double selectedActivityLevel;
    if (activityLevel.toLowerCase() == 'sedentary') {
      selectedActivityLevel = 1.2;
    } else if (activityLevel.toLowerCase() == 'lightly active') {
      selectedActivityLevel = 1.375;
    } else if (activityLevel.toLowerCase() == 'moderately active') {
      selectedActivityLevel = 1.55;
    } else if (activityLevel.toLowerCase() == 'very active') {
      selectedActivityLevel = 1.725;
    } else if (activityLevel.toLowerCase() == 'extra active') {
      selectedActivityLevel = 1.9;
    } else {
      throw ArgumentError("Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    double bmrGoal = bmr + (goalWeight - currentWeight) * 7700 / 365;
    double caloriesToGoal = bmrGoal *  selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieDeficit = (currentWeight - goalWeight) * 7700;

    totalCaloriesNeeded = (caloriesToGoal * daysInPeriod - totalCalorieDeficit)/60;

    // Assuming breakfast contributes 25% of the daily calorie intake
    breakfastCaloriesNeeded = totalCaloriesNeeded * 0.30;

    return breakfastCaloriesNeeded.round();
  }
  int calculatelunchfastCaloriesToGoal(int currentWeight, int goalWeight, int height, int age, String gender, String activityLevel, {int monthsToReach = 2}) {
    double bmr;
    double totalCaloriesNeeded;
    double lunchCaloriesNeeded;
    double heightCm = height * 30.48; // 1 foot = 30.48 centimeters

    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) - (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) - (4.330 * age);
    } else {
      throw ArgumentError("Invalid gender. Please specify 'male' or 'female'.");
    }

    // Adjust activity level
    double selectedActivityLevel;
    if (activityLevel.toLowerCase() == 'sedentary') {
      selectedActivityLevel = 1.2;
    } else if (activityLevel.toLowerCase() == 'lightly active') {
      selectedActivityLevel = 1.375;
    } else if (activityLevel.toLowerCase() == 'moderately active') {
      selectedActivityLevel = 1.55;
    } else if (activityLevel.toLowerCase() == 'very active') {
      selectedActivityLevel = 1.725;
    } else if (activityLevel.toLowerCase() == 'extra active') {
      selectedActivityLevel = 1.9;
    } else {
      throw ArgumentError("Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }
    double bmrGoal = bmr + (goalWeight - currentWeight) * 7700 / 365;
    double caloriesToGoal = bmrGoal *  selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieDeficit = (currentWeight - goalWeight) * 7700;

    totalCaloriesNeeded = (caloriesToGoal * daysInPeriod - totalCalorieDeficit)/60;

    // Assuming lunch contributes  of the daily calorie intake
    lunchCaloriesNeeded = totalCaloriesNeeded * 0.35;

    return lunchCaloriesNeeded.round();
  }
  int calculatesnackfastCaloriesToGoal(int currentWeight,int goalWeight, int height, int age, String gender, String activityLevel, {int monthsToReach = 2}) {
    double bmr;
    double totalCaloriesNeeded;
    double snackCaloriesNeeded;
    double heightCm = height * 30.48; // 1 foot = 30.48 centimeters

    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) - (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) - (4.330 * age);
    } else {
      throw ArgumentError("Invalid gender. Please specify 'male' or 'female'.");
    }
    // Adjust activity level
    double selectedActivityLevel;
    if (activityLevel.toLowerCase() == 'sedentary') {
      selectedActivityLevel = 1.2;
    } else if (activityLevel.toLowerCase() == 'lightly active') {
      selectedActivityLevel = 1.375;
    } else if (activityLevel.toLowerCase() == 'moderately active') {
      selectedActivityLevel = 1.55;
    } else if (activityLevel.toLowerCase() == 'very active') {
      selectedActivityLevel = 1.725;
    } else if (activityLevel.toLowerCase() == 'extra active') {
      selectedActivityLevel = 1.9;
    } else {
      throw ArgumentError("Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    double bmrGoal = bmr + (goalWeight - currentWeight) * 7700 / 365;
    double caloriesToGoal = bmrGoal *  selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieDeficit = (currentWeight - goalWeight) * 7700;

    totalCaloriesNeeded = (caloriesToGoal * daysInPeriod - totalCalorieDeficit)/60;


    snackCaloriesNeeded = totalCaloriesNeeded *0.10 ;

    return snackCaloriesNeeded.round();
  }
  int calculatedinnerfastCaloriesToGoal(int currentWeight, int goalWeight, int height, int age, String gender, String activityLevel, {int monthsToReach = 2}) {
    double bmr;
    double totalCaloriesNeeded;
    double dinnerCaloriesNeeded;
    double heightCm = height * 30.48; // 1 foot = 30.48 centimeters

    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) - (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) - (4.330 * age);
    } else {
      throw ArgumentError("Invalid gender. Please specify 'male' or 'female'.");
    }
    // Adjust activity level
    double selectedActivityLevel;
    if (activityLevel.toLowerCase() == 'sedentary') {
      selectedActivityLevel = 1.2;
    } else if (activityLevel.toLowerCase() == 'lightly active') {
      selectedActivityLevel = 1.375;
    } else if (activityLevel.toLowerCase() == 'moderately active') {
      selectedActivityLevel = 1.55;
    } else if (activityLevel.toLowerCase() == 'very active') {
      selectedActivityLevel = 1.725;
    } else if (activityLevel.toLowerCase() == 'extra active') {
      selectedActivityLevel = 1.9;
    } else {
      throw ArgumentError("Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    double bmrGoal = bmr + (goalWeight - currentWeight) * 7700 / 365;
    double caloriesToGoal = bmrGoal *  selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieDeficit = (currentWeight - goalWeight) * 7700;

    totalCaloriesNeeded = (caloriesToGoal * daysInPeriod - totalCalorieDeficit)/60;//total days

    // Assuming breakfast contributes 30% of the daily calorie intake
    dinnerCaloriesNeeded = totalCaloriesNeeded * 0.25;

    return dinnerCaloriesNeeded.round();
  }


}






//The code uses the Harris-Benedict equation to calculate Basal Metabolic Rate (BMR)
