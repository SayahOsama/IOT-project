import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';

class Page4 extends StatefulWidget {
  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  File? _gif;
  String dropdownValue = 'None';
  final databaseReference = FirebaseDatabase.instance.ref();


  Future getGif() async {
    final pickedFile =
        await ImagePicker().getVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      _gif = File(pickedFile.path);
      // Here you can call script on the gif
      // script(_gif);
    } else {
      print('No gif selected.');
    }
    setState(() {});
  }


    void _showSelectedOption(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // Device is not connected to the internet
      // _showNoInternetDialog(context);
      // setState() {
      //   connectionMethod = 'Connection Failed';
      // }
          print("connectivityResult is none in _printText() : page1  ");

      // Show an error message or handle it appropriately
    } else {
      // Device is connected to the internet
      databaseReference.child('Mode').set(0);
      print('Selected option: $dropdownValue');
      _sendData(dropdownValue);
    }
  }

    void _sendData(String data) async {
    try {
      await databaseReference.child('GifName').set(data);
    } catch (e) {
      print('Failed to update data: $e');
    }
  }



  void doSomething() {
    // Your code here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Upload GIF', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              height: 250,
              width: 250,
              child: Stack(
                children: <Widget>[
                  if (_gif != null)
                    Opacity(
                      opacity: 0.5,
                      child: Image.file(
                        _gif!,
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Center(
                    child: IconButton(
                      icon: Icon(Icons.add, size: 50),
                      onPressed: getGif,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Display GIF'),
              onPressed: doSomething,
            ),
Padding(
  padding: EdgeInsets.symmetric(horizontal: 50.0), // Adjust as needed
  child: Stack(
    children: <Widget>[
      Divider(
        color: Colors.grey, // Adjust as needed
        height: 50,
        thickness: 2.0, // Adjust as needed
      ),
      Positioned(
        left: 0,
        right: 0,
        child: Container(
          color: Colors.white,
        ),
      ),
    ],
  ),
),
            DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                  value: dropdownValue,
                  items: <String>['None', 'Fire', 'Foo', 'Jump', 'Mario']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Center(child: Text(value)), // Center the text
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                ),
              ),
            ),
            ElevatedButton(
              child: Text('Display Selected'),
              onPressed: () => _showSelectedOption(context),
            ),
          ],
        ),
      ),
    );
  }
}
