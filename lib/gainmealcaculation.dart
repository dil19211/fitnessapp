
class WeightGainCalculator {

  ///The code uses the Harris-Benedict equation to calculate Basal Metabolic Rate (BMR)
  int calculateTotalCaloriesToGainWeight(int currentWeight, int goalWeight,
      int height, int age, String gender, String activityLevel,
      {int monthsToReach = 2}) {
    double bmr;
    double heightCm = height * 30.48; // 1 foot = 30.48 centimeters

    // Calculate Basal Metabolic Rate (BMR) based on gender
    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) -
          (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) -
          (4.330 * age);
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
      throw ArgumentError(
          "Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    // Calculate total calories needed to reach the goal weight
    double bmrGoal = bmr + ((goalWeight - currentWeight) * 7700 / 365);
    double caloriesToGoal = bmrGoal * selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieSurplus = (goalWeight - currentWeight) * 7700;

    double totalCaloriesNeeded = (caloriesToGoal * daysInPeriod) +
        totalCalorieSurplus;

    return totalCaloriesNeeded.round();
  }


// Calculate daily calories needed to gain weight
  int calculateDailyCaloriesNeededToGainWeight(int currentWeight,
      int goalWeight, int height, int age, String gender, String activityLevel,
      {int monthsToReach = 2}) {
    double bmr;
    double dailyCaloriesNeeded;
    double totalCaloriesNeeded;
    double heightCm = height * 30.48; // 1 foot = 30.48 centimeters

    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) -
          (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) -
          (4.330 * age);
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
      throw ArgumentError(
          "Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    double bmrGoal = bmr + ((goalWeight - currentWeight) * 7700 / 365);
    double caloriesToGoal = bmrGoal * selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieSurplus = (goalWeight - currentWeight) * 7700;

    totalCaloriesNeeded = (caloriesToGoal * daysInPeriod) + totalCalorieSurplus;
    dailyCaloriesNeeded = totalCaloriesNeeded / daysInPeriod;

    return dailyCaloriesNeeded.round();
  }


  int calculateBreakfastCaloriesToGoal(int currentWeight, int goalWeight,
      int height, int age, String gender, String activityLevel,
      {int monthsToReach = 2}) {
    double bmr;
    double totalCaloriesNeeded;
    double breakfastCaloriesNeeded;
    double heightCm = height * 30.48; // 1 foot = 30.48 centimeters

    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) -
          (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) -
          (4.330 * age);
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
      throw ArgumentError(
          "Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    double bmrGoal = bmr + (goalWeight - currentWeight) * 7700 / 365;
    double caloriesToGoal = bmrGoal * selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieDeficit = (currentWeight - goalWeight) * 7700;

    totalCaloriesNeeded =
        (caloriesToGoal * daysInPeriod - totalCalorieDeficit) / 60;

    // Assuming breakfast contributes 25% of the daily calorie intake
    breakfastCaloriesNeeded = totalCaloriesNeeded * 0.30;

    return breakfastCaloriesNeeded.round();
  }

  int calculatelunchfastCaloriesToGoal(int currentWeight, int goalWeight,
      int height, int age, String gender, String activityLevel,
      {int monthsToReach = 2}) {
    double bmr;
    double totalCaloriesNeeded;
    double lunchCaloriesNeeded;
    double heightCm = height * 30.48; // 1 foot = 30.48 centimeters

    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) -
          (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) -
          (4.330 * age);
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
      throw ArgumentError(
          "Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }
    double bmrGoal = bmr + (goalWeight - currentWeight) * 7700 / 365;
    double caloriesToGoal = bmrGoal * selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieDeficit = (currentWeight - goalWeight) * 7700;

    totalCaloriesNeeded =
        (caloriesToGoal * daysInPeriod - totalCalorieDeficit) / 60;

    // Assuming lunch contributes  of the daily calorie intake
    lunchCaloriesNeeded = totalCaloriesNeeded * 0.35;

    return lunchCaloriesNeeded.round();
  }

  int calculatesnackfastCaloriesToGoal(int currentWeight, int goalWeight,
      int height, int age, String gender, String activityLevel,
      {int monthsToReach = 2}) {
    double bmr;
    double totalCaloriesNeeded;
    double snackCaloriesNeeded;
    double heightCm = height * 30.48;
    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) -
          (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) -
          (4.330 * age);
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
      throw ArgumentError(
          "Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    double bmrGoal = bmr + (goalWeight - currentWeight) * 7700 / 365;
    double caloriesToGoal = bmrGoal * selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieDeficit = (currentWeight - goalWeight) * 7700;

    totalCaloriesNeeded =
        (caloriesToGoal * daysInPeriod - totalCalorieDeficit) / 60;


    snackCaloriesNeeded = totalCaloriesNeeded * 0.10;

    return snackCaloriesNeeded.round();
  }

  int calculatedinnerfastCaloriesToGoal(int currentWeight, int goalWeight,
      int height, int age, String gender, String activityLevel,
      {int monthsToReach = 2}) {
    double bmr;
    double totalCaloriesNeeded;
    double dinnerCaloriesNeeded;
    double heightCm = height * 30.48;

    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) -
          (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) -
          (4.330 * age);
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
      throw ArgumentError(
          "Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    double bmrGoal = bmr + (goalWeight - currentWeight) * 7700 / 365;
    double caloriesToGoal = bmrGoal * selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieDeficit = (currentWeight - goalWeight) * 7700;

    totalCaloriesNeeded =
        (caloriesToGoal * daysInPeriod - totalCalorieDeficit) / 60; //total days

    // Assuming breakfast contributes 30% of the daily calorie intake
    dinnerCaloriesNeeded = totalCaloriesNeeded * 0.25;

    return dinnerCaloriesNeeded.round();
  }


  int calculateTotalStepsInPeriod(String activityLevel,
      {int monthsToReach = 2}) {
    // Determine activity level and average daily steps
    int averageDailySteps;

    if (activityLevel.toLowerCase() == 'sedentary') {
      averageDailySteps = 5000; // Rough estimate for a sedentary lifestyle
    } else if (activityLevel.toLowerCase() == 'lightly active') {
      averageDailySteps = 7500; // Rough estimate for a lightly active lifestyle
    } else if (activityLevel.toLowerCase() == 'moderately active') {
      averageDailySteps =
      10000; // Rough estimate for a moderately active lifestyle
    } else if (activityLevel.toLowerCase() == 'very active') {
      averageDailySteps = 12500; // Rough estimate for a very active lifestyle
    } else if (activityLevel.toLowerCase() == 'extra active') {
      averageDailySteps = 15000; // Rough estimate for an extra active lifestyle
    } else {
      throw ArgumentError(
          "Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    // Calculate the number of days in the specified period
    int daysInPeriod = monthsToReach * 30; // Assume each month has 30 days

    // Calculate the total steps needed for the entire period
    int totalSteps = averageDailySteps * daysInPeriod;

    // Return the total steps needed over the period
    return totalSteps.round();
  }


  int calculateTotalStepsInPerioddaily(String activityLevel, {int monthsToReach = 2}) {
    // Determine activity level and average daily steps
    int averageDailySteps;

    if (activityLevel.toLowerCase() == 'sedentary') {
      averageDailySteps = 5000; // Rough estimate for a sedentary lifestyle
    } else if (activityLevel.toLowerCase() == 'lightly active') {
      averageDailySteps = 7500; // Rough estimate for a lightly active lifestyle
    } else if (activityLevel.toLowerCase() == 'moderately active') {
      averageDailySteps = 10000; // Rough estimate for a moderately active lifestyle
    } else if (activityLevel.toLowerCase() == 'very active') {
      averageDailySteps = 12500; // Rough estimate for a very active lifestyle
    } else if (activityLevel.toLowerCase() == 'extra active') {
      averageDailySteps = 15000; // Rough estimate for an extra active lifestyle
    } else {
      throw ArgumentError("Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    // Calculate the number of days in the specified period
    int daysInPeriod = monthsToReach * 30; // Assume each month has 30 days

    // Calculate the total steps needed for the entire period
    int totalSteps = averageDailySteps * daysInPeriod;

    // Calculate the average daily steps needed
    int averageDailyStepsNeeded = totalSteps ~/ daysInPeriod;

    // Return the average daily steps needed over the period
    return averageDailyStepsNeeded.round();
  }
// weightlosss function are there


  int calculateTotalCaloriesTolossWeight(int currentWeight, int goalWeight,
      int height, int age, String gender, String activityLevel,
      {int monthsToReach = 2}) {
    double bmr;
    double heightCm = height * 30.48; // 1 foot = 30.48 centimeters

    // Calculate Basal Metabolic Rate (BMR) based on gender
    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) -
          (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) -
          (4.330 * age);
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
      throw ArgumentError(
          "Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    // Calculate total calories needed to reach the goal weight
    double bmrGoal = bmr - ((goalWeight - currentWeight) * 7700 / 365);
    double caloriesToGoal = bmrGoal * selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieSurplus = (goalWeight - currentWeight) * 7700;

    double totalCaloriesNeeded = (caloriesToGoal * daysInPeriod) +
        totalCalorieSurplus;

    return totalCaloriesNeeded.round();
  }


// Calculate daily calories needed to loss weight
  int calculateDailyCaloriesNeededTolossWeight(int currentWeight,
      int goalWeight, int height, int age, String gender, String activityLevel,
      {int monthsToReach = 2}) {
    double bmr;
    double dailyCaloriesNeeded;
    double totalCaloriesNeeded;
    double heightCm = height * 30.48; // 1 foot = 30.48 centimeters

    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) -
          (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) -
          (4.330 * age);
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
      throw ArgumentError(
          "Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    double bmrGoal = bmr - ((goalWeight - currentWeight) * 7700 / 365);
    double caloriesToGoal = bmrGoal * selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieSurplus = (goalWeight - currentWeight) * 7700;

    totalCaloriesNeeded = (caloriesToGoal * daysInPeriod) + totalCalorieSurplus;
    dailyCaloriesNeeded = totalCaloriesNeeded / daysInPeriod;

    return dailyCaloriesNeeded.round();
  }


  int calculateBreakfastCaloriesToGoalloss(int currentWeight, int goalWeight,
      int height, int age, String gender, String activityLevel,
      {int monthsToReach = 2}) {
    double bmr;
    double totalCaloriesNeeded;
    double breakfastCaloriesNeeded;
    double heightCm = height * 30.48; // 1 foot = 30.48 centimeters

    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) -
          (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) -
          (4.330 * age);
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
      throw ArgumentError(
          "Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    double bmrGoal = bmr - (goalWeight - currentWeight) * 7700 / 365;
    double caloriesToGoal = bmrGoal * selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieDeficit = (currentWeight - goalWeight) * 7700;

    totalCaloriesNeeded =
        (caloriesToGoal * daysInPeriod - totalCalorieDeficit) / 60;

    // Assuming breakfast contributes 25% of the daily calorie intake
    breakfastCaloriesNeeded = totalCaloriesNeeded * 0.30;

    return breakfastCaloriesNeeded.round();
  }

  int calculatelunchfastCaloriesToloss(int currentWeight, int goalWeight,
      int height, int age, String gender, String activityLevel,
      {int monthsToReach = 2}) {
    double bmr;
    double totalCaloriesNeeded;
    double lunchCaloriesNeeded;
    double heightCm = height * 30.48; // 1 foot = 30.48 centimeters

    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) -
          (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) -
          (4.330 * age);
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
      throw ArgumentError(
          "Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }
    double bmrGoal = bmr - (goalWeight - currentWeight) * 7700 / 365;
    double caloriesToGoal = bmrGoal * selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieDeficit = (currentWeight - goalWeight) * 7700;

    totalCaloriesNeeded =
        (caloriesToGoal * daysInPeriod - totalCalorieDeficit) / 60;

    // Assuming lunch contributes  of the daily calorie intake
    lunchCaloriesNeeded = totalCaloriesNeeded * 0.35;

    return lunchCaloriesNeeded.round();
  }

  int calculatesnackfastCaloriesToGoalloss(int currentWeight, int goalWeight,
      int height, int age, String gender, String activityLevel,
      {int monthsToReach = 2}) {
    double bmr;
    double totalCaloriesNeeded;
    double snackCaloriesNeeded;
    double heightCm = height * 30.48;
    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) -
          (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) -
          (4.330 * age);
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
      throw ArgumentError(
          "Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    double bmrGoal = bmr - (goalWeight - currentWeight) * 7700 / 365;
    double caloriesToGoal = bmrGoal * selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieDeficit = (currentWeight - goalWeight) * 7700;

    totalCaloriesNeeded =
        (caloriesToGoal * daysInPeriod - totalCalorieDeficit) / 60;


    snackCaloriesNeeded = totalCaloriesNeeded * 0.10;

    return snackCaloriesNeeded.round();
  }

  int calculatedinnerfastCaloriesToGoalloss(int currentWeight, int goalWeight,
      int height, int age, String gender, String activityLevel,
      {int monthsToReach = 2}) {
    double bmr;
    double totalCaloriesNeeded;
    double dinnerCaloriesNeeded;
    double heightCm = height * 30.48;

    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * currentWeight) + (4.799 * heightCm) -
          (5.677 * age);
    } else if (gender.toLowerCase() == 'female') {
      bmr = 447.593 + (9.247 * currentWeight) + (3.098 * heightCm) -
          (4.330 * age);
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
      throw ArgumentError(
          "Invalid activity level. Please specify one of the following: sedentary, lightly active, moderately active, very active, or extra active.");
    }

    double bmrGoal = bmr - (goalWeight - currentWeight) * 7700 / 365;
    double caloriesToGoal = bmrGoal * selectedActivityLevel;

    int daysInPeriod = monthsToReach * 30;
    double totalCalorieDeficit = (currentWeight - goalWeight) * 7700;

    totalCaloriesNeeded =
        (caloriesToGoal * daysInPeriod - totalCalorieDeficit) / 60; //total days

    // Assuming breakfast contributes 30% of the daily calorie intake
    dinnerCaloriesNeeded = totalCaloriesNeeded * 0.25;

    return dinnerCaloriesNeeded.round();
  }


}






