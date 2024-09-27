import 'package:ARRK/tabs/reservationSteps/reservation_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../globals/gloabls.dart';

class Step4Confirm extends StatefulWidget {
  final ReservationManager reservationManager;

  //final Function(bool) onVerifyReservation;

  const Step4Confirm({super.key, required this.reservationManager});

  //required this.onVerifyReservation});

  @override
  State<Step4Confirm> createState() => Step4ConfirmState();
}

class Step4ConfirmState extends State<Step4Confirm> {
  //late bool _verifyReservation;

  @override
  void initState() {
    // _verifyReservation = widget.reservationManager.verifyEmployeeCode &&
    //     widget.reservationManager.verifySelectedDate &&
    //     widget.reservationManager.verifyEmployeeDesk;
    // widget.onVerifyReservation(_verifyReservation);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
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
              widget.reservationManager.verifyEmployeeCode
                  ? Icons.check
                  : Icons.radio_button_unchecked_rounded,
              color: widget.reservationManager.verifyEmployeeCode
                  ? Colors.blueAccent
                  : Colors.yellow.shade600,
              size: screenSize.width / 30,
            ),
            Text(
              'Enter your 4-digit identification code -> ${widget.reservationManager.employeeCode}',
              style: TextStyle(
                color: widget.reservationManager.verifyEmployeeCode
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
              widget.reservationManager.verifySelectedDate
                  ? Icons.check
                  : Icons.radio_button_unchecked_rounded,
              color: widget.reservationManager.verifySelectedDate
                  ? Colors.blueAccent
                  : Colors.yellow.shade600,
              size: screenSize.width / 30,
            ),
            Text(
              'Select the date. -> ${DateFormat('dd/MM/yyyy').format(widget.reservationManager.selectedDate)}',
              style: TextStyle(
                color: widget.reservationManager.verifySelectedDate
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
              widget.reservationManager.verifyEmployeeDesk
                  ? Icons.check
                  : Icons.radio_button_unchecked_rounded,
              color: widget.reservationManager.verifyEmployeeDesk
                  ? Colors.blueAccent
                  : Colors.yellow.shade600,
              size: screenSize.width / 30,
            ),
            Text(
              'Select a desk for that date. -> ${widget.reservationManager.employeeDesk}',
              style: TextStyle(
                color: widget.reservationManager.verifyEmployeeDesk
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
              Globals.connectedToInternet
                  ? Icons.check
                  : Icons.radio_button_unchecked_rounded,
              color: Globals.connectedToInternet
                  ? Colors.blueAccent
                  : Colors.yellow.shade600,
              size: screenSize.width / 30,
            ),
            Text(
              Globals.connectedToInternet
                  ? 'Connected to Internet'
                  : 'No Internet Connection',
              style: TextStyle(
                color: Globals.connectedToInternet
                    ? Colors.blueAccent
                    : Colors.yellow.shade600,
                fontSize: screenSize.width / 30,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
