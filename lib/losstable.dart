import 'package:flutter/material.dart';

class tableloss extends StatefulWidget {
  @override
  _TableLossState createState() => _TableLossState();
}

class _TableLossState extends State<tableloss> {
  List<Map<String, String>> userData = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weight loss User Records',
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
            padding: EdgeInsets.all(8.0), // Add padding for the border
            child: DataTable(
              border: TableBorder.all(color: Colors.purple, width: 2.0), // Table border
              columnSpacing: 16.0,
              dataRowHeight: 60.0,
              columns: userData.isNotEmpty
                  ? userData[0].keys.map((fieldName) {
                return DataColumn(
                  label: Container(
                    child: Text(
                      fieldName,
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                );
              }).toList()
                  : [],
              rows: userData.map((data) {
                return DataRow(
                  cells: data.keys.map((fieldName) {
                    return DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 7.0,
                          horizontal: 12.0,
                        ),
                        child: Text(data[fieldName] ?? ''),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          fetchDataFromDatabase();
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

  void fetchDataFromDatabase() {
    setState(() {
      userData = [
        {
          'name': 'Jane Doe',
          'age': '25',
          'height': '5\'6"',
          'currentWeight': '140 lbs',
          'gainWeight': 'Yes',
          'gender': 'Female',
          'email': 'jane@example.com',
          'activityLevel': 'Medium'
        },
        {
          'name': 'John Doe',
          'age': '30',
          'height': '6\'0"',
          'currentWeight': '180 lbs',
          'gainWeight': 'No',
          'gender': 'Male',
          'email': 'john@example.com',
          'activityLevel': 'High'
        },
        {
          'name': 'John Doe',
          'age': '30',
          'height': '6\'0"',
          'currentWeight': '180 lbs',
          'gainWeight': 'No',
          'gender': 'Male',
          'email': 'john@example.com',
          'activityLevel': 'High'
        },
      ];
    });
  }
}
