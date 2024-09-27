import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/desk.dart';

class DesksFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Desk>> getDesks() async {
    final QuerySnapshot snapshot = await _firestore.collection('desk').get();
    return snapshot.docs.map((doc) => Desk.fromSnapshot(doc)).toList();
  }

  static Future<Map<String, List<int>>> getBlockedDesks() async {
    CollectionReference deskRef = _firestore.collection('desk');
    QuerySnapshot snapshot = await deskRef.get();

    Map<String, List<int>> blockedDesks = {};

    for (var doc in snapshot.docs) {
      String region = doc['region'] as String;
      List<int> blockedDeskNumbers = [];

      final List<dynamic> deskData = doc['deskNumbers'];
      for (var desk in deskData) {
        int number = desk['number'] is int ? desk['number'] : 0;
        String status = desk['status'] ?? 'BLOCKED';
        if (status == 'BLOCKED') {
          blockedDeskNumbers.add(number);
        }
      }

      if (blockedDeskNumbers.isNotEmpty) {
        blockedDesks.putIfAbsent(region, () => []);
        blockedDesks[region]!.addAll(blockedDeskNumbers);
      }
    }

    return blockedDesks;
  }



  static Future<List<String>> getDeskRegions() async {
    CollectionReference deskRef = _firestore.collection('desk');
    QuerySnapshot snapshot = await deskRef.get();
    List<String> documentIds = snapshot.docs.map((doc) => doc.id).toList();
    return documentIds;
  }

  static Future<String> addDesk(
      String regionParam, int numberParam, String statusParam) async {
    final deskRef = _firestore.collection('desk');
    final deskDoc = deskRef.doc(regionParam);

    final existingDesk = await deskDoc.get();
    String returnMessage = '';
    if (existingDesk.exists) {
      int currentNrDesks = existingDesk.data()!['nrDesks'] as int;
      final Map<int, String> currentDesks = Map.fromEntries(
        (existingDesk.data()!['deskNumbers'] as List<dynamic>).map(
          (spotData) {
            int number = spotData['number'] is int ? spotData['number'] : 0;
            String status = spotData['status'] ?? 'BLOCKED';
            return MapEntry(number, status);
          },
        ),
      );
      if (currentDesks.containsKey(numberParam)) {
        returnMessage = 'Edited Status with success.';
      } else {
        currentNrDesks++;
        returnMessage = 'Added Desk with success.';
      }
      currentDesks[numberParam] = statusParam;
      await deskDoc.update({
        'deskNumbers': currentDesks.entries
            .map((entry) => {
                  'number': entry.key,
                  'status': entry.value,
                })
            .toList(),
        'nrDesks': currentNrDesks,
      });
    } else {
      await deskDoc.set({
        'region': regionParam,
        'deskNumbers': [
          {
            'number': numberParam,
            'status': statusParam,
          },
        ],
        'nrDesks': 1,
      });
      returnMessage = 'Added Desk and new region with success.';
    }
    return returnMessage;
  }

  static Future<Map<int, String>> getMapNrAndStatusForARegion(
      String region) async {
    DocumentReference regionDocRef = _firestore.collection('desk').doc(region);
    DocumentSnapshot snapshot = await regionDocRef.get();
    Map<int, String> deskNumbers = {};
    if (snapshot.exists) {
      List<dynamic> deskNumbersData =
          (snapshot.data() as Map<String, dynamic>)['deskNumbers'];
      deskNumbersData.forEach((deskData) {
        int number = deskData['number'] is int ? deskData['number'] : 0;
        String status = deskData['status'] ?? 'BLOCKED';
        deskNumbers[number] = status;
      });
      return deskNumbers;
    } else {
      return deskNumbers;
    }
  }

  static Future<String> updateDesksStatus(
      String region, Map<int, String> deskNumbers) async {
    try {
      DocumentReference regionDocRef =
          _firestore.collection('desk').doc(region);
      await regionDocRef.update({
        'deskNumbers': deskNumbers.entries
            .map((entry) => {
                  'number': entry.key,
                  'status': entry.value,
                })
            .toList()
      });
      return 'Edit with success!';
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> deleteDesk(String regionParam, int numberParam) async {
    try {
      final deskRef = _firestore.collection('desk');
      final deskDoc = deskRef.doc(regionParam);

      final existingDesk = await deskDoc.get();

      if (existingDesk.exists) {
        int currentNrDesks = existingDesk.data()!['nrDesks'] as int;
        final List<dynamic> deskNumbersData =
            existingDesk.data()!['deskNumbers'];
        final List<Map<String, dynamic>> currentDesks =
            List.from(deskNumbersData);
        int indexToDelete = currentDesks
            .indexWhere((spotData) => spotData['number'] == numberParam);

        if (indexToDelete != -1) {
          currentDesks.removeAt(indexToDelete);
          currentNrDesks--;
          await deskDoc.update({
            'deskNumbers': currentDesks,
            'nrDesks': currentNrDesks,
          });
          return 'Deleted with success.';
        } else {
          return 'Desk not found';
        }
      } else {
        return 'Region not found';
      }
    } catch (error) {
      return error.toString();
    }
  }
}
