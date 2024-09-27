import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/constants.dart';
import '../services/parking_spots_service.dart';
import 'add_parking_spot_screen.dart';

class ParkingSpotScreen extends StatefulWidget {
  const ParkingSpotScreen({super.key});

  @override
  ParkingSpotScreenState createState() => ParkingSpotScreenState();
}

class ParkingSpotScreenState extends State<ParkingSpotScreen> {
  String? region;
  int? number;
  String? status;

  String _confirmMessage='';

  final List<String> _statusOptions = ['AVAILABLE', 'RESERVED', 'BLOCKED'];
  List<String> _regions=[];
  Map<int,String> _parkingSpotsForARegion={};
  final Set<int> _selectedNumbers={};
  DateTime _selectedDate = DateTime.now().add(const Duration(days:1));


  Future<void> _editParkingSpot() async {
    String returnString='';
    if(status != null && region != null && _selectedNumbers.isNotEmpty) {
      setState(() {
        for (int number in _selectedNumbers) {
          _parkingSpotsForARegion[number] = status!;
        }
        _selectedNumbers.clear();
      });
      // Call the function to update data in Firebase
      returnString = await ParkingSpotsFirebaseService
          .updateParkingSpotsStatus(region!, _parkingSpotsForARegion);
    } else {
      returnString='Select a region, a status and some parkingSpots!';
    }
    setState(() {
      _confirmMessage=returnString;
    });
  }
  Future<void> _editParkingSpotsScheduled(String regionParam,String statusParam, Set<int> selectedNumbersParam) async {
      setState(() {
        for (int number in selectedNumbersParam) {
          _parkingSpotsForARegion[number] = statusParam;
        }
      });
      await ParkingSpotsFirebaseService.updateParkingSpotsStatus(regionParam, _parkingSpotsForARegion);
  }

  Future<void> _scheduleUpdateParkingSpot() async {
    String returnString='';
    if(status != null && region != null && _selectedNumbers.isNotEmpty) {
      Duration difference = _selectedDate.difference(DateTime.now());
      String regionNow = region!;
      String statusNow = status!;
      Set<int> selectedNumbersNow = Set<int>.from(_selectedNumbers); // Create a copy of the set
      //print(selectedNumbersNow);
      setState(() {
        _selectedNumbers.clear();
      });
      Future.delayed(difference, () {
        _editParkingSpotsScheduled(regionNow,statusNow,selectedNumbersNow);
      });
      //Future.delayed(difference, _editParkingSpot);
      returnString =' The update will be done on scheduled time.';
    } else {
      returnString='Select a region, a status and some parkingSpots!';
    }
    setState(() {
      _confirmMessage=returnString;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchRegions();
  }

  void _showDatePicker() {
    DateTime currentDate = DateTime.now();
    DateTime tomorrow = currentDate.add(const Duration(days: 1));

    showDatePicker(
      context: context,
      initialDate: tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime(2025),
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedDate = value;
        });
      }
    });
  }

  Future<void> _fetchRegions() async {
    List<String> regionsAux = await ParkingSpotsFirebaseService.getParkingRegions();
    setState(() {
      _regions = regionsAux;
    });
  }

  Future<void> _fetchParkingSpotsForaRegion(String regionParam) async{
    Map<int, String> parkingSpotMap = await ParkingSpotsFirebaseService.getMapNrAndStatusForARegion(regionParam);
    setState(() {
      _parkingSpotsForARegion=parkingSpotMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Parking Spots'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Region'),
                key: const Key('regionCrud'),
                value: region,
                onChanged: (String? newValue) {
                  setState(() {
                    region = newValue;
                  });
                  _fetchParkingSpotsForaRegion(region!);
                },
                items: _regions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              //_parkingSpotsForARegion
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
                    if (_selectedNumbers.contains(number)) {
                      color = Colors.yellow.shade800;
                    }
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedNumbers.contains(number)) {
                            _selectedNumbers.remove(number);
                          } else {
                            _selectedNumbers.add(number);
                          }
                        });
                      },
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                key: const Key('status'),
                value: status,
                onChanged: (String? newValue) {
                  setState(() {
                    status = newValue;
                  });
                },
                items: _statusOptions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _editParkingSpot,
                key: const Key('editParkingSpots'),
                child: const Text('Edit Parking Spots'),
              ),
              const SizedBox(height: 32),
              Text(
                _confirmMessage,
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(_selectedDate),
                style: const TextStyle(fontSize: 30),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showDatePicker();
                    },
                    key: const Key('chooseDate'),
                    child: const Text('Choose date'),
                  ),
                  const SizedBox(width: 32),
                  ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.blue.shade900)),
                    onPressed: _scheduleUpdateParkingSpot,
                    key: const Key('scheduleUpdate'),
                    child: const Text('Schedule update'),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              const Text(
                'For P1 the number 42 is reserved for motocycles until 1 november.'
              ),
              const Text(
                  'For P3 the number 30 is reserved for motocycles until 1 november.'
              ),
              const Text(
                'In perioada 27.07.2023 - 10.08.2023 locurile de parcare  23,24,25,26,27,28,29,30,31 si 32 din PARKING P3 vor fi blocate pentru lucrari de asfaltare in zona presei.'
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.kBlueColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddParkingSpotScreen()),
          ).then((value) {
            //_fetchManagers();
          });
        },
      ),
    );
  }
}