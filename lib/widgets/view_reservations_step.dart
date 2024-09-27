import 'package:ARRK/constants/constants.dart';
import 'package:ARRK/models/step_office_one_reservation_model.dart';
import 'package:ARRK/services/step_office_reservation_firebase_service.dart';
import 'package:flutter/material.dart';


class ViewReservationsStep extends StatefulWidget {
  final String code;
  final String name;

  const ViewReservationsStep({super.key, required this.code, required this.name});

  @override
  ViewReservationsStepState createState() => ViewReservationsStepState();
}

class ViewReservationsStepState extends State<ViewReservationsStep> {
  List<StepOfficeOneReservationModel> _employeeReservations = [];

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchReservations() async {
    List<StepOfficeOneReservationModel> res =
    await StepOfficeReservationFirebaseService.getEmployeeReservations(employeeCode: widget.code);
    setState(() {
      _employeeReservations = res;
    });
  }
  Future<void> _showStatusSnackbar(String status) async {
    Color? snackBarColor;
    if (status.startsWith('E')) {
      snackBarColor = Colors.red;
    } else if (status.startsWith('R')) {
      snackBarColor = Colors.yellow;
    } else if (status.startsWith('S')) {
      snackBarColor = Colors.blue;
    }

    final snackBar = SnackBar(
      content: Text(status),
      backgroundColor: snackBarColor,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  Future<void> _removeEmployeeFromReservation(String selectedDate) async {
    String status=await StepOfficeReservationFirebaseService.removeEmployeeFromReservation(employeeCode: widget.code, date: selectedDate);
    await _fetchReservations();
    _showStatusSnackbar(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Reservations for ${widget.name} : ${_employeeReservations.length}'),
      ),
      body: _employeeReservations.length != 0
          ? ListView.builder(
        itemCount: _employeeReservations.length,
        itemBuilder: (context, index) {
          StepOfficeOneReservationModel stepOfficeOneReservationModel = _employeeReservations[index];
          return buildReservationCard(stepOfficeOneReservationModel);
        },
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

  Card buildReservationCard(StepOfficeOneReservationModel stepOfficeOneReservationModel) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stepOfficeOneReservationModel.date,
              style: TextStyle(color: AppColors.kBlueColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Desk: ${stepOfficeOneReservationModel.employeeDesk}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              'Number of Reservations: ${stepOfficeOneReservationModel.nrOfReservationsForThisDate}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _removeEmployeeFromReservation(stepOfficeOneReservationModel.date);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kRed800Color,
              ),
              child: Text('Delete Reservation'),
            ),
          ],
        ),
      ),
    );
  }
}
/*
return ListTile(
            title: Text(
              stepOfficeOneReservationModel.date,
              style: const TextStyle(color: AppColors.kBlueColor),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'desk: ${stepOfficeOneReservationModel.employeeDesk}',
                ),
                Text(
                    'nrOfReservations: ${stepOfficeOneReservationModel.nrOfReservationsForThisDate}'),
                ElevatedButton(
                  onPressed: () {
                    _removeEmployeeFromReservation(stepOfficeOneReservationModel.date);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kRed800Color,
                  ),
                  child: Text('Delete Reservation'),
                ),
                Divider(
                  color: Colors.grey, // Customize the color of the line
                  thickness: 2, // Customize the thickness of the line
                  height:
                  10, // Customize the vertical space around the line
                )
              ],
            ),
          );
 */