import 'package:ARRK/services/copy_and_delete_documents.dart';
import 'package:ARRK/services/step_office_reservation_firebase_service.dart';
import 'package:ARRK/tabs/reservationSteps/reservation_manager.dart';
import 'package:ARRK/tabs/reservationSteps/step1_identify.dart';
import 'package:ARRK/tabs/reservationSteps/step2_date.dart';
import 'package:ARRK/tabs/reservationSteps/step3_desk.dart';
import 'package:ARRK/tabs/reservationSteps/step4_confirm.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../globals/gloabls.dart';
import '../widgets/fancy_button.dart';
import '../widgets/view_reservations_step.dart';

class StepOfficeReservationTab extends StatefulWidget {
  const StepOfficeReservationTab({super.key});

  @override
  StepOfficeReservationTabState createState() =>
      StepOfficeReservationTabState();
}

class StepOfficeReservationTabState extends State<StepOfficeReservationTab> {
  GlobalKey<Step1IdentifyState> step1IdentifyKey = GlobalKey<Step1IdentifyState>();
  GlobalKey<Step2DateState> step2DateKey = GlobalKey<Step2DateState>();
  GlobalKey<Step3DeskState> step3DeskKey = GlobalKey<Step3DeskState>();

  ReservationManager reservationManager=ReservationManager();
  int currentStep = 0;
  bool _verifyReservation = false;

  @override
  void initState() {
    _resetAll();
    super.initState();
  }

  continueStep() {
    if (currentStep < 3) {
      if (currentStep == 2) {
        _onVerifyReservation();
      }
      setState(() {
        currentStep = currentStep + 1;
      });
    }
  }

  cancelStep() {
    if (currentStep > 0) {
      if(currentStep == 1) {
        step2DateKey.currentState?.resetAttributes();

      } else if(currentStep == 2) {
        step3DeskKey.currentState?.resetAttributes();
      }
      setState(() {
        currentStep = currentStep - 1;
      });
    }
  }

  onStepTapped(int value) {
    if(value==0) {
      step2DateKey.currentState?.resetAttributes();
      step3DeskKey.currentState?.resetAttributes();
    } else if(value==1) {
      step3DeskKey.currentState?.resetAttributes();
    }
    setState(() {
      currentStep = value;
    });
  }

  Widget controlBuilders(context, details) {
    final Size screenSize = MediaQuery.of(context).size;
    bool isBigWidth = screenSize.width>600;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          //Expanded(child: Text('${reservationManager.toString()}')),
          if (currentStep == 0)
            IgnorePointer(
              ignoring: !reservationManager.verifyEmployeeCode,
              child: ElevatedButton(
                onPressed: details.onStepContinue,
                style: ButtonStyle(
                  backgroundColor: reservationManager.verifyEmployeeCode
                      ? MaterialStateProperty.all(Colors.blue)
                      : MaterialStateProperty.all(Colors.grey),
                ),
                child: Text('Next',style: TextStyle(fontSize: isBigWidth?12:screenSize.width /24,color: Colors.white),),
              ),
            ),
          if (currentStep == 1)
            IgnorePointer(
              ignoring: !reservationManager.verifySelectedDate,
              child: ElevatedButton(
                onPressed: details.onStepContinue,
                style: ButtonStyle(
                  backgroundColor: reservationManager.verifySelectedDate
                      ? MaterialStateProperty.all(Colors.blue)
                      : MaterialStateProperty.all(Colors.grey),
                ),
                child: Text('Next',style: TextStyle(fontSize: isBigWidth?12:screenSize.width /24,color: Colors.white),),
              ),
            ),
          if (currentStep == 2)
            IgnorePointer(
              ignoring: !reservationManager.verifyEmployeeDesk,
              child: ElevatedButton(
                onPressed: details.onStepContinue,
                style: ButtonStyle(
                  backgroundColor: reservationManager.verifyEmployeeDesk
                      ? MaterialStateProperty.all(Colors.blue)
                      : MaterialStateProperty.all(Colors.grey),
                ),
                child: Text('Next',style: TextStyle(fontSize: isBigWidth?12:screenSize.width /24,color: Colors.white),),
              ),
            ),
          if (currentStep == 3)
            IgnorePointer(
              ignoring: !_verifyReservation,
              child: FancyButton(
                onPressed: confirmReservation,
                text: 'Confirm Reservation',
                fontSize: isBigWidth?12:screenSize.width /24,
                backgroundColor: _verifyReservation?Colors.blue:Colors.grey,
                textColor: Colors.white,
                borderColor: Colors.lightBlueAccent,
                borderWidth: 4,
              ),
              // child: ElevatedButton(
              //   onPressed: confirmReservation,
              //   style: ButtonStyle(
              //     backgroundColor: _verifyReservation
              //         ? MaterialStateProperty.all(Colors.blue)
              //         : MaterialStateProperty.all(Colors.grey),
              //   ),
              //   child: Text('Confirm Reservation',style: TextStyle(fontSize: screenSize.width /24),),
              // ),
            ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: details.onStepCancel,
            child: Text('Back',style: TextStyle(fontSize: isBigWidth?12:screenSize.width /24,color: Colors.white),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    bool isBigWidth = screenSize.width>600;
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Office Reservation'),
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stepper(
              controlsBuilder: controlBuilders,
              type: StepperType.vertical,
              physics: const ScrollPhysics(),
              onStepTapped: onStepTapped,
              onStepContinue: continueStep,
              onStepCancel: cancelStep,
              currentStep: currentStep,
              //0, 1, 2
              connectorColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                return states.contains(MaterialState.disabled)
                    ? Colors.grey
                    : Colors.blueAccent;
              }),
              steps: [
                Step(
                    title: Text('Step 1: Identity: ${reservationManager.employeeName}',style: TextStyle(fontSize: isBigWidth?12:screenSize.width /24),),
                    content: Step1Identify(
                      key: step1IdentifyKey,
                      reservationManager: reservationManager,
                      onEmployeeInserted: _onEmployeeInserted,
                    ),
                    isActive: currentStep >= 0,
                    state:
                        currentStep >= 0 ? StepState.complete : StepState.disabled),
                Step(
                  title: Text('Step 2: Date: ${validDate()}',style: TextStyle(fontSize: isBigWidth?12:screenSize.width /24),),
                  content: Step2Date(
                    key: step2DateKey,
                    reservationManager: reservationManager,
                    onDateSelected: _onDateSelected,
                  ),
                  isActive: currentStep >= 0,
                  state: currentStep >= 1 ? StepState.complete : StepState.disabled,
                ),
                Step(
                  title: Text('Step 3: Desk: ${reservationManager.employeeDesk}',style: TextStyle(fontSize: isBigWidth?12:screenSize.width /24),),
                  content: Step3Desk(
                    key: step3DeskKey,
                    reservationManager: reservationManager,
                    onDeskSelected: _onDeskSelected,
                  ),
                  isActive: currentStep >= 0,
                  state: currentStep >= 2 ? StepState.complete : StepState.disabled,
                ),
                Step(
                  title: Text('Confirm',style: TextStyle(fontSize: isBigWidth?12:screenSize.width /24),),
                  content: Step4Confirm(
                    reservationManager: reservationManager,
                  ),
                  isActive: currentStep >= 0,
                  state: currentStep >= 3 ? StepState.complete : StepState.disabled,
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton:
          Visibility(
            visible: reservationManager.verifyEmployeeCode,
            child: FancyButton(
              key: const Key('view Reservations'),
              onPressed: _viewReservations,
              text: 'View Reservations',
              fontSize: isBigWidth?12:screenSize.width * 0.05,
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              borderColor: Colors.lightBlueAccent,
              borderWidth: 4,
            ),
          ),
    );
  }
  Future<void> _updateDoc() async{
    await CopyAndDeleteDocuments.copyAndDeleteDocument();
  }
  String validDate() {
    if(reservationManager.verifySelectedDate == false) {
      return 'NOT';
    } else {
      return DateFormat('dd/MM/yyyy').format(reservationManager.selectedDate);
    }
  }
  void _viewReservations() {
    //_updateDoc();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewReservationsStep(
            code: reservationManager.employeeCode, name: reservationManager.employeeName
        ),
      ),
    );
  }

  void _resetAll() {
    // setState(() {
    //   reservationManager.selectedDate = DateTime.now();
    //   reservationManager.employeeCode = '';
    //   reservationManager.employeeDesk = 'NOT';
    //   reservationManager.employeeName = '';
    //   reservationManager.verifyEmployeeCode = false;
    //   reservationManager.verifyEmployeeDesk = false;
    //   reservationManager.verifySelectedDate = false;
    // });
    setState(() {
      currentStep = 0;
    });
    step1IdentifyKey.currentState?.resetAttributes();
    step2DateKey.currentState?.resetAttributes();
    step3DeskKey.currentState?.resetAttributes();
  }

  Future<void> confirmReservation() async {
    await StepOfficeReservationFirebaseService.addReservationToFirebase(
        reservationDate: reservationManager.selectedDate,
        employeeCode: reservationManager.employeeCode,
        employeeDesk: reservationManager.employeeDesk);
    showSuccessDialog();
    _resetAll();
  }

  void showSuccessDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: Text('Your reservation was confirmed ${reservationManager.employeeName}'),
            actions: <Widget>[
              TextButton(
                key: const Key('confirmedButton'),
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _onDateSelected(DateTime dateTimeArgument,bool verified) {
    setState(() {
      reservationManager.verifySelectedDate = verified;
      reservationManager.selectedDate = dateTimeArgument;
    });
    if(verified) {
      setState(() {
        currentStep ++;
      });
    }
  }

  void _onEmployeeInserted(String name, String code, bool verified) {
    setState(() {
      reservationManager.employeeName = name;
      reservationManager.employeeCode = code;
      reservationManager.verifyEmployeeCode = verified;
    });
    if(verified) {
      setState(() {
        currentStep ++;
      });
    }
  }

  void _onDeskSelected(String desk, bool verified) {
    setState(() {
      reservationManager.employeeDesk = desk;
      reservationManager.verifyEmployeeDesk = verified;
    });
    if(verified) {
      setState(() {
        currentStep ++;
      });
      _onVerifyReservation();
    }
  }

  void _onVerifyReservation() {
    setState(() {
      _verifyReservation = reservationManager.verifyEmployeeCode &&
          reservationManager.verifySelectedDate &&
          reservationManager.verifyEmployeeDesk ;//&&
          //Globals.connectedToInternet;
    });
  }
}
