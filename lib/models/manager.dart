import 'package:cloud_firestore/cloud_firestore.dart';

class Manager {
  final String id;
  String name;
  int nrOfEmployees;

  Manager({required this.id, required this.name, this.nrOfEmployees = 0});

  factory Manager.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Manager(
      id: snapshot.id,
      name: data['name'],
      nrOfEmployees: data['nrOfEmployees'] as int,
    );
  }
}
