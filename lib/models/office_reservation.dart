import 'package:ARRK/models/reservation_map_value_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OfficeReservation {
  final String id;
  final String section;
  final DateTime date;
  final int numberOfReservations;
  final CollectionReference listOfEmployees;
  final int numberOfParkingSpotsReserved;
  final int numberOfDesksReserved;

  OfficeReservation({
    required this.id,
    required this.section,
    required this.date,
    required this.numberOfReservations,
    required this.listOfEmployees,
    required this.numberOfParkingSpotsReserved,
    required this.numberOfDesksReserved,
  });
  factory OfficeReservation.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return OfficeReservation(
      id: snapshot.id,
      section: data['section'],
      date: data['date'],
      numberOfReservations: data['numberOfReservations'] as int,
      listOfEmployees: snapshot.reference.collection('listOfEmployees'),
      numberOfParkingSpotsReserved: data['numberOfParkingSpotsReserved'] as int,
      numberOfDesksReserved: data['numberOfDesksReserved'] as int,
    );
  }

  // factory OfficeReservation.fromSnapshot(DocumentSnapshot snapshot) {
  //   Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  //   List<dynamic> employeeCodesData = data['employeeCodes'];
  //
  //   Map<String, ReservationMapValueData> employeeCodes =
  //   Map<String, ReservationMapValueData>.from(
  //     (employeeCodesData as Map).map((code, codeData) {
  //       String codeStr = code as String;
  //       Map<String, dynamic> codeDataMap = codeData as Map<String, dynamic>;
  //
  //       String nameReservation = codeDataMap['nameReservation'] ?? 'NOT';
  //       String deskReservation = codeDataMap['deskReservation'] ?? 'NOT';
  //       String parkingSpotReservation =
  //           codeDataMap['parkingSpotReservation'] ?? 'NOT';
  //
  //       ReservationMapValueData reservationMapValueData =
  //       ReservationMapValueData(
  //         nameReservation: nameReservation,
  //         deskReservation: deskReservation,
  //         parkingSpotReservation: parkingSpotReservation,
  //       );
  //
  //       return MapEntry(codeStr, reservationMapValueData);
  //     }),
  //   );
  //
  //   return OfficeReservation(
  //     id: snapshot.id,
  //     section: data['section'],
  //     date: data['date'],
  //     numberOfReservations: data['numberOfReservations'] as int,
  //     employeeCodes: employeeCodes,
  //     numberOfParkingSpotsReserved: data['numberOfParkingSpotsReserved'] as int,
  //     numberOfDesksReserved: data['numberOfDesksReserved'] as int,
  //   );
  // }

  // factory OfficeReservation.fromSnapshot(DocumentSnapshot snapshot) {
  //   Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  //   List<dynamic> employeeCodesData = data['employeeCodes'];
  //   Map<String, ReservationMapValueData> employeeCodes = employeeCodesData
  //       .map((codeData) {
  //         String code = codeData['code'] ?? '';
  //         String parkingSpotReservation =
  //             codeData['parkingSpotReservation'] ?? 'NOT';
  //         String deskReservation = codeData['deskReservation'] ?? 'NOT';
  //         String nameReservation = codeData['nameReservation'] ?? 'NOT';
  //         ReservationMapValueData reservationMapValueData =
  //             ReservationMapValueData(
  //                 nameReservation: nameReservation,
  //                 deskReservation: deskReservation,
  //                 parkingSpotReservation: parkingSpotReservation);
  //         return {
  //           'code': code,
  //           'nameReservation': reservationMapValueData.nameReservation,
  //           'deskReservation': reservationMapValueData.deskReservation,
  //           'parkingSpotReservation':
  //               reservationMapValueData.parkingSpotReservation,
  //         };
  //       } as Map<String, ReservationMapValueData>;
  //   return OfficeReservation(
  //     id: snapshot.id,
  //     section: data['section'],
  //     date: data['date'],
  //     numberOfReservations: data['numberOfReservations'] as int,
  //     employeeCodes: employeeCodes,
  //     numberOfParkingSpotsReserved: data['numberOfParkingSpotsReserved'] as int,
  //     numberOfDesksReserved: data['numberOfDesksReserved'] as int,
  //   );
  // }

  static DateTime splitStringToDate(String dateString) {
    List<String> parts = dateString.split('_');
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);
    DateTime date = DateTime(year, month, day);
    return date;
  }
}
