
import 'package:fitnessapp/nextpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class welcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/images/getstarted.json'), // Replace with your animation file path
            SizedBox(height: 100), // Adjust the height as needed// Adjust the height as needed
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add padding for better text alignment
              child: Text(
                'Welcome to GritFit! Get ready to transform your fitness journey with our tailored workouts, nutrition plans, and progress tracking.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54,fontStyle: FontStyle.italic), // Adjust text style as needed
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => page()), // Replace with your next page widget
                );
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(250, 50), // Set width and height
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Add rounded corners
                backgroundColor: Colors.purple,
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Style the text
                foregroundColor: Colors.white,
              ),
              child: Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
