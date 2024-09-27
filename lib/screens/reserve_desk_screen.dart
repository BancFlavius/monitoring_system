import 'package:ARRK/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/desks_service.dart';
import '../services/office_reservation_firebase_service.dart';
//old
class ReserveDeskScreen extends StatefulWidget {
  final DateTime selectedDate;

  const ReserveDeskScreen({super.key, required this.selectedDate});

  @override
  ReserveDeskScreenState createState() => ReserveDeskScreenState();
}

class ReserveDeskScreenState extends State<ReserveDeskScreen> {
  bool deskReservationIsVisible = false;

  String _selectedDeskToReturn = '';
  String? _selectedRegion;
  int _selectedNrDesk = 0;
  int totalNrOfDesks = 40;
  int totalNrOfDesksReservedForTheSelectedDay = 0;

  List<String> _regions = [];

  Map<int, String> _desksForARegion = {};
  List<String> desksReservedForADay = [];
  Map<String, List<int>> desksReservedForSelectedDay = {};

  @override
  void initState() {
    super.initState();
    _fetchRegions();
    _getDesksReservedForADay();
  }

  Future<void> _fetchRegions() async {
    List<String> regionsAux = await DesksFirebaseService.getDeskRegions();
    setState(() {
      _regions = regionsAux;
    });
  }

  Future<void> _fetchDeskNumbersForaRegion(String regionParam) async {
    Map<int, String> deskMap =
        await DesksFirebaseService.getMapNrAndStatusForARegion(regionParam);
    if (desksReservedForSelectedDay[regionParam] != null) {
      for (int reservedNr in desksReservedForSelectedDay[regionParam]!) {
        deskMap[reservedNr] = 'RESERVED';
      }
    }
    setState(() {
      _desksForARegion = deskMap;
    });
  }

  Future<void> _getDesksReservedForADay() async {
    desksReservedForADay =
        await OfficeReservationFirebaseService.getDesksReservationForADay(
            widget.selectedDate);
    _removeReservedSpots();
  }

  void _removeReservedSpots() {
    Map<String, List<int>> deskNumbersAux = {};
    for (String deskReservedSpot in desksReservedForADay) {
      String deskReservedSpotKey = deskReservedSpot.split('_')[0];
      int reservedDeskNumber = int.parse(deskReservedSpot.split('_')[1]);
      deskNumbersAux[deskReservedSpotKey] ??=
          []; // Create an empty list if the key doesn't exist
      deskNumbersAux[deskReservedSpotKey]!.add(reservedDeskNumber);
    }
    setState(() {
      totalNrOfDesksReservedForTheSelectedDay = desksReservedForADay.length;
      desksReservedForSelectedDay = deskNumbersAux;
    });
  }

  void _returnFunction() {
    //Navigator.pop(context, '${_selectedRegion}_$_selectedNumberParkingSpot');
    Navigator.pop(context, _selectedDeskToReturn);
  }

  void _showImagePopup(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Image.asset(imagePath),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String selectedDate = DateFormat('dd/MM/yyyy').format(widget.selectedDate);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserve Desk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selected Date: ${selectedDate.toString()}'),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Region'),
                key: const Key('chooseDeskRegion'),
                value: _selectedRegion,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRegion = newValue;
                    _selectedNrDesk = 0;
                  });
                  _fetchDeskNumbersForaRegion(_selectedRegion!);
                },
                items: _regions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: GridView.builder(
                  shrinkWrap: true,
                  //physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: _desksForARegion.length,
                  itemBuilder: (context, index) {
                    int number = _desksForARegion.keys.elementAt(index);
                    String? status = _desksForARegion[number];
                    Color color;
                    if (status == 'AVAILABLE') {
                      color = Colors.green.shade800;
                    } else if (status == 'BLOCKED') {
                      color = Colors.red.shade800;
                    } else if (status == 'RESERVED') {
                      color = Colors.purple.shade600;
                    } else {
                      color = Colors.grey;
                    }
                    if (_selectedNrDesk == number) {
                      color = Colors.yellow.shade800;
                    }
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedNrDesk == number) {
                            _selectedNrDesk = 0;
                            _selectedDeskToReturn =
                                'Please select an available desk.';
                          } else if (status == 'AVAILABLE') {
                            _selectedNrDesk = number;
                            _selectedDeskToReturn =
                                '${_selectedRegion}_$_selectedNrDesk';
                          } else if (status == 'RESERVED') {
                            _selectedNrDesk = 0;
                            _selectedDeskToReturn = 'This desk is reserved.';
                          } else {
                            _selectedNrDesk = 0;
                            _selectedDeskToReturn = 'This desk is blocked.';
                          }
                        });
                      },
                      behavior: status == 'AVAILABLE'
                          ? HitTestBehavior.opaque
                          : HitTestBehavior.translucent,
                      child: Container(
                        color: color,
                        child: Center(
                          child: Text('$number'),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  const Text('Nr desk reserved:'),
                  Text(
                    //'${_selectedRegion}_$_selectedNumberParkingSpot',
                    _selectedDeskToReturn,
                    style: TextStyle(
                        color: _selectedNrDesk == 0
                            ? Colors.yellowAccent
                            : AppColors.kBlueColor),
                  ),
                ],
              ),
              IgnorePointer(
                ignoring: _selectedNrDesk == 0,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (_selectedNrDesk == 0) {
                          return Colors.grey;
                        } else {
                          return Colors.blueAccent;
                        }
                      },
                    ),
                  ),
                  onPressed: _returnFunction,
                  key: const Key('confirmButtonDesk'),
                  child: const Text('Confirm desk'),
                ),
              ),
              Row(
                children: [
                  const Text('Total number of desks: '),
                  Text(
                    '$totalNrOfDesks',
                    style: const TextStyle(color: AppColors.kBlueColor),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                      'Total number of desks reserved for selected date:'),
                  Text(
                    '$totalNrOfDesksReservedForTheSelectedDay',
                    style: const TextStyle(color: AppColors.kBlueColor),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Text('For ARRK at 5th floor we have 3 regions: '
                  '\n Lab: located in your left when you look at the tablet'
                  '\n Common: located in the back of the tablet '
                  '\n Experts: located in the back of the tablet at the end'),
              ElevatedButton(
                  onPressed: () {
                    _showImagePopup('images/desk_reservation.png');
                  },
                  key: const Key('showDeskRegions'),
                  child: const Text('Show desk regions')),
              const Text(
                  style: TextStyle(color: Colors.yellowAccent),
                  'Observation: Keep the desk clean as possible.'),
            ],
          ),
        ),
      ),
    );
  }
}
