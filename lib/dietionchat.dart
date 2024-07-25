import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chatscreen.dart';

class DietitianChatScreen extends StatefulWidget {
  @override
  _DietitianChatScreenState createState() => _DietitianChatScreenState();
}

class _DietitianChatScreenState extends State<DietitianChatScreen> {
  Future<int> _getUnreadMessageChatCount() async {
    Set<String> userIdsWithUnreadMessages = {};
    final snapshots = await FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('read', isEqualTo: false)
        .where('isFromDietitian', isEqualTo: false)
        .get();
    snapshots.docs.forEach((doc) {
      userIdsWithUnreadMessages.add(doc['userId'].toString());
    });
    return userIdsWithUnreadMessages.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Dietitian Panel",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple,
        actions: [
          FutureBuilder<int>(
            future: _getUnreadMessageChatCount(),
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
                    Icon(Icons.notifications, color: Colors.white,),
                    if (unreadChatCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
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
                      backgroundColor: Colors.indigo[200],
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
                      builder: (context) => ChatScreen(userId: userId),
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
