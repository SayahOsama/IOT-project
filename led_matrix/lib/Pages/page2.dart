import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image/image.dart' as img;

final picker = ImagePicker();

class Page2 extends StatefulWidget {
  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  File? _image;
  bool saveImage = false;
  final databaseReference = FirebaseDatabase.instance.ref();

  Future getImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
    } else {
      print('No image selected.');
    }
    setState(() {});
  }

  void sendData() async {
      if (_image == null) {
    print('No image selected.');
    return;
  }
    var url =
        Uri.parse('https://matrix-server-bzr4.onrender.com/process'); // URL of your Flask API

    var request = http.MultipartRequest('POST', url);

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      _image!.path,
    ));

    final imageData = await _image!.readAsBytes();
    final image = img.decodeImage(imageData);


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


    Future<void> showSaveImageDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save Image'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you want to save the image?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                saveImage = true;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                saveImage = false;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

    void onDisplayImageButtonPressed() async {
    await showSaveImageDialog();
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
            Text('Upload Image', style: TextStyle(fontSize: 20)),
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
                  if (_image != null)
                    Opacity(
                      opacity: 0.5,
                      child: Image.file(
                        _image!,
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  Center(
                    child: IconButton(
                      icon: Icon(Icons.add, size: 50),
                      onPressed: getImage,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Display Image'),
              onPressed: onDisplayImageButtonPressed,
            ),
          ],
        ),
      ),
    );
  }
}



















// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class Page2 extends StatefulWidget {
//   @override
//   _Page2State createState() => _Page2State();
// }

// class _Page2State extends State<Page2> {
//   File? _image;

//   Future getImage() async {
//     final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       _image = File(pickedFile.path);
//       // Here you can call script on the image
//       // script(_image);
//     } else {
//       print('No image selected.');
//     }
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Upload Image'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.grey.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               height: 200,
//               width: 200,
//               child: Stack(
//                 children: <Widget>[
//                   if (_image != null)
//                     Opacity(
//                       opacity: 0.5,
//                       child: Image.file(
//                         _image!,
//                         width: 200,
//                         height: 200,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   Center(
//                     child: IconButton(
//                       icon: Icon(Icons.add),
//                       onPressed: getImage,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 20),
//             Text('Upload Image'),
//           ],
//         ),
//       ),
//     );
//   }
// }

/******************************************************************** */

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class Page2 extends StatefulWidget {
//   @override
//   _Page2State createState() => _Page2State();
// }

// class _Page2State extends State<Page2> {
//   File? _image;

//   Future getImage() async {
//     final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       _image = File(pickedFile.path);
//       // Here you can call your script on the image
//       // script(_image);
//     } else {
//       print('No image selected.');
//     }
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Upload Image'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             _image == null
//                 ? Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey.withOpacity(0.5),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     height: 200,
//                     width: 200,
//                     child: IconButton(
//                       icon: Icon(Icons.add),
//                       onPressed: getImage,
//                     ),
//                   )
//                 : Image.file(_image!),
//             SizedBox(height: 20),
//             Text('Upload Image'),
//           ],
//         ),
//       ),
//     );
//   }
// }


