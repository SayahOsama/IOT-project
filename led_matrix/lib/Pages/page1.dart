// page1.dart
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:led_matrix/main.dart';

class Page1 extends StatefulWidget {
  @override
  _Page1State createState() => _Page1State();
}


class _Page1State extends State<Page1> {
  final TextEditingController myController = TextEditingController();
  final databaseReference = FirebaseDatabase.instance.ref();
  String TextToShow="";

    void _printText(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // Device is not connected to the internet
      print("connectivityResult is none in _printText() : page1  ");
      // _showNoInternetDialog(context);
      // setState() {
      //   connectionMethod = 'Connection Failed';
      // }

      // Show an error message or handle it appropriately
    } else {
      // Device is connected to the internet

      databaseReference.child('Mode').set(1);
      print(myController.text);
      // TextToShow=myController.text;
      _sendTextData(myController.text);
      myController.clear();
    }
  }

    void _sendTextData(String data) async {
    try {
      await databaseReference.child('Mode').set(9);
      await databaseReference.child('TextToShow').set(data);
    } catch (e) {
      print('Failed to update data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              
              controller: myController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter text",
                hintText: "Enter text"
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>_printText(context),
            child: Text('Send Text', style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 62, 101, 120))),
          ),
        ],
      ),
    );
  }
}