import 'package:flutter/material.dart';

import 'package:fitnessapp/user_repo.dart';
import 'package:sqflite/sqflite.dart';
import 'database_handler.dart';
Database? _database;
class Approved extends StatefulWidget {
  @override
  _ApprovedPageState createState() => _ApprovedPageState();
}

class _ApprovedPageState extends State<Approved> {
  List<Map<String, dynamic>> userdata = [];

  @override
  void initState() {
    super.initState();
    // Fetch the requested data from the database or any other source
    // Here, we are initializing the data with some static values
    fetchData();
  }

  Future<Database?> openDB() async{
    _database=await DatabaseHandler().openDB();

    return _database;
  }

  void fetchData() async {
    _database=await openDB();
    UserRepo userRepo=new UserRepo();
    final users= await userRepo.getpayusers(_database);

    if (_database != null) {
      await _database?.close();
    }
    setState(() {
      userdata= users;
    });
  }



@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white, // Set background color here
    appBar: AppBar(
      backgroundColor: Colors.purple,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Payments',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              shadows: [
                Shadow(
                  blurRadius: 6.0,
                  color: Colors.black,
                  offset: Offset(5, 5),
                ),
              ],
            ),
          ),
        ],
      ),
      centerTitle: true,
      shadowColor: Colors.black,
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.playlist_add_check, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Paid Users (${userdata.length})',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.deepPurple,
                      offset: Offset(1, 1),
                    ),
                  ],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: EdgeInsets.all(9.0),
            child: DataTable(
              columnSpacing: 7.0,
              dataRowHeight: 60.0,
              border: TableBorder.all(color: Colors.purple, width: 2.0),
              columns: [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Email')),
              ],

              rows: userdata.map((users) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text(users['id'].toString())),
                    DataCell(Text(users['email'])),

                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    ),
  );
}

}
