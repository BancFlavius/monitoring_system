import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/step_office_one_reservation_model.dart';
import '../models/step_office_reservation_model.dart';

class StepOfficeReservationFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<StepOfficeReservationModel>> getReservations() async {
    final QuerySnapshot snapshot =
    await _firestore.collection('stepReservation').get();
    return snapshot.docs
        .map((doc) => StepOfficeReservationModel.fromSnapshot(doc))
        .toList();
  }

  static Future<void> addReservationToFirebase({required DateTime reservationDate, required String employeeCode,
      required String employeeDesk}) async {
    CollectionReference reservationsRef = _firestore.collection('stepReservation');
    String reservationId = DateFormat('yyyy_MM_dd').format(reservationDate);
    final reservationDoc = reservationsRef.doc(reservationId);
    DocumentSnapshot existingReservation = await reservationDoc.get();
    if (existingReservation.exists) {
      Map<String, dynamic> existingData = existingReservation.data() as Map<String, dynamic>;
      existingData['employeeData'][employeeCode] = employeeDesk;

      // Update the existing document
      await reservationDoc.update({
        'employeeData': existingData['employeeData'],
      });
    } else {
      // If there is no existing reservation, create a new reservation document
      StepOfficeReservationModel newReservation = StepOfficeReservationModel(
        id: reservationId,
        date: DateFormat('yyyy_MM_dd').format(reservationDate),
        employeeData: {
          employeeCode: employeeDesk,
        },
      );
      // Add the new reservation document to the 'reservations' collection
      await reservationDoc.set(newReservation.toMap());
    }
    //String reservationId = '${reservationDate.toIso8601String()}-$employeeCode'; //random unique
  }

  static Future<bool> doesEmployeeHaveReservation({required String employeeCode, required DateTime selectedDate}) async {
    try {
      CollectionReference reservationsRef = _firestore.collection('stepReservation');
      String reservationId = '${selectedDate.year}_${selectedDate.month}_${selectedDate.day}';
      final reservationDoc = reservationsRef.doc(reservationId);
      DocumentSnapshot reservationSnapshot = await reservationDoc.get();

      if (reservationSnapshot.exists) {
        Map<String, dynamic> reservationData = reservationSnapshot.data() as Map<String, dynamic>;

        // Check if the employeeCode exists in the 'employeeData' map for the selectedDate
        return reservationData['employeeData']?[employeeCode] != null ?? false;
      } else {
        return false; // No reservation for the selectedDate
      }
    } catch (e) {
      print('Error checking reservation: $e');
      return false;
    }
  }
  static Future<List<StepOfficeOneReservationModel>> getEmployeeReservations({required String employeeCode}) async {
    try {
      CollectionReference reservationsRef = _firestore.collection('stepReservation');
      QuerySnapshot reservationSnapshot = await reservationsRef.get();
      List<StepOfficeOneReservationModel> employeeReservations =[];

      // Iterate through each reservation document
      for (QueryDocumentSnapshot reservationDoc in reservationSnapshot.docs) {
        Map<String, dynamic> reservationData = reservationDoc.data() as Map<String, dynamic>;
        if (reservationData['employeeData'] != null) {
          int nrOfReservationsForThisDate = reservationData['employeeData'].length;
          if(reservationData['employeeData'][employeeCode] != null) {
            StepOfficeOneReservationModel stepOfficeOneReservationModel = StepOfficeOneReservationModel(
                date: reservationData['date'],
                employeeDesk: reservationData['employeeData'][employeeCode],
                nrOfReservationsForThisDate: nrOfReservationsForThisDate
            );
            employeeReservations.add(stepOfficeOneReservationModel);
          }
        }
      }
      return employeeReservations;
    } catch (e) {
      print('Error getEmployeeReservations: $e');
      return [];
    }
  }

  static Future<List<String>> getEmployeeDataForDay(DateTime selectedDay) async {
    CollectionReference reservationsRef = _firestore.collection('stepReservation');

    String reservationId = '${selectedDay.year}_${selectedDay.month.toString().padLeft(2, '0')}_${selectedDay.day.toString().padLeft(2, '0')}';
    final reservationDocById = reservationsRef.doc(reservationId);

    //final reservationDocByDate = await reservationsRef.where('date', isEqualTo: DateFormat('yyyy_MM_dd').format(selectedDay)).get();

    DocumentSnapshot existingReservation;

    //if (reservationDocByDate.docs.isNotEmpty) {
    //  existingReservation = reservationDocByDate.docs.first;
    //} else {
    existingReservation = await reservationDocById.get();
    //}

    if (existingReservation.exists) {
      Map<String, dynamic> existingData = existingReservation.data() as Map<String, dynamic>;
      Map<String, dynamic>? employeeData = existingData['employeeData'];
      if (employeeData != null) {
        List<String> employeeDeskList = employeeData.values.toList().cast<String>();
        //print(employeeDeskList);
        return employeeDeskList;
      }
    }

    return []; // Return an empty list if no data is found
  }

  static Future<String> removeEmployeeFromReservation({
    required String employeeCode,
    required String date,
  }) async {
    try {
      CollectionReference reservationsRef = _firestore.collection('stepReservation');

      String reservationId = date;
      final reservationDoc = reservationsRef.doc(reservationId);
      DocumentSnapshot reservationSnapshot = await reservationDoc.get();

      if (reservationSnapshot.exists) {
        Map<String, dynamic> reservationData =
        reservationSnapshot.data() as Map<String, dynamic>;

        if (reservationData.containsKey('employeeData') &&
            reservationData['employeeData'] != null) {
          Map<String, dynamic> employeeData =
          Map<String, dynamic>.from(reservationData['employeeData']);

          // Remove the employeeCode from employeeData
          employeeData.remove(employeeCode);

          // Update the 'employeeData' field in the document
          await reservationDoc.update({'employeeData': employeeData});

          // If employeeData is empty, delete the document
          if (employeeData.isEmpty) {
            await reservationDoc.delete();
          }
          return 'Success reservation removed';
        }
        return 'Reservation does not have employeeData map';
      }
      return 'Reservation does not exists';
    } catch (e) {
      print('Error removing employee from reservation: $e');
      return 'Error removing employee from reservation: $e';
    }
  }



}