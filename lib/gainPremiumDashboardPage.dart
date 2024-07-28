import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitnessapp/userchat.dart';
import 'idstorge.dart';
import 'nextpage.dart';
import 'package:fitnessapp/pgainmeal.dart';
import 'package:fitnessapp/recipe%20page.dart';
import 'package:fitnessapp/servicechecker.dart';
import 'package:fitnessapp/stepcounter.dart';
import 'package:fitnessapp/user_repo.dart';
import 'package:fitnessapp/workout.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'chatboat.dart';
import 'database_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class preminum extends StatefulWidget {
  const preminum({Key? key}) : super(key: key);
  @override
  State<preminum> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<preminum> {
  TextEditingController emailController = TextEditingController();
  Database? _database;
  String username = '';
  int _unreadMessageCount = 0;
  bool _isOverlayVisible = false;
  OverlayEntry? _overlayEntry;


  @override
  void initState() {
    super.initState();
    loadUsername();
    SharedPreferences.getInstance().then((prefs) {
      bool hasShownDialog = prefs.getBool('showUserForminfo') ?? false;
      print("not shown before");
      if (!hasShownDialog) { // Show the dialog only if it has not been shown before
        Future.delayed(Duration(seconds: 2), () {
          //  _showWelcomeDialog(context);
          _showEmailPopup(context);
          prefs.setBool('showUserForminfo',
              true); // Set flag to indicate the dialog has been shown
        });
      }
    });
    _startListeningForUnreadMessages(); // Start listening for unread messages
  }

  @override
  void dispose() {
    super.dispose();
    _overlayEntry?.remove(); // Clean up the overlay when the widget is disposed
  }
  //overlay
  OverlayEntry _createOverlayEntryhome(BuildContext context) {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100.0, // Position above the FloatingActionButton
        right: MediaQuery.of(context).size.width / 1.5 - 50, // Center horizontally
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'home',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  OverlayEntry _createOverlayEntrychat(BuildContext context) {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100.0, // Position above the FloatingActionButton
        right: MediaQuery.of(context).size.width / 2 - 50, // Center horizontally
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'chat',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //overlay
  OverlayEntry _createOverlayEntryoffer(BuildContext context) {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100.0, // Position above the FloatingActionButton
        right: MediaQuery.of(context).size.width / 4- 50, // Center horizontally
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 120,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'premimum offer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
//home
  void _showOverlayhome(BuildContext context) {
    if (!_isOverlayVisible) {
      _overlayEntry = _createOverlayEntryhome(context);
      Overlay.of(context)?.insert(_overlayEntry!);
      _isOverlayVisible = true;

      // Automatically remove the overlay after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        if (_isOverlayVisible) {
          _overlayEntry?.remove();
          _isOverlayVisible = false;
        }
      });
    }
  }
  //chat
  void _showOverlaychat(BuildContext context) {
    if (!_isOverlayVisible) {
      _overlayEntry = _createOverlayEntrychat(context);
      Overlay.of(context)?.insert(_overlayEntry!);
      _isOverlayVisible = true;

      // Automatically remove the overlay after 2 seconds
      Future.delayed(Duration(seconds: 2), () {
        if (_isOverlayVisible) {
          _overlayEntry?.remove();
          _isOverlayVisible = false;
        }
      });
    }
  }
  //offer
  void _showOverlayoffer(BuildContext context) {
    if (!_isOverlayVisible) {
      _overlayEntry = _createOverlayEntryoffer(context);
      Overlay.of(context)?.insert(_overlayEntry!);
      _isOverlayVisible = true;

      // Automatically remove the overlay after 2 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (_isOverlayVisible) {
          _overlayEntry?.remove();
          _isOverlayVisible = false;
        }
      });
    }
  }


  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    print("called loadmethod");
    setState(() {
      username = prefs.getString('username') ?? '';
    });
    print("$username  in load method");
  }

  Future<void> storeUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    print("$username instoringfunction");
  }

  Future<void> _showEmailPopup(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('To ensure seemless access to\n premium benefits,please \nenter your Email address.', style: TextStyle(
                  color: Colors.purple,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
              content: TextField(
                controller: emailController,
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    String email = emailController.text.trim();
                    if (email.isNotEmpty) {
                      bool emailExists = await checkEmailExists(email);
                      if (emailExists) {
                        sendEmail(
                          emailController.text,
                          'Hello User!',
                          'Welcome! You are using the unpaid version of GritFit. Enjoy some extra features after getting paid. Thanks...',
                        );
                        getcurrentweightgainuser(emailController.text
                            .toString());
                        CollectionReference collref = FirebaseFirestore.instance
                            .collection('pkg_payment_users');
                        collref.add({
                          'email': emailController.text,
                        }).then((value) {
                          print("User Added in firebase");
                        }).catchError((error) {
                          print("Failed to add user in firebase: $error");
                        });
                        String email = emailController.text.toString();
                        String? name = await getNameFromEmail(email);
                        if (name != null) {
                          Navigator.of(context).pop();
                          setState(() {
                            username = name; // Update username in the state
                          });
                          print("$username in dailogue");
                          await storeUsername(name);
                        } else {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Error'),
                                content: Text(
                                    'Email not found in the database. Please try again.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close error dialog
                                      emailController.clear();
                                    },
                                    child: Text('Try Again'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      } else {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text(
                                  'This email is not the same as the previously entered email. Please try again.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close error dialog
                                    emailController.clear();
                                    _showEmailPopup(
                                        context); // Reopen the original email entering dialog box
                                  },
                                  child: Text('OK Fine'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: Text(
                      'Continue', style: TextStyle(color: Colors.purple)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showWelcomeDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text("Welcome!"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      "Welcome to the premium offer! We're glad to have you here."),
                  SizedBox(height: 20),
                  Text('Enter Your Confirm Email',
                      style: TextStyle(color: Colors.purple)),
                  TextField(
                    controller: emailController,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                      "Continue", style: TextStyle(color: Colors.purple)),
                  onPressed: () async {
                    String email = emailController.text.trim();
                    if (email.isNotEmpty) {
                      bool emailExists = await checkEmailExists(email);
                      if (emailExists) {
                        sendEmail(
                          emailController.text,
                          'Hello User!',
                          'Welcome! You are using the paid version of GritFit. Enjoy some extra features after getting paid. Thanks...',
                        );
                        // String userEmail = emailController.text;
                        // sendEmail(
                        //   'agritfit@gmail.com',
                        //   'Payment Received',
                        //   'A new payment has been received from User $userEmail',
                        // );
                        getcurrentweightgainuser(emailController.text
                            .toString());
                        String email = emailController.text.toString();
                        String? name = await getNameFromEmail(email);
                        if (name != null) {
                          Navigator.of(context).pop();
                        } else {
                          _showErrorDialog(
                              'Email not found in the database. Please try again.');
                        }
                      } else {
                        _showErrorDialog(
                            'This email is not the same as the previously entered email. Please try again.');
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                emailController.clear();
              },
              child: Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> checkEmailExists(String email) async {
    // Implement your logic to check if the email exists in the database
    // Return true if the email exists, false otherwise
    _database = await openDB();
    UserRepo userRepo = new UserRepo();
    if (await userRepo.isEmailExists(_database!, email)) {
      return true;
    }
    else {
      return false;
    }
    await _database?.close();
  }


  // Get name asynchronously

  @override
  Widget build(BuildContext context) {
    String? usern = ModalRoute
        .of(context)
        ?.settings
        .arguments as String?;
    String displayUsername = usern ??
        username; // Use route argument or stored username
    print("$username useranme variable");
    print("$displayUsername  display variable");
    // Retrieve email from the controller
    String email = emailController.text.toString();
    Future<String?> getName() async {
      String error = 'Dear!!';
      String? name = null;
      if (name == null) {
        String? nam = await getNameFromEmail(email);
        await Future.delayed(Duration(seconds: 1)); //process indicator
        if (nam != null) {
          return nam;
        }
      }
      else {
        return error;
      }
    }

    Future<int?> getAge() async {
      var age = null;
      if (age == null) {
        age = await getAgeFromEmail(email);
        if (age != null) {
          return age;
        }
      }
      else {
        print('age cant fetched');
      }
    }
    Future<int?> getHeight() async {
      var height = null;
      if (height == null) {
        height = await getHeightFromEmail(email);
        if (height != null) {
          return height;
        }
      }
      else {
        print('height cant fetched');
      }
    }
    Future<int?> get_cweight() async {
      var cweight = null;
      if (cweight == null) {
        cweight = await get_cweight_FromEmail(email);
        if (cweight != null) {
          return cweight;
        }
      }
      else {
        print('cweight cant fetched');
      }
    }
    Future<int?> get_gweight() async {
      var gweight = null;
      if (gweight == null) {
        gweight = await get_gweight_FromEmail(email);
        if (gweight != null) {
          return gweight;
        }
      }
      else {
        print('gweight cant fetched');
      }
    }
    Future<String?> getGender() async {
      String? gender = null;
      if (gender == null) {
        gender = await getGenderFromEmail(email);
        if (gender != null) {
          return gender;
        }
      }
      else {
        print('gender cant fetched');
      }
    }
    Future<String?> getActivityLevel() async {
      String error = 'error!!!!!!!!!!!!!!!!!!!!';
      String? activity_level = null;
      if (activity_level == null) {
        activity_level = await getActivityLevelFromEmail(email);
        if (activity_level != null) {
          return activity_level;
        }
      }
      else {
        return error;
      }
    }
    return FutureBuilder<String?>(
      future: getName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the name, show a loading indicator
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          // If there's an error, show an error message
          return Text('Error: ${snapshot.error}');
        } else {
          // If name is fetched successfully, build the UI with the name

          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.purple,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              title: Text(
                                //  name!=null? 'Hello': 'hello $name',
                                'Hello $displayUsername',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                              trailing: Lottie.asset(
                                'assets/images/alien.json',
                                width: 90,
                                height: 150,
                                repeat: true,
                                reverse: true,
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.purple,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50),
                          ),
                        ),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 40,
                          mainAxisSpacing: 30,
                          children: [
                            itemDashboard(
                              'Recipes',
                              'assets/images/rrr.jpg',
                                  () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        RecipePage(),
                                  ),
                                );
                              },
                            ),
                            itemDashboard(
                              'Exercises',
                              'assets/images/ex.jpg',
                                  () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Workout(),
                                  ),
                                );
                              },
                            ),
                            itemDashboard(
                              'Water',
                              'assets/images/dink.jpg',
                                  () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Water(),
                                  ),
                                );
                              },
                            ),
                            itemDashboard(
                              'StepCounter',
                              'assets/images/walk.jpg',
                                  () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => step(),
                                    settings: RouteSettings(
                                        arguments: emailController.text
                                            .toString()),
                                  ),
                                );
                              },
                            ),

                            itemDashboard(
                              'Meal',
                              'assets/images/eaat.png',
                                  () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => pmeal(),
                                    settings: RouteSettings(
                                        arguments: emailController.text
                                            .toString()),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Positioned(
                  top: 27,
                  right: 4,
                  child: IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.exit_to_app_sharp),
                    onPressed: () {
                      showLogoutDialog(context);
                    },
                  ),
                ),
              ],
            ),
            bottomNavigationBar: CurvedNavigationBar(
              backgroundColor: Colors.white,
              color: Colors.purple,
              animationDuration: Duration(milliseconds: 300),
              items: [
                Icon(Icons.home, color: Colors.white),
                GestureDetector(
                  onLongPress: () {
                    _showOverlaychat(context);// Show overlay on long press
                  },
                  child: Icon(Icons.message_outlined, color: Colors.white),
                ),
                GestureDetector(
                  onLongPress: () {
                    _showOverlayoffer(context); // Show overlay on long press
                  },
                  child: Icon(Icons.star, color: Colors.white),
                ),
              ],
              onTap: (index) {
                if (index == 1) {
                  _showMessageOptions(); // Show message options when message icon is tapped
                } else if (index == 2) {
                  _showPremiumDialog(); // Show premium dialog when star icon is tapped
                } else if (index == 0) {
                  _showOverlayhome(context);
                  navigateToPage(preminum());
                }
              },
            ),
          );
        }
      },
    );
  }


  void _showMessageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 190,
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _navigateToChatScreen(context, isChatbot: true);
                },
                title: Text('Chat with Chatbot'),
                leading: Icon(Icons.chat),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _navigateToChatScreen(context, isChatbot: false);
                },
                title: Text('Chat with Dietitian'),
                leading: Icon(Icons.person),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToChatScreen(BuildContext context, {required bool isChatbot}) async {
    if (isChatbot) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatBot(isChatBot: true)),
      );
    } else {
      String? userId = await idstorage.getUserId(); print('$userId userid from weightgain ');
      if (userId == null) {
        // Generate and store a new user ID if not already stored
        print("generted new id");

        userId = DateTime.now().millisecondsSinceEpoch.toString();
        await idstorage.storeUserId(userId);
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserChatScreen(userId: userId!)),
      );
    }
  }






  void _startListeningForUnreadMessages() async {
    String? userId = await idstorage .getUserId();
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .where('isFromDietitian', isEqualTo: true)
          .where('hasreplied', isEqualTo: false)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        setState(() {
          _unreadMessageCount = snapshot.size;
        });
      });
    }
  }





  Widget itemDashboard(String title, String imagePath, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 5),
                color: Theme
                    .of(context)
                    .primaryColor
                    .withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(imagePath, width: 90, height: 70),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );


  void navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void showLogoutDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    bool showError = false;
    bool showEmailField = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Exit',
                style: TextStyle(
                  fontSize: 17, // Example font size
                  fontWeight: FontWeight.bold, // Example font weight
                  color: Colors.purple, // Example text color
                ),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Are you sure you want to exit?'),
                  if (showEmailField)
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: showError ? 'Please enter your email' : null,
                      ),
                      onChanged: (value) {
                        if (showError && value.isNotEmpty) {
                          setState(() {
                            showError = false;
                          });
                        }
                      },
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss the dialog
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    if (showEmailField) {
                      if (emailController.text.isEmpty) {
                        setState(() {
                          showError = true;
                        });
                      } else {
                        bool emailExists = await checkEmailExists(emailController.text);
                        if (emailExists) {
                          clearSharedPreferences();
                          await deleteUser(emailController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Exit successfully'),
                            ),
                          );
                          navigateToNextPage();
                        } else {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Error'),
                                content: Text('Email not found in the database. Please try again.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close error dialog
                                      emailController.clear();
                                    },
                                    child: Text('Try Again'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    } else {
                      setState(() {
                        showEmailField = true;
                      });
                    }
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Future<void> deleteUser(String email) async {
    final db = await _database;
    await db!.delete(
      'WEIGHTGAINUSER',
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  void clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data stored in SharedPreferences
  }

  void navigateToNextPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page()),
    );
  }

  Future<Database?> openDB() async{
    _database=await DatabaseHandler().openDB();

    return _database;
  }
  Future<void> getcurrentweightgainuser(String email)async{
    _database=await openDB();
    UserRepo userRepo=new UserRepo();
    await userRepo.getcurrentweightgainuser(_database!, email);
    //await _database?.close();
  }
  Future<String?> getNameFromEmail(String email) async {
    _database=await openDB();
    List<Map<String, dynamic>> result = await _database!.query(
      'WEIGHTGAINUSER',
      columns: ['name'],
      where: 'email = ?',
      whereArgs: [email],
    );
    String? name;
    if (result.isNotEmpty) {
      name = result[0]['name'];
    }
    //await _database!.close();
    return name;
  }
  Future<int> getAgeFromEmail(String email) async {
    _database=await openDB();
    List<Map<String, dynamic>> result = await _database!.query(
      'WEIGHTGAINUSER',
      columns: ['age'],
      where: 'email = ?',
      whereArgs: [email],
    );
    var age;
    if (result.isNotEmpty) {
      age = result[0]['age'];
    }
    // await _database!.close();
    return age;
  }
  Future<int> getHeightFromEmail(String email) async {
    _database=await openDB();
    List<Map<String, dynamic>> result = await _database!.query(
      'WEIGHTGAINUSER',
      columns: ['height'],
      where: 'email = ?',
      whereArgs: [email],
    );
    var height;
    if (result.isNotEmpty) {
      height = result[0]['height'];
    }
    // await _database!.close();
    return height;
  }
  Future<int> get_cweight_FromEmail(String email) async {
    _database=await openDB();
    List<Map<String, dynamic>> result = await _database!.query(
      'WEIGHTGAINUSER',
      columns: ['cweight'],
      where: 'email = ?',
      whereArgs: [email],
    );
    var cweight;
    if (result.isNotEmpty) {
      cweight = result[0]['cweight'];
    }
   // await _database!.close();
    return cweight;
  }
  Future<int> get_gweight_FromEmail(String email) async {
    _database=await openDB();
    List<Map<String, dynamic>> result = await _database!.query(
      'WEIGHTGAINUSER',
      columns: ['gweight'],
      where: 'email = ?',
      whereArgs: [email],
    );
    var gweight;
    if (result.isNotEmpty) {
      gweight = result[0]['gweight'];
    }
    //await _database!.close();
    return gweight;
  }
  Future<String?> getGenderFromEmail(String email) async {
    _database=await openDB();
    List<Map<String, dynamic>> result = await _database!.query(
      'WEIGHTGAINUSER',
      columns: ['gender'],
      where: 'email = ?',
      whereArgs: [email],
    );
    String? gender;
    if (result.isNotEmpty) {
      gender = result[0]['gender'];
    }
   // await _database!.close();
    return gender;
  }
  Future<String?> getActivityLevelFromEmail(String email) async {
    _database=await openDB();
    List<Map<String, dynamic>> result = await _database!.query(
      'WEIGHTGAINUSER',
      columns: ['activity_level'],
      where: 'email = ?',
      whereArgs: [email],
    );
    String? activity_level;
    if (result.isNotEmpty) {
      activity_level = result[0]['activity_level'];
    }
  //  await _database!.close();
    return activity_level;
  }
  Future<void> sendEmail(String recipient, String subject, String message) async {
    // Replace with your email and password
    String username = 'agritfit@gmail.com';
    String password = 'dmehtpvtnacfuhpm';

    final smtpServer = gmail(username, password);

    final emailMessage = Message()
      ..from = Address(username, 'GritFit')
      ..recipients.add(recipient)
      ..subject = subject
      ..text = message;

    try {
      final sendReport = await send(emailMessage, smtpServer);
      print('Message sent: ' + sendReport.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail is sent on your account.'),
        ),
      );
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong ,cant send email'),
          ),
        );
      }
    }
  }
  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Premium Offer'),
          content: Text(
            'You are already in preminum mode',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('ok'),
            ),
          ],
        );
      },
    );
  }

}