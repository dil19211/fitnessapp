import 'package:fitnessapp/weightgaintable.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'approved table.dart';
import 'losstable.dart';
import 'nextpage.dart';

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
      ),
      body: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
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
              // Replace with the actual path to your Lottie animation file
              width: 280,
              height: 250, // Adjust the height as needed
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
                    // Background color for Weight Gain TextField
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blue[50], // Fill color same as container color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                          // borderSide: BorderSide(color: Colors.blue, width: 7),
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
                    // Background color for Weight Loss TextField
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.deepPurple.shade400.withOpacity(0.2),
                        // Fill color same as container color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                          // borderSide: BorderSide(color: Colors.deepPurple, width: 3),
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
                    // Background color for Payment TextField
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.green.shade400.withOpacity(0.2), // Fill color same as container color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                          // borderSide: BorderSide(color: Colors.green, width: 3),
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
                  SizedBox(height: 25),
                  Container(
                    // Background color for Dietitian TextField
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.pink.shade400.withOpacity(0.2),
                        // Fill color same as container color
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                          // borderSide: BorderSide(color: Colors.pink, width: 3),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                          borderSide: BorderSide(color: Colors.pink, width: 2),
                        ),
                      ),
                      readOnly: true,
                      style: TextStyle(
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.pink,
                            blurRadius: 1,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      controller: TextEditingController(
                        text: 'Dietitian',
                      ),
                      onTap: () {
                        // Implement navigation or other functionality here
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => page()),
                        );
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
}
