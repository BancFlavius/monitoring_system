import 'package:ARRK/constants/constants.dart';
import 'package:ARRK/screens/add_employee_screen.dart';
import 'package:ARRK/widgets/digit_keypad_office_reservation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/employee.dart';
import '../models/office_reservation.dart';
import '../screens/reserve_desk_screen.dart';
import '../screens/reserve_parking_spot_screen.dart';
import '../services/employee_firebase_service.dart';
import '../services/office_reservation_firebase_service.dart';
import '../widgets/digit_keypad.dart';
import '../widgets/view_reservations.dart';
import 'check_in_tab.dart';

class OfficeReservationTab extends StatefulWidget {
  const OfficeReservationTab({super.key});

  @override
  OfficeReservationTabState createState() => OfficeReservationTabState();
}

class OfficeReservationTabState extends State<OfficeReservationTab> {
  String _digitsEntered = '';

  String _selectedSection = '5';
  DateTime _selectedDate = DateTime.now();
  String _employeeCode = '';
  String _employeeName = '';
  String _codeStatus = 'Insert code';
  int _numberOfReservations = 0;
  bool _enableConfirmReservation = false;
  bool _verifyFloorAndDate = true;
  bool _verifyCode = false;
  bool _verifyNotHavingReservationOnThatDay = false;
  bool _reserveParking = false;
  String _nrParkingSpot = 'NOT';
  final TextEditingController _reservationCodeController =
      TextEditingController();
  bool _reserveDeskFlag = false;
  String _nrDesk = 'NOT';

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedDate = value;
          _nrParkingSpot = 'NOT';
          _reserveParking = false;
          _nrDesk = 'NOT';
          _reserveDeskFlag = false;
        });
        _fetchNumberOfReservations();
        _fetchEnableConfirmReservation();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    CheckInTabState.clearDigits();
    _fetchNumberOfReservations();
  }

  Future<void> _fetchNumberOfReservations() async {
    int nrOfReservations =
        await OfficeReservationFirebaseService.getReservationCountForDay(
            _selectedSection, _selectedDate);
    if (mounted) {
      setState(() {
        _numberOfReservations = nrOfReservations;
      });
    }
  }

  Future<void> _fetchEnableConfirmReservation() async {
    if (_employeeCode == '') {
      setState(() {
        _enableConfirmReservation = false;
      });
    } else {
      bool hasReservationOnDay =
          await OfficeReservationFirebaseService.hasReservationOnDay(
              _employeeCode, _selectedDate);
      setState(() {
        _verifyNotHavingReservationOnThatDay = !hasReservationOnDay;
        _enableConfirmReservation = _verifyNotHavingReservationOnThatDay &&
            _verifyCode &&
            _verifyFloorAndDate &&
            _reserveDeskFlag;
      });
    }
  }

  Future<void> _confirmReservation() async {
    // Implement logic to confirm reservation based on selectedSection and selectedDate
    await OfficeReservationFirebaseService.addReservation(
        section: _selectedSection,
        date: _selectedDate,
        employeeCode: _employeeCode,
        reserveParking: _reserveParking,
        nrParkingSpot: _nrParkingSpot,
        reserveDesk: _reserveDeskFlag,
        nrDesk: _nrDesk,
        employeeName: _employeeName);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Your reservation was confirmed ' + _employeeName),
            actions: <Widget>[
              TextButton(
                key: Key('confirmedButton'),
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
    _resetAll();
  }

  void _resetAll() {
    setState(() {
      _digitsEntered = '';
      DigitKeypadOfficeReservation.enteredDigits = '';
      _enableConfirmReservation = false;
      _verifyFloorAndDate = true;
      _verifyCode = false;
      _verifyNotHavingReservationOnThatDay = false;
      _employeeName = '';
      _employeeCode = '';
      _codeStatus = 'Insert Code';
      _selectedDate = DateTime.now();
      _reserveParking = false;
      _nrParkingSpot = 'NOT';

      ///update desk
      _nrDesk = 'NOT';
      _reserveDeskFlag = false;
    });
    _reservationCodeController.clear();
    _fetchNumberOfReservations();
  }

  Future<void> _confirmCode() async {
    _employeeCode = _digitsEntered; //_reservationCodeController.text;
    Employee? employee =
        await EmployeeFirebaseService.getEmployeeByCode(_employeeCode);
    if (employee != null) {
      _employeeName = employee.name;
      _codeStatus = 'Code confirmed $_employeeName';
      _verifyCode = true;
    } else {
      _codeStatus = 'Code wrong';
      _employeeCode = '';
      _verifyCode = false;
      _verifyNotHavingReservationOnThatDay = false;
    }
    _digitsEntered = '';
    DigitKeypadOfficeReservation.enteredDigits = '';
    _reservationCodeController.clear();
    FocusScope.of(context).unfocus();
    _fetchEnableConfirmReservation();
  }

  void _reserveParkingSpot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReserveParkingSpotScreen(selectedDate: _selectedDate),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          _nrParkingSpot = result;
          _reserveParking = true;
        });
      }
    });
  }

  void _cancelParkingSpot() {
    setState(() {
      _nrParkingSpot = 'NOT';
      _reserveParking = false;
    });
  }

  void _cancelCode() async {
    setState(() {
      _digitsEntered = '';
      _codeStatus = 'Code cleared';
      _employeeCode = '';
      _verifyCode = false;
      _verifyNotHavingReservationOnThatDay = false;
      _reservationCodeController.clear();
    });

    //FocusScope.of(context).unfocus();
    _fetchEnableConfirmReservation();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    bool isBigWidth = screenSize.width>600;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4.0, // Customize the vertical padding
          horizontal: 24.0, // Customize the horizontal padding
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // DropdownButtonFormField<String>(
              //   value: _selectedSection,
              //   onChanged: (value) {
              //     setState(() {
              //       _selectedSection = value!;
              //     });
              //     _fetchNumberOfReservations();
              //   },
              //   items: const [
              //     DropdownMenuItem(
              //       key: Key('selectFloor'),
              //       value: '5',
              //       child: Text('5'),
              //     ),
              //     DropdownMenuItem(
              //       value: '6',
              //       child: Text('6'),
              //     ),
              //     DropdownMenuItem(
              //       value: '7',
              //       child: Text('7'),
              //     ),
              //     DropdownMenuItem(
              //       value: '8',
              //       child: Text('8'),
              //     ),
              //   ],
              //   decoration: const InputDecoration(
              //     labelText:
              //         'Select the floor and the date to make an office Reservation at ARRK: ',
              //   ),
              // ),
              Text(
                'Number of reservations for the date selected: $_numberOfReservations',
                style: TextStyle(fontSize: screenSize.width / 30),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // buildStepCard("Step 1", "Content for Step 1"),
                  // buildStepCard("Step 2", "Content for Step 2"),
                  Expanded(
                    child: Container(
                      width: screenSize.width / 2.3,
                      height: screenSize.height / 5,
                      color: Colors.grey.shade700,
                      child: Column(
                        children: [
                          Text(
                            'Step 1:',
                            style: TextStyle(fontSize: screenSize.width / 25),
                          ),
                          SizedBox(
                            height: screenSize.height / 100,
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: TextStyle(fontSize: screenSize.width / 22),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _showDatePicker();
                            },
                            key: const Key('chooseDate'),
                            child: Text(
                              'Choose Date',
                              style: TextStyle(
                                  fontSize: screenSize.width /
                                      20), // Adjust the font size as needed
                            ),
                          ),
                          Icon(
                            Icons.done,
                            color: Colors.blueAccent,
                            size: screenSize.width / 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenSize.width / 20,
                  ),
                  Expanded(
                    child: Container(
                        width: screenSize.width / 2.3,
                        height: screenSize.height / 5,
                        color: Colors.grey.shade700,
                        child: Column(
                          children: [
                            Text(
                              'Step 2:',
                              style: TextStyle(fontSize: screenSize.width / 25),
                            ),
                            SizedBox(
                              height: screenSize.height / 100,
                            ),
                            Text(
                              _nrDesk,
                              style: TextStyle(fontSize: screenSize.width / 22),
                            ),
                            if (_reserveDeskFlag == false)
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          AppColors.kBlueColor),
                                ),
                                onPressed: () {
                                  _reserveDesk();
                                },
                                key: const Key('reserveDesk'),
                                child: Text(
                                  'Reserve Desk',
                                  style: TextStyle(
                                      fontSize: screenSize.width /
                                          20), // Adjust the font size as needed
                                ),
                              ),
                            if (_reserveDeskFlag)
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          AppColors.kRed800Color),
                                ),
                                onPressed: () {
                                  _cancelDesk();
                                },
                                key: const Key('cancelDesk'),
                                child: Text(
                                  'CancelDesk',
                                  style: TextStyle(
                                      fontSize: screenSize.width / 20),
                                ),
                              ),
                            if (_reserveDeskFlag)
                              Icon(
                                Icons.done,
                                color: Colors.blueAccent,
                                size: screenSize.width / 15,
                              ),
                            if (_reserveDeskFlag == false)
                              Icon(
                                Icons.cancel,
                                color: AppColors.kRed800Color,
                                size: screenSize.width / 15,
                              ),
                          ],
                        )),
                  ),
                ],
              ),
              //buildStepCard("Step 3", "Content for Step 3"),
              // Text(
              //   _numberOfReservations.toString(),
              //   style: const TextStyle(fontSize: 30, color: Colors.blueAccent),
              // ),
              // Row(
              //   children: [
              //     Theme(
              //       data: ThemeData(
              //         toggleableActiveColor: AppColors.kBlueColor, // Set the desired color for the checkbox
              //       ),
              //       child: Checkbox(
              //         key: const Key('checkBox'),
              //         value: _reserveParking,
              //         onChanged: (value) {
              //           setState(() {
              //             _reserveParking = value!;
              //           });
              //         },
              //       ),
              //     ),
              //     const Text('Reserve Parking Spot'),
              //     const SizedBox(
              //       width: 20,
              //     ),
              //   ],
              // ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     // Column(
              //     //   children: [
              //     //     ElevatedButton(
              //     //       style: ButtonStyle(
              //     //         backgroundColor: MaterialStateProperty.all<Color>(
              //     //             AppColors.kBlueColor),
              //     //       ),
              //     //       onPressed: () {
              //     //         _reserveParkingSpot();
              //     //       },
              //     //       key: const Key('reserveParkingSpot'),
              //     //       child: const Text('Reserve parking spot'),
              //     //     ),
              //     //     const SizedBox(
              //     //       width: 20,
              //     //     ),
              //     //     Text(_nrParkingSpot),
              //     //     const SizedBox(
              //     //       width: 20,
              //     //     ),
              //     //     if (_reserveParking)
              //     //       ElevatedButton(
              //     //         style: ButtonStyle(
              //     //           backgroundColor: MaterialStateProperty.all<Color>(
              //     //               AppColors.kRed800Color),
              //     //         ),
              //     //         onPressed: () {
              //     //           _cancelParkingSpot();
              //     //         },
              //     //         key: const Key('cancelParkingButton'),
              //     //         child: const Text('Cancel parking spot'),
              //     //       ),
              //     //   ],
              //     // ),
              //     SizedBox(
              //       width: 20,
              //     ),
              //     Column(
              //       children: [
              //         ElevatedButton(
              //           style: ButtonStyle(
              //             backgroundColor: MaterialStateProperty.all<Color>(
              //                 AppColors.kBlueColor),
              //           ),
              //           onPressed: () {
              //             _reserveDesk();
              //           },
              //           key: const Key('reserveDesk'),
              //           child: const Text('Reserve desk'),
              //         ),
              //         const SizedBox(
              //           width: 20,
              //         ),
              //         Text(_nrDesk),
              //         const SizedBox(
              //           width: 20,
              //         ),
              //         if (_reserveDeskFlag)
              //           ElevatedButton(
              //             style: ButtonStyle(
              //               backgroundColor: MaterialStateProperty.all<Color>(
              //                   AppColors.kRed800Color),
              //             ),
              //             onPressed: () {
              //               _cancelDesk();
              //             },
              //             key: const Key('cancelDesk'),
              //             child: const Text('CancelDesk'),
              //           ),
              //       ],
              //     )
              //   ],
              // ),
              SizedBox(
                height: screenSize.height / 21,
              ),
              Container(
                width: screenSize.width / 1.3,
                height:
                    _verifyCode ? screenSize.height / 6 : screenSize.height / 2,
                color: Colors.grey.shade700,
                child: Column(
                  children: [
                    Text(
                      'Step 3:',
                      style: TextStyle(fontSize: screenSize.width / 25),
                    ),
                    if (_verifyCode == false)
                      DigitKeypadOfficeReservation(
                        onDigitEntered: handleDigitsReservation,
                        screenWidth: screenSize.width / 1.2,
                        screenHeight: screenSize.height / 1.2,
                      ),
                    // TextField(
                    //   controller: _reservationCodeController,
                    //   obscureText: true,
                    //   decoration:
                    //   const InputDecoration(labelText: 'Enter 4-digit Code'),
                    //   keyboardType: TextInputType.number,
                    //   maxLength: 4,
                    //   onChanged: (value) {
                    //     if (value.length == 4) {
                    //       _confirmCode();
                    //     }
                    //   },
                    //   key: Key('enterDigitsCode'),
                    // ),
                    Text(
                      'Code entered: $_digitsEntered',
                      style: TextStyle(fontSize: screenSize.width / 25),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ElevatedButton(
                        //   onPressed: () {
                        //     _confirmCode();
                        //   },
                        //   key: const Key('verifyCodeButton'),
                        //   child: const Text('Verify code'),
                        // ),
                        // const SizedBox(
                        //   width: 10,
                        // ),

                        if (_verifyCode)
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  AppColors.kRed800Color),
                            ),
                            onPressed: () {
                              _cancelCode();
                            },
                            child: Text(
                              'Cancel code',
                              style: TextStyle(fontSize: screenSize.width / 20),
                            ),
                          ),
                      ],
                    ),
                    //const SizedBox(height: 6.0),
                    Text(
                      _codeStatus,
                      style: TextStyle(
                          color: _verifyCode
                              ? Colors.blueAccent
                              : Colors.yellow.shade600,
                          fontSize: screenSize.width / 25),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenSize.height / 35,
              ),
              IgnorePointer(
                ignoring: !_enableConfirmReservation,
                child: ElevatedButton(
                  onPressed: () {
                    _confirmReservation();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (_enableConfirmReservation) {
                          return Colors.blue;
                        } else {
                          return Colors.grey;
                        }
                      },
                    ),
                  ),
                  child: Text(
                    'Confirm Reservation',
                    key: Key('confirmResButton'),
                    style: TextStyle(fontSize: screenSize.width / 20),
                  ),
                ),
              ),
              SizedBox(
                height: screenSize.height / 35,
              ),
              Row(
                children: [
                  Text(
                    'In order to confirm a reservation, you need to:',
                    style: TextStyle(fontSize: screenSize.width / 30),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    _verifyFloorAndDate
                        ? Icons.check
                        : Icons.radio_button_unchecked_rounded,
                    color: _verifyFloorAndDate
                        ? Colors.blueAccent
                        : Colors.yellow.shade600,
                    size: screenSize.width / 30,
                  ),
                  Text(
                    'Select the date.',
                    style: TextStyle(
                      color: _verifyFloorAndDate
                          ? Colors.blueAccent
                          : Colors.yellow.shade600,
                      fontSize: screenSize.width / 30,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    _reserveDeskFlag
                        ? Icons.check
                        : Icons.radio_button_unchecked_rounded,
                    color: _reserveDeskFlag
                        ? Colors.blueAccent
                        : Colors.yellow.shade600,
                    size: screenSize.width / 30,
                  ),
                  Text(
                    'Select a desk for that date.',
                    style: TextStyle(
                      color: _reserveDeskFlag
                          ? Colors.blueAccent
                          : Colors.yellow.shade600,
                      fontSize: screenSize.width / 30,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    _verifyCode
                        ? Icons.check
                        : Icons.radio_button_unchecked_rounded,
                    color: _verifyCode
                        ? Colors.blueAccent
                        : Colors.yellow.shade600,
                    size: screenSize.width / 30,
                  ),
                  Text(
                    'Enter your 4-digit identification code',
                    style: TextStyle(
                      color: _verifyCode
                          ? Colors.blueAccent
                          : Colors.yellow.shade600,
                      fontSize: screenSize.width / 30,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    _verifyNotHavingReservationOnThatDay
                        ? Icons.check
                        : Icons.radio_button_unchecked_rounded,
                    color: _verifyNotHavingReservationOnThatDay
                        ? Colors.blueAccent
                        : Colors.yellow.shade600,
                    size: screenSize.width / 30,
                  ),
                  Text(
                    'Do not have another reservation on the same day',
                    style: TextStyle(
                      color: _verifyNotHavingReservationOnThatDay
                          ? Colors.blueAccent
                          : Colors.yellow.shade600,
                      fontSize: screenSize.width / 30,
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: _verifyCode,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewReservations(
                                code: _employeeCode, name: _employeeName),
                          ),
                        );
                      },
                      child: Text(
                        'View Reservations',
                        style: TextStyle(
                          fontSize: screenSize.width / 30,
                        ),
                        key: Key('viewRes'),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      // floatingActionButton: Visibility(
      //   visible: _verifyCode,
      //   child: FloatingActionButton.extended(
      //     onPressed: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) =>
      //               ViewReservations(code: _employeeCode, name: _employeeName),
      //         ),
      //       );
      //     },
      //     //child: Text('View reservations' + _employeeName),
      //     label: const Text(
      //       'View Reservations',
      //       style: TextStyle(fontSize: 16),
      //       key: Key('viewRes'),
      //     ),
      //     icon: const Icon(Icons.calendar_today),
      //     backgroundColor: Colors.blue,
      //     foregroundColor: Colors.white,
      //   ),
      // ),
    );
  }

  void _reserveDesk() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReserveDeskScreen(selectedDate: _selectedDate),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          _nrDesk = result;
          _reserveDeskFlag = true;
        });
        _fetchEnableConfirmReservation();
      }
    });
  }

  void _cancelDesk() {
    setState(() {
      _nrDesk = 'NOT';
      _reserveDeskFlag = false;
    });
  }

  void handleDigitsReservation(String digits) {
    setState(() {
      _digitsEntered = digits;
    });
    if (digits.length == 4) {
      _confirmCode();
    }
  }
}
