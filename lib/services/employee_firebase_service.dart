import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee.dart';
import 'package:flutter/material.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class EmployeeFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Employee>> getEmployees() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('employee')
          .get();
      return querySnapshot.docs.map((doc) => Employee.fromSnapshot(doc))
          .toList();
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        // Handle the case where Firestore is unavailable (no internet connection)
        // Display a message to the user indicating that the app is offline.
        // You can show this message in a snackbar, alert dialog, or other UI element.
        print("Firestore is unavailable. App is offline. getEmployees");
      } else {
        // Handle other errors as needed
        print("Error getEmployees: $e");
      }
      return [];
    }
  }
  static Stream<List<Employee>> getEmployeesStream() {
    final streamController = StreamController<List<Employee>>();
    try {
      final stream = _firestore.collection('employee').snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => Employee.fromSnapshot(doc)).toList());

      streamController.addStream(stream);
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        // Handle the case where Firestore is unavailable (no internet connection)
        // Display a message to the user indicating that the app is offline.
        // You can show this message in a snackbar, alert dialog, or other UI element.
        print("Firestore is unavailable. App is offline. getEmployeesStream");
      } else {
        // Handle other errors as needed
        print("Error getEmployeesStream: $e");
      }

      // Provide an initial empty list to the stream
      streamController.add([]);
    }

    return streamController.stream;
  }


  static Future<void> deleteEmployee(String employeeId) async {
    try {
      await _firestore.collection('employee').doc(employeeId).delete();
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        // Handle the case where Firestore is unavailable (no internet connection)
        // You can display a message to the user indicating that the app is offline.
        // Consider showing this message in a snackbar, alert dialog, or other UI element.
        print("Firestore is unavailable. App is offline. deleteEmployee");
      } else {
        // Handle other errors as needed
        print("Error deleteEmployee: $e");
      }
    }
  }


  static Future<Employee?> getEmployeeByCode(String code) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('employee')
          .where('code', isEqualTo: code)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Employee employee = Employee.fromSnapshot(querySnapshot.docs[0]);
        return employee;
      } else {
        return null;
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        // Handle the case where Firestore is unavailable (no internet connection)
        // You can display a message to the user indicating that the app is offline.
        // Consider showing this message in a snackbar, alert dialog, or other UI element.
        print("Firestore is unavailable. App is offline. getEmployeeByCode");
      } else {
        // Handle other errors as needed
        print("Error getEmployeeByCode: $e");
      }

      return null; // Return null or another appropriate value in case of an error
    }
  }


  static Future<List<Employee>> searchEmployeeByName(String name) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('employee')
          .where('name', isGreaterThanOrEqualTo: name)
          .where('name', isLessThan: '${name}z')
          .get();

      List<Employee> employees = [];
      querySnapshot.docs.forEach((doc) {
        Employee employee = Employee.fromSnapshot(doc);
        employees.add(employee);
      });

      return employees;
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        // Handle the case where Firestore is unavailable (no internet connection)
        // You can display a message to the user indicating that the app is offline.
        // Consider showing this message in a snackbar, alert dialog, or other UI element.
        print("Firestore is unavailable. App is offline. searchEmployeeByName");
      } else {
        // Handle other errors as needed
        print("Error searchEmployeeByName: $e");
      }

      return []; // Return an empty list or another appropriate value in case of an error
    }
  }


  static Future<void> addEmployee(Employee newEmployee) async {
    final employeeRef = _firestore.collection('employee');
    final employeeDoc =
        employeeRef.doc('${newEmployee.name}_${newEmployee.code}');
    await employeeDoc.set({
      'name': newEmployee.name,
      'code': newEmployee.code,
      'isInOffice': newEmployee.isInOffice,
      'managerId': newEmployee.managerId,
      'isManager': newEmployee.isManager,
    });
  }
  static Future<void> generateNamesAndCodes() async {
    final employeeRef = _firestore.collection('employee');
    final employees = await employeeRef.get();
    print('names:');
    for (var employee in employees.docs) {
      final employeeData = employee.data();
      String name = employeeData['name'];
      print(name);
    }
    print('codes:');
    for (var employee in employees.docs) {
      final employeeData = employee.data();
      String code = employeeData['code'];//_${employeeData['code']}';
      print(code);
    }
  }

  static Future<void> updateEmployeeIsInOffice(Employee employee) async {
    try {
      await _firestore
          .collection('employee')
          .doc(employee.id)
          .update({'isInOffice': employee.isInOffice});
    } catch (error) {
      // Handle error
      print('Error updating employee: $error');
    }
  }

  static Future<void> updateEmployee(Employee employee) async {
    try {
      await _firestore.collection('employee').doc(employee.id).update({
        'name': employee.name,
        'code': employee.code,
        'managerId': employee.managerId,
      });
    } catch (error) {
      // Handle the error
      print('Error updating employee: $error');
    }
  }

  static Future<List<Employee>> getEmployeesInOffice(BuildContext context) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('employee')
          .where('isInOffice', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => Employee.fromSnapshot(doc)).toList();
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        // Handle the case where Firestore is unavailable (no internet connection)
        // Display a snackbar message to inform the user that the app is offline.
        const snackBar = SnackBar(
          content: Text("Firestore is unavailable. App is offline. Employees in office, saved offline."),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // Print a message for debugging purposes
        print("Firestore is unavailable. App is offline. getEmployeesInOffice");
      } else {
        // Handle other errors as needed
        print("Error getEmployeesInOffice: $e");
      }

      return []; // Return an empty list or another appropriate value in case of an error
    }
  }


  static Future<void> updateEmployeesInOffice(List<Employee> employees) async {
    final batch = _firestore.batch();

    for (final employee in employees) {
      batch.update(
        _firestore.collection('employee').doc(employee.id),
        {'isInOffice': false},
      );
    }

    await batch.commit();
  }

  static Future<void> updateEmployeeIsInOfficeAutomatized({required String employeeId, required bool newIsInOffice}) async {
    try {
      await _firestore
          .collection('employee')
          .doc(employeeId)
          .update({'isInOffice': newIsInOffice});
    } catch (error) {
      // Handle error
      print('Error updating employee: $error');
    }
  }

}
