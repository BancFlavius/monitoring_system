import 'package:cloud_firestore/cloud_firestore.dart';

class StepOfficeReservationModel {
  String id;
  String date;
  Map<String, String> employeeData;

  StepOfficeReservationModel({
    required this.id,
    required this.date,
    required this.employeeData,
  });

  factory StepOfficeReservationModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data  = snapshot.data() as Map<String, dynamic>;

    return StepOfficeReservationModel(
      id: snapshot.id,
      date: data['date'],
      employeeData: Map<String, String>.from(data['employeeData'] ?? {}),
    );
  }

  // Convert StepOfficeReservationModel to Map for Firebase storage
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'employeeData': employeeData,
    };
  }
}
