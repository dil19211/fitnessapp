
import 'dart:async';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:fitnessapp/partialpayment.dart';
import 'package:fitnessapp/seeuserchatpanelinadminside.dart';
import 'package:fitnessapp/weightgaintable.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'approved table.dart';
import 'chatpanelofadmin.dart';
import 'idsssstorages.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'losstable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<admin> {

  bool _isOverlayVisible = false;
  OverlayEntry? _overlayEntry;
  @override
  Stream<int> _getUnreadMessageCountStream() {
    return FirebaseFirestore.instance
        .collectionGroup('messaging')
        .where('read', isEqualTo: false)
        .where('isFromDietitian', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      Set<String> userIdsWithUnreadMessages = {};
      snapshot.docs.forEach((doc) {
        userIdsWithUnreadMessages.add(doc['userId'].toString());
      });
      return userIdsWithUnreadMessages.length;
    });
  }
  OverlayEntry _createOverlayEntry(BuildContext context) {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100.0, // Position above the FloatingActionButton
        right: MediaQuery.of(context).size.width / 5 - 50, // Center horizontally
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
                'Chats',
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

  void _showOverlay(BuildContext context) {
    if (!_isOverlayVisible) {
      _overlayEntry = _createOverlayEntry(context);
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



  @override
  void dispose() {
    _overlayEntry?.remove(); // Clean up the overlay when the widget is disposed
    super.dispose();
  }

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
            icon: Icon(Icons.block, color: Colors.white),
            onPressed: () {
              navigateToBlockList(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.email, color: Colors.white),
            onPressed: _showEmailFormDialog,
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
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
              'assets/images/changeadmin.json',
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
                          builder: (BuildContext context) => losstable(),
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
                        showPaymentOptions(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<int>(
        stream: _getUnreadMessageCountStream(),
        builder: (context, snapshot) {
          int unreadCount = snapshot.data ?? 0; // Default to 0 if data is null

          return GestureDetector(
            onLongPress: () {
              _showOverlay(context); // Show the overlay on long press
              //_showBottomSheet(context, unreadCount); // Show the bottom sheet as well
            },
            child: FloatingActionButton(
              onPressed: () {
                _showBottomSheet(context, unreadCount); // Just show the bottom sheet on tap
              },
              backgroundColor: Colors.purple,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.chat, color: Colors.white),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  void navigateToBlockList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlockListScreen(),
      ),
    );
  }
  void _showEmailFormDialog() {
    final _toController = TextEditingController();
    // final _fromController = TextEditingController();
    final _messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Send Email"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _toController,
                  decoration: InputDecoration(labelText: "To"),
                ),
                TextField(
                  controller: _messageController,
                  decoration: InputDecoration(labelText: "Message"),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Submit"),
              onPressed: () {
                sendEmail(
                  _toController.text,
                  'Warning Alert!!!!!!!!!!',
                  _messageController.text,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
      builder: (context) {
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
                clearSharedPreferences();
                navigateToNextPage(context);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
  void _showBottomSheet(BuildContext context, int unreadCount) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.people),
                title: Text('See User Chats'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => adminseenuserchat()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.chat),
                title: Row(
                  children: [
                    Text('Chat with Dietitian'),
                    if (unreadCount > 0) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop(); // Close the bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => adminChatScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }


  void clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data stored in SharedPreferences
  }

  void showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.payments),
                title: Text('Partial Payment'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the modal
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => partialpayment(),
                  ));
                },
              ),
              ListTile(
                leading: Icon(Icons.payment),
                title: Text('Full Payment'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the modal
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => wholepayment(),
                  ));
                },
              ),
            ],
          ),
        );
      },
    );
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
          content: Text('E-mail is sent on user account.'),
        ),
      );
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong ,cant send email to user.'),
          ),
        );
      }
    }
  }
}
class BlockListScreen extends StatefulWidget {
  @override
  _BlockListScreenState createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen> {

  Future<void> _unblockUser(String userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('blocked_users')
        .where('userId', isEqualTo: userId)
        .get();

    for (DocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }


  Future<void> _blockUser(String userId) async {
    await FirebaseFirestore.instance.collection('blocked_users').add({
      'userId': userId,
      'blockedAt': FieldValue.serverTimestamp(),
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blocklist'),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('blocked_users')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var blockedUsers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              var userId = blockedUsers[index]['userId']; // Access userId field
              return ListTile(
                title: Text('User ID: $userId'), // Display user ID
                trailing: IconButton(
                  icon: Icon(Icons.block, color: Colors.red),
                  onPressed: () {
                    _unblockUser(userId);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBlockUserDialog(context);
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
      ),
    );
  }
  void _showBlockUserDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Block User'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Enter User ID"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _blockUser(_controller.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Block'),
            ),
          ],
        );
      },
    );
  }

}