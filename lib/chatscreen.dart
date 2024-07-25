import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  ChatScreen({required this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  void _markMessagesAsRead() async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.userId)
        .collection('messages')
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
      await FirebaseFirestore.instance
          .collection('chats') // Top-level collection
          .doc(widget.userId) // User-specific document
          .collection('messages') // Messages sub-collection
          .add({
        'userId': widget.userId,
        'message': _controller.text,
        'isFromDietitian': true,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'hasreplied':false

      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: Text(
          "User: ${widget.userId}",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.userId) // Access the specific user's document
                  .collection('messages') // Access the messages sub-collection
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                return ListView(
                  reverse: true,
                  children: snapshot.data!.docs.map((doc) {
                    bool isFromDietitian = doc['isFromDietitian'];
                    return Container(
                      alignment: isFromDietitian ? Alignment.centerLeft : Alignment.centerRight,
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['message'],
                              style: TextStyle(color: Colors.white),
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
                    decoration: InputDecoration(labelText: "Type a message"),
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
