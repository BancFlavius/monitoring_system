import '../globals/gloabls.dart';
import '../tabs/office_reservation_tab.dart';
import 'package:flutter/material.dart';

import '../tabs/admin_tab.dart';
import '../tabs/check_in_tab.dart';
import '../tabs/employee_list_tab.dart';
import '../tabs/step_office_reservation_tab.dart';
import '../widgets/connectivity_methods.dart';
import '../widgets/connectivity_status_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    //if(screenWidth>600) {
      return buildScaffold();
    //}
    ///TO DO
    // return FutureBuilder<bool>(
    //   // Replace with your asynchronous connectivity check logic
    //   future: checkConnectivity(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       // If the connectivity check is still in progress, you can show a loading indicator or something else
    //       return CircularProgressIndicator();
    //     } else if (snapshot.hasError) {
    //       // Handle errors
    //       return Text('Error: ${snapshot.error}');
    //     } else {
    //       // Check the connectivity result
    //       if (snapshot.data == true) {
    //         // Connected to the internet, display your Scaffold
    //         return buildScaffold();
    //       } else {
    //         // Not connected to the internet, show the connectivity dialog
    //         WidgetsBinding.instance!.addPostFrameCallback((_) {
    //           ConnectivityMethods.showConnectivityDialog(context);
    //         });
    //         return buildScaffold();
    //       }
    //     }
    //   },
    // );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Attendance system'),
    //     actions: [
    //       if(screenWidth<600)
    //       ConnectivityStatusWidget(), // Add this widget to display status
    //     ],
    //   ),
    //   body: TabBarView(
    //     controller: _tabController,
    //     physics: const NeverScrollableScrollPhysics(),
    //     children: [
    //       AdminTab(navigateToEmployeeListTab: navigateToEmployeeListTab),
    //       CheckInTab(navigateToEmployeeListTab: navigateToEmployeeListTab),
    //       EmployeeListTab(
    //         onTabCreated: _setEmployeeListTabState,
    //       ),
    //       const StepOfficeReservationTab(),
    //       //const OfficeReservationTab(),
    //     ],
    //   ),
    //   bottomNavigationBar: BottomNavigationBar(
    //     currentIndex: _currentIndex,
    //     onTap: (index) {
    //       setState(() {
    //         _currentIndex = index;
    //         _tabController.animateTo(index);
    //       });
    //     },
    //     items: const [
    //       BottomNavigationBarItem(
    //         icon: Icon(Icons.people),
    //         label: 'Home',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(Icons.check),
    //         label: 'Check-in',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(Icons.list),
    //         label: 'List',
    //       ),
    //       BottomNavigationBarItem(
    //         icon: Icon(Icons.home_repair_service_rounded),
    //         label: 'Res',
    //       ),
    //     ],
    //     selectedItemColor: Colors.blueAccent,
    //     unselectedItemColor: Colors.grey,
    //     backgroundColor:
    //         Colors.black,
    //   ),
    // );
  }

  void navigateToEmployeeListTab() {
    setState(() {
      _currentIndex = 2;
      _tabController.animateTo(2);
    });
  }

  void _setEmployeeListTabState(EmployeeListTabState state) {
    setState(() {
    });
  }
  Future<bool> checkConnectivity() async {
    // Replace with your own connectivity check logic
    // Example: You can use the connectivity package or any other method
    // to check if the device is connected to the internet.
    // For simplicity, I'm using a dummy delay here.
    //await Future.delayed(Duration(seconds: 1));

    return Globals.connectedToInternet;
  }

  Widget buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance system'),
        actions: [
          if (MediaQuery.of(context).size.width < 600)
            ConnectivityStatusWidget(), // Add this widget to display status
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          AdminTab(navigateToEmployeeListTab: navigateToEmployeeListTab),
          CheckInTab(navigateToEmployeeListTab: navigateToEmployeeListTab),
          EmployeeListTab(
            onTabCreated: _setEmployeeListTabState,
          ),
          const StepOfficeReservationTab(),
          //const OfficeReservationTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _tabController.animateTo(index);
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Check-in',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_repair_service_rounded),
            label: 'Res',
          ),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
      ),
    );
  }
}
