import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package for formatting dates
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class diettoadmin extends StatefulWidget {
  final String? userId;
  diettoadmin({this.userId});
  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<diettoadmin> {
  final TextEditingController _controller = TextEditingController();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _hasFullInternetAccess = false;

  @override
  void initState() {
    super.initState();

    _checkInternetConnection();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
        List<ConnectivityResult> results) {
      _updateConnectionStatus(
          results.first); // Taking the first result for simplicity
    });
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

  void _markMessagesAsRead(QuerySnapshot snapshot) async {
    for (var doc in snapshot.docs) {
      if (doc['isFromDietitian'] && !doc['hasreplied']) {
        await FirebaseFirestore.instance
            .collection('chatting')
            .doc(widget.userId)
            .collection('messaging')
            .doc(doc.id)
            .update({'hasreplied': true});
      }
    }
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      if (_hasFullInternetAccess) {
        await FirebaseFirestore.instance
            .collection('chatting')
            .doc(widget.userId)
            .collection('messaging')
            .add({
          'userId': widget.userId,
          'message': _controller.text,
          'isFromDietitian': false,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'hasreplied': false,
          'type': 'text', // Specify the type as text
        });
        _controller.clear();
      } else {
        _showToast("Stable internet connection required to send message");
      }
    }
  }

  Future<void> _pickAndSendImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image
    != null) {
      try {
        File file = File(image.path);
        String fileName = image.name;

        // Check if the file exists (optional, for debugging)
        if (await file.exists()) {
          print("File exists: ${file.path}");
        }

        // Upload the image to Firebase Storage
        String storagePath = 'dietitionfitnessappimages/$fileName';
        print("Uploading to: $storagePath");

        UploadTask uploadTask = FirebaseStorage.instance.ref(storagePath)
            .putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String imageUrl = await snapshot.ref.getDownloadURL();

        // Send the message with the image URL
        await FirebaseFirestore.instance
            .collection('chatting')
            .doc(widget.userId)
            .collection('messaging')
            .add({
          'userId': widget.userId,
          'message': imageUrl,
          'isFromDietitian': false,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'hasreplied': false,
          'type': 'image', // Specify the type as image
        });
      } catch (e) {
        _showToast("Failed to upload image: $e");
        print("Error uploading image: $e");

        // Additional handling for specific StorageException
        if (e is FirebaseException && e.code == 'object-not-found') {
          print(
              "The object does not exist at the specified location in Firebase Storage.");
        } else if (e is FirebaseException && e.code == 'unauthorized') {
          print("User does not have permission to access the object.");
        } else if (e is FirebaseException && e.code == 'cancelled') {
          print("The upload was cancelled.");
        } else {
          print("An unexpected error occurred.");
        }
      }
    } else {
      _showToast("No image selected.");
      print("Image selection was canceled or failed.");
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
          "Chat with admin",
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatting')
                  .doc(widget.userId)
                  .collection('messaging')
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
                              child: doc['type'] == 'image' // Check the type field
                                  ? Image.network(
                                doc['message'], // Image URL
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              )
                                  : Text(
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
                  icon: Icon(Icons.image),
                  onPressed: _pickAndSendImage,
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed:_sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
