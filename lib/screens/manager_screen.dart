import 'package:ARRK/screens/update_manager_screen.dart';
import 'package:ARRK/services/employee_firebase_service.dart';
import 'package:ARRK/services/manager_firebase_service.dart';
import 'package:ARRK/widgets/admin_manager_list_item.dart';
import 'package:flutter/material.dart';
import 'package:ARRK/models/manager.dart';

import '../constants/constants.dart';
import '../models/employee.dart';
import 'add_manager_screen.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  ManagerScreenState createState() => ManagerScreenState();
}

class ManagerScreenState extends State<ManagerScreen> {
  List<Manager> _managers = [];
  List<Employee> _employees = [];

  @override
  void initState() {
    super.initState();
    _fetchManagers();
    _fetchEmployees();
  }

  Future<void> _fetchManagers() async {
    List<Manager> managers = await ManagerFirebaseService.getManagers();
    setState(() {
      _managers = managers;
    });
  }
  Future<void> _fetchEmployees() async {
    List<Employee> employees = await EmployeeFirebaseService.getEmployees();
    setState(() {
      _employees=employees;
    });
  }
  Future<void> _deleteManager(String managerId) async {
    for(Employee employee in _employees) {
      if(employee.managerId==managerId) {
        employee.managerId = DefaultManager.kDefaultManager;
        await EmployeeFirebaseService.updateEmployee(employee);
        Manager? manager = await ManagerFirebaseService.getManagerById(DefaultManager.kDefaultManager);
        await ManagerFirebaseService.incrementNrOfEmployees(manager!);
      }
    }
    await ManagerFirebaseService.deleteManager(managerId);
    await _fetchManagers();
  }
  Future<void> _updateManager(Manager manager) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateManagerScreen(manager: manager),
      ),
    ).then((_) {
      _fetchManagers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Managers'),
      ),
      body: ListView.builder(
        itemCount: _managers.length,
        itemBuilder: (context, index) {
          final manager = _managers[index];
          if(manager.name=='None') {
            return ListTile(
              title: Text(manager.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(manager.nrOfEmployees.toString(),
                      style: const TextStyle(color: Colors.blueAccent)),
                  const SizedBox(width: 105,),
                ],
              )
            );
          } else {
          return AdminManagerListItem(
            manager: manager,
            onDelete: () => _deleteManager(manager.id),
            onEdit: () => _updateManager(manager),
          );}
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.kBlueColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddManagerScreen()),
          ).then((value) {
            _fetchManagers();
          });
        },
      ),
    );
  }
}