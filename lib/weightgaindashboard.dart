import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fitnessapp/servicechecker.dart';
import 'package:fitnessapp/unpaidrecipe.dart';
import 'package:fitnessapp/unpiadworkout.dart';
import 'package:fitnessapp/user_repo.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'chatboat.dart';
import 'database_handler.dart';
import 'gainPremiumDashboardPage.dart';
import 'gainmeal.dart';
import 'nextpage.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;

class dashboaard extends StatefulWidget {
  const dashboaard({Key? key}) : super(key: key);

  @override
  State<dashboaard> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<dashboaard> {
  Map<String, dynamic>? paymentIntentData;
  TextEditingController emailController = TextEditingController();
  Database? _database;
  String username = '';
  bool _isOverlayVisible = false;
  OverlayEntry? _overlayEntry;


  @override
  void initState() {
    super.initState();
    loadUsername();
    checkSubscriptionStatus();
    // Show email popup after a delay
    Future.delayed(Duration(seconds: 3), _showEmailPopup);
  }

  Future<void> checkSubscriptionStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isSubscribed = prefs.getBool('isSubscribed') ?? false;
    if (isSubscribed) {
      // Navigate to the premium dashboard
      navigateToPremiumPage();
    }
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
  //exit
  OverlayEntry _createOverlayEntryexit(BuildContext context) {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: 600.0, // Position above the FloatingActionButton
        right: MediaQuery.of(context).size.width / 4- 50, // Center horizontally
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 70,
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
                'Exit',
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
  void _showOverlayexit(BuildContext context) {
    if (!_isOverlayVisible) {
      _overlayEntry = _createOverlayEntryexit(context);
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



  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  Future<void> storeUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<void> navigateToPremiumPage() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => preminum()),
    );
  }

  void _showEmailPopup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    if (isFirstTime) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return AlertDialog(
                title: Text('Enter Your Email account on\n which you want to receive\n emails from GritFit. ', style: TextStyle(
                    color: Colors.purple,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
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
                            'Welcome! you are using the un-paid version of GritFit.Enjoy some extra features after getting paid. Thanks...',
                          );
                          getcurrentweightgainuser(emailController.text
                              .toString());
                          String Email = emailController.text.toString();
                          String? name = await getNameFromEmail(Email);
                          if (name != null) {
                            Navigator.of(context).pop();
                            prefs.setBool('isFirstTime', false);
                            setState(() {
                              username = name; // Update username in the state
                            });
                            await storeUsername(name);
                            //setUserNameFromModalRoute();
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
                                    'This E-mail is not same as previous entered E-mail. Please try again.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close error dialog
                                      emailController.clear();
                                      _showEmailPopup(); // Reopen the original email entering dialog box
                                    }, child: Text('OK Fine'),
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
  }

  Future<bool> checkEmailExists(String email) async {
    // Return true if the email exists, false otherwise
    _database = await openDB();
    UserRepo userRepo = new UserRepo();
    if (await userRepo.isEmailExists(_database!, email)) {
      return true;
    }
    else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String? usern = ModalRoute
        .of(context)
        ?.settings
        .arguments as String?;
    String displayUsername = usern ??
        username; // Use route argument or stored username
    // Retrieve email from the controller
    String email = emailController.text.toString();
    // Get name asynchronously
    Future<String?> getName() async {
      String error = 'Dear!!';
      String? name = null;
      if (name == null) {
        String? nam = await getNameFromEmail(email);
        await Future.delayed(Duration(seconds: 1)); //process indicator
        if (nam != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('nam', nam);
        }
        return nam;
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
          //  return CircularProgressIndicator();
          return Scaffold(
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
                                'assets/images/dumbles.json',
                                width: 130,
                                height: 300,
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
                                        uRecipePage(),
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
                                        uWorkout(),
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
                              'Meal',
                              'assets/images/eaat.png',
                                  () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => meal(),
                                    settings: RouteSettings(
                                        arguments: emailController.text
                                            .toString()),
                                  ),
                                );
                              },
                            ),
                            // SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                    // SizedBox(height: 30),
                    SizedBox(height: 60),
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 150.0,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        pauseAutoPlayOnTouch: true,
                        enlargeCenterPage: true,
                        scrollDirection: Axis.horizontal,
                      ),

                      items: [
                        {
                          'text': 'Every step you take brings you closer to a stronger\n,healthier you\nKeep moving forward!',
                          'animation': 'assets/images/ggg.json',
                          'gradient': LinearGradient(
                            colors: [Colors.blue[200]!, Colors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        },

                        {
                          'text': 'Transform your body, transform your life\nYour journey starts today',
                          'animation': 'assets/images/yoga.json',
                          'gradient': LinearGradient(
                            colors: [Colors.red[100]!, Colors.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        },
                        {
                          'text': 'Believe in yourself and\n all that you are\nYou have the power to change',
                          'animation': 'assets/images/gh.json',
                          'gradient': LinearGradient(
                            colors: [ Colors.amber, Colors.yellowAccent[200]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        },
                        {
                          'text': 'Small progress is still progress\nStay consistent and watch the magic happen',
                          'animation': 'assets/images/ggg.json',
                          'gradient': LinearGradient(
                            colors: [Colors.green, Colors.yellow],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        },
                        {
                          'text': 'Donot wait for tomorrow.Start\n your fitness journey today',
                          'animation': 'assets/images/kl.json',
                          'gradient': LinearGradient(
                            colors: [Colors.indigo[300]!,
                              Colors.teal[500]!,
                            ],

                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        },
                        {
                          'text': 'Strive for progress, not perfection\nEvery workout counts.',
                          'animation': 'assets/images/lll.json',
                          'gradient': LinearGradient(
                            colors: [Colors.green[400]!, Colors.yellow[300]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        },
                        {
                          'text': 'Push yourself because no one \nelse is going to do it for you',
                          'animation': 'assets/images/tt.json',
                          'gradient': LinearGradient(
                            colors: [Colors.cyan[200]!,

                              Colors.indigo,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        },
                        {
                          'text': 'The only bad workout is the one that didnot happen\n Get up and get moving!',
                          'animation': 'assets/images/strength.json',
                          'gradient': LinearGradient(
                            colors: [Colors.purple[500]!, Colors.blueAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        },
                        {
                          'text': '"Your only limit is you\nPush beyond!"',
                          'animation': 'assets/images/ty.json',
                          'gradient': LinearGradient(
                            colors: [ Colors.green[300]!,
                              Colors.red[200]!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        },
                        {
                          'text': 'Sweat is just fat crying\nKeep going and make it weep!',
                          'animation': 'assets/images/yoga.json',
                          'gradient': LinearGradient(
                            colors: [Colors.green, Colors.yellow],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        },
                      ].map((slide) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width,
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),

                                gradient: slide['gradient'] as Gradient,
                              ),
                              child: Row( // Use Row instead of Column for horizontal alignment
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    // Adjust flex values as per your preference
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        slide['text'] as String,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    // Adjust flex values as per your preference
                                    child: Lottie.asset(
                                      //  height: 100,
                                      width: 100,
                                      slide['animation'] as String,
                                      //fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Positioned(
                  top: 27,
                  right: 4,
                  child: GestureDetector(
                    onLongPress: () {
                      _showOverlayexit(context);
                      // Show overlay on long press
                    },
                    onTap: () {
                      showLogoutDialog(context); // Show logout dialog on regular tap
                    },
                    child: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.exit_to_app_sharp),
                      onPressed: () {
                        showLogoutDialog(context);
                        // You can remove this onPressed since tap and long press are now handled by GestureDetector
                      },
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: CurvedNavigationBar(
              backgroundColor: Colors.white,
              color: Colors.purple,
              animationDuration: Duration(milliseconds: 100),
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
                  navigateToPage(dashboaard());
                }
              },
            )
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
          height: 100,
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
            ],
          ),
        );
      },
    );
  }


  void _navigateToChatScreen(BuildContext context, {required bool isChatbot}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatBot(isChatBot: isChatbot),
      ),
    );
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

  void navigateToNextPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page()),
    );
  }

  void clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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
                        bool emailExists = await checkEmailExists(
                            emailController.text);
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

    print('Database: $db');
    print('Email: $email');

    if (db == null) {
      throw Exception("Database is not initialized");
    }

    if (email == null || email.isEmpty) {
      throw Exception("Invalid email");
    }

    await db.delete(
      'WEIGHTGAINUSER',
      where: 'email = ?',
      whereArgs: [email],
    );
  }


  Future<Database?> openDB() async {
    _database = await DatabaseHandler().openDB();

    return _database;
  }

  Future<void> getcurrentweightgainuser(String email) async {
    _database = await openDB();
    UserRepo userRepo = new UserRepo();
    await userRepo.getcurrentweightgainuser(_database!, email);
    //  await _database?.close();
  }

  Future<String?> getNameFromEmail(String email) async {
    _database = await openDB();
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
    // await _database!.close();
    return name;
  }

  Future<int> getAgeFromEmail(String email) async {
    _database = await openDB();
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
    //  await _database!.close();
    return age;
  }

  Future<int> getHeightFromEmail(String email) async {
    _database = await openDB();
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
    //   await _database!.close();
    return height;
  }

  Future<int> get_cweight_FromEmail(String email) async {
    _database = await openDB();
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
    _database = await openDB();
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
    _database = await openDB();
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
    //await _database!.close();
    return gender;
  }

  Future<String?> getActivityLevelFromEmail(String email) async {
    _database = await openDB();
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
    //   await _database!.close();
    return activity_level;
  }


  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Premium Offer',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w700,
              color: Colors.purple,
            ),
          ),
          content: Container(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Subscribe to our premium plan to get:\n\n'
                  '- A structured diet plan\n'
                  '- Exercise plan\n'
                  '- Access to the step counter facility\n\n'
                  'Do you want to proceed?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.0,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                showInternetConnectionDialog(
                    context); // Show internet connection dialog
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void showInternetConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            'Make sure you have an internet connection',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Check internet connection
                bool isConnected = await _isConnected();
                if (!isConnected) {
                  _showNoInternetToast();
                } else {
                  // Show payment sheet
                  await makePayment((paymentSuccessful) {
                    if (paymentSuccessful) {
                      sendEmail(
                        emailController.text,
                        'Payment Successful!',
                        'Welcome! you are using the premium package of GritFit. Thanks...',
                      );
                      String userEmail = emailController.text;
                      sendAdminEmail(
                        'agritfit@gmail.com',
                        'Payment Received',
                        'A new payment has been received from User $userEmail',
                      );
                      handleSuccessfulPayment();
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Payment Failed'),
                            content: Text('Payment failed. Please try again.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  });
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _isConnected() async {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    if (!hasConnection) {
      return false;
    }

    try {
      final response = await http.get(Uri.parse('https://www.google.com'))
          .timeout(Duration(seconds: 4));
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error checking internet connection: $e');
    }
    return false;
  }

  void _showNoInternetToast() {
    Fluttertoast.showToast(
      msg: "No internet connection available",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> handleSuccessfulPayment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSubscribed', true);
    navigateToPremiumPage();
  }

  Future<void> makePayment(Function(bool) onPaymentResult) async {
    try {
      // Calculate the amounts
      int totalAmount = 300; // The total amount in cents
      int platformFee = (totalAmount * 0.20).toInt(); // 20% fee

      // Create the main payment intent for 80% of the amount
      paymentIntentData =
      await createPaymentIntent(totalAmount.toString(), 'USD');

      // Initialize the payment sheet for the main payment
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Sif',
        ),
      );

      // Display the payment sheet to the user
      await displayPaymentSheet(onPaymentResult);

      // After a successful payment, transfer 20% to another account
      if (onPaymentResult(true)) {
        await transferFunds(platformFee.toString(), 'USD');
      }
    } catch (e) {
      print('Error during payment process: $e');
      onPaymentResult(false);
    }
  }
  Future<void> displayPaymentSheet(Function(bool) onPaymentResult) async {
    try {
      await stripe.Stripe.instance.presentPaymentSheet();
      paymentIntentData = null;
      onPaymentResult(true);
    } catch (e) {
      if (e is stripe.StripeException) {
        print('Error presenting payment sheet: ${e.error.localizedMessage}');
      } else {
        print('Unexpected error: $e');
      }
      onPaymentResult(false);
    }
  }

  Future<void> transferFunds(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'destination': 'acct_1Pn8j5RwHbx9y5OW',
        // Replace with the connected account ID
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/transfers'),
        body: body,
        headers: {
          'Authorization':
          'Bearer sk_test_51QCFMZGzHm25KgpHi1WHRRacbj2BBQb75zWYhShEn5xtcRyiKpZC7dJhdwS76tX4JEPOqCdofVihwwTD8bqYkbgp00D0D1p3zJ',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      );
      print("Transfer response: ${response.body}");
    } catch (e) {
      print("Error during transfer: $e");
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization':
            'Bearer sk_test_51QCFMZGzHm25KgpHi1WHRRacbj2BBQb75zWYhShEn5xtcRyiKpZC7dJhdwS76tX4JEPOqCdofVihwwTD8bqYkbgp00D0D1p3zJ',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      return jsonDecode(response.body.toString());
    } catch (e) {
      print("Error creating payment intent: $e");
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }



  Future<void> sendEmail(String recipient, String subject,
          String message) async {
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
  Future<void> sendAdminEmail(String recipient, String subject, String message) async {
    // Replace with your email and password
    String username = 'gritfitapp7@gmail.com';
    String password = 'aksyxvonaufddkis';

    final smtpServer = gmail(username, password);

    final emailMessage = Message()
      ..from = Address(username, 'GritFit')
      ..recipients.add(recipient)
      ..subject = subject
      ..text = message;

    try {
      final sendReport = await send(emailMessage, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
