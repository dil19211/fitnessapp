import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart'; // Import the intl package for formatting dates
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class adminschatscreentodiet extends StatefulWidget {
  final String userId;
  adminschatscreentodiet({required this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<adminschatscreentodiet> {
  final TextEditingController _controller = TextEditingController();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _hasFullInternetAccess = false;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
    _checkInternetConnection();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results.first); // Taking the first result for simplicity
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

  void _markMessagesAsRead() async {
    await FirebaseFirestore.instance
        .collection('chatting')
        .doc(widget.userId)
        .collection('messaging')
        .where('read', isEqualTo: false)
        .where('isFromDietitian', isEqualTo: false) // Only mark messages from the user as read
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'read': true});
      });
    });
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      if (_hasFullInternetAccess) {
        await FirebaseFirestore.instance
            .collection('chatting') // Top-level collection
            .doc(widget.userId) // User-specific document
            .collection('messaging') // Messages sub-collection
            .add({
          'userId': widget.userId,
          'message': _controller.text,
          'isFromDietitian': true,
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

  Future<void> _pickAndUploadImage() async {
    final ImagePicker _imagePicker = ImagePicker();

    // Pick an image from the gallery
    XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
    print('File path: ${file?.path}');

    if (file == null) return;

    // Generate a unique filename using the current timestamp
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    // Get a reference to the root of Firebase Storage
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('adminimages');

    // Create a reference for the image to be stored
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      // Store the file in Firebase Storage
      await referenceImageToUpload.putFile(File(file.path));

      // Success: get the download URL of the uploaded image
      String imageUrl = await referenceImageToUpload.getDownloadURL();

      // Send the message with the image URL to Firestore
      await FirebaseFirestore.instance
          .collection('chatting')
          .doc(widget.userId)
          .collection('messaging')
          .add({
        'userId': widget.userId,
        'message': imageUrl,
        'isFromDietitian': true,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'hasreplied': false,
        'type': 'image', // Specify the type as image
      });

      print('Image uploaded and message sent successfully. Download URL: $imageUrl');
    } catch (error) {
      // Handle any errors during the upload or Firestore operations
      print('Failed to upload image or send message: $error');
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
          "dietitionId: ${widget.userId}",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatting')
                  .doc(widget.userId) // Access the specific user's document
                  .collection('messaging') // Access the messages sub-collection
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                // Mark messages as read in real-time
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _markMessagesAsRead();
                });

                return ListView(
                  reverse: true,
                  children: snapshot.data!.docs.map((doc) {
                    bool isFromDietitian = doc['isFromDietitian'];
                    Timestamp timestamp = doc['timestamp'] ?? Timestamp.now(); // Default to now if timestamp is missing
                    return Container(
                      alignment: isFromDietitian ? Alignment.centerRight : Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Column(
                        crossAxisAlignment: isFromDietitian ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isFromDietitian ? Colors.deepPurple[400] : Colors.indigo[200],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomLeft: isFromDietitian ? Radius.circular(0) : Radius.circular(16),
                                bottomRight: isFromDietitian ? Radius.circular(16) : Radius.circular(0),
                              ),
                            ),
                            child: doc['type'] == 'image' // Check if the message type is an image
                                ? Image.network(
                              doc['message'], // Display the image from the URL
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
                    decoration: InputDecoration(labelText: "Type a message"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: _pickAndUploadImage,
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage, // Button for sending images
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
