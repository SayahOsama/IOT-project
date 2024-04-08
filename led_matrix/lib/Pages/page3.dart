
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
  bool _isOn = false;
  final databaseReference = FirebaseDatabase.instance.ref();

    void _toggle(BuildContext context) async {
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

      
      print("Trace: _toggle in page3");
      // TextToShow=myController.text;
      _sendToggleData();
    }
  }

    void _sendToggleData() async {
    try {
      await databaseReference.child('switch').set(_isOn);
      await databaseReference.child('Mode').set(10);
    } catch (e) {
      print('Failed to update Brightness: $e');
    }
  }


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

      
      print("Trace: _setBrightness in page3");
      print('Current brightness level: $_currentSliderValue');
      // TextToShow=myController.text;
      _sendBrightnessData((_currentSliderValue));
    }
  }

  void _sendBrightnessData(double data) async {
    try {
      await databaseReference.child('Brightness').set(data.floor());
      await databaseReference.child('Mode').set(12);
    } catch (e) {
      print('Failed to update Brightness: $e');
    }
  }

  void doSomething() {
    print('Switch is $_isOn');
  }


      void _displaySD(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // Device is not connected to the internet
      print("connectivityResult is none in _displaySD() : page3");
      // _showNoInternetDialog(context);
      // setState() {
      //   connectionMethod = 'Connection Failed';
      // }

      // Show an error message or handle it appropriately
    } else {
      // Device is connected to the internet

      
      print("Trace: _displaySD in page3");
      // TextToShow=myController.text;
      _sendDisplaySdData();
    }
  }

    void _sendDisplaySdData() async {
    try {
      await databaseReference.child('Mode').set(13);
    } catch (e) {
      print('Failed to update Brightness: $e');
    }
  }


@override
Widget build(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Toggle Matrix', style: TextStyle(fontSize: 20)),
            SizedBox(width: 20),
            Text('Off ', style: TextStyle(fontSize: 20)),
            Switch(
              activeColor: _isOn ? const Color.fromARGB(255, 12, 114, 15) : const Color.fromARGB(255, 123, 20, 12),
              value: _isOn,
              onChanged: (value) {
                setState(() {
                  _isOn = value;
                  _toggle(context);
                });
              },
            ),
            Text(' On', style: TextStyle(fontSize: 20)),
          ],
        ),
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
          onPressed: () => _setBrightness(context),
          child: Text('Set Brightness', style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 62, 101, 120))),
        ),
        ElevatedButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Container(
                height: MediaQuery.of(context).size.height * 0.5, // Adjust this value as needed
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: FutureBuilder<DatabaseEvent>(
                      future: databaseReference.child('files').once(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          String files = snapshot.data!.snapshot.value as String;
                          List<String> fileNames = files.split(',');
                          return Column(
                            children: fileNames.map((fileName) => ListTile(
                              title: Text(fileName),
                            )).toList(),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                  TextButton(
    child: Text('Display Media', style: TextStyle(color: Color.fromARGB(255, 62, 101, 120))),
    onPressed: () {
      _displaySD(context);
      Navigator.of(context).pop();
    },
  ),
                TextButton(
                  child: Text('Cancel',style: TextStyle(color: Color.fromARGB(255, 62, 101, 120))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          child: Text('Check Saved Files', style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 62, 101, 120))),
        ),
      ],
    ),
  );
}

// @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: <Widget>[
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Text('Toggle Matrix', style: TextStyle(fontSize: 20)),
//               SizedBox(width: 20),
//               Text('Off ', style: TextStyle(fontSize: 20)),
//               Switch(
//                 activeColor: _isOn ? const Color.fromARGB(255, 12, 114, 15) : const Color.fromARGB(255, 123, 20, 12),
//                 value: _isOn,
//                 onChanged: (value) {
//                   setState(() {
//                     _isOn = value;
//                     doSomething();
//                   });
//                 },
//               ),
//               Text(' On', style: TextStyle(fontSize: 20)),
//             ],
//           ),
//           Slider(
//             value: _currentSliderValue,
//             min: 10,
//             max: 100,
//             divisions: 90,
//             activeColor: Colors.lightBlue.withOpacity(_currentSliderValue / 100),
//             onChanged: (double value) {
//               setState(() {
//                 _currentSliderValue = value;
//               });
//             },
//           ),
//           ElevatedButton(
//             onPressed: () => _setBrightness(context),
//             child: Text('Set Brightness', style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 62, 101, 120))),
//           ),
// ElevatedButton(
//   onPressed: () => showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       content: Container(
//         height: MediaQuery.of(context).size.height * 0.5, // Adjust this value as needed
//         child: SingleChildScrollView(
//           child: FutureBuilder<DatabaseEvent>(
//             future: databaseReference.child('files').once(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return CircularProgressIndicator();
//               } else if (snapshot.hasError) {
//                 return Text('Error: ${snapshot.error}');
//               } else {
//                 String files = snapshot.data!.snapshot.value as String;
//                 List<String> fileNames = files.split(',');
//                 return Column(
//                   children: fileNames.map((fileName) => ListTile(
//                     title: Text(fileName),
//                   )).toList(),
//                 );
//               }
//             },
//           ),
//         ),
//       ),
// actions: <Widget>[
//   TextButton(
//     child: Text('Cancel',style: TextStyle(color: Color.fromARGB(255, 62, 101, 120))),
//     onPressed: () {
//       Navigator.of(context).pop();
//     },
//   ),
// ],
//     ),
//   ),
//   child: Text('Check Saved Files', style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 62, 101, 120))),
// ),
//         ],
//       ),
//     );
//   }



  // @override
//   Widget build(BuildContext context) {
//   return Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: <Widget>[
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text('Toggle Matrix', style: TextStyle(fontSize: 20)),
//             SizedBox(width: 20),
//             Text('Off ', style: TextStyle(fontSize: 20)),
//             Switch(
//                 activeColor: _isOn ? const Color.fromARGB(255, 12, 114, 15) : const Color.fromARGB(255, 123, 20, 12),
//               value: _isOn,
//               onChanged: (value) {
//                 setState(() {
//                   _isOn = value;
//                   doSomething();
//                 });
//               },
//             ),
//             Text(' On', style: TextStyle(fontSize: 20)),
//           ],
//         ),
//         Slider(
//           value: _currentSliderValue,
//           min: 10,
//           max: 100,
//           divisions: 90,
//           activeColor: Colors.lightBlue.withOpacity(_currentSliderValue / 100),
//           onChanged: (double value) {
//             setState(() {
//               _currentSliderValue = value;
//             });
//           },
//         ),
//         ElevatedButton(
//           onPressed: () => _setBrightness(context),
//           child: Text('Set Brightness', style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 62, 101, 120))),
//         ),
//       ],
//     ),
//   );
// }
//   Widget build(BuildContext context) {
//   return Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: <Widget>[
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text('Toggle Matrix', style: TextStyle(fontSize: 20)),
//             Text('Off', style: TextStyle(fontSize: 20)),
//             Switch(
//               value: _isOn,
//               onChanged: (value) {
//                 setState(() {
//                   _isOn = value;
//                   doSomething();
//                 });
//               },
//             ),
//             Text('On', style: TextStyle(fontSize: 20)),
//           ],
//         ),
//         Slider(
//           value: _currentSliderValue,
//           min: 10,
//           max: 100,
//           divisions: 90,
//           activeColor: Colors.lightBlue.withOpacity(_currentSliderValue / 100),
//           onChanged: (double value) {
//             setState(() {
//               _currentSliderValue = value;
//             });
//           },
//         ),
//         ElevatedButton(
//           onPressed: () => _setBrightness(context),
//           child: Text('Set Brightness'),
//         ),
//       ],
//     ),
//   );
// }
//   Widget build(BuildContext context) {
//   return Center(
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         Switch(
//           value: _isOn,
//           onChanged: (value) {
//             setState(() {
//               _isOn = value;
//               doSomething();
//             });
//           },
//         ),
//         Spacer(flex: 1),
//         Slider(
//           value: _currentSliderValue,
//           min: 10,
//           max: 100,
//           divisions: 90,
//           activeColor: Colors.lightBlue.withOpacity(_currentSliderValue / 100),
//           onChanged: (double value) {
//             setState(() {
//               _currentSliderValue = value;
//             });
//           },
//         ),
//         Spacer(flex: 1),
//         ElevatedButton(
//           onPressed: () => _setBrightness(context),
//           child: Text('Set Brightness'),
//         ),
//       ],
//     ),
//   );
// }

  // Widget build(BuildContext context) {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: <Widget>[
  //         Slider(
  //           value: _currentSliderValue,
  //           min: 10,
  //           max: 100,
  //           divisions: 90,
  //           activeColor: Colors.lightBlue.withOpacity(_currentSliderValue / 100),
  //           onChanged: (double value) {
  //             setState(() {
  //               _currentSliderValue = value;
  //             });
  //           },
  //         ),
  //         ElevatedButton(
  //           onPressed: () =>_setBrightness(context),
  //           child: Text('Set Brightness'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}