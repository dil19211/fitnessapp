import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:fitnessapp/usermanger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    profileImage: "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    String? userId = await UserManager.getUserId();
    if (userId == null) {
      // If no userId is found, assign a new one (for demo purposes, you might fetch this from a backend)
      userId = "user_${DateTime.now().millisecondsSinceEpoch}";
      await UserManager.setUserId(userId);
    }

    final nonNullableUserId = userId; // Assign to a non-nullable variable

    setState(() {
      currentUser = ChatUser(id: nonNullableUserId, firstName: "User");
    });

    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (currentUser == null) return;
    List<ChatMessage> loadedMessages = await DatabaseHelper().getMessagesForUser(currentUser!.id);
    setState(() {
      messages = loadedMessages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple[500],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
                fontStyle: FontStyle.italic,

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
      ) ??
          "";
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
    });
  }

  void _sendMediaMessage() async {
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