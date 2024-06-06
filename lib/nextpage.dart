import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:fitnessapp/getstarted%20page.dart';
import 'package:fitnessapp/weightgain.dart';
import 'package:fitnessapp/weightloss.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'adminpanel.dart';
import 'login.dart';

class page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(
          'GriftFit',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: Colors.white,
            ),
            onPressed: () {
              // Navigate to user account page
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => admin(),
              ));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 40),
              // Lottie Animation
              Lottie.asset(
                'assets/images/nextpage.json',
                // Replace with the actual path to your Lottie animation file
                width: 280,
                height: 280, // Adjust the height as needed
                repeat: true,
                reverse: true,
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Choose Your Goal',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 40),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple, width: 3),
                        ),
                      ),
                      readOnly: true,
                      style: TextStyle(
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      controller: TextEditingController(
                        text: 'Weight Gain',
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => WeightGain(),
                        ));
                      },
                    ),
                    SizedBox(height: 30),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple, width: 3),
                        ),
                      ),
                      readOnly: true,
                      style: TextStyle(
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      controller: TextEditingController(
                        text: 'Weight Loss',
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => weightloss(),
                        ));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: IconButton(
              icon: Icon(
                Icons.person,
                color: Colors.purple,
              ),
              onPressed: () {
                // Navigate to dietitian page or perform other actions here
              },
            ),
          ),
        ],
      ),
    );
  }
}