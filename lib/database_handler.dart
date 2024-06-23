import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DatabaseHandler {
  static final DatabaseHandler _databaseHandler = DatabaseHandler._internal();

  factory DatabaseHandler(){
    return _databaseHandler;
  }

  DatabaseHandler._internal();

  Future<Database> openDB() async {
    Database _database;
    _database = await openDatabase(
        join(await getDatabasesPath(), 'weightgainuser')
    );
    return _database;
  }
}