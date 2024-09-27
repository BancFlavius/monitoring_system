import 'package:ARRK/constants/constants.dart';
import 'package:ARRK/tabs/check_in_tab.dart';
import 'package:ARRK/widgets/fancy_button.dart';
import 'package:flutter/material.dart';

import '../globals/gloabls.dart';
import '../google_drive/google_drive.dart';
import '../models/manager.dart';
import '../models/employee.dart';
import '../screens/desks_screen.dart';
import '../screens/manager_screen.dart';
import '../screens/parking_spots_screen.dart';
import '../screens/step_reservations_admin_screen.dart';
import '../services/employee_firebase_service.dart';
import '../services/global_settings_firebase_service.dart';
import '../services/manager_firebase_service.dart';
import '../widgets/admin_employee_list_item.dart';
import '../screens/add_employee_screen.dart';
import '../screens/update_employee_screen.dart';

class AdminTab extends StatefulWidget {
  final VoidCallback navigateToEmployeeListTab;

  const AdminTab({super.key, required this.navigateToEmployeeListTab});

  @override
  AdminTabState createState() => AdminTabState();
}

class AdminTabState extends State<AdminTab> {
  bool _isAdmin = false;
  bool _adminLoginBlocked = false;
  List<Employee> _employees = [];
  Manager? _selectedManager;
  List<Employee> _filteredEmployees = [];
  List<Employee> _filteredEmployeesInOffice = [];
  List<Employee> _filteredEmployeesFromManager = [];
  List<Manager> _managers = [];
  String _filterInOffice = 'all';
  String _adminPassword = '';
  int _nrOfEmployeesForSelectedManager = 0;
  late int _totalNrOfEmployees;
  bool showRegisterInfo = false;

  @override
  void initState() {
    super.initState();
    CheckInTabState.clearDigits();
    _isAdmin = false;
    _fetchEmployees();
    _fetchManagers();
    _fetchAdminPassword();
    _fetchTotalNumberOfEmployees();
  }

  Future<void> _fetchTotalNumberOfEmployees() async {
    _totalNrOfEmployees = await ManagerFirebaseService.getTotalNrOfEmployees();
    if (mounted) {
      setState(() {
        _nrOfEmployeesForSelectedManager = _totalNrOfEmployees;
      });
    }
  }

  Future<void> _fetchNrOfEmployeesForAManager(Manager manager) async {
    int nrOfEmployeesForAManager =
        await ManagerFirebaseService.getNrOfEmployeesForAManager(manager);
    //if (mounted) {
    setState(() {
      _nrOfEmployeesForSelectedManager = nrOfEmployeesForAManager;
    });
    //}
  }

  Future<void> _fetchAdminPassword() async {
    String password = await GlobalSettingsFirebaseService.getAdminPassword();
    if (mounted) {
      setState(() {
        _adminPassword = password;
      });
    }
  }

  Future<void> _fetchEmployees() async {
    List<Employee> employees = await EmployeeFirebaseService.getEmployees();
    if (mounted) {
      setState(() {
        _employees = employees;
        _filteredEmployees = List.from(employees);
        _filteredEmployeesInOffice = List.from(employees);
        _filteredEmployeesFromManager = List.from(employees);
      });
      if (_selectedManager != null) {
        await _filterByManager(_selectedManager);
      }
      if (_filterInOffice != 'all') {
        _filterByInOffice();
      }
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    await EmployeeFirebaseService.deleteEmployee(employee.id);
    Manager? manager =
        await ManagerFirebaseService.getManagerById(employee.managerId);
    if (manager != null) {
      await ManagerFirebaseService.decrementNrOfEmployees(manager);
      if (_selectedManager == null) {
        _fetchTotalNumberOfEmployees();
      } else {
        _fetchNrOfEmployeesForAManager(manager);
      }
    }
    _fetchEmployees();
  }

  Future<void> _updateEmployee(Employee employee) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateEmployeeScreen(employee: employee),
      ),
    ).then((_) {
      _fetchEmployees();
    });
  }

  Future<void> _authenticateAdmin() async {
    String passwordAdmin = '';
    bool exitAlertDialog = false;
    //await EmployeeFirebaseService.generateNamesAndCodes();
    //TO DO
    //await GoogleDriveExcel.initialize();
    //List<dynamic> listi=await GoogleDriveExcel.readColumn(0);
    //print(listi);

    while (exitAlertDialog == false) {
      String? enteredPassword = await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Admin Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_adminLoginBlocked == false &&
                  Globals.wrongPasswordAdminAttempts == 1)
                Text(
                  'Incorrect password, you have 2 more attempts, after that login will be blocked for 5 minutes.',
                  style: TextStyle(color: Colors.yellow.shade600),
                ),
              if (_adminLoginBlocked == false &&
                  Globals.wrongPasswordAdminAttempts == 2)
                Text(
                  'Incorrect password, you have 1 more attempt, after that login will be blocked for 5 minutes.',
                  style: TextStyle(color: Colors.orange),
                ),
              if (_adminLoginBlocked == true)
                Text(
                  'Admin Login blocked for 5 minutes.',
                  style: TextStyle(color: Colors.red.shade600),
                ),
              TextField(
                key: const Key('adminPassword'),
                onChanged: (value) {
                  passwordAdmin = value;
                },
                decoration:
                    const InputDecoration(labelText: 'Enter Admin Password'),
                obscureText: true,
                enabled: !_adminLoginBlocked,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              key: const Key('authenticateAdmin'),
              onPressed: _adminLoginBlocked == true
                  ? null
                  : () {
                      Globals.wrongPasswordAdminAttempts++;
                      Navigator.of(context).pop(passwordAdmin);
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue),
              child: const Text('Login',style: TextStyle(color: Colors.white),),
            ),
            ElevatedButton(
              onPressed: () {
                exitAlertDialog = true;
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600),
              child: const Text('Exit'),
            ),
          ],
        ),
      );

      if (enteredPassword == _adminPassword) {
        setState(() {
          _isAdmin = true;
        });
        exitAlertDialog = true;
      } else {
        if (Globals.wrongPasswordAdminAttempts == 3) {
          setState(() {
            _adminLoginBlocked = true;
          });
          await Future.delayed(const Duration(
              minutes: AppCompany.kMinuteBlockScreenAdminPasswordWrong));
          setState(() {
            _adminLoginBlocked = false;
            Globals.wrongPasswordAdminAttempts = 0;
          });
        }
      }
    }
  }

  // void _showMessage(String message, Color color) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: color,
  //     ),
  //   );
  // }

  Future<void> _fetchManagers() async {
    List<Manager> managers = await ManagerFirebaseService.getManagers();
    if (mounted) {
      setState(() {
        _managers = managers;
      });
    }
  }

  Future<void> _filterByManager(Manager? manager) async {
    if (manager == null) {
      _fetchTotalNumberOfEmployees();
    } else {
      _fetchNrOfEmployeesForAManager(manager);
    }
    setState(() {
      _selectedManager = manager;
      if (manager != null) {
        if (_nrOfEmployeesForSelectedManager == 0) {
          _filteredEmployeesFromManager = [];
        } else {
          _filteredEmployeesFromManager = _filteredEmployeesInOffice
              .where((employee) => employee.managerId == manager.id)
              .toList();
        }
      } else {
        _filteredEmployeesFromManager = List.from(_employees);
        _nrOfEmployeesForSelectedManager = _totalNrOfEmployees;
      }
    });
    _applyCombinedFilters();
  }

  Future<void> _filterByInOffice() async {
    if (_filterInOffice == 'all') {
      setState(() {
        _filteredEmployeesInOffice = List.from(_employees);
      });
    } else if (_filterInOffice == 'inOffice') {
      setState(() {
        _filteredEmployeesInOffice =
            _employees.where((employee) => employee.isInOffice).toList();
      });
    }
    if (_selectedManager != null) {
      await _filterByManager(_selectedManager);
    }
    _applyCombinedFilters();
  }

  void _applyCombinedFilters() {
    setState(() {
      _filteredEmployees = _filteredEmployeesInOffice
          .where((employee) => _filteredEmployeesFromManager.contains(employee))
          .toList();
    });
  }

  void _openDesksScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DesksScreen(),
      ),
    );
  }

  void _openParkingSpotsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ParkingSpotScreen(),
      ),
    ).then((_) async {
      _fetchManagers();
      setState(() {
        _selectedManager = null;
      });
      _fetchTotalNumberOfEmployees();
      _fetchEmployees();
    });
  }

  void _openManagerScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManagerScreen(),
      ),
    ).then((_) async {
      _fetchManagers();
      setState(() {
        _selectedManager = null;
      });
      _fetchTotalNumberOfEmployees();
      _fetchEmployees();
    });
  }
  void _openStepReservationsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StepReservationsAdminScreen(),
      ),
    );
  }

  void registerInfo() {
    setState(() {
      showRegisterInfo = !showRegisterInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isBigWidth = screenWidth > 600;
    double screenHeight = MediaQuery.of(context).size.height;
    if (_isAdmin == false) {
      if(isBigWidth==true){
        return webScaffold(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          showRegisterInfo: showRegisterInfo,
          authenticateAdmin: _authenticateAdmin,
          registerInfo: registerInfo,
        );
      }else {
        return mobileScaffold(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
          showRegisterInfo: showRegisterInfo,
          authenticateAdmin: _authenticateAdmin,
          registerInfo: registerInfo,
        );
      }
    } else {
      return Scaffold(
        body: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('CRUD operations on: '),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _openDesksScreen,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        key: const Key('crudOpDesk'),
                        child: const Text('Desks'),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      ElevatedButton(
                        onPressed: _openParkingSpotsScreen,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        key: const Key('crudOpParking'),
                        child: const Text('Parking Spots'),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      ElevatedButton(
                        onPressed: _openManagerScreen,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        child: const Text('Managers'),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _openStepReservationsScreen,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text('StepReservations'),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: _filterInOffice,
                  onChanged: (value) {
                    setState(() {
                      _filterInOffice = value!;
                      _filterByInOffice();
                    });
                  },
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'all',
                      child: Text('All Employees'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'inOffice',
                      child: Text('In Office Employees'),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                DropdownButton<Manager>(
                  value: _selectedManager,
                  onChanged: _filterByManager,
                  items: [
                    const DropdownMenuItem<Manager>(
                      value: null,
                      key: Key('filterByManagersHomeTab'),
                      child: Text('All Managers'),
                    ),
                    for (var manager in _managers)
                      DropdownMenuItem<Manager>(
                        value: manager,
                        child: Text(manager.name),
                      ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Nr of employees:${_filteredEmployees.length}'),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredEmployees.length,
                itemBuilder: (context, index) {
                  final employee = _filteredEmployees[index];
                  return AdminEmployeeListItem(
                    employee: employee,
                    onDelete: () => _deleteEmployee(employee),
                    onEdit: () => _updateEmployee(employee),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.kBlueColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEmployeeScreen(),
              ),
            ).then((_) {
              _fetchEmployees();
            });
          },
          child: const Icon(Icons.add),
        ),
      );
    }
  }

  Scaffold mobileScaffold({required double screenWidth, required double screenHeight, required bool showRegisterInfo, required VoidCallback authenticateAdmin,required VoidCallback registerInfo}) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth* 0.04),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color
                      spreadRadius: 3, // Spread radius
                      blurRadius: 7, // Blur radius
                      offset: Offset(0, 3), // Shadow offset
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5), // Border color
                    width: 2, // Border width
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  // Same radius as the container
                  child: Image.asset(
                    'images/home.png',
                    //width: screenWidth * 0.8, // Adjust image width as needed
                    //height: screenHeight * 0.3, // Adjust image height as needed
                    fit: BoxFit.cover, // Image fit
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Row(
                children: [
                  Icon(
                    Icons.check,
                    color: AppColors.kBlueColor,
                    size: screenWidth * 0.08,
                  ),
                  Text(
                    'Check IN/ Check OUT when you enter in the office.',
                    style: TextStyle(
                      color: AppColors.kBlueColor,
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.list,
                    size: screenWidth * 0.06,
                  ),
                  Text(
                    'View current employees in the office.',
                    style: TextStyle(
                      //color: AppColors.kBlueColor,
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.home_repair_service_rounded,
                    size: screenWidth * 0.06,
                  ),
                  Text(
                    'Make a reservation when you will come to the office.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ],
              ),
              Text('You can see your reservations:',style: TextStyle(
                fontSize: screenWidth * 0.03,
              ),),
              Row(
                children: [
                  Icon(
                    Icons.remove_red_eye_outlined,
                    size: screenWidth * 0.04,
                  ),
                  Text(
                    'When doing check-in',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.remove_red_eye_outlined,
                    size: screenWidth * 0.04,
                  ),
                  Expanded(
                    child: Text(
                      'When you enter your code in step 1 on the last tab, a floating action button will appear at the bottom right.',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              //const Text('If you have any feedback or observations regarding the application, you can contact the administrator on Teams or email.'),
              InkWell(
                onTap: registerInfo,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registration Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                    Icon(
                      showRegisterInfo
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: screenWidth * 0.05,
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              if (showRegisterInfo)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To become a registered user of the application, kindly provide the following information: ',
                      style: TextStyle(fontSize: screenWidth * 0.028),
                    ),
                    Text(
                      '1. Your full name',
                      style: TextStyle(fontSize: screenWidth * 0.028),
                    ),
                    Text(
                      '2. The four-digit code located on the back of your badge.',
                      style: TextStyle(fontSize: screenWidth * 0.028),
                    ),
                    Text(
                      '3. The full name of your immediate supervisor.',
                      style: TextStyle(fontSize: screenWidth * 0.028),
                    ),
                    Text(
                      'Please send this information to the administrator through Teams or email.',
                      style: TextStyle(fontSize: screenWidth * 0.028),
                    ),
                    Row(
                      children: [
                        Text(
                          'Admin:  ',
                          style: TextStyle(
                            color: AppColors.kBlueColor,
                            fontSize: screenWidth * 0.03,
                          ),
                        ),
                        Text(
                          'szabolcs-andras.csillag@arrk-engineering.com',
                          style: TextStyle(fontSize: screenWidth * 0.028),
                        ),
                      ],
                    ),
                  ],
                ),
              //ElevatedButton(onPressed: _testImageScreen, child: const Text('Test Image')),
            ],
          ),
        ),
      ),
      // floatingActionButton: ElevatedButton(
      //   key: const Key('adminLoginButton'),
      //   onPressed: _authenticateAdmin,
      //   child: Text('Admin Login',style:TextStyle(fontSize: screenWidth * 0.03,),),
      // ),
      floatingActionButton: FancyButton(
        key: const Key('adminLoginButton'),
        onPressed: authenticateAdmin,
        text: 'Admin Login',
        fontSize: screenWidth * 0.03,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        borderColor: Colors.lightBlueAccent,
        borderWidth: 4,
      ),
    );
  }
  Scaffold webScaffold({required double screenWidth, required double screenHeight,  required bool showRegisterInfo, required VoidCallback authenticateAdmin,required VoidCallback registerInfo}) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                width: 500,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color
                      spreadRadius: 3, // Spread radius
                      blurRadius: 7, // Blur radius
                      offset: Offset(0, 3), // Shadow offset
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5), // Border color
                    width: 2, // Border width
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  // Same radius as the container
                  child: Image.asset(
                    'images/home.png',
                    //width: screenWidth * 0.8, // Adjust image width as needed
                    //height: screenHeight * 0.3, // Adjust image height as needed
                    fit: BoxFit.cover, // Image fit
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(
                    Icons.check,
                    color: AppColors.kBlueColor,
                    size: 14,
                  ),
                  Text(
                    'Check IN/ Check OUT when you enter in the office.',
                    style: TextStyle(
                      color: AppColors.kBlueColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.list,
                    size: 14,
                  ),
                  Text(
                    'View current employees in the office.',
                    style: TextStyle(
                      //color: AppColors.kBlueColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.home_repair_service_rounded,
                    size: 14,
                  ),
                  Text(
                    'Make a reservation when you will come to the office.',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text('You can see your reservations:',style: TextStyle(
                fontSize: 12,
              ),),
              Row(
                children: [
                  Icon(
                    Icons.remove_red_eye_outlined,
                    size: 14,
                  ),
                  Text(
                    'When doing check-in',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.remove_red_eye_outlined,
                    size: 14,
                  ),
                  Expanded(
                    child: Text(
                      'When you enter your code in step 1 on the last tab, a floating action button will appear at the bottom right.',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              //const Text('If you have any feedback or observations regarding the application, you can contact the administrator on Teams or email.'),
              InkWell(
                onTap: registerInfo,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registration Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Icon(
                      showRegisterInfo
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 12,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              if (showRegisterInfo)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To become a registered user of the application, kindly provide the following information: ',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '1. Your full name',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '2. The four-digit code located on the back of your badge.',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      '3. The full name of your immediate supervisor.',
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Please send this information to the administrator through Teams or email.',
                      style: TextStyle(fontSize: 12),
                    ),
                    Row(
                      children: [
                        Text(
                          'Admin:  ',
                          style: TextStyle(
                            color: AppColors.kBlueColor,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'szabolcs-andras.csillag@arrk-engineering.com',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FancyButton(
        key: const Key('adminLoginButton'),
        onPressed: authenticateAdmin,
        text: 'Admin Login',
        fontSize: 12,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        borderColor: Colors.lightBlueAccent,
        borderWidth: 4,
      ),
    );
  }
}


