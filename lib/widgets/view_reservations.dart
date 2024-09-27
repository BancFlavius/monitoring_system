import 'package:ARRK/constants/constants.dart';
import 'package:ARRK/models/reservation_map_value_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/office_reservation.dart';
import '../services/office_reservation_firebase_service.dart';

class ViewReservations extends StatefulWidget {
  final String code;
  final String name;

  const ViewReservations({super.key, required this.code, required this.name});

  @override
  ViewReservationsState createState() => ViewReservationsState();
}

class ViewReservationsState extends State<ViewReservations> {
  List<OfficeReservation> _officeReservations = [];
  List<ReservationMapValueData> _reservationDetails = [];

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
    //final start = DateTime.now();
    List<OfficeReservation> res =
        await OfficeReservationFirebaseService.getReservationsForAnEmployee(
            widget.code, widget.name);
    setState(() {
      _officeReservations = res;
    });
    //print('1');
    //print('Fetching reservations took: ${DateTime.now().difference(start).inMilliseconds}');
    bool done= await _fetchReservationsDetails();
  }

  Future<bool> _fetchReservationsDetails() async {
    List<ReservationMapValueData> aux = [];
    for (OfficeReservation officeReservation in _officeReservations) {
      ReservationMapValueData reservationMapValueData =
          await OfficeReservationFirebaseService.getEmployeeReservationDetail(
              officeReservation.id, widget.code);
      aux.add(reservationMapValueData);
    }
    setState(() {
      _reservationDetails = aux;
    });
    //print('dfg');
    return true;
  }

  Future<void> _removeEmployeeFromReservation(String reservationId) async {
    await OfficeReservationFirebaseService.removeEmployeeFromReservation(
        reservationId, widget.code);
    await _fetchReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Reservations for ${widget.name} : ${_officeReservations.length}'),
      ),
      body: _reservationDetails.length != 0
          ? ListView.builder(
              itemCount: _officeReservations.length,
              itemBuilder: (context, index) {
                OfficeReservation officeReservation =
                    _officeReservations[index];
                ReservationMapValueData reservationMapValueData =
                    _reservationDetails[index];
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateFormat('dd/MM/yyyy').format(officeReservation.date)} ',
                        style: const TextStyle(color: AppColors.kBlueColor),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'floor: ${officeReservation.section}, ',
                              ),
                              Text(
                                'parkingSpot: ${reservationMapValueData.parkingSpotReservation}, ',
                              ),
                              Text(
                                'desk: ${reservationMapValueData.deskReservation}',
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'nrOfReservations: ${officeReservation.numberOfReservations}'),
                              Text(
                                  'nrOfParkingSpotsReserved: ${officeReservation.numberOfParkingSpotsReserved}'),
                              Text(
                                  'nrOfDesksReserved: ${officeReservation.numberOfDesksReserved}'),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _removeEmployeeFromReservation(officeReservation.id);
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
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.kRed800Color,
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
