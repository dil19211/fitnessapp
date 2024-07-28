import 'package:fitnessapp/dietlogin.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:fitnessapp/weightgain.dart';
import 'package:fitnessapp/weightloss.dart';
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
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.account_circle_outlined, color: Colors.white),
                onPressed: () {
                  final RenderBox button = context.findRenderObject() as RenderBox;
                  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                  final RelativeRect position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(Offset.zero, ancestor: overlay),
                      button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                    ),
                    Offset.zero & overlay.size,
                  );

                  showMenu<String>(
                    context: context,
                    position: position,
                    items: [
                      PopupMenuItem<String>(
                        value: 'Admin',
                        child: Text('Admin'),
                      ),
                      PopupMenuItem<String>(
                        value: 'Dietitian',
                        child: Text('Dietitian'),
                      ),
                    ],
                  ).then((String? result) {
                    if (result != null) {
                      switch (result) {
                        case 'Admin':
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => LoginPage(),
                          ));
                          break;
                        case 'Dietitian':
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => dietlogin(), // Replace with the appropriate page
                          ));
                      }
                    }
                  });
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
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
                        builder: (BuildContext context) => Weightloss(),
                      ));
                    },
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
