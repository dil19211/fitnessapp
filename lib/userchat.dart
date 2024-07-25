import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserChatScreen extends StatefulWidget {
  final String userId;
  UserChatScreen({required this.userId});

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _markMessagesAsRead(); // Mark messages as read when screen is initialized
  }

  void _markMessagesAsRead() async {
    QuerySnapshot unreadMessages = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.userId)
        .collection('messages')
        .where('isFromDietitian', isEqualTo: true)
        .where('hasreplied', isEqualTo: false)
        .get();

    for (var doc in unreadMessages.docs) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.userId)
          .collection('messages')
          .doc(doc.id)
          .update({'hasreplied': true}); // Mark the message as read
    }
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
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
        'hasreplied':false
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(title: Text("Chat with Dietitian",style: TextStyle(color: Colors.white,fontSize:17,fontWeight:FontWeight.w700),),backgroundColor: Colors.purple,),
      body: Column(
        children: [
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

                return ListView(
                  reverse: true,
                  children: snapshot.data!.docs.map((doc) {
                    bool isFromDietitian = doc['isFromDietitian'];
                    return Align(
                      alignment: isFromDietitian
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        child: Container(
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
