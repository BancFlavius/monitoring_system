import 'package:ARRK/constants/constants.dart';
import 'package:flutter/material.dart';
import '../services/parking_spots_service.dart';

class AddParkingSpotScreen extends StatefulWidget {
  const AddParkingSpotScreen({super.key});

  @override
  AddParkingSpotScreenState createState() => AddParkingSpotScreenState();
}

class AddParkingSpotScreenState extends State<AddParkingSpotScreen> {
  String? region;
  int? number;
  int? fromNumber,toNumber;
  String? status;

  String _confirmMessage='';

  final List<String> statusOptions = ['AVAILABLE', 'RESERVED', 'BLOCKED'];

  Future<void> _addParkingSpot() async {
    String returnMessage;
    if(region!=null && status != null) {
      if(number!=null) {
        returnMessage = await ParkingSpotsFirebaseService.addParkingSpot(region!, number!, status!);
      } else if(fromNumber!=null && toNumber!=null) {
        for(int? i=fromNumber; i!<=toNumber!;i++) {
          await ParkingSpotsFirebaseService.addParkingSpot(region!, i, status!);
        }
        returnMessage='Added Parking Spots with success.';
      } else {
        returnMessage='Select a number or an interval!';
      }
    } else {
      returnMessage='Select a region and a status!';
    }
    setState(() {
      _confirmMessage=returnMessage;
    });
  }
  Future<void> _deleteParkingSpot() async {
    String returnMessage;
    if(region!=null) {
      if(number!=null) {
        returnMessage = await ParkingSpotsFirebaseService.deleteParkingSpot(region!, number!);
      } else if(fromNumber!=null && toNumber!=null) {
        for(int? i=fromNumber; i!<=toNumber!;i++) {
          await ParkingSpotsFirebaseService.deleteParkingSpot(region!, i);
        }
        returnMessage='Deleted Parking Spots with success.';
      } else {
        returnMessage='Select a number or an interval!';
      }
    } else {
      returnMessage='Select a region!';
    }
    setState(() {
      _confirmMessage=returnMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Parking Spots'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Region'),
                onChanged: (value) {
                  setState(() {
                    region = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Number (priority)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    number = int.tryParse(value);
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Or Select an interval:'),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'From'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          fromNumber = int.tryParse(value);
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'To'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          toNumber = int.tryParse(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: status,
                onChanged: (String? newValue) {
                  setState(() {
                    status = newValue;
                  });
                },
                items: statusOptions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _addParkingSpot,
                child: const Text('Add/Edit Parking Spots'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(
                    AppColors.kRed800Color),),
                onPressed: _deleteParkingSpot,
                child: const Text('Delete Parking Spots'),
              ),
              const SizedBox(height: 32),
              Text(
                _confirmMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}