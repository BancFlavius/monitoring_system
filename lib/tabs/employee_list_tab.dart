import 'package:ARRK/widgets/fancy_button.dart';
import 'package:flutter/material.dart';

import '../models/employee.dart';
import '../models/manager.dart';
import '../services/employee_firebase_service.dart';
import '../services/manager_firebase_service.dart';
import '../widgets/digit_keypad.dart';
import 'check_in_tab.dart';

class EmployeeListTab extends StatefulWidget {
  final void Function(EmployeeListTabState state) onTabCreated;

  const EmployeeListTab({super.key, required this.onTabCreated});

  static final GlobalKey<EmployeeListTabState> tabKey =
      GlobalKey<EmployeeListTabState>();

  @override
  EmployeeListTabState createState() => EmployeeListTabState();
}

class EmployeeListTabState extends State<EmployeeListTab> {
  final TextEditingController _searchEmployeeController =
      TextEditingController();
  List<Employee> _employeesInOffice = [];
  Manager? _selectedManager;
  List<Employee> _filteredEmployees = [];
  List<Manager> _managers = [];

  @override
  void initState() {
    super.initState();
    CheckInTabState.clearDigits();
    _searchEmployeeController.addListener(searchEmployee); // Add listener
    searchEmployee(); // Trigger initial search
    _fetchManagers();
    _filteredEmployees = List.from(_employeesInOffice);
  }

  @override
  void dispose() {
    _searchEmployeeController.removeListener(searchEmployee); // Remove listener
    _searchEmployeeController.dispose();
    super.dispose();
  }

  Future<void> _fetchManagers() async {
    List<Manager> managers = await ManagerFirebaseService.getManagers();
    if (mounted) {
      setState(() {
        _managers = managers;
      });
    }
  }

  void _filterByManager(Manager? manager) {
    if(mounted) {
      setState(() {
        _selectedManager = manager;
        if (manager != null) {
          if (manager.nrOfEmployees == 0) {
            _filteredEmployees = [];
          } else {
            _filteredEmployees = _employeesInOffice
                .where((employee) => employee.managerId == manager.id)
                .toList();
          }
        } else {
          _filteredEmployees = List.from(_employeesInOffice);
        }
      });
    }
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) {
      return text;
    }

    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> searchEmployee() async {
    String nameInput = _searchEmployeeController.text;
    String name = capitalizeFirstLetter(nameInput);
    List<Employee> employees =
        await EmployeeFirebaseService.searchEmployeeByName(name);
    if (mounted) {
      setState(() {
        _employeesInOffice =
            employees.where((employee) => employee.isInOffice).toList();
      });
    }
    _filterByManager(_selectedManager);
  }

  void _checkOutFail(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Your code was wrong.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Try again'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkOut(Employee employee) async {
    final TextEditingController checkOutCodeController =
        TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Check-out Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your 4-digit code'),
            const SizedBox(height: 8),
            TextField(
              controller: checkOutCodeController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Code'),
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            child: const Text('Confirm'),
            onPressed: () async {
              String code = checkOutCodeController.text;
              if (code == employee.code) {
                employee.isInOffice = false;
                await EmployeeFirebaseService.updateEmployeeIsInOffice(
                    employee);
                //_checkOutSuccessful(context);
                checkOutCodeController.clear();
                searchEmployee();
                Navigator.of(context).pop();
              } else {
                _checkOutFail(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double searchTextFieldWidth = 0.4 * screenWidth;
    bool isBigWidth= screenWidth > 600;

    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: searchTextFieldWidth,
                child: TextField(
                  controller: _searchEmployeeController,
                  decoration: const InputDecoration(
                      labelText: 'Search Employee'),
                  key: const Key('searchEmployee'),
                ),
              ),
              DropdownButton<Manager>(
                value: _selectedManager,
                onChanged: _filterByManager,
                items: [
                  const DropdownMenuItem<Manager>(
                    value: null,
                    key: Key('allManagersFilter'),
                    child: Text('All Managers'),
                  ),
                  if (_managers.isNotEmpty)
                    for (var manager in _managers)
                      DropdownMenuItem<Manager>(
                        value: manager,
                        key: const Key('managerName'),
                        child: Text(manager.name),
                      ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 32,
          ),
          Expanded(
            key: const Key('listViewer'),
            child: ListView.builder(
              itemCount: _filteredEmployees.length,
              itemBuilder: (context, index) {
                final Employee employee = _filteredEmployees[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    title: Text( '${index+1}. ${employee.name}',
                        style: TextStyle(fontSize: isBigWidth?14:screenWidth / 23)),
                    key: const Key('updateList'),
                    // trailing: FancyButton(
                    //   onPressed: () => _checkOut(employee),
                    //   text: 'Check-out',
                    //   fontSize: screenWidth / 23,
                    //   backgroundColor: Colors.blue,
                    //   textColor: Colors.white,
                    //   borderColor: Colors.lightBlueAccent,
                    //   borderWidth: 3,
                    // ),
                    // subtitle: Divider(
                    //   height: screenHeight * 0.1,
                    //   //thickness: screenHeight *0.2,
                    // ),
                    // trailing: ElevatedButton(
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(3.0),
                    //     child: Text('Check-out',
                    //         style: TextStyle(fontSize: screenWidth / 23)),
                    //   ),
                    //   onPressed: () => _checkOut(employee),
                    // ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
