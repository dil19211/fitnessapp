import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:fitnessapp/usermanger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'chtboathelper.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({Key? key, required bool isChatBot}) : super(key: key);

  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  ChatUser? currentUser;
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage:
    "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    String? userId = await UserManager.getUserId();
    if (userId == null) {
      userId = "user_${DateTime.now().millisecondsSinceEpoch}";
      await UserManager.setUserId(userId);
    }

    final nonNullableUserId = userId;

    setState(() {
      currentUser = ChatUser(id: nonNullableUserId, firstName: "User");
    });

    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (currentUser == null) return;
    List<ChatMessage> loadedMessages =
    await DatabaseHelper().getMessagesForUser(currentUser!.id);
    setState(() {
      messages = loadedMessages;
    });
  }

  Future<bool> _isConnected() async {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    if (!hasConnection) {
      return false;
    }

    try {
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(Duration(seconds: 4));
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error checking internet connection: $e');
    }

    return false;
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 15,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple[500],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.chat,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'ChatMate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        shadowColor: Colors.black,
      ),
      body: currentUser == null
          ? Center(child: CircularProgressIndicator())
          : _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      inputOptions: InputOptions(trailing: [
        IconButton(
          onPressed: _sendMediaMessage,
          icon: const Icon(Icons.image),
        ),
      ]),
      currentUser: currentUser!,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  void _sendMessage(ChatMessage chatMessage) async {
    print('Attempting to send media message...');
    if (!await _isConnected()) {
      print('No internet connection. Message not sent.');
      _showToast('No internet connection. Message not sent.');
      return;
    }

    try {
      setState(() {
        messages = [chatMessage, ...messages];
      });

      await DatabaseHelper().insertMessage(chatMessage, true);

      String question = chatMessage.text;
      List<Uint8List>? images;

      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [File(chatMessage.medias!.first.url).readAsBytesSync()];
      }

      gemini.streamGenerateContent(question, images: images).listen((event) async {
        String response = event.content?.parts?.fold(
          "",
              (previous, current) => "$previous ${current.text}",
        ) ?? "";
        ChatMessage geminiMessage = ChatMessage(
          user: geminiUser,
          createdAt: DateTime.now(),
          text: response,
        );

        setState(() {
          messages = [geminiMessage, ...messages];
        });

        await DatabaseHelper().insertMessage(geminiMessage, false);
      }).onError((error) {
        print(error);
        _showToast('Failed to send message. Please try again.');
      });
    } catch (e) {
      print('Error sending message: $e');
      _showToast('Failed to send message. Please try again.');
    }
  }

  void _sendMediaMessage() async {
    if (!await _isConnected()) {
      print('No internet connection. Message not sent.');
      _showToast('No internet connection. Message not sent.');
      return;
    }

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final chatMessage = ChatMessage(
        user: currentUser!,
        createdAt: DateTime.now(),
        text: "Describe this picture?",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          ),
        ],
      );
      _sendMessage(chatMessage);
    }
  }

}
