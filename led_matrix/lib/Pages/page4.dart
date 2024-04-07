import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class Page4 extends StatefulWidget {
  @override
  _Page4State createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  File? _gif;
  String dropdownValue = 'None';
  bool saveGif = false;
  final databaseReference = FirebaseDatabase.instance.ref();

  Future getGif() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _gif = File(pickedFile.path);
      // Here you can call script on the gif
      // script(_gif);
    } else {
      print('No gif selected.');
    }
    setState(() {});
  }

    void sendData() async {
      if (_gif == null) {
    print('No image selected.');
    return;
  }
    var url =
        Uri.parse('https://matrix-server-bzr4.onrender.com/process'); // URL of your Flask API

    var request = http.MultipartRequest('POST', url);
    final imageData = await _gif!.readAsBytes();
    final image = img.decodeImage(imageData);


    request.files.add(await http.MultipartFile.fromPath(
      'file',
      _gif!.path,
    ));

    request.fields['size1'] = image!.width.toString();
    request.fields['size2'] = image!.height.toString();

    var response = await request.send();

    if (response.statusCode == 200) {
      var result = json.decode(await response.stream.bytesToString());
      print(result); // Print the result
      try {
      await databaseReference.child('Mode').set(2);
      await databaseReference.child('image').set(result);
    } catch (e) {
      print('Failed to update data: $e');
    }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void sendDataToSendData() async {
        var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {

      print("connectivityResult is none in _printText() : page1  ");

      // Show an error message or handle it appropriately
    } else {
      // Device is connected to the internet
      sendData();
    }
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



  Future<void> showSaveGifDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Save GIF'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Do you want to save the GIF?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Yes'),
            onPressed: () {
              saveGif = true;
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('No'),
            onPressed: () {
              saveGif = false;
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void onDisplayGifButtonPressed() async {
  await showSaveGifDialog();
  sendDataToSendData();
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
              onPressed: onDisplayGifButtonPressed,
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 50.0), // Adjust as needed
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
