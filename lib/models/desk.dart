import 'package:cloud_firestore/cloud_firestore.dart';

class Desk {
  final String id;
  final String region;
  final Map<int, String> deskNumbers;
  final int nrDesks;

  Desk({
    required this.id,
    required this.region,
    required this.deskNumbers,
    required this.nrDesks,
  });

  factory Desk.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    Map<String, String> deskNumbersData =
        Map<String, String>.from(data['deskNumbers'] ?? {});
    Map<int, String> deskNumbers = deskNumbersData.map(
      (key, value) => MapEntry(int.parse(key), value),
    );
    return Desk(
      id: snapshot.id,
      region: data['region'],
      deskNumbers: deskNumbers,
      nrDesks: data['nrDesks'] ?? 0,
    );
  }
}
