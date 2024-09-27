import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalSettingsFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> getCheckInEnabled() async {
    final DocumentSnapshot snapshot =
        await _firestore.collection('globals').doc('settings').get();
    final Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    final bool checkInEnabled = data?['checkInEnabled'] ?? false;
    return checkInEnabled;
  }

  static Future<void> setCheckInEnabled(bool isEnabled) async {
    await _firestore
        .collection('globals')
        .doc('settings')
        .set({'checkInEnabled': isEnabled});
  }

  static Future<String> getAdminPassword() async {
    try {
      final DocumentSnapshot snapshot =
      await _firestore.collection('globals').doc('adminPassword').get();
      final Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      final String password = data?['password'];
      return password;
    } catch (e) {
      print('error: $e');
      return '';
    }

  }
  static Future<int> getParkingSpots() async {
    final DocumentSnapshot snapshot =
    await _firestore.collection('globals').doc('parking').get();
    final Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    final int nrParkingSpots = data?['nrParkingSpots'];
    return nrParkingSpots;
  }
}
