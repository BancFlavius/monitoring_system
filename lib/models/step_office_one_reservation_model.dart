import 'package:cloud_firestore/cloud_firestore.dart';

class StepOfficeOneReservationModel {
  //String id;
  String date;
  String employeeDesk;
  int nrOfReservationsForThisDate;

  StepOfficeOneReservationModel({
    //required this.id,
    required this.date,
    required this.employeeDesk,
    required this.nrOfReservationsForThisDate,
  });

  factory StepOfficeOneReservationModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data  = snapshot.data() as Map<String, dynamic>;

    return StepOfficeOneReservationModel(
      //id: snapshot.id,
      date: data['date'],
      employeeDesk: data['employeeDesk'],
      nrOfReservationsForThisDate: data['nrOfReservationsForThisDate'],
    );
  }
}
