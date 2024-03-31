import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:typed_data';
import 'package:connectivity/connectivity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'Pages/page1.dart';
import 'Pages/page2.dart';
import 'Pages/page3.dart';
import 'Pages/page4.dart';
import 'Pages/page5.dart';
import 'appBar.dart';

// ********************************************************************************************* START HERE

bool isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
    isFirebaseInitialized = true;
  } catch (e) {
    print('Failed to initialize Firebase: $e');
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

          return MyHomePage(title: 'LED Matrix');
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// ************************************************************************************************ END HERE

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> _children = [
    Page1(),
    Page2(),
    Page3(),
    Page4(),
    Page5(),
  ];
  int _currentIndex = 2;

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

  void _sendTextData(String data) async {
    try {
      await databaseReference.child('Mode').set(currentMode);
      await databaseReference.child('TextToShow').set(data);
    } catch (e) {
      print('Failed to update data: $e');
    }
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

  void _sendData(String data) async {
    databaseReference.child('GifName').set(data);
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(widget.title),
  //       centerTitle: true,
  //       backgroundColor: const Color.fromARGB(255, 62, 101, 120),
  //       actions: <Widget>[
  //         Builder(
  //           builder: (BuildContext context) =>
  //               StreamBuilder<ConnectivityResult>(
  //             stream: Connectivity().onConnectivityChanged,
  //             builder: (BuildContext context,
  //                 AsyncSnapshot<ConnectivityResult> snapshot) {
  //               if (snapshot.hasData &&
  //                   snapshot.data == ConnectivityResult.wifi) {
  //                 // ScaffoldMessenger.of(context).showSnackBar(
  //                 //   SnackBar(
  //                 //     content: Text('Connected to Wi-Fi'),
  //                 //     duration: Duration(seconds: 3),
  //                 //   ),
  //                 // );
  //                 return Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Icon(
  //                     Icons.wifi,
  //                     color: Color.fromARGB(255, 10, 252, 22),
  //                     size: 30.0,
  //                   ),
  //                 );
  //               } else {
  //                 // ScaffoldMessenger.of(context).showSnackBar(
  //                 //   SnackBar(
  //                 //     content: Text('No internet connection'),
  //                 //     duration: Duration(seconds: 3),
  //                 //   ),
  //                 // );
  //                 return Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Icon(Icons.wifi_off, color: Colors.red, size: 30.0),
  //                 );
  //               }
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //     body: _children[_currentIndex],
  //     bottomNavigationBar: BottomNavigationBar(
  //       backgroundColor: Colors.black,
  //       selectedItemColor: Colors.green,
  //       unselectedItemColor: Colors.white.withOpacity(.60),
  //       type: BottomNavigationBarType.fixed,
  //       onTap: onTabTapped,
  //       currentIndex: _currentIndex,
  //       items: [
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.text_fields),
  //           activeIcon: Icon(Icons.text_fields),
  //           label: 'Text',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.image),
  //           activeIcon: Icon(Icons.image),
  //           label: 'images',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.hourglass_empty),
  //           activeIcon: Icon(Icons.hourglass_empty, color: Colors.green),
  //           label: 'Idle',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.show_chart),
  //           activeIcon: Icon(Icons.show_chart, color: Colors.green),
  //           label: 'Tetris Game',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.linear_scale),
  //           activeIcon: Icon(Icons.linear_scale, color: Colors.green),
  //           label: 'Snake Game',
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),
      // appBar: AppBar(
      //   title: Text(widget.title),
      //   centerTitle: true,
      //   backgroundColor: const Color.fromARGB(255, 62, 101, 120),
      //   actions: <Widget>[
      //     StreamBuilder<ConnectivityResult>(
      //       stream: Connectivity().onConnectivityChanged,
      //       builder: (BuildContext context,
      //           AsyncSnapshot<ConnectivityResult> snapshot) {
      //         if (snapshot.hasData &&
      //             snapshot.data == ConnectivityResult.wifi) {
      //           return Padding(
      //             padding: const EdgeInsets.all(8.0),
      //             child: Icon(
      //               Icons.wifi,
      //               color: Color.fromARGB(255, 10, 252, 22),
      //               size: 30.0,
      //             ),
      //           );
      //         } else {
      //           ScaffoldMessenger.of(context).showSnackBar(
      //             SnackBar(
      //               content: Text('No internet connection'),
      //               duration: Duration(seconds: 3),
      //             ),
      //           );
      //           return Padding(
      //             padding: const EdgeInsets.all(8.0),
      //             child: Icon(Icons.wifi_off, color: Colors.red, size: 30.0),
      //           );
      //         }
      //       },
      //     ),
      //   ],
      // ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        // selectedItemColor: Colors.lightBlueAccent,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white.withOpacity(.60),
        // selectedFontSize: 20,
        // unselectedFontSize: 14,
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.text_fields,
            ), // This changes the color of the icon
            activeIcon: Icon(Icons.text_fields),
            label: 'Text',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.image,
            ), // This changes the color of the icon
            activeIcon: Icon(
              Icons.image,
            ),
            label: 'images',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_empty),
            activeIcon: Icon(
              Icons.hourglass_empty,
              color: Colors.green,
            ),
            label: 'Idle',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.movie_filter,
            ), // This changes the color of the icon
            activeIcon: Icon(Icons.movie_filter, color: Colors.green),
            label: 'GIFs',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.linear_scale,
            ), // This changes the color of the icon
            activeIcon: Icon(Icons.linear_scale, color: Colors.green),
            label: 'Snake Game',
          ),
        ],
      ),
    );
  }
}


class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  MyAppBar({required this.title});

  @override
  _MyAppBarState createState() => _MyAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _MyAppBarState extends State<MyAppBar> {
  late Stream<ConnectivityResult> connectivityStream;
  ConnectivityResult? previousResult;

  @override
  void initState() {
    super.initState();
    connectivityStream = Connectivity().onConnectivityChanged;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 62, 101, 120),
      actions: <Widget>[
        StreamBuilder<ConnectivityResult>(
          stream: connectivityStream,
          builder: (BuildContext context, AsyncSnapshot<ConnectivityResult> snapshot) {
            if (snapshot.hasData && snapshot.data != previousResult) {
              previousResult = snapshot.data;
              if (snapshot.data == ConnectivityResult.wifi) {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Connected to Wi-Fi'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                });
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.wifi,
                    color: Color.fromARGB(255, 10, 252, 22),
                    size: 30.0,
                  ),
                );
              } else {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No internet connection'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                });
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.wifi_off, color: Colors.red, size: 30.0),
                );
              }
            } else {
              return Container();
            }
          },
        ),
      ],
    );
  }
}


