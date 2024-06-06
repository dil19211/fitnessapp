import 'package:sqflite/sqflite.dart';
class UserRepo {

  void createTable(Database? db) {
    db?.execute(
        'CREATE TABLE IF NOT EXISTS WEIGHTGAINUSER(id INTEGER PRIMARY KEY, name TEXT,email TEXT,age INTEGER,height INTEGER, gender TEXT,activity_level TEXT,cweight INTEGER,gweight INTEGER)');
  }

  Future<List<Map<String, dynamic>>> getweightgainusers(Database? db) async {
    final List<Map<String, dynamic>> maps = await db!.query('WEIGHTGAINUSER');
    if (maps.isNotEmpty) {
      print(maps);
      return maps;
    }
    else {
      throw Exception("USERss NOT FOUND");
    }
  }

  Future<List<Map<String, dynamic>>> getcurrentweightgainuser(Database? db,
      String email) async {
    final List<Map<String, dynamic>> map = await db!.query(
        'WEIGHTGAINUSER', where: 'email="$email"');
    if (map.isNotEmpty) {
      print(map);
      return map;
    }
    else {
      throw Exception("USERcurr NOT FOUND");
    }
  }

  // Future<List<Map<String,dynamic>>> getcurrentweightgainusername(Database? db,String email)async{
  //   final mapn= await db!.rawQuery("SELECT name FROM WEIGHTGAINUSER WHERE email=?",[email]);
  //   if(mapn.isNotEmpty) {
  //     print(mapn);
  //     return mapn;
  //   }
  //   else{
  //     throw Exception("USER name NOT FOUND");
  //   }
  // }
  Future<bool> isEmailExists(Database? db, String email) async {
    var result = await db!.rawQuery(
        "SELECT * FROM WEIGHTGAINUSER WHERE email = ?", [email]);
    if (result.isNotEmpty) {
      print(result);
      return true;
    }
    else {
      throw Exception("many USERs FOUND");
      return false;
    }
  }

  void createTable_wg_meal(Database? db) {
    db?.execute(
        'CREATE TABLE IF NOT EXISTS WEIGHTGAINMEAL(id INTEGER PRIMARY KEY, item TEXT,calories INTEGER)');
    print("table is created in db");
  }

  void insert(Database? db) {
    db?.execute(
        "INSERT INTO WEIGHTGAINMEAL(item, calories)VALUES('1_boiled_Egg', 100),('Milk', 86),('rice', 130),('1_boiledPotato', 50),('Grain_bread', 340),('dark_chocolate', 600),('1_banana', 98),('Date', 50),('mango', 122),('slice_bread', 82),('cheesy_pasta', 315),('5_almonds', 85),('Biryani', 350),('korma', 460),('cheesy_burger', 320),('Paratha-1', 340),('roti-1', 100),('coffee', 200),('milk_tea', 200),('biscuits_500g', 350)");
    if (db != null) {
      print("meal is inserted in db");
    }
    else {
      throw Exception('not inserted');
    }
  }

  Future<List<Map<String, dynamic>>> get_wg_meal(Database? db) async {
    final List<Map<String, dynamic>> mapmeal = await db!.query(
        'WEIGHTGAINMEAL');
    if (mapmeal.isNotEmpty) {
      print(mapmeal);
      print('map of meal is fetched in user repo');
      return mapmeal;
    }
    else {
      throw Exception("weight gain items NOT FOUND");
    }
  }

  void createpayTable(Database? db) {
    db?.execute(
        'CREATE TABLE IF NOT EXISTS PAIDUSER(id INTEGER PRIMARY KEY, name TEXT,email TEXT,phn INTEGER)');
  }

  Future<List<Map<String, dynamic>>> getpayusers(Database? db) async {
    final List<Map<String, dynamic>> maps = await db!.query('PAIDUSER');
    if (maps.isNotEmpty) {
      print(maps);
      return maps;
    }
    else {
      throw Exception("PAYED USERss NOT FOUND");
    }
  }
}