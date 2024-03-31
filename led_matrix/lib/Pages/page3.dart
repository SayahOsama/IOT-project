
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:led_matrix/main.dart';

class Page3 extends StatefulWidget {
  @override
  _Page3State createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  double _currentSliderValue = 50;
  final databaseReference = FirebaseDatabase.instance.ref();


  void _setBrightness(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // Device is not connected to the internet
      print("connectivityResult is none in _setBrightness() : page3");
      // _showNoInternetDialog(context);
      // setState() {
      //   connectionMethod = 'Connection Failed';
      // }

      // Show an error message or handle it appropriately
    } else {
      // Device is connected to the internet

      databaseReference.child('Mode').set(0);
      print("Trace: _setBrightness in page3");
      print('Current brightness level: $_currentSliderValue');
      // TextToShow=myController.text;
      _sendTextData(_currentSliderValue);
    }
  }

  void _sendTextData(double data) async {
    try {
      await databaseReference.child('Brightness').set(data);
    } catch (e) {
      print('Failed to update Brightness: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Slider(
            value: _currentSliderValue,
            min: 10,
            max: 100,
            divisions: 90,
            activeColor: Colors.lightBlue.withOpacity(_currentSliderValue / 100),
            onChanged: (double value) {
              setState(() {
                _currentSliderValue = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: () =>_setBrightness(context),
            child: Text('Set Brightness'),
          ),
        ],
      ),
    );
  }
}