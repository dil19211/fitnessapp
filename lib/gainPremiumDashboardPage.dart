import 'package:flutter/material.dart';

class preminum extends StatefulWidget {
  @override
  _PreminumState createState() => _PreminumState();
}

class _PreminumState extends State<preminum> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Premium Dashboard'),
      ),
      body: Center(
        child: Text('This is the premium dashboard data'),
      ),
    );
  }
}
