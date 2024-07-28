import 'dart:async';
import 'package:fitnessapp/idstorge.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package for formatting dates
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class UserChatScreen extends StatefulWidget {
  final String? userId;
  UserChatScreen({required this.userId});

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _hasFullInternetAccess = false;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results.first); // Taking the first result for simplicity
    });
    _checkIfUserBlocked(); // Check if the user is blocked on screen load
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showToast("No internet connection");
    } else {
      _checkFullInternetAccess();
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _showToast("No internet connection");
    } else {
      _checkFullInternetAccess();
    }
  }

  void _checkFullInternetAccess() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      if (response.statusCode == 200) {
        setState(() {
          _hasFullInternetAccess = true;
        });
      } else {
        setState(() {
          _hasFullInternetAccess = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasFullInternetAccess = false;
      });
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<bool> _isUserBlocked() async {
    String? userId = await idstorage.getUserId(); // Retrieve user ID from shared preferences
    if (userId == null || userId.isEmpty) {
      print('Error: Trying to check blocked status for null or empty userId');
      return false;
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('blocked_users')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.isNotEmpty; // Return true if the user is blocked
  }

  void _checkIfUserBlocked() async {
    bool isBlocked = await _isUserBlocked();
    if (isBlocked) {
      _showToast("You are blocked from sending messages."); // Show toast if blocked
      // Optionally navigate back or perform any other action
      Navigator.pop(context); // Go back to the previous screen
    }
  }

  void _markMessagesAsRead(QuerySnapshot snapshot) async {
    for (var doc in snapshot.docs) {
      if (doc['isFromDietitian'] && !doc['hasreplied']) {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.userId)
            .collection('messages')
            .doc(doc.id)
            .update({'hasreplied': true});
      }
    }
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      if (_hasFullInternetAccess) {
        bool isBlocked = await _isUserBlocked(); // Check if the user is blocked
        if (isBlocked) {
          _showToast("You are blocked from sending messages."); // Show toast if blocked
          return; // Exit if the user is blocked
        }

        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.userId)
            .collection('messages')
            .add({
          'userId': widget.userId,
          'message': _controller.text,
          'isFromDietitian': false,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'hasreplied': false,
        });
        _controller.clear();
      } else {
        _showToast("Stable internet connection required to send message");
      }
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    var format = DateFormat('yyyy-MM-dd HH:mm'); // Custom format
    return format.format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: Text(
          "Chat with Dietitian",
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.0),
            color: Colors.purpleAccent,
            child: Text(
              "Do not use abusive words During Chat",
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.userId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet."));
                }

                // Mark messages as read immediately
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _markMessagesAsRead(snapshot.data!);
                });

                return ListView(
                  reverse: true,
                  children: snapshot.data!.docs.map((doc) {
                    bool isFromDietitian = doc['isFromDietitian'];
                    Timestamp timestamp = doc['timestamp'] ?? Timestamp.now(); // Default to now if timestamp is missing
                    return Align(
                      alignment: isFromDietitian ? Alignment.centerLeft : Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: isFromDietitian ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                          children: [
                            Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                              decoration: BoxDecoration(
                                color: isFromDietitian ? Colors.indigo[200] : Colors.purple[400],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                  bottomLeft: isFromDietitian ? Radius.circular(0) : Radius.circular(16),
                                  bottomRight: isFromDietitian ? Radius.circular(16) : Radius.circular(0),
                                ),
                              ),
                              child: Text(
                                doc['message'],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              _formatTimestamp(timestamp),
                              style: TextStyle(color: Colors.grey[600], fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: "Type a message",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
