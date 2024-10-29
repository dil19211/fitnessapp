import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chatscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dietitiontoadmin.dart';
import 'dietlogin.dart';
import 'idsssstorages.dart';

class DietitianChatScreen extends StatefulWidget {
  @override
  _DietitianChatScreenState createState() => _DietitianChatScreenState();
}

class _DietitianChatScreenState extends State<DietitianChatScreen> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _hasFullInternetAccess = false;
  int _unreadMessageCount = 0;


  Timer? _longPressTimer;
  bool _isButtonPressed = false;
  bool _isOverlayVisible = false;
  OverlayEntry? _overlayEntry;

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
          .collection('chatting')
          .doc(userId)
          .collection('messaging')
          .where('isFromDietitian', isEqualTo: true)
          .where('hasreplied', isEqualTo: false)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        setState(() {
          _unreadMessageCount = snapshot.size;
          print("Unread message count: $_unreadMessageCount");
        });
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _longPressTimer?.cancel();
    _overlayEntry?.remove();
    super.dispose();
  }
  OverlayEntry _createOverlayEntry(BuildContext context) {
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100.0, // Position above the FloatingActionButton
        right: MediaQuery.of(context).size.width / 5 - 50, // Center horizontally
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 150,
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
                'Chat With Admin',
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
  //overlay
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

  void _handleLongPressStart(LongPressStartDetails details) {
    _isButtonPressed = true;
    _longPressTimer = Timer(Duration(milliseconds: 2), () {
      if (_isButtonPressed) {
        _showOverlay(context);
      }
    });
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _isButtonPressed = false;
    _longPressTimer?.cancel();
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                clearSharedPreferences();
                navigateToNextPage(context);
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
          "User Chats",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple,
        actions: [
          // Notification icon in the first position
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
          // Logout icon in the second position
          // IconButton(
          //   icon: Icon(Icons.logout, color: Colors.white),
          //   onPressed: _showLogoutDialog,
          //
          // ),
          GestureDetector(
            onLongPress: () {
              _showOverlayexit(context);
            },
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed:  _showLogoutDialog,// Normal press action
            ),
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

          return ListView.separated(
            itemCount: sortedUserMessages.length,
            itemBuilder: (context, index) {
              final userId = sortedUserMessages[index].key;
              final userMessageData = sortedUserMessages[index].value;

              return ListTile(
                leading: Icon(Icons.person, color: Colors.purple), // Add the person icon here
                title: Text(
                  "User: $userId",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
                subtitle: Text(
                  "Latest: ${userMessageData['latestMessage'] ?? 'No messages'}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                ),
                trailing: userMessageData['unreadCount'] > 0
                    ? CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.purple[200],
                  child: Text(
                    '${userMessageData['unreadCount']}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
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
                      builder: (context) => ChatScreen(userId: userId),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (context, index) => Divider(), // Add divider between each ListTile
          );
        },
      ),
      floatingActionButton: GestureDetector(
        onLongPressStart: _handleLongPressStart,
        onLongPressEnd: _handleLongPressEnd,
        onTap: () async {
          if (!_isOverlayVisible) {
            String? userId = await idstorages.getUserId();
            if (userId == null) {
              // Generate and store a new user ID if not already stored
              userId = DateTime.now().millisecondsSinceEpoch.toString();
              await idstorages.storeUserId(userId);
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => diettoadmin(userId: userId!)),
            );
          }
        },
        child: FloatingActionButton(
          onPressed: () async {
            if (!_isOverlayVisible) {
              String? userId = await idstorages.getUserId();
              if (userId == null) {
                // Generate and store a new user ID if not already stored
                userId = DateTime.now().millisecondsSinceEpoch.toString();
                await idstorages.storeUserId(userId);
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => diettoadmin(userId: userId!)),
              );
            }
            // Empty function to satisfy the requirement
          },
          child: Stack(
            children: [
              Icon(Icons.chat, color: Colors.white),
              if (_unreadMessageCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.redAccent[200],
                    child: Text(
                      _unreadMessageCount.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          backgroundColor: Colors.purple,
        ),
      ),
    );
  }
}
