import 'package:ARRK/tabs/reservationSteps/reservation_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/constants.dart';
import '../../services/step_office_reservation_firebase_service.dart';
import '../../widgets/fancy_button.dart';
import '../../widgets/view_reservations_step.dart';

class Step2Date extends StatefulWidget {
  final ReservationManager reservationManager;
  final Function(DateTime,bool) onDateSelected;

  const Step2Date(
      {super.key,
      required this.reservationManager,
      required this.onDateSelected});

  @override
  State<Step2Date> createState() => Step2DateState();
}

class Step2DateState extends State<Step2Date> {
  late DateTime _selectedDate;
  late bool _verifySelectedDate;
  bool _moreInfo=false;
  late double _containerHeight;

  @override
  void initState() {
    _selectedDate = widget.reservationManager.selectedDate;
    _verifySelectedDate = widget.reservationManager.verifySelectedDate;

    super.initState();
  }

  void _showDatePicker(Size screenSize) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
      builder: (BuildContext context, Widget? child) {
        return SizedBox(
          height: 800,
          width: screenSize.width / 1.3,
          child: child,
        );
      },
    ).then((value) async {
      if (value != null) {
        setState(() {
          _selectedDate = value;
        });
        await _doesEmployeeHaveReservation();
        widget.onDateSelected(_selectedDate,_verifySelectedDate);
      }
    });
  }
  Future<void> _doesEmployeeHaveReservation() async {
    bool hasReservation = await StepOfficeReservationFirebaseService.doesEmployeeHaveReservation(
      employeeCode: widget.reservationManager.employeeCode,
      selectedDate: _selectedDate,
    );
    setState(() {
      _verifySelectedDate=!hasReservation;
    });
  }

  void resetAttributes() {
    setState(() {
      _selectedDate = DateTime.now();
      _verifySelectedDate = false;
    });
    widget.onDateSelected(_selectedDate,_verifySelectedDate);
  }
  String validDate() {
    if(_verifySelectedDate ==false) {
      DateTime nowi=DateTime.now();
      if(_selectedDate.day == nowi.day &&_selectedDate.month == nowi.month && _selectedDate.year == nowi.year) {
        return 'NOT';
      }
    }
    return DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    bool isBigWidth = screenSize.width > 600;
    _containerHeight= _moreInfo?
      _containerHeight:
     (isBigWidth?200:screenSize.height / 5);
    return Container(
      width: screenSize.width / 1.2,
      height: _containerHeight,
      color: Colors.grey.shade700,
      child: Column(
        children: [
          SizedBox(
            height: screenSize.height / 100,
          ),
          // Text(
          //   validDate(),
          //   style: TextStyle(fontSize: screenSize.width / 22),
          // ),
          FancyButton(
            key: const Key('chooseDate'),
            onPressed: () {_showDatePicker(screenSize);},
            text: 'Choose Date',
            fontSize: isBigWidth?20:screenSize.width * 0.05,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            borderColor: Colors.lightBlueAccent,
            borderWidth: 4,
          ),
          if (_verifySelectedDate)
            Icon(
              Icons.done,
              color: Colors.blueAccent,
              size: isBigWidth?20:screenSize.width / 15,
            ),
          if (_verifySelectedDate == false)

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Choose a date when you do not have a reservation',
                  style: TextStyle(color: AppColors.kYellowColor,fontSize: isBigWidth?12:screenSize.width /31),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _containerHeight = screenSize.height/3;
                      _moreInfo = !_moreInfo;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'More info ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                            fontSize: isBigWidth?12:screenSize.width / 50
                        ),
                      ),
                      Icon(
                        _moreInfo
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: isBigWidth?12:screenSize.width / 50,
                      ),
                    ],
                  ),
                ),
                if(_moreInfo)
                Column(
                  children: [
                    Text('Select a date.'),
                    Text('If you can see the selected date and can not go next, then you have a reservation on this date.'),
                    Text('Select another date, when you do not have a reservation.'),
                    //Text('View reservations for ${widget.reservationManager.employeeName}'),
                    //ElevatedButton(onPressed: _viewReservations, child: Text('Here')),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
