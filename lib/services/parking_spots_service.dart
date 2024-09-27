import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:cloud_functions/cloud_functions.dart';
import '../models/parking_spot.dart';

class ParkingSpotsFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //static final FirebaseFunctions _firebaseFunctions = FirebaseFunctions.instance;

  static Future<List<ParkingSpot>> getParkingSpots() async {
    final QuerySnapshot snapshot =
    await _firestore.collection('parkingSpot').get();
    return snapshot.docs
        .map((doc) => ParkingSpot.fromSnapshot(doc))
        .toList();
  }
  static Future<List<String>> getParkingRegions() async {
    CollectionReference parkingSpotRef = _firestore.collection('parkingSpot');
    QuerySnapshot snapshot = await parkingSpotRef.get();
    List<String> documentIds = snapshot.docs.map((doc) => doc.id).toList();
    return documentIds;
  }

  static Future<String> addParkingSpot(String regionParam, int numberParam, String statusParam) async {
    final parkingSpotRef = _firestore.collection('parkingSpot');
    final parkingSpotDoc = parkingSpotRef.doc(regionParam);

    final existingParkingSpot = await parkingSpotDoc.get();
    String returnMessage='';
    if (existingParkingSpot.exists) {
      int currentNrParkingSpots = existingParkingSpot.data()!['nrParkingSpots'] as int;
      final Map<int, String> currentParkingSpots = Map.fromEntries(
        (existingParkingSpot.data()!['spotNumbers'] as List<dynamic>).map(
              (spotData) {
            int number = spotData['number'] is int ? spotData['number'] : 0;
            String status = spotData['status'] ?? 'BLOCKED';
            return MapEntry(number, status);
          },
        ),
      );
      if (currentParkingSpots.containsKey(numberParam)) {
        returnMessage='Edited Status with success.';
      } else {
        currentNrParkingSpots++;
        returnMessage='Added Parking Spot with success.';
      }
      currentParkingSpots[numberParam] = statusParam;
      await parkingSpotDoc.update({
        'spotNumbers': currentParkingSpots.entries.map((entry) => {
          'number': entry.key,
          'status': entry.value,
        }).toList(),
        'nrParkingSpots': currentNrParkingSpots,
      });
    } else {
      await parkingSpotDoc.set({
        'region': regionParam,
        'spotNumbers': [
          {
            'number': numberParam,
            'parkingSpotReservation': statusParam,
          },
        ],
        'nrParkingSpots': 1,
      });
      returnMessage='Added Parking Spot and new region with success.';
    }
    return returnMessage;
  }

  static Future<Map<int,String>> getMapNrAndStatusForARegion(String region) async{
    DocumentReference regionDocRef = _firestore.collection('parkingSpot').doc(region);
    DocumentSnapshot snapshot = await regionDocRef.get();
    Map<int, String> spotNumbers= {};
    if (snapshot.exists) {
      List<dynamic> spotNumbersData = (snapshot.data() as Map<String, dynamic>)['spotNumbers'];
      spotNumbersData.forEach((spotData) {
        int number = spotData['number'] is int ? spotData['number'] : 0;
        String status = spotData['status'] ?? 'BLOCKED';
        spotNumbers[number] = status;
      });
      return spotNumbers;
    } else {
      return spotNumbers;
    }
  }

  static Future<String> updateParkingSpotsStatus(String region, Map<int, String> spotNumbers) async{
    try{
      DocumentReference regionDocRef = _firestore.collection('parkingSpot').doc(region);
      await regionDocRef.update({'spotNumbers': spotNumbers.entries.map((entry) => {
        'number': entry.key,
        'status': entry.value,
      }).toList()});
      return 'Edit with success!';
    }catch(e) {
      return e.toString();
    }
  }

  static Future<String> deleteParkingSpot(String regionParam, int numberParam) async {
    try {
      final parkingSpotRef = _firestore.collection('parkingSpot');
      final parkingSpotDoc = parkingSpotRef.doc(regionParam);

      final existingParkingSpot = await parkingSpotDoc.get();

      if (existingParkingSpot.exists) {
        int currentNrParkingSpots = existingParkingSpot.data()!['nrParkingSpots'] as int;
        final List<dynamic> spotNumbersData = existingParkingSpot.data()!['spotNumbers'];
        final List<Map<String, dynamic>> currentParkingSpots =
        List.from(spotNumbersData);
        int indexToDelete = currentParkingSpots.indexWhere(
                (spotData) => spotData['number'] == numberParam);

        if (indexToDelete != -1) {
          currentParkingSpots.removeAt(indexToDelete);
          currentNrParkingSpots--;
          await parkingSpotDoc.update({
            'spotNumbers': currentParkingSpots,
            'nrParkingSpots': currentNrParkingSpots,
          });
          return 'Deleted with success.';
        } else {
          return 'Parking spot not found';
        }
      } else {
        return 'Region not found';
      }
    } catch (error) {
      return error.toString();
    }
  }
  // static Future<String> scheduleUpdateParkingSpot(String regionParam,String statusParam, Set<int> selectedParkingSpots, DateTime scheduledTime) async {
  //   try {
  //     final int  difference = scheduledTime.difference(DateTime.now()).inMilliseconds;
  //     //final HttpsCallable callable = _firebaseFunctions.httpsCallable('modifyParkingSpotsStatus');
  //     // // Prepare the data to be sent to the function.
  //     // final Map<String, dynamic> data = {
  //     //   'selectedParkingSpots': selectedParkingSpots.toList(),
  //     //   'scheduledDifference': difference,
  //     //   'status': statusParam,
  //     //   'region': regionParam,
  //     // };
  //     // print(difference);
  //     // print('data:');
  //     // print(data['selectedParkingSpots']);
  //     // print(data['scheduledDifference']);
  //     // print(data['status']);
  //     // print(data['region']);
  //     //
  //     // // Call the Firebase Cloud Function.
  //     // final HttpsCallableResult result = await callable.call(data);
  //     // final Map<String, dynamic> response = result.data;
  //
  //     // Add a delay to wait for the Firestore update to take place.
  //     //await Future.delayed(Duration(milliseconds: difference));
  //     return 'Parking spots updated as scheduled';
  //     //return response['message']; // 'Parking spots will be blocked as scheduled.'
  //   } catch (e) {
  //     return 'Error: $e';
  //   }
  // }

  // static Future<Map<int, String>> getAvailableParkingSpots() async {
  //   Map<int, String> availableSpots = {};
  //
  //   try {
  //     QuerySnapshot snapshot = await _firestore
  //         .collection('parkingSpot')
  //         .get();
  //
  //     for (QueryDocumentSnapshot doc in snapshot.docs) {
  //       Map<String, dynamic> data = doc.data();
  //
  //       // Replace 'status' with the field that represents the status of the parking spot in your Firestore document.
  //       String status = data['status'];
  //
  //       // Replace 'number' with the field that represents the number of the parking spot in your Firestore document.
  //       int number = data['number'];
  //
  //       // Check if the parking spot is available (you can adjust the condition based on your status values).
  //       if (status == 'available') {
  //         availableSpots[number] = status;
  //       }
  //     }
  //   } catch (e) {
  //     // Handle any errors that may occur during fetching data from Firestore.
  //     print('Error fetching available parking spots: $e');
  //   }
  //
  //   return availableSpots;
  // }


}
