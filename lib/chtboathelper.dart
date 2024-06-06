import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chatbot.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE messages(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT,
          message TEXT,
          createdAt TEXT,
          isUser INTEGER,
          mediaUrl TEXT,
          mediaType TEXT
        )
      ''');
      },
    );
  }

  Future<void> insertMessage(ChatMessage message, bool isUser) async {
    final db = await database;
    await db.insert(
      'messages',
      {
        'userId': message.user.id,
        'message': message.text,
        'createdAt': message.createdAt.toIso8601String(),
        'isUser': isUser ? 1 : 0,
        'mediaUrl': message.medias?.isNotEmpty ?? false ? message.medias!.first
            .url : null,
        'mediaType': message.medias?.isNotEmpty ?? false ? message.medias!.first
            .type.toString() : null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatMessage>> getMessagesForUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'userId = ? OR isUser = 0',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      final isUser = maps[i]['isUser'] == 1;
      final mediaUrl = maps[i]['mediaUrl'];
      final mediaTypeString = maps[i]['mediaType'] as String?;
      MediaType? mediaType;

      if (mediaTypeString != null) {
        // Convert string to MediaType using a lookup table or switch statement
        switch (mediaTypeString) {
          case 'image':
            mediaType = MediaType.image;
            break;
          case 'video':
            mediaType = MediaType.video;
            break;
        }
      }
      return ChatMessage(
        user: isUser ? ChatUser(id: userId, firstName: 'User') : ChatUser(
            id: '1',
            firstName: 'Gemini',
            profileImage: "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png"),
        text: maps[i]['message'],
        createdAt: DateTime.parse(maps[i]['createdAt']),
        medias: mediaUrl != null && mediaType != null
            ? [
          ChatMedia(
            url: mediaUrl,
            fileName: "",
            type: mediaType,
          ),
        ]
            : null,
      );
    });
  }
}
