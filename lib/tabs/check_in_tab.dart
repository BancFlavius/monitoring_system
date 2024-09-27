import 'package:ARRK/constants/constants.dart';
import 'package:ARRK/screens/handle_4_digit_input.dart';
import 'package:ARRK/widgets/check_in_bullets.dart';
import 'package:ARRK/widgets/digit_keypad.dart';
import 'package:ARRK/widgets/digit_keypad_tablet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/employee.dart';
import '../services/employee_firebase_service.dart';
import '../services/global_settings_firebase_service.dart';
import '../widgets/check_in_bullets_constant.dart';
import '../widgets/digit_keypad_constant.dart';
import '../widgets/excel_office_presence.dart';
import '../widgets/qr_scanner_page.dart';
import '../widgets/view_reservations_step.dart';
import 'employee_list_tab.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CheckInTab extends StatefulWidget {
  final VoidCallback navigateToEmployeeListTab;

  const CheckInTab({super.key, required this.navigateToEmployeeListTab});

  @override
  CheckInTabState createState() => CheckInTabState();
}

class CheckInTabState extends State<CheckInTab> {
  static final TextEditingController _checkInCodeController =
      TextEditingController();
  bool _showWelcomeMessage = false;
  String _welcomeMessage = '';
  Timer? _timer; // Declare a Timer variable
  bool _verifyCode = false;
  static List<Color> _colorIcon = [
    //static
    AppColors.kGrey300Color,
    AppColors.kGrey300Color,
    AppColors.kGrey300Color,
    AppColors.kGrey300Color
  ];
  int? _colTodayIndex = -1;
  bool _navigatePush = false;

  String _qrText = '';

  @override
  void initState() {
    super.initState();
    //setColTodayIndex();
    //readExcel();
    // readExcelFirebaseStorage();
    fetchExcel();
  }

  Future<void> fetchExcel() async {
    // print('try open excel');
    // await ExcelOfficePresence.processSharePointExcel();
    // await ExcelOfficePresence.initializeExcel();
    // print('simplePRint');
    // await ExcelOfficePresence.simplePrint();
    // print('search date of today');
    // await ExcelOfficePresence.openAndSearchDate();
    // print('try to add a test');
    // String name = "test1";
    // await ExcelOfficePresence.updateStatus(name, "Check IN");
  }

  Future<void> getDownloadUrl() async {
    String filePath =
        "gs://attendance-6dcd9.appspot.com//AttendanceSystemOfficePresence2023.xlsx"; // File path in Firebase Storage
    firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref(filePath);
    String downloadUrl = await ref.getDownloadURL();
    print('Download URL: $downloadUrl');

    // Now you can share the download URL with your team member
  }

  Future<void> readExcelFirebaseStorage() async {
    try {
      String filePath =
          "gs://attendance-6dcd9.appspot.com//AttendanceSystemOfficePresence2023.xlsx"; // File path in Firebase Storage
      firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.ref(filePath);
      firebase_storage.FullMetadata metadata = await ref.getMetadata();

      if (metadata.size == 0) {
        print('Excel file is empty.');
        return;
      }

      // Now you can read the Excel file using the excel package as shown in previous examples
      // ...

      print('Excel file downloaded and read successfully.');
    } catch (e) {
      print('Firebase Storage Error: $e');
    }
  }

  Future<void> readExcel() async {
    String filePath = ExcelOfficePresencePath.kExcelOfficePresencePath;
    print('File path: $filePath');
    ByteData data = await rootBundle.load(filePath);
    var bytes = data.buffer.asUint8List();
    var excel = Excel.decodeBytes(bytes);

    var sheet = excel.tables.keys.first;

    // Read a specific row (e.g., row index 0)
    var specificRow = excel.tables[sheet]!.rows[0];
    print('Specific Row:');
    for (var cell in specificRow) {
      print(cell?.value);
    }

    // Read specific columns (e.g., column index 0 and 1)
    var columnIndexList = [0, 1];
    print('Specific Columns:');
    for (var row in excel.tables[sheet]!.rows) {
      for (var columnIndex in columnIndexList) {
        if (columnIndex < row.length) {
          print(row[columnIndex]?.value);
        }
      }
    }
  }

  void readExcelFile() {
    try {
      String filePath = ExcelOfficePresencePath.kExcelOfficePresencePath;
      String fileName = 'AttendanceSystemOfficePresence2023.xlsx';
      String directory = 'C:\\szaby\\attendance_system\\excelPresence';

      //String filePath = path.join(directory, fileName);
      print('File path: $filePath');
      File excelFile = File(filePath);

      if (!excelFile.existsSync()) {
        print('Excel file does not exist.');
        return;
      }
      print('exists');
      // Now you can read the Excel file
      // You can use a library like 'excel' or 'excel/excel.dart' to parse the Excel content
      // For example: var excel = Excel.decodeBytes(excelFile.readAsBytesSync());

      // Perform further operations on the excel object
    } catch (e) {
      print('Error reading Excel file: $e');
    }
  }

  Future<void> setColTodayIndex() async {
    _colTodayIndex = await getTodayColumnIndex();
    print('colTodayIndex $_colTodayIndex');
  }

  Future<int?> getTodayColumnIndex() async {
    String filePath = ExcelOfficePresencePath.kExcelOfficePresencePath;
    var excel = Excel.decodeBytes(File(filePath).readAsBytesSync());
    var table = excel.tables['Sheet1']; // Adjust sheet name if needed

    String today = DateFormat('dd/MM/yy').format(DateTime.now());
    var row = table?.rows[8]; // Assuming you want to search in the 9th row

    for (var cell in row!) {
      if (cell?.value == today) {
        return cell?.columnIndex;
      }
    }
    return -1; // Today's date not found
  }

  Future<bool> _verifyCheckInEnabled() async {
    bool checkInEnabled =
        await GlobalSettingsFirebaseService.getCheckInEnabled();
    _showWelcomeMessage = true;
    _welcomeMessage = 'You can not check in now!';
    return checkInEnabled;
  }

  Future<void> _checkIn() async {
    String code = _checkInCodeController.text;
    bool verifyCheckInEnabled = await _verifyCheckInEnabled();
    if (verifyCheckInEnabled) {
      Employee? employee =
          await EmployeeFirebaseService.getEmployeeByCode(code);
      //FocusScope.of(context).unfocus();

      if (employee != null) {
        //sfd
        if (employee.isInOffice == true) {
          setState(() {
            _verifyCode = true;
            _checkInCodeController.clear();
            _colorIcon = [
              AppColors.kGrey300Color,
              AppColors.kGrey300Color,
              AppColors.kGrey300Color,
              AppColors.kGrey300Color
            ];
            DigitKeypad.enteredDigits = '';
            _welcomeMessage = '${employee.name} you are already checked in.';
            _showWelcomeMessage = true;
          });
        } else {
          setState(() {
            _verifyCode = true;
            employee.isInOffice = true;
            _checkInCodeController.clear();
            _colorIcon = [
              AppColors.kGrey300Color,
              AppColors.kGrey300Color,
              AppColors.kGrey300Color,
              AppColors.kGrey300Color
            ];
            DigitKeypad.enteredDigits = '';
            _welcomeMessage = 'Hi, ${employee.name}! Welcome.';
            _showWelcomeMessage = true;
          });
          await EmployeeFirebaseService.updateEmployeeIsInOffice(employee);
        }
        _timer = Timer(const Duration(seconds: 2), () {
          setState(() {
            _showWelcomeMessage = false;
            EmployeeListTab.tabKey.currentState?.searchEmployee();
            widget.navigateToEmployeeListTab();
          });
        });
      } else {
        if (mounted) {
          setState(() {
            _verifyCode = false;
            _welcomeMessage = 'Code wrong!';
            _showWelcomeMessage = true;
            _checkInCodeController.clear();
            _colorIcon = [
              AppColors.kGrey300Color,
              AppColors.kGrey300Color,
              AppColors.kGrey300Color,
              AppColors.kGrey300Color
            ];
          });
        }
        DigitKeypad.enteredDigits = '';
      }
    }
  }

  Future<void> _checkOut() async {
    String code = _checkInCodeController.text;
    Employee? employee = await EmployeeFirebaseService.getEmployeeByCode(code);
    //FocusScope.of(context).unfocus();
    setState(() {
      _showWelcomeMessage = true;
    });

    if (employee != null) {
      if (employee.isInOffice == true) {
        setState(() {
          _verifyCode = true;
          employee.isInOffice = false;
          _checkInCodeController.clear();
          _colorIcon = [
            AppColors.kGrey300Color,
            AppColors.kGrey300Color,
            AppColors.kGrey300Color,
            AppColors.kGrey300Color
          ];
          DigitKeypad.enteredDigits = '';
          _welcomeMessage = 'Good bye, ${employee.name}! You are checked out.';
        });
        _timer = Timer(const Duration(seconds: 2), () {
          setState(() {
            _showWelcomeMessage = false;
            EmployeeListTab.tabKey.currentState?.searchEmployee();
            widget.navigateToEmployeeListTab();
          });
        });
        await EmployeeFirebaseService.updateEmployeeIsInOffice(employee);
      } else {
        _welcomeMessage =
            '${employee.name} you are not checked in. To check out, you must first check in.';
      }
    } else {
      setState(() {
        _verifyCode = false;
        _welcomeMessage = 'Code wrong!';
        _checkInCodeController.clear();
        _colorIcon = [
          AppColors.kGrey300Color,
          AppColors.kGrey300Color,
          AppColors.kGrey300Color,
          AppColors.kGrey300Color
        ];
        DigitKeypad.enteredDigits = '';
      });
    }
  }

  static void clearDigits() {
    _checkInCodeController.clear();
    _colorIcon = [
      AppColors.kGrey300Color,
      AppColors.kGrey300Color,
      AppColors.kGrey300Color,
      AppColors.kGrey300Color
    ];
    DigitKeypad.enteredDigits = '';
    DigitKeypadConstant.enteredDigits = '';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void onHandleDigits({required BuildContext context, required String digits}) {
    _checkInCodeController.text = digits;
    int digitsLength = digits.length;
    List<Color> colorIconAux;
    switch (digitsLength) {
      case 0:
        colorIconAux = [
          AppColors.kGrey300Color,
          AppColors.kGrey300Color,
          AppColors.kGrey300Color,
          AppColors.kGrey300Color
        ];
        break;
      case 1:
        colorIconAux = [
          Colors.blueAccent,
          AppColors.kGrey300Color,
          AppColors.kGrey300Color,
          AppColors.kGrey300Color
        ];
        break;
      case 2:
        colorIconAux = [
          Colors.blueAccent,
          Colors.blueAccent,
          AppColors.kGrey300Color,
          AppColors.kGrey300Color
        ];
        break;
      case 3:
        colorIconAux = [
          Colors.blueAccent,
          Colors.blueAccent,
          Colors.blueAccent,
          AppColors.kGrey300Color
        ];
        break;
      case 4:
        colorIconAux = [
          Colors.blueAccent,
          Colors.blueAccent,
          Colors.blueAccent,
          Colors.blueAccent
        ];
        //modify
        _navigate(context: context, digits: digits);
        break;
      default:
        colorIconAux = [Colors.grey, Colors.grey, Colors.grey, Colors.grey];
        break;
    }
    setState(() {
      _colorIcon = colorIconAux;
    });
  }

  void _navigate({required BuildContext context, required String digits}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Handle4DigitInput(
          employeeCode: digits,
        ),
      ),
    );
  }

  void _updateQRText(String? qrText) {
    setState(() {
      _qrText = qrText!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    bool isBigWidth = screenWidth > 600;
    if (isBigWidth) {
      return webScaffold(screenSize: screenSize, context: context);
    } else {
      return mobileScaffold(screenSize: screenSize, context: context);
    }
  }

  Scaffold mobileScaffold({required Size screenSize,required BuildContext context}) {
    return Scaffold(
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_qrText != '')
            Text(
              'When you enter the office, you need to check in.',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: screenSize.width * 0.03,
              ),
            ),
          Text('When you exit the office, you need to check out.',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: screenSize.width * 0.03,
              )),
          Text(
            'You are allowed to check in just between:',
            style: TextStyle(
                color: Colors.blueAccent,
                fontSize: screenSize.width * 0.03
            ),
          ),
          Text(
            '7:00 and 20:30.',
            style: TextStyle(
                color: Colors.blueAccent,
                fontSize: screenSize.width * 0.03
            ),
          ),
          SizedBox(
            height: screenSize.height * 0.0001,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CheckInBullet(
                  screenSize: screenSize,
                  color: _colorIcon[0],
                  index: 0,
                  key: const Key('index0')),
              SizedBox(
                //width: screenSize.width * 0.02,
              ),
              CheckInBullet(
                  screenSize: screenSize,
                  color: _colorIcon[1],
                  index: 1,
                  key: const Key('index1')),
              SizedBox(
                //width: screenSize.width * 0.02,
              ),
              CheckInBullet(
                  screenSize: screenSize,
                  color: _colorIcon[2],
                  index: 2,
                  key: const Key('index2')),
              SizedBox(
                //width: screenSize.width * 0.02,
              ),
              CheckInBullet(
                  screenSize: screenSize,
                  color: _colorIcon[3],
                  index: 3,
                  key: const Key('index3')),
            ],
          ),
          SizedBox(
            //height: screenSize.height * 0.01,
          ),
          DigitKeypad(
            onDigitEntered: onHandleDigits,
            buildContext: context,
            screenSize: screenSize,
            //add a key
            key: const Key('enterDigits'),
          ),
          SizedBox(
            // height: screenSize.height * 0.05,
          ),
          //
          //Text('qr read:  $_qrText' ),
          //qrImage done

          // SingleChildScrollView(
          //   scrollDirection: Axis.horizontal,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       ElevatedButton(
          //         style: ElevatedButton.styleFrom(
          //           minimumSize: Size(screenSize.width * 0.2, screenSize.height * 0.05),
          //         ),
          //         onPressed: _checkIn,
          //         key: const Key('checkinButton'),
          //         child: Padding(
          //           padding: EdgeInsets.all(screenSize.width * 0.03),
          //           child: Text(
          //             'Check-in',
          //             style: TextStyle(fontSize: screenSize.width * 0.07),
          //           ),
          //         ),
          //       ),
          //       SizedBox(
          //         width: screenSize.width * 0.05
          //       ),
          //       ElevatedButton(
          //         style: ElevatedButton.styleFrom(
          //           minimumSize: Size(screenSize.width * 0.2, screenSize.height * 0.05),
          //         ),
          //         onPressed: _checkOut,
          //         key:const Key('checkoutButton'),
          //         child: Padding(
          //           padding: EdgeInsets.all(screenSize.width * 0.03),
          //           child: Text(
          //             'Check-out',
          //             style: TextStyle(fontSize: screenSize.width * 0.07),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // if(_showWelcomeMessage)
          //   Padding(
          //     padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01,horizontal: screenSize.width * 0.01),
          //     child: Text(
          //       _welcomeMessage,
          //       style: TextStyle(
          //           fontSize: screenSize.width * 0.05,
          //           color: _verifyCode
          //               ? AppColors.kBlueColor
          //               : AppColors.kYellowColor),
          //       textAlign: TextAlign.center,
          //     ),
          //   ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            left: screenSize.width * 0.46,
            bottom: screenSize.height * 0.1,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerPage(),
                  ),
                ).then((value) {
                  // Handle the returned value from the qr page
                  if (value != null && value.length == 4) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Handle4DigitInput(employeeCode: value),
                      ),
                    );
                  }
                });
              },
              icon: Icon(
                Icons.qr_code_scanner,
                size: screenSize.width * 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Scaffold webScaffold({required Size screenSize,required BuildContext context}) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            Text(
              'When you enter the office, you need to check in.',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 12,
              ),
            ),
          Text('When you exit the office, you need to check out.',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 12,
              )),
          Text(
            'You are allowed to check in just between:',
            style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 12
            ),
          ),
          Text(
            '7:00 and 20:30.',
            style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 12
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CheckInBulletConstant(
                  color: _colorIcon[0],
                  index: 0,
                  key: const Key('index0')),
              CheckInBulletConstant(
                  color: _colorIcon[1],
                  index: 1,
                  key: const Key('index1')
              ),
              CheckInBulletConstant(
                  color: _colorIcon[2],
                  index: 2,
                  key: const Key('index2')),
              CheckInBulletConstant(
                  color: _colorIcon[3],
                  index: 3,
                  key: const Key('index3')),
            ],
          ),
          DigitKeypadConstant(
            onDigitEntered: onHandleDigits,
            buildContext: context,
            key: const Key('enterDigits'),
          ),
        ],
      ),
    );
  }
}
