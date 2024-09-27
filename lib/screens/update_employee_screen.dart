import 'package:ARRK/services/manager_firebase_service.dart';
import 'package:flutter/material.dart';

import '../models/employee.dart';
import '../models/manager.dart';
import '../services/employee_firebase_service.dart';

class UpdateEmployeeScreen extends StatefulWidget {
  final Employee employee;

  const UpdateEmployeeScreen({Key? key, required this.employee})
      : super(key: key);

  @override
  UpdateEmployeeScreenState createState() => UpdateEmployeeScreenState();
}

class UpdateEmployeeScreenState extends State<UpdateEmployeeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  Manager? _selectedManager;
  Manager? _givenManager;
  List<Manager> _managers = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.employee.name;
    _codeController.text = widget.employee.code;
    _fetchManager(widget.employee.managerId);
    _fetchManagers();
  }

  Future<void> _fetchManager(String managerId) async {
    _givenManager=await ManagerFirebaseService.getManagerById(managerId);
  }
  Future<void> _fetchManagers() async {
    List<Manager> managers = await ManagerFirebaseService.getManagers();
    setState(() {
      _managers = managers;
    });
  }
  void _selectManagerDropDown(Manager? manager) {
    setState(() {
      _selectedManager = manager;
    });
  }
  Future<void> _updateEmployee() async {
      String newName = _nameController.text;
      String newCode = _codeController.text;

      Employee updatedEmployee = Employee(
        id: widget.employee.id,
        name: newName,
        code: newCode,
        isInOffice: widget.employee.isInOffice,
        managerId: _selectedManager==null?'':_selectedManager!.id,
        isManager: false,
      );
      if(_givenManager!=null) {
        await ManagerFirebaseService.decrementNrOfEmployees(_givenManager!);
      }
      if(_selectedManager!=null) {
        await ManagerFirebaseService.incrementNrOfEmployees(_selectedManager!);
      }

      EmployeeFirebaseService.updateEmployee(updatedEmployee)
          .then((_) {
        widget.employee.name = newName;
        widget.employee.code = newCode;

        Navigator.pop(context);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Employee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              key: const Key('nameEmployee'),
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              key:const Key('codeEmployee'),
              controller: _codeController,
              decoration: const InputDecoration(labelText: 'Code'),
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),
            Row(
              children: [
                const Text('Current Manager: '),

                Text(
                  _givenManager==null?'null':_givenManager!.name,
                ),
              ]
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Reports to:'),
                const SizedBox(
                  width: 20,
                ),
                DropdownButton<Manager>(
                  value: _selectedManager,
                  onChanged: _selectManagerDropDown,
                  items: [
                    const DropdownMenuItem<Manager>(
                      value: null,
                      child: Text('Select new manager'),
                    ),
                    if (_managers.isNotEmpty)
                    // Populate dropdown items with available managers
                      for (var manager in _managers)
                        DropdownMenuItem<Manager>(
                          value: manager,
                          child: Text(manager.name),
                        ),
                  ],
                ),
              ],
            ),

            ElevatedButton(
              child: const Text('Update'),
              onPressed: () => _updateEmployee(),
            ),
          ],
        ),
      ),
    );
  }
}
