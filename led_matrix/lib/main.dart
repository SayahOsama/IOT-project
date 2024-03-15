import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:typed_data';
import 'package:connectivity/connectivity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     print('Firebase initialized successfully');
//   } catch (e) {
//     print('Failed to initialize Firebase: $e');
//   }
//   runApp(MyApp());
// }

bool isFirebaseInitialized = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    isFirebaseInitialized = false;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Matrix',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Builder(
        builder: (context) {
          if (!isFirebaseInitialized) {
            Future.delayed(Duration(seconds: 5), () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Failed to initialize Firebase. Please check your internet connection and try again.'),
                  duration: Duration(seconds: 5),
                ),
              );
            });
          }
          SnackBar(
            content: Text('Connected via internet'),
            duration: Duration(seconds: 5),
          );

          return MyHomePage(title: 'LED Matrix');
        },
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'LED Matrix',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(title: 'LED Matrix'),
//     );
//   }
// }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController();
  String dropdownValue = 'None'; // Default value
  String connectionMethod = "connected to wifi";
  int currentMode = 0; //default for gifs
  late BluetoothCharacteristic characteristic;
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference gifNameRef = FirebaseDatabase.instance.ref("GifName");
  DatabaseReference textRef = FirebaseDatabase.instance.ref("TextToShow");

  final databaseReference = FirebaseDatabase.instance.reference();

  void _printText(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // Device is not connected to the internet
      _showNoInternetDialog(context);
      setState() {
        connectionMethod = 'Connection Failed';
      }
      
      // Show an error message or handle it appropriately
    } else {
      // Device is connected to the internet
      setState() {
        connectionMethod = 'Connected to Wi-Fi';
      }

      currentMode = 1;
      databaseReference.child('Mode').set(currentMode);
      _sendTextData(myController.text);
    }
  }

  void _connect() async {
    // Start scanning
    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
    var subscription = FlutterBluePlus.adapterState
        .listen((BluetoothAdapterState state) async {
      print(state);
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
        // Listen to scan results
        var subscription = FlutterBluePlus.scanResults.listen((results) async {
          // do something with scan results
          for (ScanResult r in results) {
            print('${r.device.name} found! rssi: ${r.rssi}');

            // Check if the device is the one we want to connect to
            if (r.device.name == 'Your ESP32 device name') {
              // Stop scanning
              FlutterBluePlus.stopScan();

              // Connect to the device
              await r.device.connect();

              // Discover services
              List<BluetoothService> services =
                  await r.device.discoverServices();

              // Find the service and characteristic you want to write to
              // Replace 'serviceUUID' and 'characteristicUUID' with your actual UUIDs
              var service = services.firstWhere((s) => s.uuid == 'serviceUUID');
              characteristic = service.characteristics
                  .firstWhere((c) => c.uuid == 'characteristicUUID');

              // Break the loop
              break;
            }
          }
          //print no devices to connect to
        });
      } else {
        // show an error to the user, etc
        if (Platform.isAndroid) {
          await FlutterBluePlus.turnOn();
        }
      }
    });
    subscription.cancel();
  }

  void _showSelectedOption(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // Device is not connected to the internet
      _showNoInternetDialog(context);
      setState() {
        connectionMethod = 'Connection Failed';
      }
      // Show an error message or handle it appropriately
    } else {
      // Device is connected to the internet
      setState() {
        connectionMethod = 'Connected to Wi-Fi';
      }

      currentMode = 0;
      databaseReference.child('Mode').set(currentMode);
      print('Selected option: $dropdownValue');
      _sendData(dropdownValue);
    }
  }

  void bleFollowup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bluetooth'),
          content: Text(
              'The Bluetooth Low Energy connection is still under development'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  // connectionMethod = 'Connected via BLE';
                });
              },
            ),
          ],
        );
      },
    );
  }

  void wifiFollowup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Wi-Fi'),
          content: Text('Connected to Wi-Fi'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  connectionMethod = 'Connected to Wi-Fi';
                });
              },
            ),
          ],
        );
      },
    );
  }

// void _wifiDataSend(String data){
//     var connectivityResult = await (Connectivity().checkConnectivity());
//   if (connectivityResult == ConnectivityResult.wifi) {
//     // Connected to WiFi

//     // Initialize Firestore
//     final firestoreInstance = FirebaseFirestore.instance;

//     // Send data to Firestore
//     firestoreInstance.collection('yourCollection').add({
//       'field': 'value',
//       // Add more fields as needed
//     }).then((value) {
//       print('Data added to Firestore');
//     }).catchError((error) {
//       print('Failed to add data to Firestore: $error');
//     });
//   } else {
//     // Not connected to WiFi
//     print('Not connected to WiFi');
//   }
// }

  void _sendTextData(String data) async {
    databaseReference.child('TextToShow').set(data);
  }

  void _sendData(String data) async {
    databaseReference.child('GifName').set(data);

    // await ref.update(data);

    // if (characteristic == null) {
    //   print('Characteristic not initialized');
    //   return;
    // }
    // if(connectionMethod == 'Connected via BLE'){
    //   var dataToSend =Uint8List.fromList(data.codeUnits); // convert string to bytes
    //   await characteristic.write(dataToSend);
    // }
    // else if(connectionMethod == 'Connected via BLE'){
    //   var dataToSend =Uint8List.fromList(data.codeUnits); // convert string to bytes
    //   await characteristic.write(dataToSend);
    // }
  }

  void _showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Please check your internet connection and try again.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'connection method: $connectionMethod',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Spacer(), // Takes up 1/3 of the space
                  IconButton(
                    icon: Icon(Icons.bluetooth),
                    onPressed: bleFollowup,
                    color: Colors.blue,
                    iconSize: 50.0,
                  ),
                  Spacer(), // Takes up 1/3 of the space
                  IconButton(
                    icon: Icon(Icons.wifi),
                    onPressed: wifiFollowup,
                    color: Colors.blue,
                    iconSize: 50.0,
                  ),
                  Spacer(), // Takes up 1/3 of the space
                ],
              ),

              // Middle section
              Center(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: myController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter text',
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _printText(context),
                        child:
                            Text('Send Text', style: TextStyle(fontSize: 20)),
                      ),

                      SizedBox(height: 10), // Add some space
                      DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<String>(
                            value: dropdownValue,
                            items: <String>[
                              'None',
                              'Fire',
                              'Foo',
                              'Jump',
                              'Mario'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Center(
                                    child: Text(value)), // Center the text
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
                      SizedBox(height: 10),
                      Container(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: () => _showSelectedOption(context),
                          child: Text('Show', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }


// class _MyHomePageState extends State<MyHomePage> {
//   final myController = TextEditingController();
//   String dropdownValue = 'Option 1'; // Default value

//   void _printText() {
//     print(myController.text);
//   }

//   void _connect() async {
//     // Start scanning
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

//     // Listen to scan results
//     var subscription = FlutterBluePlus.scanResults.listen((results) {
//       // do something with scan results
//       for (ScanResult r in results) {
//         print('${r.device.name} found! rssi: ${r.rssi}');
//       }
//     });

//     // Stop scanning
//     FlutterBluePlus.stopScan();
//   }

//   void _showSelectedOption() {
//     print('Selected option: $dropdownValue');
//   }

//   @override
//  Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         centerTitle: true,
//         backgroundColor: Colors.lightBlue[800], // Change the AppBar color
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topRight,
//             end: Alignment.bottomRight,
//             colors: [
//               Color.fromARGB(255, 116, 212, 229),
//               Color.fromARGB(255, 135, 235, 212),
//               const Color.fromARGB(255, 142, 189, 228)
//               // Colors.lightBlue[200],
//               // Colors.lightBlue[300],
//               // Colors.lightBlue[400],
//             ],
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: <Widget>[
//               // Top section
//               IconButton(
//                 icon: Icon(Icons.bluetooth),
//                 onPressed: _connect,
//                 color: Colors.blue,
//                 iconSize: 50.0,
//               ),
//               // Middle section
//               Expanded(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       SizedBox(height: 50), // Add some space
//                       Container(
//                         width: 200.0, // Adjust as needed
//                         child: DropdownButtonHideUnderline(
//                           child: ButtonTheme(
//                             alignedDropdown: true,
//                             child: DropdownButton<String>(
//                               value: dropdownValue,
//                               items: <String>['Option 1', 'Option 2', 'Option 3', 'Option 4', 'Option 5', 'Option 6']
//                                   .map<DropdownMenuItem<String>>((String value) {
//                                 return DropdownMenuItem<String>(
//                                   value: value,
//                                   child: Center(child: Text(value)), // Center the text
//                                 );
//                               }).toList(),
//                               onChanged: (String? newValue) {
//                                 setState(() {
//                                   dropdownValue = newValue!;
//                                 });
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       Container(
//                         width: 150.0, // Adjust as needed
//                         child: ElevatedButton(
//                           onPressed: _showSelectedOption,
//                           child: Text('Show', style: TextStyle(fontSize: 20)),
//                           // style: ElevatedButton.styleFrom(
//                           //   primary: Colors.lightBlue[600], // background
//                           //   onPrimary: Colors.white, // foreground
//                           // ),
//                         ),
//                       ),
//                       SizedBox(height: 50), // Add some space
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: TextField(
//                           controller: myController,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             labelText: 'Enter text',
//                           ),
//                         ),
//                       ),
//                       ElevatedButton(
//                         onPressed: _printText,
//                         child: Text('Send Text', style: TextStyle(fontSize: 20)),
//                         // style: ElevatedButton.styleFrom(
//                         //   primary: Colors.lightBlue[600], // background
//                         //   onPrimary: Colors.white, // foreground
//                         // ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



//   void _connect() async {
//   // Start scanning
//   FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

//   // Listen to scan results
//   var subscription = FlutterBluePlus.scanResults.listen((results) async {
//     // do something with scan results
//     for (ScanResult r in results) {
//       print('${r.device.name} found! rssi: ${r.rssi}');

//       // Check if the device is the one we want to connect to
//       if (r.device.name == 'Your ESP32 device name') {
//         // Stop scanning
//         FlutterBluePlus.stopScan();

//         // Connect to the device
//         await r.device.connect();

//         // Discover services
//         List<BluetoothService> services = await r.device.discoverServices();

//         // Find the service and characteristic you want to write to
//         // Replace 'serviceUUID' and 'characteristicUUID' with your actual UUIDs
//         var service = services.firstWhere((s) => s.uuid == 'serviceUUID');
//         var characteristic = service.characteristics.firstWhere((c) => c.uuid == 'characteristicUUID');

//         // Write to the characteristic
//         var dataToSend = Uint8List.fromList([0x01, 0x02]); // data to send
//         await characteristic.write(dataToSend);

//         // Disconnect from the device
//         await r.device.disconnect();

//         // Break the loop
//         break;
//       }
//     }
//   });
// }