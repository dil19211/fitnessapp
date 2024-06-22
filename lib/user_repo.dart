import 'package:sqflite/sqflite.dart';
class UserRepo{

  void createTable(Database db){
    db?.execute('CREATE TABLE IF NOT EXISTS WEIGHTGAINUSER(id INTEGER PRIMARY KEY, name TEXT,email TEXT,age INTEGER,height INTEGER,gender TEXT,activity_level TEXT,cweight INTEGER,gweight INTEGER)');
  }
  Future<List<Map<String,dynamic>>> getweightgainusers(Database db)async{
    final List<Map<String,dynamic>> maps= await db!.query('WEIGHTGAINUSER');
    if(maps.isNotEmpty) {
      print(maps);
      return maps;

    }
    else{
      throw Exception("USERss NOT FOUND");
    }
  }
  void createpayTable(Database? db){
    db?.execute('CREATE TABLE IF NOT EXISTS PAIDUSER(id INTEGER PRIMARY KEY, name TEXT,email TEXT,phn INTEGER)');
  }

  Future<List<Map<String,dynamic>>> getpayusers(Database? db)async {
    final List<Map<String, dynamic>> maps = await db!.query('PAIDUSER');
    if (maps.isNotEmpty) {
      print(maps);
      return maps;
    }
    else {
      throw Exception("PAYED USERss NOT FOUND");
    }
  }
  Future<List<Map<String,dynamic>>> getcurrentweightgainuser(Database db,String email)async{
    final List<Map<String,dynamic>> map= await db!.query('WEIGHTGAINUSER',where: 'email="$email"');
    if(map.isNotEmpty) {
      print(map);
      return map; }
    else{
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
  Future<bool> isEmailExists(Database db,String email) async {

    var result = await db!.rawQuery("SELECT * FROM WEIGHTGAINUSER WHERE email = ?", [email]);
    if(result.isNotEmpty) {
      print(result);
      return true;
    }
    else{
      return false;
      throw Exception("many USERs FOUND");
    }
  }
  Future<void> createTable_wg_meal(Database db) async{
    db?.execute('CREATE TABLE IF NOT EXISTS WEIGHTGAINMEAL(id INTEGER PRIMARY KEY, item TEXT,calories INTEGER)');
    print("table is created in db");
  }

  Future<void> insert(Database db) async{
    db.execute(
        "INSERT INTO WEIGHTGAINMEAL(item, calories)VALUES('boiled_Egg', 100),('glassMilk', 86),('rice', 130),('boiledPotato', 50),('Grain_bread', 340),('dark_chocolate', 600),('banana', 98),('Date', 50),('mango', 122),('slice_bread', 82),('cheesy_pasta', 315),('5_almonds', 85),('Chicken Biryani plate', 350),('korma plate', 460),('cheesy_burger', 320),('Paratha', 340),('roti-1', 100),('coffee', 200),('milk_tea', 200),('biscuits_500g', 350),('Green Smoothie',150),('Mango Lassi',180),('Berry Blast Smoothie',180),('Banana Berry Smoothie',200),('Apple Pie Smoothie',200),('Chickpea Salad',250),('Greek Salad',200),('Chicken Salad',350),('Veggie Chips',150),('Fruit Kabobs',50),('cup of Popcorn',100),('Energy Balls',100),('Classic Brownies',250),('Banana Bread',200),('Strawberry Shortcake',350),('Vanilla Cupcake',200),('Chocolate Cake Slice',350),('Sushi',50),('Chow Mein',400),('Noodles',350),('Macaroni',450),('Zarda',350),('Beaf Biryani plate',500),('Chicken Curry',450),('Apple Pie',300),('Chocolate Chip Cookie',100)");
    print("meal is inserted in db");

  }
  Future<List<Map<String,dynamic>>> get_wg_meal(Database db)async{
    final List<Map<String,dynamic>> mapmeal= await db.query('WEIGHTGAINMEAL');
    if(mapmeal.isNotEmpty) {
      print(mapmeal);
      print('map of meal is fetched in user repo');
      return mapmeal;
    }
    else{
      print(mapmeal);
      throw Exception("weight gain items NOT FOUND");
    }
  }






}