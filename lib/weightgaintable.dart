import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class gaintable extends StatefulWidget {
  @override
  _GainTableState createState() => _GainTableState();
}

class _GainTableState extends State<gaintable> {
  List<Map<String, dynamic>> userData = [];
  String searchQuery = '';
  int? highlightedRowId;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('weight_gain_users').get();
      setState(() {
        userData = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          // Adjust this line based on the actual type of 'id' in Firestore
          data['id'] = int.tryParse(data['id'].toString()); // Convert to int
          return data;
        }).toList();
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _searchById(String query) {
    setState(() {
      searchQuery = query;
      highlightedRowId = int.tryParse(query); // Convert search query to integer
    });

    // Scroll to the highlighted row if it matches an ID
    if (highlightedRowId != null) {
      int rowIndex = userData.indexWhere((user) => user['id'] == highlightedRowId);
      if (rowIndex != -1) {
        // Calculate the vertical position of the row
        double rowPosition = rowIndex * 60.0; // Assuming each row has a height of 60.0
        _scrollController.animateTo(
          rowPosition,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weight Gain Users',
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by ID',
                hintStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.yellow, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                ),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              onChanged: _searchById,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            controller: _scrollController, // Set the scroll controller
            scrollDirection: Axis.vertical,
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
                  int? userId = users['id'] as int?;
                  bool isHighlighted = userId == highlightedRowId;
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        if (isHighlighted) {
                          return Colors.yellow.withOpacity(0.3); // Highlight color
                        }
                        return null; // Use default color otherwise
                      },
                    ),
                    cells: <DataCell>[
                      DataCell(Text(userId?.toString() ?? '')),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: fetchData,
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
