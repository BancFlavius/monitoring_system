import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/manager.dart';
import 'package:uuid/uuid.dart';

class ManagerFirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Manager>> searchManagersByName(String name) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('manager')
        .where('name', isGreaterThanOrEqualTo: name)
        .where('name', isLessThan: '${name}z')
        .get();

    List<Manager> managers = [];
    querySnapshot.docs.forEach((doc) {
      Manager manager = Manager.fromSnapshot(doc);
      managers.add(manager);
    });

    return managers;
  }

  static Future<void> addManager(Manager manager) async {
    final managerRef = _firestore.collection('manager');
    final managerDoc = managerRef.doc('${manager.name}_${Uuid().v4()}');
    await managerDoc.set({
      'name': manager.name,
      'nrOfEmployees': manager.nrOfEmployees,
    });
  }

  static Future<void> incrementNrOfEmployees(Manager manager) async {
    try {
      await _firestore.collection('manager').doc(manager.id).update({
        'nrOfEmployees': manager.nrOfEmployees + 1,
      });
    } catch (error) {
      return;
    }
  }
  static Future<void> decrementNrOfEmployees(Manager manager) async {
    try {
      await _firestore.collection('manager').doc(manager.id).update({
        'nrOfEmployees': manager.nrOfEmployees - 1,
      });
    } catch (error) {
      return;
    }
  }
  static Future<int> getTotalNrOfEmployees() async {
    try {
      QuerySnapshot querySnapshot =
      await _firestore.collection('manager').get();
      int totalNrOfEmployees = 0;

      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        Manager manager = Manager.fromSnapshot(docSnapshot);
        totalNrOfEmployees += manager.nrOfEmployees;
      }

      return totalNrOfEmployees;
    } catch (error) {
      return -1;
    }
  }
  static Future<int> getNrOfEmployeesForAManager(Manager manager) async {
    DocumentSnapshot snapshot = await _firestore.collection('manager').doc(manager.id).get();
    return snapshot['nrOfEmployees'];
  }

  static Future<List<Manager>> getManagers() async {
    final QuerySnapshot snapshot = await _firestore.collection('manager').get();
    return snapshot.docs.map((doc) => Manager.fromSnapshot(doc)).toList();
  }

  static Future<Manager?> getManagerByName(String name) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('manager')
        .where('name', isEqualTo: name)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      Manager manager = Manager.fromSnapshot(querySnapshot.docs[0]);
      return manager;
    } else {
      return null;
    }
  }
  static Future<Manager?> getManagerById(String managerId) async {
    DocumentSnapshot documentSnapshot =
    await _firestore.collection('manager').doc(managerId).get();

    if (documentSnapshot.exists) {
      Manager manager = Manager.fromSnapshot(documentSnapshot);
      return manager;
    } else {
      return null;
    }
  }
  static Stream<Manager> getManagerByIdStream(String managerId) {
    return _firestore
        .collection('manager')
        .doc(managerId)
        .snapshots()
        .map((snapshot) => Manager.fromSnapshot(snapshot));
  }

  static Future<void> deleteManager(String managerId) async {
    await _firestore.collection('manager').doc(managerId).delete();
  }
  static Future<void> updateManager(Manager manager) async {
    try {
      await _firestore.collection('manager').doc(manager.id).update({
        'name': manager.name,
      });
    } catch (error) {
      return;
    }
  }

}
