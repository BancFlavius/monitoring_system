import 'package:ARRK/tabs/reservationSteps/reservation_manager.dart';
import 'package:flutter/material.dart';

import '../../constants/constants.dart';
import '../../models/employee.dart';
import '../../services/employee_firebase_service.dart';
import '../../widgets/digit_keypad_constant.dart';
import '../../widgets/digit_keypad_office_reservation.dart';

class Step1Identify extends StatefulWidget {
  final ReservationManager reservationManager;
  final Function(String, String, bool) onEmployeeInserted;

  const Step1Identify(
      {super.key,
      required this.reservationManager,
      required this.onEmployeeInserted});

  @override
  State<Step1Identify> createState() => Step1IdentifyState();
}

class Step1IdentifyState extends State<Step1Identify> {
  String _codeStatus = 'Insert Code';
  late String _employeeName;
  late String _employeeCode;
  late bool _verifyEmployeeCode;

  @override
  void initState() {
    _employeeName = widget.reservationManager.employeeName;
    _employeeCode = widget.reservationManager.employeeCode;
    _verifyEmployeeCode = widget.reservationManager.verifyEmployeeCode;
    super.initState();
  }

  Future<void> _confirmCode() async {
    Employee? employee =
        await EmployeeFirebaseService.getEmployeeByCode(_employeeCode);
    if (employee != null) {
      setState(() {
        _employeeName = employee.name;
        _codeStatus = 'Code confirmed $_employeeName';
        _verifyEmployeeCode = true;
      });
    } else {
      setState(() {
        _codeStatus = 'Code wrong';
        _employeeCode = '';
        _employeeName = '';
        _verifyEmployeeCode = false;
      });
    }
    DigitKeypadOfficeReservation.enteredDigits = '';
    DigitKeypadConstant.enteredDigits = '';
    widget.onEmployeeInserted(
        _employeeName, _employeeCode, _verifyEmployeeCode);
  }

  // void _cancelCode() async {
  //   resetAttributes();
  //   widget.onEmployeeInserted(
  //       _employeeName, _employeeCode, _verifyEmployeeCode);
  // }

  void resetAttributes() {
    setState(() {
      _employeeName = '';
      _employeeCode = '';
      _codeStatus = 'Code cleared';
      _verifyEmployeeCode = false;
    });
    widget.onEmployeeInserted(
        _employeeName, _employeeCode, _verifyEmployeeCode);
  }

  Future<void> handleDigitsReservation(String digits) async {
    setState(() {
      _employeeCode = digits;
    });
    if (digits.length == 4) {
      await _confirmCode();
    }
  }
  Future<void> handleDigitsReservationConstant({required BuildContext context,required String digits}) async {
    setState(() {
      _employeeCode = digits;
    });
    if (digits.length == 4) {
      await _confirmCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    bool isBigWidth = screenSize.width > 600;
    return Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(12.0), // Adjust the radius for desired roundness
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.grey,//.withOpacity(0.5), // Adjust the color and opacity of the shadow
      //       spreadRadius: 5,
      //       blurRadius: 7,
      //       offset: Offset(0, 3), // Adjust the position of the shadow
      //     ),
      //   ],
      //   border: Border.all(
      //     color: Colors.grey, // Adjust the color of the border
      //     width: 1, // Adjust the width of the border
      //   ),
      // ),
      width: isBigWidth?600:screenSize.width / 1.2,
      height:
          _verifyEmployeeCode ?
          (isBigWidth?200:screenSize.height / 6 ):
          (isBigWidth?500:screenSize.height / 1.7),
      color: Colors.grey.shade700,
      child: Column(
        children: [
          if (_verifyEmployeeCode == false)
          SizedBox(height: isBigWidth?12:screenSize.height *0.03,),
          if (_verifyEmployeeCode == false &&isBigWidth==false)
            DigitKeypadOfficeReservation(
              onDigitEntered: handleDigitsReservation,
              screenWidth: screenSize.width / 1.2,
              screenHeight: screenSize.height,
            ),
          if (_verifyEmployeeCode == false &&isBigWidth==true)
            DigitKeypadConstant(
              onDigitEntered: handleDigitsReservationConstant, buildContext: context,
            ),
          Text(
            'Code entered: $_employeeCode',
            style: TextStyle(fontSize: isBigWidth?12:screenSize.width / 25),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_verifyEmployeeCode)
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        AppColors.kRed800Color),
                  ),
                  onPressed: () {
                    resetAttributes();
                  },
                  child: Text(
                    'Cancel code',
                    style: TextStyle(fontSize: isBigWidth?12:screenSize.width / 20),
                  ),
                ),
            ],
          ),
          //const SizedBox(height: 6.0),
          Text(
            _codeStatus,
            style: TextStyle(
                color: _verifyEmployeeCode
                    ? Colors.blueAccent
                    : Colors.yellow.shade600,
                fontSize: isBigWidth?12:screenSize.width / 25),
          ),
        ],
      ),
    );
  }
}
