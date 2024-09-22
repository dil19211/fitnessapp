import 'dart:async';
import 'package:fitnessapp/lossdashboard.dart';
import 'package:fitnessapp/weightgaindashboard.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'adminpanel.dart';
import 'dietionchatpanel.dart';
import 'getstarted page.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateToSelectedDashboard();
  }

  Future<void> navigateToSelectedDashboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedPage = prefs.getString('selectedPage');

    Widget dashboard;

    // Check if the selectedPage is null or empty
    if (selectedPage == null || selectedPage.isEmpty) {
      // If no selection is made, clear all stored data
      await prefs.clear();
      // Navigate to the welcome page or any default page
      dashboard = Welcome(); // Replace with your default page
    } else {
      // If a selection is made, navigate to the respective dashboard
      switch (selectedPage) {
        case 'weightgain':
          dashboard = dashboaard();
          break;
        case 'weightloss':
          dashboard = lossdashboaard();
          break;
        case 'login':
          dashboard = admin();
          break;
        case 'dietlogin':
          dashboard = DietitianChatScreen();
          break;
        default:
        // Handle any other cases here
          dashboard = Welcome(); // Replace with your default page
          break;
      }
    }

    // Navigate to the dashboard after 5 seconds
    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => dashboard,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Your splash screen UI here
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/images/pics.json',height: 300,width: 300,reverse: true,repeat: true,), // Replace with your animation file path
            // Adjust spacing as needed
            Text(
              '',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900,color: Colors.purple,fontStyle: FontStyle.italic,),
            ),
          ],
        ), // Placeholder for the splash screen UI
      ),
    );
  }
}
