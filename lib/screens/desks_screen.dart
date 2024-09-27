import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../services/desks_service.dart';
import 'add_desk_screen.dart';
//new
class DesksScreen extends StatefulWidget {
  const DesksScreen({super.key});

  @override
  DesksScreenState createState() => DesksScreenState();
}

class DesksScreenState extends State<DesksScreen> {
  String? region;
  int? number;
  String? status;

  String _confirmMessage = '';

  final List<String> _statusOptions = ['AVAILABLE', 'RESERVED', 'BLOCKED'];
  List<String> _regions = [];
  Map<int, String> _desksForARegion = {};
  final Set<int> _selectedNumbers = {};
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  Future<void> _editDesk() async {
    String returnString = '';
    if (status != null && region != null && _selectedNumbers.isNotEmpty) {
      setState(() {
        for (int number in _selectedNumbers) {
          _desksForARegion[number] = status!;
        }
        _selectedNumbers.clear();
      });
      // Call the function to update data in Firebase
      returnString = await DesksFirebaseService.updateDesksStatus(
          region!, _desksForARegion);
    } else {
      returnString = 'Select a region, a status and some desks!';
    }
    setState(() {
      _confirmMessage = returnString;
    });
  }

  Future<void> _editDesksScheduled(String regionParam, String statusParam,
      Set<int> selectedNumbersParam) async {
    setState(() {
      for (int number in selectedNumbersParam) {
        _desksForARegion[number] = statusParam;
      }
    });
    await DesksFirebaseService.updateDesksStatus(regionParam, _desksForARegion);
  }

  Future<void> _scheduleUpdateParkingSpot() async {
    String returnString = '';
    if (status != null && region != null && _selectedNumbers.isNotEmpty) {
      Duration difference = _selectedDate.difference(DateTime.now());
      String regionNow = region!;
      String statusNow = status!;
      Set<int> selectedNumbersNow =
          Set<int>.from(_selectedNumbers); // Create a copy of the set
      //print(selectedNumbersNow);
      setState(() {
        _selectedNumbers.clear();
      });
      Future.delayed(difference, () {
        _editDesksScheduled(regionNow, statusNow, selectedNumbersNow);
      });
      //Future.delayed(difference, _editParkingSpot);
      returnString = ' The update will be done on scheduled time.';
    } else {
      returnString = 'Select a region, a status and some desks!';
    }
    setState(() {
      _confirmMessage = returnString;
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
    List<String> regionsAux = await DesksFirebaseService.getDeskRegions();
    setState(() {
      _regions = regionsAux;
    });
  }

  Future<void> _fetchParkingSpotsForaRegion(String regionParam) async {
    Map<int, String> deskMap =
        await DesksFirebaseService.getMapNrAndStatusForARegion(regionParam);
    setState(() {
      _desksForARegion = deskMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Desks'),
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
                onPressed: _editDesk,
                key: const Key('editDesks'),
                child: const Text('Edit Desks'),
              ),
              const SizedBox(height: 32),
              Text(
                _confirmMessage,
              ),
              // Text(
              //   DateFormat('dd/MM/yyyy').format(_selectedDate),
              //   style: const TextStyle(fontSize: 30),
              // ),
              // Row(
              //   children: [
              //     ElevatedButton(
              //       onPressed: () {
              //         _showDatePicker();
              //       },
              //       key: const Key('chooseDate'),
              //       child: const Text('Choose date'),
              //     ),
              //     const SizedBox(width: 32),
              //     ElevatedButton(
              //       style: ButtonStyle(
              //           backgroundColor: MaterialStateProperty.all<Color>(
              //               Colors.blue.shade900)),
              //       onPressed: _scheduleUpdateParkingSpot,
              //       key: const Key('scheduleUpdate'),
              //       child: const Text('Schedule update'),
              //     ),
              //   ],
              // ),

              const Text('For ARRK at 5th floor we have 3 regions: '
                  '\n Lab: located in your left when you look at the tablet'
                  '\n Common: located in the back of the tablet '
                  '\n Experts: located in the back of the tablet at the end'),
              ElevatedButton(
                  onPressed: () {
                    _showImagePopup('images/officeFloor5ES_vertical.png');
                  },
                  key: const Key('showDeskRegions'),
                  child: const Text('Show desk regions')),
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
            MaterialPageRoute(builder: (context) => const AddDeskScreen()),
          ).then((value) {
            //_fetchManagers();
          });
        },
      ),
    );
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
}
