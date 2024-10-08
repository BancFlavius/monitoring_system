import 'package:ARRK/constants/constants.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import '../models/employee.dart';
import 'package:flutter/material.dart';

import '../models/manager.dart';
import '../services/employee_firebase_service.dart';
import '../services/manager_firebase_service.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  AddEmployeeScreenState createState() => AddEmployeeScreenState();
}

class AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String _statusCode = '';
  String _statusExcel = '';
  bool _statusExcelSuccess = false;
  final bool _isManager = false;
  Manager? _selectedManager;
  List<Manager> _managers = [];

  @override
  void initState() {
    super.initState();
    _fetchManagers();
  }

  Future<void> _fetchManagers() async {
    List<Manager> managers = await ManagerFirebaseService.getManagers();
    setState(() {
      _managers = managers;
    });
  }

  bool _hasFourDigits(String code) {
    return RegExp(r'^\d{4}$').hasMatch(code);
  }

  Future<void> _addEmployee() async {
    String name = _nameController.text;
    String code = _codeController.text;

    if (_hasFourDigits(code) == false) {
      setState(() {
        _statusCode = 'Enter please 4 digit code';
      });
    } else if (_selectedManager == null) {
      setState(() {
        _statusCode = 'Manager not selected!';
      });
    } else if (name.isNotEmpty && code.isNotEmpty) {
      Employee? employee =
          await EmployeeFirebaseService.getEmployeeByCode(code);
      if (employee == null) {
        Employee newEmployee = Employee(
          id: '', // Leave the ID empty since it will be generated by Firestore
          name: name,
          code: code,
          isInOffice: false,
          managerId: _selectedManager == null ? "-" : _selectedManager!.id,
          isManager: _isManager,
        );
        await EmployeeFirebaseService.addEmployee(newEmployee);
        if (_isManager == true) {
          Manager newManager = Manager(
            id: '', // Leave the ID empty since it will be generated by Firestore
            name: name,
            nrOfEmployees: 0,
          );
          await ManagerFirebaseService.addManager(newManager);
        } else if (_selectedManager != null) {
          await ManagerFirebaseService.incrementNrOfEmployees(
              _selectedManager!);
        }
        Navigator.of(context).pop();
      } else {
        setState(() {
          _statusCode =
              'Code is already in use for the employee: ${employee.name}';
        });
      }
    } else {
      setState(() {
        _statusCode = 'Name or code empty.';
      });
    }
  }

  Future<bool> _addEmployeeExcelLine(
      Employee newEmployee, Manager manager) async {
    if (_hasFourDigits(newEmployee.code) == false) {
      return false;
    }
    Employee? employee =
        await EmployeeFirebaseService.getEmployeeByCode(newEmployee.code);
    if (employee != null) {
      return false;
    }
    await EmployeeFirebaseService.addEmployee(newEmployee);
    if (newEmployee.isManager == true) {
      Manager newManager = Manager(
        id: '', // Leave the ID empty since it will be generated by Firestore
        name: newEmployee.name,
        nrOfEmployees: 0,
      );
      await ManagerFirebaseService.addManager(newManager);
    } else {
      await ManagerFirebaseService.incrementNrOfEmployees(manager);
    }
    return true;
  }

  Future<void> _pickExcelFile() async {
    try {
      ByteData data = await rootBundle.load('assets/addEmployees.xlsx');
      var bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      var excel = Excel.decodeBytes(bytes);
      var table = excel.tables.keys.first;

      if (excel.tables[table]?.maxColumns != AppAddEmployees.kExcelColumns) {
        setState(() {
          _statusExcel = "Error number of columns are not ${AppAddEmployees.kExcelColumns}";
        });
        return;
      }

      int nrOfRows = excel.tables[table]!.rows.length;
      int nrOfNewEmployeesAdded = 0;
      for (var i = 1; i < nrOfRows; i++) {
        var row = excel.tables[table]!.rows[i];
        String? newEmployeeName = row[0]?.value?.toString() ?? '';
        String? newEmployeeCode = row[1]?.value?.toString() ?? '';
        int? newEmployeeIsManagerValue = row[2]?.value as int?;
        bool newEmployeeIsManager = newEmployeeIsManagerValue == 1;
        String? newEmployeeManagerName = row[3]?.value?.toString() ?? '';

        Manager? manager = await ManagerFirebaseService.getManagerByName(
            newEmployeeManagerName);
        if (manager == null) {
          continue;
        }
        Employee newEmployee = Employee(
          id: '', // Leave the ID empty since it will be generated by Firestore
          name: newEmployeeName,
          code: newEmployeeCode,
          isInOffice: false,
          managerId: manager.id,
          isManager: newEmployeeIsManager,
        );
        bool addedSuccesful = await _addEmployeeExcelLine(newEmployee, manager);
        if (addedSuccesful == true) {
          nrOfNewEmployeesAdded++;
        }
      }
      setState(() {
        _statusExcel = "Added with success: $nrOfNewEmployeesAdded employees";
        _statusExcelSuccess = true;
      });
    } catch (e) {
      setState(() {
        _statusExcel = "Error loading Excel file";
        _statusExcelSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                key: const Key('nameEmployee'),
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _codeController,
                key: const Key('codeEmployee'),
                decoration: const InputDecoration(labelText: 'Code'),
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Reports to:'),
                  const SizedBox(

                    width: 20,
                  ),
                  DropdownButton<Manager>(
                    key: const Key('reportsToManager'),
                    value: _selectedManager,
                    onChanged: _selectManagerDropDown,
                    items: [
                      const DropdownMenuItem<Manager>(
                        value: null,
                        child: Text('None'),
                      ),
                      if (_managers.isNotEmpty)
                        for (var manager in _managers)
                          DropdownMenuItem<Manager>(
                            value: manager,
                            child: Text(manager.name),
                          ),
                    ],
                  ),
                ],
              ),
              Text(
                _statusCode,
                style: const TextStyle(color: AppColors.kRed800Color),
              ),
              ElevatedButton(
                onPressed: _addEmployee,
                key: const Key('addEmployee'),
                child: const Text('Add'),
              ),
              const SizedBox(
                height: 100,
              ),
              const Text(
                'You can add employees with an excel file in the assets folder, if an employee already exists, will go to the next one:',
              ),
              ElevatedButton(
                onPressed: _pickExcelFile,
                child: const Text('Add employees from excel'),
              ),
              Text(
                _statusExcel,
                style: TextStyle(
                    color: _statusExcelSuccess
                        ? AppColors.kBlueColor
                        : AppColors.kRed800Color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectManagerDropDown(Manager? manager) {
    setState(() {
      _selectedManager = manager;
    });
  }
}