
import 'package:flutter/material.dart';


class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {

  //notify notification= notify();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stateful Widget Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // First button pressed action
                print('First button pressed!');
              },
              child: Text('Button 1'),
            ),
            ElevatedButton(
              onPressed: () {
                // Second button pressed action
                print('Second button pressed!');
                //notification.scdulenotification("me", "ready");
              },
              child: Text('Button 2'),
            ),
            ElevatedButton(
              onPressed: () {
                // Third button pressed action
                print('Third button pressed!');
              },
              child: Text('Button 3'),
            ),
          ],
        ),
      ),
    );
  }
}

