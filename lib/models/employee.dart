import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String id;
  String name;
  String code;
  bool isInOffice;
  String managerId;
  bool isManager;

  Employee({
    required this.id,
    required this.name,
    required this.code,
    this.isInOffice = false,
    required this.managerId,
    required this.isManager,
  });

  factory Employee.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Employee(
      id: snapshot.id,
      name: data['name'],
      code: data['code'],
      isInOffice: data['isInOffice'] as bool,
      managerId: data['managerId'],
      isManager: data['isManager'],
    );
  }

}
