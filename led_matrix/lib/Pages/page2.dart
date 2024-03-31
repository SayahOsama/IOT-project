import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Page2 extends StatefulWidget {
  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  File? _image;

  Future getImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      // Here you can call script on the image
      // script(_image);
    } else {
      print('No image selected.');
    }
    setState(() {});
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
              onPressed: doSomething,
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


