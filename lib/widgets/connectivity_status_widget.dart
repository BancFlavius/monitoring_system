// import 'package:flutter/material.dart';
// import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';
//
// class ConnectivityStatusWidget extends StatelessWidget {
//   const ConnectivityStatusWidget({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return ConnectivityBuilder(
//       builder: (ConnectivityStatus status) {
//         if (status == ConnectivityStatus.online) {
//           return Text(
//             "Connected to Internet",
//             style: TextStyle(color: Colors.blueAccent),
//           );
//         } else {
//           return Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 "No Internet Connection",
//                 style: TextStyle(color: Colors.yellowAccent),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   // InternetConnectivityChecker internet=Inter;
//                   // internet.checkInternetAccess();
//                   // Try to reconnect when the button is pressed
//                   InternetConnectivityChecker().openInternetSettings();
//                 },
//                 child: Icon(Icons.signal_wifi_connected_no_internet_4),
//               ),
//             ],
//           );
//         }
//       },
//     );
//   }
// }
//done

// import 'package:flutter/material.dart';
// import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';
//
// class ConnectivityStatusWidget extends StatelessWidget {
//   const ConnectivityStatusWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ConnectivityBuilder(
//       builder: (ConnectivityStatus status) {
//         return Text(
//           status == ConnectivityStatus.online
//               ? "Connected to Internet"
//               : "No Internet Connection",
//           style: TextStyle(
//               color: status == ConnectivityStatus.online? Colors.blueAccent : Colors.yellowAccent
//           )
//         );
//       },
//     );
//   }
// }
//initial work


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';

import '../globals/gloabls.dart';

class ConnectivityStatusWidget extends StatefulWidget {
  const ConnectivityStatusWidget({Key? key}) : super(key: key);

  @override
  _ConnectivityStatusWidgetState createState() =>
      _ConnectivityStatusWidgetState();
}

class _ConnectivityStatusWidgetState extends State<ConnectivityStatusWidget> {

  @override
  Widget build(BuildContext context) {
    return ConnectivityBuilder(
      builder: (ConnectivityStatus status) {
        if (status == ConnectivityStatus.online) {
          Globals.connectedToInternet=true;
          Globals.retryCount = 0; // Reset the retry count when online
        }
        if(Globals.connectedToInternet==true && status==ConnectivityStatus.offline){
          Globals.connectedToInternet=false;
          //_showConnectivityDialog();
        }

        return Text(
          status == ConnectivityStatus.online
              ? "Connected to Internet"
              : "No Internet Connection",
          style: TextStyle(
            color: status == ConnectivityStatus.online
                ? Colors.blueAccent
                : Colors.yellowAccent,
          ),
        );
      },
    );
  }
}