import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSpot {
  final String id;
  final String region;
  final Map<int, String> spotNumbers;
  final int nrParkingSpots;

  ParkingSpot({
    required this.id,
    required this.region,
    required this.spotNumbers,
    required this.nrParkingSpots,
  });

  factory ParkingSpot.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    Map<String, String> spotNumbersData = Map<String, String>.from(data['spotNumbers'] ?? {});
    Map<int, String> spotNumbers = spotNumbersData.map(
          (key, value) => MapEntry(int.parse(key), value),
    );
    //print('SpotNumbersData from Firestore: $spotNumbers');
    return ParkingSpot(
      id: snapshot.id,
      region: data['region'],
      spotNumbers: spotNumbers,
      nrParkingSpots: data['nrParkingSpots'] ?? 0,
    );
  }

}

