import 'package:ARRK/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/parking_spot.dart';
import '../services/office_reservation_firebase_service.dart';
import '../services/parking_spots_service.dart';


class ReserveParkingSpotScreen extends StatefulWidget {
  final DateTime selectedDate;
  const ReserveParkingSpotScreen({super.key, required this.selectedDate});

  @override
  ReserveParkingSpotScreenState createState() => ReserveParkingSpotScreenState();
}

class ReserveParkingSpotScreenState extends State<ReserveParkingSpotScreen> {
  bool isP1Visible=false;
  bool isP2Visible=false;
  bool isP3Visible=false;

  String _selectedParkingSpotToReturn='';
  String? _selectedRegion;
  int _selectedNumberParkingSpot=0;
  int totalNrOfParkingSlots=88;
  int totalNrOfParkingSlotsReservedForTheSelectedDay=0;

  List<String> _regions=[];

  // Map<String, List<int>> spotNumbers={};
  // late List<ParkingSpot> allParkingSpots;
  Map<int,String> _parkingSpotsForARegion={};
  List<String> parkingSpotsReservedForADay=[];
  Map<String,List<int>> spotNumbersReservedForSelectedDay={};

  @override
  void initState() {
    super.initState();
    _fetchRegions();
    //_fetchSpotNumbers();
    _getParkingSpotsReservedForADay();
  }
  // Future<void> _fetchSpotNumbers() async{
  //   List<ParkingSpot> allParkingSpotsAux = await ParkingSpotsFirebaseService.getParkingSpots();
  //   setState(() {
  //     allParkingSpots=allParkingSpotsAux;
  //     for(ParkingSpot parkingSpot in allParkingSpotsAux) {
  //       String regionToAdd = parkingSpot.region;
  //       List<int> valuesToAdd = parkingSpot.spotNumbers.entries
  //           .where((entry) => entry.value == 'AVAILABLE')
  //           .map((entry) => entry.key)
  //           .toList();
  //       spotNumbers[regionToAdd] = valuesToAdd;
  //     }
  //     print(spotNumbers);
  //   });
  // }
  Future<void> _fetchRegions() async {
    List<String> regionsAux = await ParkingSpotsFirebaseService.getParkingRegions();
    setState(() {
      _regions = regionsAux;
    });
  }

  Future<void> _fetchParkingSpotsForaRegion(String regionParam) async{
    Map<int, String> parkingSpotMap = await ParkingSpotsFirebaseService.getMapNrAndStatusForARegion(regionParam);
    if(spotNumbersReservedForSelectedDay[regionParam] !=null) {
      for(int reservedNr in spotNumbersReservedForSelectedDay[regionParam]!) {
        parkingSpotMap[reservedNr]='RESERVED';
      }
    }
    setState(() {
      _parkingSpotsForARegion=parkingSpotMap;
    });
  }
  Future<void> _getParkingSpotsReservedForADay() async {
    parkingSpotsReservedForADay = await OfficeReservationFirebaseService.getParkingSpotsReservationForADay(widget.selectedDate);
    //print(parkingSpotsReservedForADay);
    _removeReservedSpots();
  }
  void _removeReservedSpots()  {
    Map<String, List<int>> spotNumbersAux={};
    for(String reservedSpot in parkingSpotsReservedForADay) {
      String reservedSpotKey=reservedSpot.split('_')[0];
      int reservedSpotNumber = int.parse(reservedSpot.split('_')[1]);
      spotNumbersAux[reservedSpotKey] ??= []; // Create an empty list if the key doesn't exist
      spotNumbersAux[reservedSpotKey]!.add(reservedSpotNumber);
    }
    setState(() {
      totalNrOfParkingSlotsReservedForTheSelectedDay=parkingSpotsReservedForADay.length;
      spotNumbersReservedForSelectedDay=spotNumbersAux;
      //print(spotNumbersReservedForSelectedDay);
    });
  }


  void _returnFunction() {
    //Navigator.pop(context, '${_selectedRegion}_$_selectedNumberParkingSpot');
    Navigator.pop(context, _selectedParkingSpotToReturn);
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
        title: const Text('Reserve Parking Spot'),
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
                key: const Key('chooseRegion'),
                value: _selectedRegion,

                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRegion = newValue;
                    _selectedNumberParkingSpot=0;
                  });
                  _fetchParkingSpotsForaRegion(_selectedRegion!);
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
                  itemCount: _parkingSpotsForARegion.length,
                  itemBuilder: (context, index) {
                    int number = _parkingSpotsForARegion.keys.elementAt(index);
                    String? status = _parkingSpotsForARegion[number];
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
                    if (_selectedNumberParkingSpot==number) {
                      color = Colors.yellow.shade800;
                    }
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedNumberParkingSpot==number) {
                            _selectedNumberParkingSpot=0;
                            _selectedParkingSpotToReturn='Please select an available parking spot.';
                          } else if(status=='AVAILABLE'){
                            _selectedNumberParkingSpot=number;
                            _selectedParkingSpotToReturn='${_selectedRegion}_$_selectedNumberParkingSpot';
                          } else if(status=='RESERVED') {
                            _selectedNumberParkingSpot=0;
                            _selectedParkingSpotToReturn='This parkign spot is reserved.';
                          } else {
                            _selectedNumberParkingSpot=0;
                            _selectedParkingSpotToReturn='This parkign spot is blocked.';
                          }
                        });
                      },
                      behavior: status=='AVAILABLE' ? HitTestBehavior.opaque : HitTestBehavior.translucent,
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
              // Stack(
              //   children:
              //   [
              //     Image.asset('images/p1.png'),
              //     SizedBox(
              //       height: MediaQuery.of(context).size.height * 0.55,
              //       child: GridView.builder(
              //         shrinkWrap: true,
              //         //physics: const NeverScrollableScrollPhysics(),
              //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //           crossAxisCount: 5,
              //           crossAxisSpacing: 8.0,
              //           mainAxisSpacing: 8.0,
              //         ),
              //         itemCount: _parkingSpotsForARegion.length,
              //         itemBuilder: (context, index) {
              //           int number = _parkingSpotsForARegion.keys.elementAt(index);
              //           String? status = _parkingSpotsForARegion[number];
              //           Color color;
              //           if (status == 'AVAILABLE') {
              //             color = Colors.green.shade800;
              //           } else if (status == 'BLOCKED') {
              //             color = Colors.red.shade800;
              //           } else if (status == 'RESERVED') {
              //             color = Colors.purple.shade600;
              //           } else {
              //             color = Colors.grey;
              //           }
              //           if (_selectedNumberParkingSpot==number) {
              //             color = Colors.yellow.shade800;
              //           }
              //           return GestureDetector(
              //             onTap: () {
              //               setState(() {
              //                 if (_selectedNumberParkingSpot==number) {
              //                   _selectedNumberParkingSpot=0;
              //                   _selectedParkingSpotToReturn='Please select an available parking spot.';
              //                 } else if(status=='AVAILABLE'){
              //                   _selectedNumberParkingSpot=number;
              //                   _selectedParkingSpotToReturn='${_selectedRegion}_$_selectedNumberParkingSpot';
              //                 } else if(status=='RESERVED') {
              //                   _selectedNumberParkingSpot=0;
              //                   _selectedParkingSpotToReturn='This parkign spot is reserved.';
              //                 } else {
              //                   _selectedNumberParkingSpot=0;
              //                   _selectedParkingSpotToReturn='This parkign spot is blocked.';
              //                 }
              //               });
              //             },
              //             behavior: status=='AVAILABLE' ? HitTestBehavior.opaque : HitTestBehavior.translucent,
              //             child: Container(
              //               color: color,
              //               child: Center(
              //                 child: Text('$number'),
              //               ),
              //             ),
              //           );
              //         },
              //       ),
              //     ),
              // ],
              // ),
              Row(
                children: [
                  const Text('Nr parking spot reserved:'),
                  Text(
                    //'${_selectedRegion}_$_selectedNumberParkingSpot',
                    _selectedParkingSpotToReturn,
                    style: TextStyle(color: _selectedNumberParkingSpot==0?Colors.yellowAccent:AppColors.kBlueColor),
                  ),
                ],
              ),

              IgnorePointer(
                ignoring: _selectedNumberParkingSpot==0,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (_selectedNumberParkingSpot==0) {
                          return Colors.grey;
                        } else {
                          return Colors.blueAccent;
                        }
                      },
                    ),
                  ),
                  onPressed: _returnFunction,
                  key: const Key('confirmButtonParking'),
                  child: const Text('Confirm parking spot'),
                ),
              ),
              // Center(
              //   child: isP1Visible
              //       ? Image.asset('images/p1.png')
              //       : TextButton(
              //     onPressed: () {
              //       setState(() {
              //         isP1Visible = true;
              //       });
              //     },
              //     child: Text('Show P1 Image'),
              //   ),
              // ),
              // Center(
              //   child: isP2Visible
              //       ? Image.asset('images/p2.png')
              //       : TextButton(
              //     onPressed: () {
              //       setState(() {
              //         isP2Visible = true;
              //       });
              //     },
              //     child: Text('Show P2 Image'),
              //   ),
              // ),
              // Center(
              //   child: isP3Visible
              //       ? Image.asset('images/p3.png')
              //       : TextButton(
              //     onPressed: () {
              //       setState(() {
              //         isP1Visible = true;
              //       });
              //     },
              //     child: Text('Show P3 Image'),
              //   ),
              // ),
              Row(
                children: [
                  const Text('Total number of parking slots: '),
                  Text(
                    '$totalNrOfParkingSlots',
                    style: const TextStyle(color: AppColors.kBlueColor),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Total number of parking slots reserved for selected date:'),
                  Text(
                    '$totalNrOfParkingSlotsReservedForTheSelectedDay',
                    style: const TextStyle(color: AppColors.kBlueColor),
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),
              const Text('For ARRK we have:\n * P1 with all numbers, except for 42, which is reserved for motorcycles until 1 november. \n * P2 with numbers 23,24,43 and 44 \n * P3 the numbers between 14 and 41, except number 30, which is reserved for motorcycles and scooters.'),
              ElevatedButton(
                  onPressed: () {
                    _showImagePopup('images/p1.png');
                  },
                  key: const Key ('showP1'),
                  child: const Text('Show P1')),

              ElevatedButton(
                  onPressed: () {

                    _showImagePopup('images/p2.png');
                  },
                  key: const Key('showP2'),
                  child: const Text('Show P2')),
              ElevatedButton(
                  onPressed: () {
                    _showImagePopup('images/p3.png');
                  },
                key: const Key('showP3'),
                  child: const Text('Show P3'),
              ),
              ElevatedButton(
                onPressed: () {
                  _showImagePopup('images/p3Details.png');
                },
                key:const Key('detailP3'),
                child: const Text('Show Detail P3'),
              ),
              const Text(
                style: TextStyle(color: Colors.yellowAccent),
                'Observation: If you make a parking reservation, and the spot is not free then, try to park in other spot, until this app will be used by all employees from ARRK.'
              ),
            ],
          ),
        ),
      ),
    );
  }
}