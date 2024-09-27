import 'package:flutter/material.dart';

import '../globals/gloabls.dart';

class ConnectivityMethods {
  static void showConnectivityDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("No Internet Connection"),
          content: Text("Retry connecting?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                retryConnection(context);
              },
              child: Text("Retry"),
            ),
          ],
        );
      },
    );
  }

  static void showRunningOfflineDialog(BuildContext context) {
    bool closed=false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Running Offline"),
          content: Text("The app is running offline."),
          actions: [
            TextButton(
              onPressed: () {
                closed=true;
                Navigator.of(context).pop();
              },
              child: Text("Ok"),
            ),
          ],
        );
      },
    );

    // Close the offline dialog after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if(closed==false) {
        Navigator.of(context).pop();
        closed=true;
      }
    });
  }

  static void retryConnection(BuildContext context) {
    Globals.retryCount++;

    if (Globals.retryCount >= 3) {
      // Show "Running Offline" dialog after 3 retries
      showRunningOfflineDialog(context);
    } else {
      // Retry the connection
      // Add your connectivity retry logic here
      showConnectivityDialog(context);
    }
  }
}