import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'adminseenindividualuserscreen.dart';
import 'chatscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dietitiontoadmin.dart';
import 'dietlogin.dart';
import 'idsssstorages.dart';

class adminseenuserchat extends StatefulWidget {
  @override
  _DietitianChatScreenState createState() => _DietitianChatScreenState();
}

class _DietitianChatScreenState extends State< adminseenuserchat> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _hasFullInternetAccess = false;
  int _unreadMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results.first); // Taking the first result for simplicity
    });
    _startListeningForUnreadMessages();
  }

  void _startListeningForUnreadMessages() async {
    String? userId = await idstorages.getUserId();
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

  @override
  void dispose() {
    _connectivitySubscription.cancel();
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
        _showToast("Limited internet connection");
        setState(() {
          _hasFullInternetAccess = false;
        });
      }
    } catch (e) {
      _showToast("Limited internet connection");
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


  void navigateToNextPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dietlogin()),
    );
  }

  void clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all data stored in SharedPreferences
  }

  Stream<int> _getUnreadMessageChatCountStream() {
    return FirebaseFirestore.instance
        .collectionGroup('messages')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: Text(
         'Users messages',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple,
        actions: [

          StreamBuilder<int>(
            stream: _getUnreadMessageChatCountStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Icon(Icons.error);
              }
              int unreadChatCount = snapshot.data ?? 0;
              return IconButton(
                icon: Stack(
                  children: [
                    Icon(Icons.notifications, color: Colors.white, size: 27),
                    if (unreadChatCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.purple[200],
                          child: Text(
                            '$unreadChatCount',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  // Handle notifications icon press if needed
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collectionGroup('messages').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          Map<String, Map<String, dynamic>> userMessages = {};

          for (var doc in snapshot.data!.docs) {
            String userId = doc['userId'].toString();
            String message = doc['message'];
            bool isRead = doc['read'] ?? false;
            bool isFromDietitian = doc['isFromDietitian'] ?? false;
            Timestamp timestamp = doc['timestamp'] ?? Timestamp.now();

            if (!isFromDietitian) { // Only count messages from the user
              if (userMessages.containsKey(userId)) {
                if (!isRead) {
                  userMessages[userId]!['unreadCount']++;
                }
                if (timestamp.compareTo(userMessages[userId]!['timestamp']) > 0) {
                  userMessages[userId]!['latestMessage'] = message;
                  userMessages[userId]!['timestamp'] = timestamp;
                }
              } else {
                userMessages[userId] = {
                  'latestMessage': message,
                  'timestamp': timestamp,
                  'unreadCount': isRead ? 0 : 1,
                };
              }
            } else { // For messages from the dietitian
              if (userMessages.containsKey(userId)) {
                if (timestamp.compareTo(userMessages[userId]!['timestamp']) > 0) {
                  userMessages[userId]!['latestMessage'] = message;
                  userMessages[userId]!['timestamp'] = timestamp;
                }
              } else {
                userMessages[userId] = {
                  'latestMessage': message,
                  'timestamp': timestamp,
                  'unreadCount': 0,
                };
              }
            }
          }

          List<MapEntry<String, Map<String, dynamic>>> sortedUserMessages = userMessages.entries.toList()
            ..sort((a, b) => b.value['timestamp'].compareTo(a.value['timestamp']));

          return ListView.builder(
            itemCount: sortedUserMessages.length,
            itemBuilder: (context, index) {
              final userId = sortedUserMessages[index].key;
              final userMessageData = sortedUserMessages[index].value;

              return ListTile(
                leading: Icon(Icons.person), // Add the person icon here
                title: Text(
                  "User: $userId",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
                subtitle: Text(
                  "Latest: ${userMessageData['latestMessage'] ?? 'No messages'}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: userMessageData['unreadCount'] > 0
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.purple[200],
                      radius: 12,
                      child: Text(
                        "${userMessageData['unreadCount']}",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "${userMessageData['unreadCount']} new",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                )
                    : null,
                onTap: () async {
                  // Mark messages as read when opening the chat
                  await FirebaseFirestore.instance
                      .collection('chats')
                      .doc(userId)
                      .collection('messages')
                      .where('read', isEqualTo: false)
                      .where('isFromDietitian', isEqualTo: false)
                      .get()
                      .then((querySnapshot) {
                    querySnapshot.docs.forEach((doc) {
                      doc.reference.update({'read': true});
                    });
                  });

                  // Update the UI to reflect the changes
                  setState(() {});

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => adminseenindividualuserChatScreen(userId: userId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

