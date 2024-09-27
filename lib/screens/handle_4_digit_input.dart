import 'dart:async';

import 'package:ARRK/constants/constants.dart';
import 'package:ARRK/widgets/fancy_button.dart';
import 'package:flutter/material.dart';

import '../models/employee.dart';
import '../services/employee_firebase_service.dart';
import '../services/global_settings_firebase_service.dart';
import '../tabs/check_in_tab.dart';
import '../widgets/view_reservations_step.dart';

class Handle4DigitInput extends StatefulWidget {
  final String employeeCode;

  const Handle4DigitInput({super.key, required this.employeeCode});

  @override
  State<Handle4DigitInput> createState() => Handle4DigitInputState();
}

class Handle4DigitInputState extends State<Handle4DigitInput> {
  bool _verifiedEmployee = false;
  bool _isLoading = true;
  bool _checkInEnable=true;
  bool _welcome = false;
  late Employee _employee;
  late Timer _timer;
  bool _viewReservationsPressed = false;

  @override
  void initState() {
    CheckInTabState.clearDigits();
    super.initState();
    _fetchEmployee();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _fetchEmployee() async {
    bool verifyCheckInEnabled = await GlobalSettingsFirebaseService.getCheckInEnabled();
    if(verifyCheckInEnabled) {
      setState(() {
        _checkInEnable=true;
      });
      Employee? fetchedEmployee =
      await EmployeeFirebaseService.getEmployeeByCode(widget.employeeCode);
      if (fetchedEmployee != null) {
        setState(() {
          _employee = fetchedEmployee;
          _verifiedEmployee = true;
        });
        await _updateEmployeeStatus();
      } else {
        setState(() {
          _verifiedEmployee = false;
        });
      }
    } else {
      setState(() {
        _checkInEnable=false;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 10), () {
      if (!_viewReservationsPressed) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _updateEmployeeStatus() async {
    if (_employee.isInOffice) {
      // Employee is checked in  => we will check him out
      await EmployeeFirebaseService.updateEmployeeIsInOfficeAutomatized(
          employeeId: _employee.id, newIsInOffice: false);
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checked out with success')));
    } else {
      // Employee is not checked in => we will check him in
      await EmployeeFirebaseService.updateEmployeeIsInOfficeAutomatized(
          employeeId: _employee.id, newIsInOffice: true);
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checked in with success')));
    }
    setState(() {
      _welcome = !_employee.isInOffice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    bool isBigWidth= screenSize.width > 600;
    return Scaffold(
      appBar: AppBar(title: Text('Employee Details')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : // Display loading indicator while fetching employee:
          Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_checkInEnable && _verifiedEmployee)
                    verifiedEmployee(screenSize,isBigWidth),
                  if(_checkInEnable && _verifiedEmployee==false)
                    wrongCode(screenSize,isBigWidth),
                  if(!_checkInEnable)
                    wrongTime(screenSize, isBigWidth),
                  SizedBox(height: isBigWidth?10:screenSize.height * 0.1),
                  Text(
                    'This page will close in 10 seconds',
                    style: TextStyle(fontSize: isBigWidth?12:screenSize.width * 0.03),
                  ),
                  SizedBox(height: isBigWidth?10:screenSize.height * 0.1),
                  FancyButton(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'Go back',
                    fontSize: isBigWidth?14:screenSize.width * 0.07,
                    backgroundColor: AppColors.kRed800Color,
                    textColor: Colors.white,
                    borderColor: Colors.redAccent,
                    borderWidth: 4,
                  ),
                ],
              ),
            ),
    );
  }
  Text wrongCode(Size screenSize,bool isBigWidth) {
    return Text(
      'This code: ${widget.employeeCode} is wrong.',
      style: TextStyle(fontSize: isBigWidth?14:screenSize.width * 0.07,color: AppColors.kYellowColor),
    );
  }
  Text wrongTime(Size screenSize,bool isBigWidth) {
    return Text(
      'You can only check in between 7:00 and 20:30',
      style: TextStyle(fontSize: isBigWidth?14:screenSize.width * 0.07,color: AppColors.kYellowColor),
    );
  }

  Widget verifiedEmployee(Size screenSize,bool isBigWidth) {
    return Column(
      children: [
        if (_welcome)
          Text(
            'Hi, ${_employee.name}',
            style: TextStyle(fontSize: isBigWidth?14:screenSize.width * 0.07),
          ),
        if (_welcome)
          Text(
            'Checked in with success.',
            style: TextStyle(fontSize: isBigWidth?13:screenSize.width * 0.04),
          ),
        if (!_welcome)
          Text(
            'Good bye, ${_employee.name}',
            style: TextStyle(fontSize: isBigWidth?14:screenSize.width * 0.07),
          ),
        if (!_welcome)
          Text(
            'Checked out with success.',
            style: TextStyle(fontSize: isBigWidth?13:screenSize.width * 0.04),
          ),
        SizedBox(height: isBigWidth?7:screenSize.height * 0.1),
        // ElevatedButton(
        //   onPressed: () {
        //     setState(() {
        //       _viewReservationsPressed = true;
        //     });
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => ViewReservationsStep(
        //           code: _employee.code,
        //           name: _employee.name,
        //         ),
        //       ),
        //     ).then((_) {
        //       // When returning from ViewReservations screen
        //       setState(() {
        //         _viewReservationsPressed = false;
        //       });
        //       Navigator.of(context).pop();
        //     });
        //   },
        //   child: Text('View Reservations ${_employee.name}'),
        // ),
        FancyButton(
          onPressed: () {
            setState(() {
              _viewReservationsPressed = true;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewReservationsStep(
                  code: _employee.code,
                  name: _employee.name,
                ),
              ),
            ).then((_) {
              // When returning from ViewReservations screen
              setState(() {
                _viewReservationsPressed = false;
              });
              Navigator.of(context).pop();
            });
          },
          text: 'View Reservations ${_employee.name}',
          fontSize: isBigWidth?13:screenSize.width * 0.04,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          borderColor: Colors.blueAccent,
          borderWidth: 4,
        ),
      ],
    );
  }
}
