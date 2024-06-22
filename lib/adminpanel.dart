import 'package:fitnessapp/weightgaintable.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'approved table.dart';

import 'login.dart';
import 'losstable.dart';
import 'nextpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
class admin extends StatelessWidget {
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
            icon: Icon(Icons.exit_to_app,color: Colors.white,),
            onPressed: () {
              showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Center(
              child: Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.purple.shade900,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  shadows: [
                    Shadow(
                      color: Colors.deepPurple,
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
            // Lottie Animation
            Lottie.asset(
              'assets/images/admin.json',
              width: 280,
              height: 250,
              repeat: true,
              reverse: true,
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                      readOnly: true,
                      style: TextStyle(
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.blue,
                            blurRadius: 1,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      controller: TextEditingController(
                        text: 'Weight Gain',
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => gaintable(),
                        ));
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.deepPurple.shade400.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                        ),
                      ),
                      readOnly: true,
                      style: TextStyle(
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.purple,
                            blurRadius: 1,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      controller: TextEditingController(
                        text: 'Weight Loss',
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => tableloss(),
                        ));
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.green.shade400.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                      ),
                      readOnly: true,
                      style: TextStyle(
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.green,
                            blurRadius: 1,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      controller: TextEditingController(
                        text: 'Payment',
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => Approved(),
                        ));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void navigateToNextPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: ( context) {
        return AlertDialog(
          title: Text('Exit'),
          content: Text('Are you sure you want to exit?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // Clear shared preferences data
                clearSharedPreferences();
                // Navigate to the next page
                navigateToNextPage(context);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }


  void clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data stored in SharedPreferences
  }

    }








