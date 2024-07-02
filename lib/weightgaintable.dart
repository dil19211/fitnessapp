import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class gaintable extends StatefulWidget {
  @override
  _GainTableState createState() => _GainTableState();
}

class _GainTableState extends State<gaintable> {
  List<Map<String, dynamic>> userData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('weight_gain_users').get();
      setState(() {
        userData = querySnapshot.docs.asMap().entries.map((entry) {
          int index = entry.key + 1; // Incremental ID starts from 1
          Map<String, dynamic> data = entry.value.data() as Map<String, dynamic>;
          data['id'] = index; // Add ID to the data
          return data;
        }).toList();
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weight Gain User Records',
          style: TextStyle(
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.grey,
                blurRadius: 2,
                offset: Offset(1, 1),
              ),
            ],
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 78.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: DataTable(
              border: TableBorder.all(color: Colors.black26, width: 2.0),
              columnSpacing: 16.0,
              dataRowHeight: 60.0,
              columns: [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Age')),
                DataColumn(label: Text('Height')),
                DataColumn(label: Text('Gender')),
                DataColumn(label: Text('Activity-level')),
                DataColumn(label: Text('Current-weight')),
                DataColumn(label: Text('Goal-weight')),
              ],
              rows: userData.map((users) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text(users['id']?.toString() ?? '')),
                    DataCell(Text(users['name'] ?? '')),
                    DataCell(Text(users['email'] ?? '')),
                    DataCell(Text(users['age']?.toString() ?? '')),
                    DataCell(Text(users['height']?.toString() ?? '')),
                    DataCell(Text(users['gender'] ?? '')),
                    DataCell(Text(users['activity_level'] ?? '')),
                    DataCell(Text(users['cweight']?.toString() ?? '')),
                    DataCell(Text(users['gweight']?.toString() ?? '')),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          fetchData();
        },
        label: Text(
          'Records: ${userData.length}',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.white,
                offset: Offset(1, 1),
              ),
            ],
            fontStyle: FontStyle.italic,
          ),
        ),
        icon: Icon(Icons.refresh, color: Colors.white),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
