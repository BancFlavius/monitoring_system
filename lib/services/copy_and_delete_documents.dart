import 'package:cloud_firestore/cloud_firestore.dart';

class CopyAndDeleteDocuments {
  static Future<void> copyAndDeleteDocument() async {
    String sourceDocumentID = 'Lab'; // Source document ID
    String destinationDocumentID = 'Labs'; // Destination document ID

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the data from the source document
    DocumentSnapshot sourceDoc = await firestore.collection('desk').doc(sourceDocumentID).get();
    if (sourceDoc.exists) {
      Map<String, dynamic>? sourceData = sourceDoc.data() as Map<String, dynamic>?;

      // Create a new document with the destination ID and copy the data
      await firestore.collection('desk').doc(destinationDocumentID).set(sourceData!);

      // Delete the original document
      await firestore.collection('desk').doc(sourceDocumentID).delete();

      print('Data copied successfully.');
    } else {
      print('Source document does not exist.');
    }
  }

}
