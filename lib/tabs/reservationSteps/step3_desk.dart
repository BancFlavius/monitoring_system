import 'package:ARRK/tabs/reservationSteps/reservation_manager.dart';
import 'package:ARRK/tabs/reservationSteps/step3_desk_reserve_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/constants.dart';
import '../../screens/reserve_desk_screen.dart';
import '../../widgets/fancy_button.dart';

class Step3Desk extends StatefulWidget {
  final ReservationManager reservationManager;
  final Function(String, bool) onDeskSelected;

  const Step3Desk(
      {super.key,
      required this.reservationManager,
      required this.onDeskSelected});

  @override
  State<Step3Desk> createState() => Step3DeskState();
}

class Step3DeskState extends State<Step3Desk> {
  late bool _verifyEmployeeDesk;
  late String _employeeDesk;

  @override
  void initState() {
    _employeeDesk = widget.reservationManager.employeeDesk;
    _verifyEmployeeDesk = widget.reservationManager.verifyEmployeeDesk;
    super.initState();
  }

  void _reserveDesk() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => //ReserveDeskScreen(selectedDate: widget.reservationManager.selectedDate),
            Step3DeskReserveScreen(selectedDate: widget.reservationManager.selectedDate),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          _employeeDesk = result;
          _verifyEmployeeDesk = true;
        });
        widget.onDeskSelected(_employeeDesk, _verifyEmployeeDesk);
        //_resetAttributes();
      }
    });
  }

  void resetAttributes() {
    setState(() {
      _employeeDesk = 'NOT';
      _verifyEmployeeDesk = false;
    });
    widget.onDeskSelected(_employeeDesk, _verifyEmployeeDesk);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    bool isBigWidth = screenSize.width > 600;
    return Container(
      width: screenSize.width / 1.2,
      height: isBigWidth?300:screenSize.height / 4,
      color: Colors.grey.shade700,
      child: Column(
        children: [
          Text(
            'Date: ${DateFormat('dd/MM/yyyy').format(widget.reservationManager.selectedDate)}',
            style: TextStyle(fontSize: isBigWidth?20:screenSize.width / 25),
          ),
          SizedBox(
            height: isBigWidth?5:screenSize.height / 100,
          ),
          Text(
            _employeeDesk,
            style: TextStyle(fontSize: isBigWidth?20:screenSize.width / 22),
          ),
          if (_verifyEmployeeDesk == false)
            FancyButton(
              key: const Key('reserveDesk'),
              onPressed: _reserveDesk,
              text: 'Reserve Desk',
              fontSize: isBigWidth?20:screenSize.width / 20,
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              borderColor: Colors.lightBlueAccent,
              borderWidth: 4,
            ),
          if (_verifyEmployeeDesk)
            FancyButton(
              key: const Key('cancelDesk'),
              onPressed: resetAttributes,
              text: 'CancelDesk',
              fontSize: isBigWidth?20:screenSize.width / 20,
              backgroundColor: AppColors.kRed800Color,
              textColor: Colors.white,
              borderColor: Colors.redAccent,
              borderWidth: 4,
            ),
          if (_verifyEmployeeDesk)
            Icon(
              Icons.done,
              color: Colors.blueAccent,
              size: isBigWidth?15:screenSize.width / 15,
            ),
          if (_verifyEmployeeDesk == false)
            Text(
              'Please reserve a desk!',
              style: TextStyle(color: AppColors.kYellowColor,fontSize: isBigWidth?22:screenSize.width /27),
            ),
        ],
      ),
    );
  }
}
