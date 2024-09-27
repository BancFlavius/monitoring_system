import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationMapValueData {
  final String id;
  final String nameReservation;
  final String deskReservation;
  final String parkingSpotReservation;

  ReservationMapValueData({
    required this.id,
    required this.nameReservation,
    required this.deskReservation,
    required this.parkingSpotReservation,
  });
  factory ReservationMapValueData.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return ReservationMapValueData(
      id: snapshot.id,
      nameReservation: data['nameReservation'],
      deskReservation: data['deskReservation'],
      parkingSpotReservation: data['parkingSpotReservation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameReservation': nameReservation,
      'deskReservation': deskReservation,
      'parkingSpotReservation': parkingSpotReservation,
    };
  }
}