import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';



class Page5 extends StatefulWidget {
  @override
  _Page5State createState() => _Page5State();
}

class _Page5State extends State<Page5> {
  // final databaseReference = FirebaseDatabase.instance.ref('snakeGame/moves');
  final databaseReference = FirebaseDatabase.instance.ref();
  int currIndex = 0;
  int size = 0;

  void _daddCurrentMove(BuildContext context, int move) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // Device is not connected to the internet
      // _showNoInternetDialog(context);
      // setState() {
      //   connectionMethod = 'Connection Failed';
      // }
      print("connectivityResult is none in _daddCurrentMove() : page5  ");

      // Show an error message or handle it appropriately
    } else {
      // Device is connected to the internet
      databaseReference.child('Mode').set(5);
      print('Selected option: $move');
      _sendData(move);
    }
  }

  void _sendData(int data) async {
    try {
      await databaseReference.child('mode').set(5);
      await databaseReference.child('snakeGame/moves/$size').set(data);
      size++;
    } catch (e) {
      print('Failed to update data: $e');
    }
  }

  void _resetGame() async {
    size = 0;
    currIndex = 0;
    await databaseReference.child('snakeGame/moves').remove();
  }




@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(),
    body: Column(
      children: <Widget>[
        Center(
          child: ElevatedButton.icon(
            icon: Icon(Icons.play_arrow),
            label: Text('Start Game'),
            onPressed: _resetGame,
          ),
        ),
        Expanded(
          flex: 7,
          child: Container(
            margin: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    _daddCurrentMove(context, 3);
                  } else if (details.primaryVelocity! < 0) {
                    _daddCurrentMove(context, 1);
                  }
                },
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    _daddCurrentMove(context, 2);
                  } else if (details.primaryVelocity! < 0) {
                    _daddCurrentMove(context, 0);
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Text('Swipe to control the snake'),
                  ),
                ),
              ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.keyboard_arrow_up, size: 30),
                onPressed: () {
                  _daddCurrentMove(context, 1);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_left, size: 30),
                    onPressed: () {
                      _daddCurrentMove(context, 0);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_right, size: 30),
                    onPressed: () {
                      _daddCurrentMove(context, 2);
                    },
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_down, size: 30,),
                onPressed: () {
                  _daddCurrentMove(context, 3);
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}




// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(),
//     body: Column(
//       children: <Widget>[
//         Expanded(
//           flex: 7,
//           child: Container(
//             margin: EdgeInsets.all(10.0),
//             decoration: BoxDecoration(
//               color: Colors.grey.withOpacity(0.5),
//               borderRadius: BorderRadius.circular(10.0),
//             ),
//               child: GestureDetector(
//                 onVerticalDragEnd: (details) {
//                   if (details.primaryVelocity! > 0) {
//                     _daddCurrentMove(context, 3);
//                   } else if (details.primaryVelocity! < 0) {
//                     _daddCurrentMove(context, 1);
//                   }
//                 },
//                 onHorizontalDragEnd: (details) {
//                   if (details.primaryVelocity! > 0) {
//                     _daddCurrentMove(context, 2);
//                   } else if (details.primaryVelocity! < 0) {
//                     _daddCurrentMove(context, 0);
//                   }
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   height: double.infinity,
//                   child: Center(
//                     child: Text('Swipe to control the snake'),
//                   ),
//                 ),
//               ),
//           ),
//         ),
//         Expanded(
//           flex: 3,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               IconButton(
//                 icon: Icon(Icons.arrow_drop_up, size: 30),
//                 onPressed: () {
//                   _daddCurrentMove(context, 1);
//                 },
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: <Widget>[
//                   IconButton(
//                     icon: Icon(Icons.arrow_left, size: 30),
//                     onPressed: () {
//                       _daddCurrentMove(context, 0);
//                     },
//                   ),
//                   ElevatedButton.icon(
//                     icon: Icon(Icons.play_arrow),
//                     label: Text('Start Game'),
//                     onPressed: _resetGame,
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.arrow_right, size: 30),
//                     onPressed: () {
//                       _daddCurrentMove(context, 2);
//                     },
//                   ),
//                 ],
//               ),
//               IconButton(
//                 icon: Icon(Icons.arrow_drop_down, size: 30),
//                 onPressed: () {
//                   _daddCurrentMove(context, 3);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
// }



//    @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         actions: <Widget>[
//           ElevatedButton.icon(
//             icon: Icon(Icons.play_arrow),
//             label: Text('Start Game'),
//             onPressed: _resetGame,
//           ),
//         ],
//       ),
//       body: Column(
//         children: <Widget>[
//           FractionallySizedBox(
//             heightFactor: 0.8,
//             child: Container(
//               margin: EdgeInsets.all(10.0),
//               decoration: BoxDecoration(
//                 color: Colors.grey.withOpacity(0.5),
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               child: GestureDetector(
//                 onVerticalDragEnd: (details) {
//                   if (details.primaryVelocity! > 0) {
//                     _daddCurrentMove(context, 3);
//                   } else if (details.primaryVelocity! < 0) {
//                     _daddCurrentMove(context, 1);
//                   }
//                 },
//                 onHorizontalDragEnd: (details) {
//                   if (details.primaryVelocity! > 0) {
//                     _daddCurrentMove(context, 2);
//                   } else if (details.primaryVelocity! < 0) {
//                     _daddCurrentMove(context, 0);
//                   }
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   height: double.infinity,
//                   child: Center(
//                     child: Text('Swipe to control the snake'),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           FractionallySizedBox(
//             heightFactor: 0.2,
//             child: IconTheme(
//               data: IconThemeData(size: 50),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   IconButton(
//                     icon: Icon(Icons.arrow_upward),
//                     onPressed: () {
//                       _daddCurrentMove(context, 1);
//                     },
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       IconButton(
//                         icon: Icon(Icons.arrow_back),
//                         onPressed: () {
//                           _daddCurrentMove(context, 0);
//                         },
//                       ),
//                       SizedBox(width: 20),
//                       IconButton(
//                         icon: Icon(Icons.arrow_forward),
//                         onPressed: () {
//                           _daddCurrentMove(context, 2);
//                         },
//                       ),
//                     ],
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.arrow_downward),
//                     onPressed: () {
//                       _daddCurrentMove(context, 3);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Snake Game'),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(Icons.play_arrow),
//             onPressed: _resetGame,
//           ),
//         ],
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: Container(
//               color: Colors.grey.withOpacity(0.5),
//               child: GestureDetector(
//                 onVerticalDragEnd: (details) {
//                   if (details.primaryVelocity! > 0) {
//                     _daddCurrentMove(context, 3);
//                   } else if (details.primaryVelocity! < 0) {
//                     _daddCurrentMove(context, 1);
//                   }
//                 },
//                 onHorizontalDragEnd: (details) {
//                   if (details.primaryVelocity! > 0) {
//                     _daddCurrentMove(context, 2);
//                   } else if (details.primaryVelocity! < 0) {
//                     _daddCurrentMove(context, 0);
//                   }
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   height: double.infinity,
//                   child: Center(
//                     child: Text('Swipe to control the snake'),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Spacer(flex: 1),
//           IconTheme(
//             data: IconThemeData(size: 50),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 IconButton(
//                   icon: Icon(Icons.arrow_upward),
//                   onPressed: () {
//                     _daddCurrentMove(context, 1);
//                   },
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     IconButton(
//                       icon: Icon(Icons.arrow_back),
//                       onPressed: () {
//                         _daddCurrentMove(context, 0);
//                       },
//                     ),
//                     SizedBox(width: 20),
//                     IconButton(
//                       icon: Icon(Icons.arrow_forward),
//                       onPressed: () {
//                         _daddCurrentMove(context, 2);
//                       },
//                     ),
//                   ],
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.arrow_downward),
//                   onPressed: () {
//                     _daddCurrentMove(context, 3);
//                   },
//                 ),
//               ],
//             ),
//           ),
//           Spacer(flex: 2),
//         ],
//       ),
//     );
//   }
// }
