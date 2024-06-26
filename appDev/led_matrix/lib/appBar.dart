import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final databaseReference = FirebaseDatabase.instance.ref();

  late Stream<ConnectivityResult> connectivityStream;
  ConnectivityResult? previousResult;
  ConnectivityResult? realPrev;
  bool hide = true;
  Timer? _timer;
  late Timer _timerEsp;
  late Timer _timerApp;

  @override
  // void initState() {
  //   super.initState();
  //   connectivityStream = Connectivity().onConnectivityChanged;
  //    initConnectivity();
  // }
  //   void initState() {
  //   super.initState();
  //   connectivityStream = Connectivity().onConnectivityChanged;
  //   initConnectivity();
  //   _timer = Timer.periodic(Duration(seconds: 10), (timer) {
  //     updateConnectionStatus();
  //   });
  // }
  void initState() {
    super.initState();
    connectivityStream = Connectivity().onConnectivityChanged;
    initConnectivity();
    _timerEsp = Timer.periodic(Duration(seconds: 10), (timer) {
      updateConnectionStatus();
    });
    _timerApp = Timer.periodic(Duration(seconds: 3), (timer) {
      updateAppConnectedStatus();
    });
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    setState(() {
      realPrev = previousResult;
      previousResult = result;
      hide = false;
    });
  }

  void updateAppConnectedStatus() {
    final isConnected = previousResult != ConnectivityResult.none;
    databaseReference.child('AppConnected').set(isConnected);
  }

  void updateConnectionStatus() async {
    DatabaseEvent event =
        await databaseReference.child('Esp32Connected').once();
    bool isEspConnected = event.snapshot.value as bool;
    if (!isEspConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ESP is not connected'),
          duration: Duration(seconds: 5),
        ),
      );
    } else {
      
    }
    databaseReference.child('Esp32Connected').set(false);
  }

  @override
  void dispose() {
    super.dispose();
    _timerEsp?.cancel();
    _timerApp?.cancel();
  }

//TODO : add descriptions for each page.
  List<String> pageDescriptions = [
    "Custom Text Page\n\nWrite down your custom text to display it on the matrix.\n\n",
    "Upload Image Page\n\nUpload an image from your device.\nClick on the '+' to preview the image, and click 'Show Image' to display it on the matrix.\n\n",
    "Idle Page\n\nHere you can set the brightness of the matrix using the slide.\nClick 'Set Brightness' to adjust the matrix’s brightness and display the time and date.\n\n",
    "Upload GIF Page\n\nChoose between uploading your own GIF by clicking the '+', or select a GIF to display from a given set of options.\nClick 'Display GIF' to show the chosen GIF.\n\n",
    "Snake Game Page\n\nTo start a game, click 'Start Game' at the top of the page.\nUse the arrows or the touchpad to determine the direction.\n\n"
  ];

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 62, 101, 120),
      leading: IconButton(
        icon: Icon(Icons.info),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              int currentPage = 0;
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return AlertDialog(
                    title: Text('User Guide'),
                    content: Text(pageDescriptions[currentPage]),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Next'),
                        onPressed: () {
                          setState(() {
                            currentPage =
                                (currentPage + 1) % pageDescriptions.length;
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      actions: <Widget>[
        if (!hide)
          StreamBuilder<ConnectivityResult>(
            stream: connectivityStream,
            builder: (BuildContext context,
                AsyncSnapshot<ConnectivityResult> snapshot) {
              if (snapshot.hasData && (snapshot.data != previousResult)) {
                realPrev = previousResult;
                previousResult = snapshot.data;
              }
              if (previousResult == ConnectivityResult.wifi) {
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
            },
          ),
      ],
    );
  }

// @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: Text(widget.title),
//       centerTitle: true,
//       backgroundColor: const Color.fromARGB(255, 62, 101, 120),
//       actions: <Widget>[
//         if (!hide)
//           StreamBuilder<ConnectivityResult>(
//             stream: connectivityStream,
//             builder: (BuildContext context, AsyncSnapshot<ConnectivityResult> snapshot) {
//               if (snapshot.hasData && snapshot.data != previousResult) {
//                 previousResult = snapshot.data;
//               }
//               if (previousResult == ConnectivityResult.wifi) {
//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Icon(
//                     Icons.wifi,
//                     color: Color.fromARGB(255, 10, 252, 22),
//                     size: 30.0,
//                   ),
//                 );
//               } else {
//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Icon(Icons.wifi_off, color: Colors.red, size: 30.0),
//                 );
//               }
//             },
//           ),
//       ],
//     );
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return AppBar(
//   //     title: Text(widget.title),
//   //     centerTitle: true,
//   //     backgroundColor: const Color.fromARGB(255, 62, 101, 120),
//   //     actions: <Widget>[
//   //       StreamBuilder<ConnectivityResult>(
//   //         stream: connectivityStream,
//   //         builder: (BuildContext context,
//   //             AsyncSnapshot<ConnectivityResult> snapshot) {
//   //           if (snapshot.hasData && snapshot.data != previousResult) {
//   //             previousResult = snapshot.data;
//   //             if (snapshot.data == ConnectivityResult.wifi) {
//   //               return Padding(
//   //                 padding: const EdgeInsets.all(8.0),
//   //                 child: Icon(
//   //                   Icons.wifi,
//   //                   color: Color.fromARGB(255, 10, 252, 22),
//   //                   size: 30.0,
//   //                 ),
//   //               );
//   //             } else {
//   //               return Padding(
//   //                 padding: const EdgeInsets.all(8.0),
//   //                 child: Icon(Icons.wifi_off, color: Colors.red, size: 30.0),
//   //               );
//   //             }
//   //           } else {
//   //             return Container();
//   //           }
//   //         },
//   //       ),
//   //     ],
//   //   );
//   // }

  // @override
  // Widget build(BuildContext context) {
  //   return AppBar(
  //     title: Text(widget.title),
  //     centerTitle: true,
  //     backgroundColor: const Color.fromARGB(255, 62, 101, 120),
  //     actions: <Widget>[
  //       StreamBuilder<ConnectivityResult>(
  //         stream: connectivityStream,
  //         builder: (BuildContext context,
  //             AsyncSnapshot<ConnectivityResult> snapshot) {
  //           if (snapshot.hasData && snapshot.data != previousResult) {
  //             previousResult = snapshot.data;
  //             if (snapshot.data == ConnectivityResult.none) {
  //                 WidgetsBinding.instance!.addPostFrameCallback((_) {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                       content: Text('No internet connection'),
  //                       duration: Duration(seconds: 3),
  //                     ),
  //                   );
  //                 });
  //               return Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Icon(Icons.wifi_off, color: Colors.red, size: 30.0),
  //               );
  //             } else {
  //                 WidgetsBinding.instance!.addPostFrameCallback((_) {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                       content: Text('Connected to Wi-Fi'),
  //                       duration: Duration(seconds: 3),
  //                     ),
  //                   );
  //                 });

  //               return Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Icon(
  //                   Icons.wifi,
  //                   color: Color.fromARGB(255, 10, 252, 22),
  //                   size: 30.0,
  //                 ),
  //               );
  //             }
  //           } else {
  //             return Container();
  //           }
  //         },
  //       ),
  //     ],
  //   );
  // }
}
