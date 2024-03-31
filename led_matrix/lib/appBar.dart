
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  
}

class _CustomAppBarState extends State<CustomAppBar> {
  late Stream<ConnectivityResult> connectivityStream;
  ConnectivityResult? previousResult;
  ConnectivityResult? realPrev ;
  bool hide = true;

  @override
  void initState() {
    super.initState();
    connectivityStream = Connectivity().onConnectivityChanged;
     initConnectivity();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    setState(() {
      realPrev = previousResult;
      previousResult = result;
      hide=false;
    });
  }

  List<String> pageDescriptions = [
    'Description for page 1',
    'Description for page 2',
    'Description for page 3',
    'Description for page 4',
    'Description for page 5'
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
                          currentPage = (currentPage + 1) % pageDescriptions.length;
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
            builder: (BuildContext context, AsyncSnapshot<ConnectivityResult> snapshot) {
              if (snapshot.hasData && (snapshot.data != previousResult)) {
                realPrev = previousResult;
                previousResult = snapshot.data;
              }
              if (previousResult == ConnectivityResult.wifi ) {
                //                 WidgetsBinding.instance!.addPostFrameCallback((_) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: Text('Connected to Wi-Fi'),
                //       duration: Duration(seconds: 3),
                //     ),
                //   );
                // });
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
