import 'dart:convert';
import 'dart:io';
import 'package:ARRK/constants/constants.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:googleapis/driveactivity/v2.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
//import 'package:path/path.dart';
//import 'package:flutter_microsoft_authentication/flutter_microsoft_authentication.dart';


class ExcelOfficePresence {
  static late Excel _excel;
  static late String _sheetName;
  static const String FILE_PATH = 'assets/AttendanceSystemOfficePresence2023.xlsx';
  static const String SHAREPOINT_PATH='https://arrkengineering.sharepoint.com/:x:/r/sites/Electronics-Software-Cluj/_layouts/15/Doc.aspx?sourcedoc=%7B146F7601-F8ED-46C0-8C73-4E85ABC78F4F%7D&file=AttendanceSystemOfficePresence2023.xlsx&action=default&mobileredirect=true';
  static int _nameColumnIndex = 0;
  static int _dateRowIndex = 8;
  static int _dateColumnIndexFound=0;

  static Future<void> initializeExcel() async {
    ByteData data = await rootBundle.load(FILE_PATH);
    var bytes = data.buffer.asUint8List();
    _excel = Excel.decodeBytes(bytes);
    _sheetName = _excel.tables.keys.first;
  }
  static Future<void> simplePrint() async {
    var sheet = _excel.tables[_sheetName]!;
    var row = sheet.rows[_dateRowIndex];
    print(row[2]?.value.toString());
    print(sheet.rows[9][0]?.value.toString());
  }

  static Future<void> openAndSearchDate() async {
    //await initializeExcel();
    var sheet = _excel.tables[_sheetName]!;
    var row = sheet.rows[_dateRowIndex];
    var dateFormatter = DateFormat('dd/MM/yy'); // Date formatter for comparison
    var todayFormattedDate = dateFormatter.format(DateTime.now()); // Today's date in the same format
    print('todayFormattedDate: $todayFormattedDate');
    for (var columnIndex = 1; columnIndex < row.length; columnIndex++) {
      var cellValue = row[columnIndex]?.value.toString();
      var cellDateTime = DateTime.parse(cellValue!); // Parse the cell's string value into DateTime
      var cellFormattedDate = dateFormatter.format(cellDateTime);
      print(cellFormattedDate);
      if (cellFormattedDate == todayFormattedDate) {
        // Store the column index for the date
        _dateColumnIndexFound = columnIndex;
        print('Date column index: $_dateColumnIndexFound');
        return;
      }
    }
    print('Date column not found.');
  }

  static Future<void> updateStatus(String name, String status) async {
    var sheet = _excel.tables[_sheetName]!;

    for (var rowIndex = 9; rowIndex < 50; rowIndex++) {
      var row = sheet.rows[rowIndex];
      if (row[_nameColumnIndex]?.value.toString() == name) {
        print('find name: make update');
        row[_dateColumnIndexFound]?.value=TextCellValue(status);
        break;
      } else if(row[_nameColumnIndex]?.value.toString()==null) {
        print('did not find name, add name, make update');
        row[_nameColumnIndex]?.value=TextCellValue(name);
        //row.setCell(_nameColumnIndex, name);
        row[_dateColumnIndexFound]?.value=TextCellValue(status);
        var excelBytes = _excel.encode();
        // await File('outputexcel\\excel.xlsx').writeAsBytes(excelBytes!);
        print(row[_nameColumnIndex]?.value.toString());
        print(row[_dateColumnIndexFound]?.value.toString());
        break;
      }
    }
  }

  static Future<void> processSharePointExcel() async {
    const username = 'Szabolcs-Andras.Csillag@arrk-engineering.com';
    const password = ExcelOfficePresencePath.kPrivatePassword;
    // final authBytes = utf8.encode('$username:$password');
    // final base64Auth = base64.encode(authBytes);
    //
    // final headers = {
    //   'Authorization': 'Basic $base64Auth',
    //   // Additional headers as needed
    // };
    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
      // Additional headers as needed
    };

    final response = await http.put(
      Uri.parse(SHAREPOINT_PATH),
      headers: headers,
      // Additional request parameters as needed
    );
    print('a');
    print(response.statusCode);
    if (response.statusCode == 200) {
      print('b');
      // Parse the downloaded Excel data
      final bytes = response.bodyBytes;
      final excel = Excel.decodeBytes(bytes);

      // Get the active sheet
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName]!;

      // Read value from 2nd row, 1st column
      final valueToRead = sheet.rows[1][0]?.value?.toString();
      print('Value read from Excel: $valueToRead');

      // Modify the Excel data
      if (sheet.maxRows > 1) {
        sheet.rows[1][1]?.value = TextCellValue('heiii');
      }

      // Encode the modified Excel data
      final modifiedBytes = excel.encode();

      // Upload the modified Excel back to SharePoint
      final uploadResponse = await http.put(
        Uri.parse(SHAREPOINT_PATH), // Replace with appropriate upload URL
        body: modifiedBytes,
      );

      if (uploadResponse.statusCode == 200) {
        print('Modified Excel uploaded successfully.');
      } else {
        print('Error uploading modified Excel.');
      }
    } else {
      print('Error downloading Excel from SharePoint.');
    }
  }

  // static Future<void> trySharePointConnection1() async {
  //   final scopes = ['https://your-sharepoint-site.sharepoint.com/.default'];
  //
  //   // Authenticate with MSAL to get an access token
  //   final result = await MsalMobile.acquireToken(scopes);
  //   final accessToken = result.accessToken;
  //
  //   final headers = {
  //     'Authorization': 'Bearer $accessToken',
  //     'Accept': 'application/json',
  //     // Add any other headers you need
  //   };
  //
  //   final sharepointUrl = 'https://your-sharepoint-site.sharepoint.com/sites/your-site/_api/web/lists/getbytitle(\'Documents\')/items';
  //
  //   // Make an authenticated request to SharePoint
  //   final response = await http.get(Uri.parse(sharepointUrl), headers: headers);
  //
  //   if (response.statusCode == 200) {
  //     // Process SharePoint response data here
  //     print(response.body);
  //   } else {
  //     print('Failed to access SharePoint: ${response.statusCode}');
  //   }
  // }
  static Future<void> trySharePointConnection2() async {
    //30992635-7d31-42cc-9452-d91e875b2973  //directory id
    //0330b1e095de4e9bbf511a17ad390c69      //Session ID
    final clientId = 'your-client-id';
    final clientSecret = 'your-client-secret';
    final authority = 'https://login.microsoftonline.com/your-tenant-id';
    final resource = 'https://your-sharepoint-site.sharepoint.com';
    final redirectUri = 'your-redirect-uri';
    final scope = 'openid profile offline_access $resource/.default';

    // Authenticate and obtain an access token
    final response = await http.post(
      Uri.parse('$authority/oauth2/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        'grant_type': 'password',
        'scope': scope,
        'username': 'your-username',
        'password': 'your-password',
      },
    );

    if (response.statusCode == 200) {
      final accessToken = response.body;

      final headers = {
        'Authorization': 'Bearer $accessToken',
        // Add any other headers you need
      };

      // Make an authenticated request to SharePoint
      final sharepointResponse = await http.get(Uri.parse(SHAREPOINT_PATH), headers: headers);

      if (sharepointResponse.statusCode == 200) {
        // Process SharePoint response data here
        print(sharepointResponse.body);
      } else {
        print('Failed to access SharePoint: ${sharepointResponse.statusCode}');
      }
    } else {
      print('Failed to obtain access token: ${response.statusCode}');
    }
  }
}
