import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/drive/v3.dart' as drive;
import 'dart:io' as io;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class GoogleDriveExcel {
  static const String jsonPath='assets/attendance.json';
  static const String fileId='1KMJ3PqtgAdJndqZSvgWRbxmY_9yTz6ku4wC9XVYecnw';
  static late  drive.DriveApi myDrive;
  static late Excel myExcel;
  static late io.File myExcelFile;

  static Future<void> initialize() async {
    //var jsonFile = io.File(jsonPath);
    //var jsonString = jsonFile.readAsStringSync();
    var jsonString=await rootBundle.loadString(jsonPath);
    ServiceAccountCredentials jsonCredentials = auth.ServiceAccountCredentials.fromJson(jsonString);
    List<String> scopes = [drive.DriveApi.driveFileScope, drive.DriveApi.driveScope];
    var client = await auth.clientViaServiceAccount(jsonCredentials, scopes);
    myDrive = drive.DriveApi(client);
    HttpClientResponse media = await myDrive.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as HttpClientResponse;
    var tempDir = await getTemporaryDirectory();
    myExcelFile = io.File('${tempDir.path}/temp.xlsx');
    await myExcelFile.writeAsBytes(await consolidateHttpClientResponseBytes(media));
    myExcel = Excel.decodeBytes(myExcelFile.readAsBytesSync());
  }

  static List<dynamic> readColumn(int columnIndex) {
    var sheet = myExcel['Sheet1'];
    return sheet.rows.map((row) => row[columnIndex]).toList();
  }

  void updateCell(int rowIndex, int columnIndex, dynamic value) {
    var sheet = myExcel['Sheet1'];
    sheet.updateCell(CellIndex.indexByColumnRow(rowIndex: rowIndex, columnIndex: columnIndex), value);
    myExcelFile.writeAsBytesSync(myExcel.encode() as List<int>);
  }
  //Use Microsoft Graph API: i want this part explain to me step by step what setup and authentification do i need? to be able to read and modify directly an excel from a sharepoint using my flutter app
  //Microsoft Graph API: Sharepoint Excel Flutter

  Future<void> uploadUpdatedFile() async {
    var file = drive.File();
    file.name = 'attendance.xlsx';
    var response = await myDrive.files.create(
      file,
      uploadMedia: drive.Media(myExcelFile.openRead(), myExcelFile.lengthSync()),
    );
    print('Uploaded file. File ID: ${response.id}');
  }
  void prompt(String url) {
    print("Please go to the following URL and grant access:");
    print("  => $url");
    print("");
  }
}



// import 'package:googleapis_auth/auth.dart';
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:googleapis/drive/v3.dart' as drive;
// import 'package:google_sign_in/google_sign_in.dart';
// import 'dart:io' as io;
// import 'package:excel/excel.dart';
//
// var jsonFile = io.File('assets/attendance.json');
// var jsonString = jsonFile.readAsStringSync();
// ServiceAccountCredentials jsonCredentials = auth.ServiceAccountCredentials.fromJson(jsonString);
// List<String> scopes = [drive.DriveApi.driveFileScope, drive.DriveApi.driveScope];
// String fileId ='1KMJ3PqtgAdJndqZSvgWRbxmY_9yTz6ku4wC9XVYecnw';
// late Excel excel;
//
//
// final _googleSignIn = GoogleSignIn(
//   scopes: <String>[
//     drive.DriveApi.driveFileScope,
//     drive.DriveApi.driveScope
//   ],
// );
//
// void handleSignIn() async {
//   try {
//     await _googleSignIn.signIn();
//     var client = await auth.clientViaServiceAccount(jsonCredentials, scopes);
//     var myDrive = drive.DriveApi(client);
//     // Use the Drive API client as needed.
//   } catch (error) {
//     print(error);
//   }
// }
//
// void readExcel(io.File file) {
//   var bytes = file.readAsBytesSync();
//   excel = Excel.decodeBytes(bytes);
//   // Manipulate the Excel file as needed.
// }
// void updateStatus(String employeeName, String status) {
//   var sheet = excel['Sheet1'];
//   for (var table in excel.tables.keys) {
//     for (var row in excel.tables[table]!.rows) {
//       if (row[0] == employeeName) {
//         row[2] = status;
//         break;
//       }
//     }
//   }
//   // Save the changes
//   file.writeAsBytesSync(excel.encode());
//   // Upload the updated file back to Google Drive
//   uploadFileToGoogleDrive(file);
// }
//
// Future<void> uploadFileToGoogleDrive(io.File fileToUpload) async {
//   var client = await auth.clientViaServiceAccount(jsonCredentials, scopes);
//   var myDrive = drive.DriveApi(client);
//   var file = drive.File();
//   file.name = 'UpdatedFile.xlsx';
//   var response = await myDrive.files.create(
//     file,
//     uploadMedia: drive.Media(fileToUpload.openRead(), fileToUpload.lengthSync()),
//   );
//   print('Uploaded file. File ID: ${response.id}');
// }