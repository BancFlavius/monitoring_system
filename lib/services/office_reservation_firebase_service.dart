import 'package:ARRK/models/office_reservation.dart';
import 'package:ARRK/models/reservation_map_value_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OfficeReservationFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<OfficeReservation>> getReservations() async {
    final QuerySnapshot snapshot =
        await _firestore.collection('reservation').get();
    return snapshot.docs
        .map((doc) => OfficeReservation.fromSnapshot(doc))
        .toList();
  }

  static String dateToString(DateTime date, String section) {
    String formattedDay = date.day < 10 ? "0${date.day}" : "${date.day}";
    String formattedMonth =
        date.month < 10 ? "0${date.month}" : "${date.month}";
    String formattedYear = "${date.year}";
    String formattedSection = section;

    String documentId =
        '${formattedDay}_${formattedMonth}_${formattedYear}_$formattedSection';

    return documentId;
  }

  static Future<void> addReservation({
    required String section,
    required DateTime date,
    required String employeeCode,
    required bool reserveParking,
    required String nrParkingSpot,
    required bool reserveDesk,
    required String nrDesk,
    required String employeeName,
  }) async {
    try {
      final reservationRef = _firestore.collection('reservation');
      final reservationDoc =
          reservationRef.doc('${date.day}_${date.month}_${date.year}_$section');

      final existingReservation = await reservationDoc.get();
      if (existingReservation.exists) {
        int currentReservations =
            existingReservation.data()!['numberOfReservations'];
        int numberOfParkingSpotsReserved =
            existingReservation.data()!['numberOfParkingSpotsReserved'];
        int numberOfDesksReserved =
            existingReservation.data()!['numberOfDesksReserved'];
        await reservationDoc.update({
          'numberOfReservations': currentReservations + 1,
          'numberOfParkingSpotsReserved':
              numberOfParkingSpotsReserved + (reserveParking ? 1 : 0),
          'numberOfDesksReserved':
              numberOfDesksReserved + (reserveDesk ? 1 : 0),
        });
      } else {
        await reservationDoc.set({
          'floor': section,
          'date': DateFormat('dd_MM_yyyy').format(date),
          'numberOfReservations': 1,
          'numberOfParkingSpotsReserved': reserveParking ? 1 : 0,
          'numberOfDesksReserved': reserveDesk ? 1 : 0,
        });
      }
      final listOfEmployeesCollection =
          reservationDoc.collection('listOfEmployees');
      final documentId = employeeCode;
      await listOfEmployeesCollection.doc(documentId).set({
        'nameReservation': employeeName,
        'deskReservation': nrDesk,
        'parkingSpotReservation': nrParkingSpot,
      });
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        print("Firestore is unavailable. App is offline.");
      } else {
        print("Error addReservation: $e");
      }
    }
  }

  // static Future<void> addReservationV2({
  //   required String section,
  //   required DateTime date,
  //   required String employeeCode,
  //   required bool reserveParking,
  //   required String nrParkingSpot,
  //   required bool reserveDesk,
  //   required String nrDesk,
  //   required String employeeName,
  // }) async {
  //   try {
  //     final reservationRef = _firestore.collection('reservation');
  //     final reservationDoc =
  //     reservationRef.doc('${date.day}_${date.month}_${date.year}_$section');
  //
  //     final existingReservation = await reservationDoc.get();
  //     if (existingReservation.exists) {
  //       int currentReservations = existingReservation.data()!['numberOfReservations'];
  //       int numberOfParkingSpotsReserved = existingReservation.data()!['numberOfParkingSpotsReserved'];
  //       int numberOfDesksReserved = existingReservation.data()!['numberOfDesksReserved'];
  //
  //       Map<String, dynamic> currentEmployeeCodes =
  //           Map<String, dynamic>.from(existingReservation.data()!['employeeCodes']) ?? {};
  //
  //       // Add the new employee data to currentEmployeeCodes
  //       currentEmployeeCodes[employeeCode] = {
  //         'nameReservation': employeeName,
  //         'deskReservation': nrDesk,
  //         'parkingSpotReservation': nrParkingSpot,
  //       };
  //
  //       await reservationDoc.update({
  //         'numberOfReservations': currentReservations + 1,
  //         'employeeCodes': currentEmployeeCodes,
  //         'numberOfParkingSpotsReserved': numberOfParkingSpotsReserved + (reserveParking ? 1 : 0),
  //         'numberOfDesksReserved': numberOfDesksReserved + (reserveDesk ? 1 : 0),
  //       });
  //     } else {
  //       await reservationDoc.set({
  //         'floor': section,
  //         'date': DateFormat('dd_MM_yyyy').format(date),
  //         'numberOfReservations': 1,
  //         'employeeCodes': {
  //           employeeCode: {
  //             'nameReservation': employeeName,
  //             'deskReservation': nrDesk,
  //             'parkingSpotReservation': nrParkingSpot,
  //           },
  //         },
  //         'numberOfParkingSpotsReserved': reserveParking ? 1 : 0,
  //         'numberOfDesksReserved': reserveDesk ? 1 : 0,
  //       });
  //     }
  //   } catch (e) {
  //     if (e is FirebaseException && e.code == 'unavailable') {
  //       print("Firestore is unavailable. App is offline.");
  //     } else {
  //       print("Error addReservation: $e");
  //     }
  //   }
  // }

  // static Future<void> addReservationV1({
  //   required String section,
  //   required DateTime date,
  //   required String employeeCode,
  //   required bool reserveParking,
  //   required String nrParkingSpot,
  //   required bool reserveDesk,
  //   required String nrDesk,
  //   required String employeeName,
  // }) async {
  //   try {
  //     final reservationRef = _firestore.collection('reservation');
  //     final reservationDoc =
  //         reservationRef.doc('${date.day}_${date.month}_${date.year}_$section');
  //
  //     final existingReservation = await reservationDoc.get();
  //     if (existingReservation.exists) {
  //       print('exists');
  //       int currentReservations =
  //           existingReservation.data()!['numberOfReservations'];
  //       int numberOfParkingSpotsReserved =
  //           existingReservation.data()!['numberOfParkingSpotsReserved'];
  //       int numberOfDesksReserved =
  //           existingReservation.data()!['numberOfDesksReserved'];
  //       if (reserveParking == true) {
  //         numberOfParkingSpotsReserved++;
  //       }
  //       if (reserveDesk) {
  //         numberOfDesksReserved++;
  //       }
  //       Map<String, dynamic> currentEmployeeCodes = existingReservation.data()!['employeeCodes'] ?? {};
  //       // Map<String, ReservationMapValueData> currentEmployeeCodes =
  //       //     (existingReservation.data()!['employeeCodes']
  //       //             as Map<dynamic, dynamic>)
  //       //         .map((key, codeData) {
  //       //   String code = key as String;
  //       //   String parkingSpotReservation =
  //       //       codeData['parkingSpotReservation'] ?? 'NOT';
  //       //   String deskReservation = codeData['deskReservation'] ?? 'NOT';
  //       //   String nameReservation = codeData['nameReservation'] ?? 'NOT';
  //       //
  //       //   return MapEntry(
  //       //     code,
  //       //     ReservationMapValueData(
  //       //       nameReservation: nameReservation,
  //       //       deskReservation: deskReservation,
  //       //       parkingSpotReservation: parkingSpotReservation,
  //       //     ),
  //       //   );
  //       // });
  //       // Add the new employee data to currentEmployeeCodes
  //       currentEmployeeCodes[employeeCode] = ReservationMapValueData(
  //         nameReservation: employeeName,
  //         deskReservation: nrDesk,
  //         parkingSpotReservation: nrParkingSpot,
  //       );
  //   await reservationDoc.update({
  //         'numberOfReservations': currentReservations + 1,
  //         'employeeCodes': currentEmployeeCodes,
  //         'numberOfParkingSpotsReserved': numberOfParkingSpotsReserved,
  //         'numberOfDesksReserved': numberOfDesksReserved,
  //       });
  //     } else {
  //       await reservationDoc.set({
  //         'floor': section,
  //         'date': DateFormat('dd_MM_yyyy').format(date),
  //         'numberOfReservations': 1,
  //         'employeeCodes': {
  //           employeeCode: ReservationMapValueData(
  //             nameReservation: employeeName,
  //             deskReservation: nrDesk,
  //             parkingSpotReservation: nrParkingSpot,
  //           ).toMap(),
  //         },
  //         'numberOfParkingSpotsReserved': reserveParking ? 1 : 0,
  //         'numberOfDesksReserved': reserveDesk ? 1 : 0,
  //       });
  //     }
  //   } catch (e) {
  //     if (e is FirebaseException && e.code == 'unavailable') {
  //       // Handle the case where Firestore is unavailable (no internet connection)
  //       // Display a message to the user indicating that the app is offline.
  //       // You can show this message in a snackbar, alert dialog, or other UI element.
  //       print("Firestore is unavailable. App is offline.");
  //     } else {
  //       // Handle other errors as needed
  //       print("Error addReservation: $e");
  //     }
  //   }
  // }

  // static Future<void> addReservationChatiVector({
  //   required String section,
  //   required DateTime date,
  //   required String employeeCode,
  //   required bool reserveParking,
  //   required String nrParkingSpot,
  //   required bool reserveDesk,
  //   required String nrDesk,
  //   required String employeeName,
  // }) async {
  //   try {
  //     final reservationRef = _firestore.collection('reservation');
  //     final reservationDoc =
  //     reservationRef.doc('${date.day}_${date.month}_${date.year}_$section');
  //
  //     final existingReservation = await reservationDoc.get();
  //     if (existingReservation.exists) {
  //       int currentReservations =
  //       existingReservation.data()!['numberOfReservations'];
  //       int numberOfParkingSpotsReserved =
  //       existingReservation.data()!['numberOfParkingSpotsReserved'];
  //       int numberOfDesksReserved =
  //       existingReservation.data()!['numberOfDesksReserved'];
  //
  //       List<Map<String, dynamic>> currentEmployeeCodes = (existingReservation.data()!['employeeCodes'] as List<dynamic>).map((codeData) {
  //         return {
  //           'code': codeData['code'],
  //           'nameReservation': codeData['nameReservation'],
  //           'deskReservation': codeData['deskReservation'],
  //           'parkingSpotReservation': codeData['parkingSpotReservation'],
  //         };
  //       }).toList();
  //
  //       currentEmployeeCodes.add({
  //         'code': employeeCode,
  //         'nameReservation': employeeName,
  //         'deskReservation': nrDesk,
  //         'parkingSpotReservation': nrParkingSpot,
  //       });
  //
  //       await reservationDoc.update({
  //         'numberOfReservations': currentReservations + 1,
  //         'employeeCodes': currentEmployeeCodes,
  //         'numberOfParkingSpotsReserved': numberOfParkingSpotsReserved,
  //         'numberOfDesksReserved': numberOfDesksReserved,
  //       });
  //     } else {
  //       await reservationDoc.set({
  //         'floor': section,
  //         'date': DateFormat('dd_MM_yyyy').format(date),
  //         'numberOfReservations': 1,
  //         'employeeCodes': [
  //           {
  //             'code': employeeCode,
  //             'nameReservation': employeeName,
  //             'deskReservation': nrDesk,
  //             'parkingSpotReservation': nrParkingSpot,
  //           }
  //         ],
  //         'numberOfParkingSpotsReserved': reserveParking ? 1 : 0,
  //         'numberOfDesksReserved': reserveDesk ? 1 : 0,
  //       });
  //     }
  //   } catch (e) {
  //     if (e is FirebaseException && e.code == 'unavailable') {
  //       print("Firestore is unavailable. App is offline.");
  //     } else {
  //       print("Error addReservation: $e");
  //     }
  //   }
  // }

  static Future<int> getReservationCountForDay(
      String section, DateTime date) async {
    try {
      final reservationRef =
          FirebaseFirestore.instance.collection('reservation');
      final reservationDoc =
          reservationRef.doc('${date.day}_${date.month}_${date.year}_$section');

      final existingReservation = await reservationDoc.get();
      if (existingReservation.exists) {
        return existingReservation.data()!['numberOfReservations'];
      }
      return 0;
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        // Handle the case where Firestore is unavailable (no internet connection)
        // Display a message to the user indicating that the app is offline.
        // You can show this message in a snackbar, alert dialog, or other UI element.
        print(
            "Firestore is unavailable.getReservationCountForDay. App is offline.");
      } else {
        // Handle other errors as needed
        print("Error getReservationCountForDay: $e");
      }
      return 0;
    }
  }

  static Future<bool> hasReservationOnDay(
      String employeeCode, DateTime date) async {
    try {
      final reservationRef = _firestore.collection('reservation');
      final dayPrefix = '${date.day}_${date.month}_${date.year}_';

      for (int i = 0; i < 9; i++) {
        final reservationDoc = reservationRef.doc('$dayPrefix$i');
        final reservationSnapshot = await reservationDoc.get();

        if (reservationSnapshot.exists) {
          final listOfEmployeesCollection =
              reservationDoc.collection('listOfEmployees');
          String documentId = employeeCode;
          final employeeSnapshot =
              await listOfEmployeesCollection.doc(documentId).get();
          if (employeeSnapshot.exists) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      if (e is FirebaseException && e.code == 'unavailable') {
        // Handle the case where Firestore is unavailable (no internet connection)
        // Display a message to the user indicating that the app is offline.
        // You can show this message in a snackbar, alert dialog, or other UI element.
        print(
            "Firestore is unavailable.Error fetching in-office. App is offline.");
      } else {
        // Handle other errors as needed
        print("Error fetching in-office employees: $e");
      }
      return false;
    }
  }

  static Future<List<String>> getParkingSpotsReservationForADay(
      DateTime date) async {
    List<String> parkingSpotsReserved = [];
    final reservationRef = _firestore.collection('reservation');
    final dayPrefix = '${date.day}_${date.month}_${date.year}_';

    for (int i = 0; i < 9; i++) {
      final reservationDoc = reservationRef.doc('$dayPrefix$i');
      final reservationSnapshot = await reservationDoc.get();

      if (reservationSnapshot.exists) {
        final listOfEmployeesCollection =
            reservationDoc.collection('listOfEmployees');
        final querySnapshot = await listOfEmployeesCollection.get();
        for (final docSnapshot in querySnapshot.docs) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          final parkingSpotReservation =
              data['parkingSpotReservation'] as String;

          // Check and collect parkingSpotReservations
          if (parkingSpotReservation != null &&
              parkingSpotReservation != 'NOT') {
            parkingSpotsReserved.add(parkingSpotReservation);
          }
        }
      }
    }
    return parkingSpotsReserved;
  }

  static Future<List<String>> getDesksReservationForADay(DateTime date) async {
    List<String> desksReserved = [];
    final reservationRef = _firestore.collection('reservation');
    final dayPrefix = '${date.day}_${date.month}_${date.year}_';

    for (int i = 0; i < 9; i++) {
      final reservationDoc = reservationRef.doc('$dayPrefix$i');
      final reservationSnapshot = await reservationDoc.get();

      if (reservationSnapshot.exists) {
        final listOfEmployeesCollection =
            reservationDoc.collection('listOfEmployees');
        final querySnapshot = await listOfEmployeesCollection.get();
        for (final docSnapshot in querySnapshot.docs) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          final deskReservation = data['deskReservation'] as String;

          // Check and collect parkingSpotReservations
          if (deskReservation != null && deskReservation != 'NOT') {
            desksReserved.add(deskReservation);
          }
        }
      }
    }
    return desksReserved;
  }

  static Future<List<OfficeReservation>> getReservationsForAnEmployee(
      String codeParam, String nameParam) async {
    final reservationRef = _firestore.collection('reservation');
    QuerySnapshot reservationSnapshot = await reservationRef.get();
    List<OfficeReservation> reservations = [];
    for (QueryDocumentSnapshot reservationDoc in reservationSnapshot.docs) {
      final listOfEmployeesCollection =
          reservationDoc.reference.collection('listOfEmployees');
      final listOfEmployeesSnapshot = await listOfEmployeesCollection.get();
      bool containsCode = false;

      for (QueryDocumentSnapshot employeeDoc in listOfEmployeesSnapshot.docs) {
        //ReservationMapValueData employeeData = employeeDoc.data() as ReservationMapValueData;
        if (employeeDoc.id == codeParam) {
          containsCode = true;
          break;
        }
      }

      if (containsCode) {
        String section = reservationDoc['floor'];
        DateTime date =
            OfficeReservation.splitStringToDate(reservationDoc['date']);
        int numberOfReservations = reservationDoc['numberOfReservations'];
        int numberOfParkingSpotsReserved =
            reservationDoc['numberOfParkingSpotsReserved'];
        int numberOfDesksReserved = reservationDoc['numberOfDesksReserved'];

        OfficeReservation reservation = OfficeReservation(
          id: reservationDoc.id,
          section: section,
          date: date,
          numberOfReservations: numberOfReservations,
          listOfEmployees:
              reservationDoc.reference.collection('listOfEmployees'),
          numberOfParkingSpotsReserved: numberOfParkingSpotsReserved,
          numberOfDesksReserved: numberOfDesksReserved,
        );

        reservations.add(reservation);
      }
    }

    return reservations;
  }

  // static Future<List<OfficeReservation>> getReservationsForAnEmployee2(
  //     String codeParam, String nameParam) async {
  //   final reservationRef = _firestore.collection('reservation');
  //
  //   QuerySnapshot reservationSnapshot = await reservationRef.get();
  //
  //   List<OfficeReservation> reservations = [];
  //
  //   for (QueryDocumentSnapshot reservationDoc in reservationSnapshot.docs) {
  //     final listOfEmployeesCollection = reservationDoc.get().collection('listOfEmployees');
  //     final querySnapshot = await listOfEmployeesCollection.get();
  //     bool containsCode = false;
  //     String parkingSpotReservation = 'NOT';
  //     String deskReservation = 'NOT';
  //
  //     for (var codeData in employeeCodes) {
  //       Map<String, dynamic> codeMap = codeData as Map<String, dynamic>;
  //
  //       if (codeMap.containsKey('code')) {
  //         String employeeCode = codeMap['code'];
  //         ReservationMapValueData reservationMapValueData = ReservationMapValueData(
  //           parkingSpotReservation: codeMap['parkingSpotReservation'],
  //           deskReservation: codeMap['deskReservation'],
  //           nameReservation: codeMap['nameReservation'],
  //         );
  //
  //         if (employeeCode == codeParam) {
  //           containsCode = true;
  //           parkingSpotReservation = reservationMapValueData.parkingSpotReservation;
  //           deskReservation = reservationMapValueData.deskReservation;
  //           break;
  //         }
  //       }
  //     }
  //
  //
  //     if (containsCode == true) {
  //       String section = reservationDoc.get('floor');
  //       DateTime date =
  //           OfficeReservation.splitStringToDate(reservationDoc.get('date'));
  //       int numberOfReservations = reservationDoc.get('numberOfReservations');
  //       int numberOfParkingSpotsReserved =
  //           reservationDoc.get('numberOfParkingSpotsReserved');
  //       int numberOfDesksReserved = reservationDoc.get('numberOfDesksReserved');
  //       Map<String,ReservationMapValueData> newEmployeeCodes =
  //         {
  //           codeParam: ReservationMapValueData(
  //             parkingSpotReservation: parkingSpotReservation,
  //             deskReservation: deskReservation,
  //             nameReservation: nameParam,
  //           ),
  //         };
  //
  //       OfficeReservation reservation = OfficeReservation(
  //         id: reservationDoc.id,
  //         section: section,
  //         date: date,
  //         numberOfReservations: numberOfReservations,
  //         employeeCodes: newEmployeeCodes,
  //         numberOfParkingSpotsReserved: numberOfParkingSpotsReserved,
  //         numberOfDesksReserved: numberOfDesksReserved,
  //       );
  //       reservations.add(reservation);
  //     }
  //   }
  //   return reservations;
  // }

  static Future<void> removeEmployeeFromReservation(
      String reservationId, String employeeCode) async {
    final reservationRef = _firestore.collection('reservation');
    final reservationDoc = reservationRef.doc(reservationId);

    final reservationSnapshot = await reservationDoc.get();
    if (reservationSnapshot.exists) {
      final reservationData =
          reservationSnapshot.data() as Map<String, dynamic>;
      int numberOfReservations = reservationData['numberOfReservations'] as int;
      int numberOfParkingSpotsReserved =
          reservationData['numberOfParkingSpotsReserved'] as int;
      int numberOfDesksReserved =
          reservationData['numberOfDesksReserved'] as int;

      ReservationMapValueData employeeDataObject;
      final listOfEmployeesSnapshot = await reservationSnapshot.reference
          .collection('listOfEmployees')
          .get();
      for (QueryDocumentSnapshot employeeDoc in listOfEmployeesSnapshot.docs) {
        String documentId = employeeDoc.id;
        if (documentId == employeeCode) {
          Map<String, dynamic> employeeData =
              employeeDoc.data() as Map<String, dynamic>;

          employeeDataObject = ReservationMapValueData(
            id: '',
            nameReservation: employeeData['nameReservation'],
            deskReservation: employeeData['deskReservation'],
            parkingSpotReservation: employeeData['parkingSpotReservation'],
          );
          if (employeeDataObject.parkingSpotReservation.startsWith('P') ==
              true) {
            numberOfParkingSpotsReserved--;
          }
          if (employeeDataObject.deskReservation != 'NOT') {
            numberOfDesksReserved--;
          }
          numberOfReservations--;

          await reservationDoc.update({
            'numberOfReservations': numberOfReservations,
            'numberOfParkingSpotsReserved': numberOfParkingSpotsReserved,
            'numberOfDesksReserved': numberOfDesksReserved,
          });
          await employeeDoc.reference.delete();
        }
      }
    }
  }
  static Future<ReservationMapValueData> getEmployeeReservationDetail(
      String reservationId, String employeeCode) async {
    final reservationRef = _firestore.collection('reservation');
    final reservationDoc = reservationRef.doc(reservationId);
    ReservationMapValueData employeeDataObjectDefault=ReservationMapValueData(id: '', nameReservation: 'NOT', deskReservation: 'NOT', parkingSpotReservation: 'NOT');

    final reservationSnapshot = await reservationDoc.get();
    if (reservationSnapshot.exists) {

      final listOfEmployeesSnapshot = await reservationSnapshot.reference
          .collection('listOfEmployees')
          .get();
      for (QueryDocumentSnapshot employeeDoc in listOfEmployeesSnapshot.docs) {
        String documentId = employeeDoc.id;
        if (documentId == employeeCode) {
          Map<String, dynamic> employeeData =
          employeeDoc.data() as Map<String, dynamic>;

          ReservationMapValueData employeeDataObject = ReservationMapValueData(
            id: '',
            nameReservation: employeeData['nameReservation'],
            deskReservation: employeeData['deskReservation'],
            parkingSpotReservation: employeeData['parkingSpotReservation'],
          );
          return employeeDataObject;
        }
      }
    }
    return employeeDataObjectDefault;
  }
}
