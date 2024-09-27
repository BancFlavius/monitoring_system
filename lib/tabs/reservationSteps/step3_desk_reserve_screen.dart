import 'package:ARRK/constants/constants.dart';
import 'package:ARRK/services/step_office_reservation_firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/desks_service.dart';
import '../../widgets/fancy_button.dart';

class Step3DeskReserveScreen extends StatefulWidget {
  final DateTime selectedDate;

  const Step3DeskReserveScreen({super.key, required this.selectedDate});

  @override
  Step3DeskReserveScreenState createState() => Step3DeskReserveScreenState();
}

class Step3DeskReserveScreenState extends State<Step3DeskReserveScreen> {
  bool _canRender=false;
  bool _showMoreInfo=false;
  String _selectedDeskToReturn = '';
  bool _validSelectedDesk=false;
  String _imagePath = 'images/officeFloor5ES_vertical.png';

  int totalNrOfDesks = 40;
  int totalNrOfDesksReservedForTheSelectedDay = 0;
  int totalNrOfDesksBlocked=0;
  Map<String, List<int>> desksReservedForSelectedDay = {
    // 'Labs': [1, 2, 3, 4], // Example reserved desks for Labs
    // 'Common': [5, 6, 7, 8], // Example reserved desks for Common
    // 'Experts': [1, 2], // Example reserved desks for Experts
  };

  Map<String, List<int>> desksBlocked = {
    // 'Common': [15, 16], // Example blocked desks for Common
  };
  Map<String, String> officeStatus = {};

  @override
  void initState() {
    _getDesksBlocked();
    super.initState();
  }

  Future<void> _initializeOfficeStatus() async{
    for (int i = 1; i <= 20; i++) {
      if (desksBlocked['Common']?.contains(i) ?? false) {
        officeStatus['Common_$i'] = 'Blocked';
        totalNrOfDesksBlocked++;
      } else if (desksReservedForSelectedDay['Common']?.contains(i) ?? false) {
        officeStatus['Common_$i'] = 'Reserved';
      } else {
        officeStatus['Common_$i'] = 'Available';
      }
    }
    for (int i = 1; i <= 6; i++) {
      if (desksBlocked['Experts']?.contains(i) ?? false) {
        officeStatus['Experts_$i'] = 'Blocked';
        totalNrOfDesksBlocked++;
      } else if (desksReservedForSelectedDay['Experts']?.contains(i) ?? false) {
        officeStatus['Experts_$i'] = 'Reserved';
      } else {
        officeStatus['Experts_$i'] = 'Available';
      }
    }
    for (int i = 1; i <= 14; i++) {
      if (desksBlocked['Labs']?.contains(i) ?? false) {
        officeStatus['Labs_$i'] = 'Blocked';
        totalNrOfDesksBlocked++;
      } else if (desksReservedForSelectedDay['Labs']?.contains(i) ?? false) {
        officeStatus['Labs_$i'] = 'Reserved';
      } else {
        officeStatus['Labs_$i'] = 'Available';
      }
    }
  }

  Future<void> _getDesksBlocked() async {
    final auxBlocked = await DesksFirebaseService.getBlockedDesks();
    if(mounted) {
      setState(() {
        desksBlocked=auxBlocked;
        //print(desksBlocked);
      });
    }
    await _getDesksReservedForADay();
  }

  Future<void> _getDesksReservedForADay() async {
    //print(widget.selectedDate);
    List<String> desksReservedForADay =
        await StepOfficeReservationFirebaseService.getEmployeeDataForDay(
            widget.selectedDate);
    //print(desksReservedForADay);
    Map<String, List<int>> deskNumbersAux = {};
    for (String deskReservedSpot in desksReservedForADay) {
      String deskReservedSpotKey = deskReservedSpot.split('_')[0];
      int reservedDeskNumber = int.parse(deskReservedSpot.split('_')[1]);
      deskNumbersAux[deskReservedSpotKey] ??=
          []; // Create an empty list if the key doesn't exist
      deskNumbersAux[deskReservedSpotKey]!.add(reservedDeskNumber);
    }
    totalNrOfDesksReservedForTheSelectedDay = desksReservedForADay.length;
    desksReservedForSelectedDay = deskNumbersAux;
    await _initializeOfficeStatus();
    setState(() {
      _canRender=true;
      //print(officeStatus);
    });
  }

  void _returnFunction() {
    //Navigator.pop(context, '${_selectedRegion}_$_selectedNumberParkingSpot');
    Navigator.pop(context, _selectedDeskToReturn);
  }


  // @override
  // Widget build(BuildContext context) {
  //   return FutureBuilder(
  //     future: Future.wait([
  //       _getDesksBlocked(),
  //       _getDesksReservedForADay(),
  //       Future.sync(_initializeOfficeStatus),
  //     ]),
  //     builder: (BuildContext context, AsyncSnapshot snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return CircularProgressIndicator();  // Show a loading spinner while waiting for the Futures to complete
  //       } else if (snapshot.hasError) {
  //         return Text('Error: ${snapshot.error}');  // If any Future completed with an error, display the error
  //       } else {
  //         // The data from the Futures will be in snapshot.data, which is a List
  //         //var desksStatus = snapshot.data[0];
  //         //var desksReservedForADay = snapshot.data[1];
  //         // _initializeOfficeStatus() doesn't return any data, so there's no need to get it from snapshot.data
  //
  //         // Now you can use desksStatus and desksReservedForADay to build your widget
  //         return content(context);  // Replace this with your actual widget
  //       }
  //     },
  //   );
  // }

  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    String selectedDate = DateFormat('dd/MM/yyyy').format(widget.selectedDate);
    final double screenHeight=screenSize.height;
    final double screenWidth=screenSize.width;
    bool isBigWidth = screenWidth > 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserve Desk'),
      ),
      body: _canRender?
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(isBigWidth==false)
            Stack(
            children: [
              Image.asset(
                _imagePath,
                fit: BoxFit.cover,
                width: screenSize.width /1.6,
                height: screenSize.height / 1,
              ),
              _buildButton(region: 'Labs', index: 1,height: screenHeight * 0.68, width: screenWidth * 0.35, ),
              _buildButton(region: 'Labs', index: 2,height: screenHeight * 0.68, width: screenWidth * 0.25, ),
              _buildButton(region: 'Labs', index: 3,height: screenHeight * 0.71, width: screenWidth * 0.25, ),
              _buildButton(region: 'Labs', index: 4,height: screenHeight * 0.71, width: screenWidth * 0.35, ),

              _buildButton(region: 'Labs', index: 5,height: screenHeight * 0.63, width: screenWidth * 0.19, ),
              _buildButton(region: 'Labs', index: 6,height: screenHeight * 0.63, width: screenWidth * 0.11, ),
              _buildButton(region: 'Labs', index: 7,height: screenHeight * 0.63, width: screenWidth * 0.03, ),
              _buildButton(region: 'Labs', index: 10,height: screenHeight * 0.66, width: screenWidth * 0.19, ),
              _buildButton(region: 'Labs', index: 9,height: screenHeight * 0.66, width: screenWidth * 0.11, ),
              _buildButton(region: 'Labs', index: 8,height: screenHeight * 0.66, width: screenWidth * 0.03, ),

              _buildButton(region: 'Labs', index: 11,height: screenHeight * 0.73, width: screenWidth * 0.13, ),
              _buildButton(region: 'Labs', index: 12,height: screenHeight * 0.73, width: screenWidth * 0.05, ),
              _buildButton(region: 'Labs', index: 14,height: screenHeight * 0.76, width: screenWidth * 0.13, ),
              _buildButton(region: 'Labs', index: 13,height: screenHeight * 0.76, width: screenWidth * 0.05, ),

              _buildButton(region: 'Common', index: 1,height: screenHeight * 0.56, width: screenWidth * 0.33, ),
              _buildButton(region: 'Common', index: 2,height: screenHeight * 0.56, width: screenWidth * 0.25, ),
              _buildButton(region: 'Common', index: 4,height: screenHeight * 0.53, width: screenWidth * 0.33, ),
              _buildButton(region: 'Common', index: 3,height: screenHeight * 0.53, width: screenWidth * 0.25, ),

              _buildButton(region: 'Common', index: 5,height: screenHeight * 0.47, width: screenWidth * 0.33, ),
              _buildButton(region: 'Common', index: 6,height: screenHeight * 0.47, width: screenWidth * 0.25, ),
              _buildButton(region: 'Common', index: 8,height: screenHeight * 0.44, width: screenWidth * 0.33, ),
              _buildButton(region: 'Common', index: 7,height: screenHeight * 0.44, width: screenWidth * 0.25, ),

              _buildButton(region: 'Common', index: 9,height: screenHeight * 0.36, width: screenWidth * 0.33, ),
              _buildButton(region: 'Common', index: 10,height: screenHeight * 0.36, width: screenWidth * 0.25, ),
              _buildButton(region: 'Common', index: 12,height: screenHeight * 0.33, width: screenWidth * 0.33, ),
              _buildButton(region: 'Common', index: 11,height: screenHeight * 0.33, width: screenWidth * 0.25, ),

              _buildButton(region: 'Common', index: 13,height: screenHeight * 0.27, width: screenWidth * 0.33, ),
              _buildButton(region: 'Common', index: 14,height: screenHeight * 0.27, width: screenWidth * 0.25, ),
              _buildButton(region: 'Common', index: 16,height: screenHeight * 0.24, width: screenWidth * 0.33, ),
              _buildButton(region: 'Common', index: 15,height: screenHeight * 0.24, width: screenWidth * 0.25, ),

              _buildButton(region: 'Common', index: 17,height: screenHeight * 0.18, width: screenWidth * 0.33, ),
              _buildButton(region: 'Common', index: 18,height: screenHeight * 0.18, width: screenWidth * 0.25, ),
              _buildButton(region: 'Common', index: 20,height: screenHeight * 0.15, width: screenWidth * 0.33, ),
              _buildButton(region: 'Common', index: 19,height: screenHeight * 0.15, width: screenWidth * 0.25, ),

              _buildButton(region: 'Experts', index: 1,height: screenHeight * 0.1, width: screenWidth * 0.42, ),
              _buildButton(region: 'Experts', index: 2,height: screenHeight * 0.1, width: screenWidth * 0.29, ),
              _buildButton(region: 'Experts', index: 3,height: screenHeight * 0.08, width: screenWidth * 0.2, ),
              _buildButton(region: 'Experts', index: 4,height: screenHeight * 0.03, width: screenWidth * 0.25, ),
              _buildButton(region: 'Experts', index: 5,height: screenHeight * 0.03, width: screenWidth * 0.33, ),
              _buildButton(region: 'Experts', index: 6,height: screenHeight * 0.03, width: screenWidth * 0.42, ),
            ],
          ),
          if(isBigWidth)
            Stack(
              children: [
                Image.asset(
                  _imagePath,
                  fit: BoxFit.fitHeight,
                ),
                _buildButton(region: 'Labs', index: 1,height: 520, width: 210, ),
                _buildButton(region: 'Labs', index: 2,height: 520, width: 150, ),
                _buildButton(region: 'Labs', index: 3,height: 560, width: 150, ),
                _buildButton(region: 'Labs', index: 4,height: 560, width: 210, ),

                _buildButton(region: 'Labs', index: 5,height: 480, width: 120, ),
                _buildButton(region: 'Labs', index: 6,height: 480, width: 60, ),
                _buildButton(region: 'Labs', index: 7,height: 480, width: 0, ),
                _buildButton(region: 'Labs', index: 10,height: 520, width: 100, ),
                _buildButton(region: 'Labs', index: 9,height: 520, width: 50, ),
                _buildButton(region: 'Labs', index: 8,height: 520, width: 0, ),

                _buildButton(region: 'Labs', index: 11,height: 560, width: 80, ),
                _buildButton(region: 'Labs', index: 12,height: 560, width: 20, ),
                _buildButton(region: 'Labs', index: 14,height: 600, width: 80, ),
                _buildButton(region: 'Labs', index: 13,height: 600, width: 20, ),

                _buildButton(region: 'Common', index: 1,height: 440, width: 180, ),
                _buildButton(region: 'Common', index: 2,height: 440, width: 120, ),
                _buildButton(region: 'Common', index: 4,height: 410, width: 180, ),
                _buildButton(region: 'Common', index: 3,height: 410, width: 120, ),

                _buildButton(region: 'Common', index: 5,height: 370, width: 180, ),
                _buildButton(region: 'Common', index: 6,height: 370, width: 120, ),
                _buildButton(region: 'Common', index: 8,height: 340, width: 180, ),
                _buildButton(region: 'Common', index: 7,height: 340, width: 120, ),

                _buildButton(region: 'Common', index: 9,height: 300, width: 180, ),
                _buildButton(region: 'Common', index: 10,height: 300, width: 120, ),
                _buildButton(region: 'Common', index: 12,height: 270, width: 180, ),
                _buildButton(region: 'Common', index: 11,height: 270, width: 120, ),

                _buildButton(region: 'Common', index: 13,height: 230, width: 180, ),
                _buildButton(region: 'Common', index: 14,height: 230, width: 120, ),
                _buildButton(region: 'Common', index: 16,height: 200, width: 180, ),
                _buildButton(region: 'Common', index: 15,height: 200, width: 120, ),

                _buildButton(region: 'Common', index: 17,height: 160, width: 120, ),
                _buildButton(region: 'Common', index: 18,height: 160, width: 180, ),
                _buildButton(region: 'Common', index: 20,height: 130, width: 120, ),
                _buildButton(region: 'Common', index: 19,height: 130, width: 180, ),

                _buildButton(region: 'Experts', index: 1,height: 70, width: 220, ),
                _buildButton(region: 'Experts', index: 2,height: 70, width: 160, ),
                _buildButton(region: 'Experts', index: 3,height: 60, width: 100, ),
                _buildButton(region: 'Experts', index: 4,height: 20, width: 120, ),
                _buildButton(region: 'Experts', index: 5,height: 20, width: 180, ),
                _buildButton(region: 'Experts', index: 6,height: 20, width: 230, ),
              ],
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  left: isBigWidth?10:screenSize.width / 100, top: isBigWidth?10:screenSize.height / 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Desk reserved:',
                    style: TextStyle(fontSize: isBigWidth?12:screenSize.width / 25),
                  ),
                  Text(
                    _selectedDeskToReturn,
                    style: TextStyle(
                      color: _validSelectedDesk == false
                          ? Colors.yellowAccent
                          : AppColors.kBlueColor,
                      fontSize: isBigWidth?12:screenSize.width / 25,
                    ),
                  ),
                  IgnorePointer(
                    ignoring: _validSelectedDesk == false,
                    child: FancyButton(
                      key: const Key('confirmButtonDesk'),
                      onPressed: _returnFunction,
                      text: 'Confirm desk',
                      fontSize: isBigWidth?12:screenSize.width / 20,
                      backgroundColor: (_validSelectedDesk == false) ?Colors.grey:Colors.blue,
                      textColor: Colors.white,
                      borderColor: (_validSelectedDesk == false) ?Colors.black45:Colors.lightBlueAccent,
                      borderWidth: 4,
                    ),
                  ),
                  SizedBox(
                    height: isBigWidth?5:screenSize.height / 70,
                  ),
                  TextButton(onPressed: () {
                    setState(() {
                      _showMoreInfo=!_showMoreInfo;
                    });
                  }, child: Text('More info',
                    style: TextStyle(fontSize: isBigWidth?12:screenSize.width / 30),),),
                  if(_showMoreInfo)
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('green = available',
                          style: TextStyle(fontSize: isBigWidth?9:screenSize.width / 32),),
                        Text('red = blocked by admin',
                          style: TextStyle(fontSize: isBigWidth?9:screenSize.width / 32),),
                        Text('purple = reserved by another user on this day',
                          style: TextStyle(fontSize: isBigWidth?9:screenSize.width / 32),),
                        Text(
                          'Selected Date: ${selectedDate.toString()}',
                          style: TextStyle(fontSize: isBigWidth?9:screenSize.width / 32),
                        ),
                        Text(
                          'Total number of desks: ',
                          style: TextStyle(fontSize: isBigWidth?9:screenSize.width / 32),
                        ),
                        Text(
                          '$totalNrOfDesks',
                          style: TextStyle(
                            color: AppColors.kBlueColor,
                            fontSize: isBigWidth?9:screenSize.width / 30,
                          ),
                        ),
                        Text(
                          'Total number of desks reserved for selected date:',
                          style: TextStyle(
                            fontSize: isBigWidth?9:screenSize.width / 32,
                          ),
                        ),
                        Text(
                          '$totalNrOfDesksReservedForTheSelectedDay',
                          style: TextStyle(
                            color: AppColors.kBlueColor,
                            fontSize: isBigWidth?9:screenSize.width / 25,
                          ),
                        ),
                        Text(
                          'Total number of desks blocked :',
                          style: TextStyle(
                            fontSize: isBigWidth?9:screenSize.width / 32,
                          ),
                        ),
                        Text(
                          '${totalNrOfDesksBlocked}',
                          style: TextStyle(
                            color: AppColors.kBlueColor,
                            fontSize: isBigWidth?12:screenSize.width / 25,
                          ),
                        ),
                        Text(
                          'Total number of desks available :',
                          style: TextStyle(
                            fontSize: isBigWidth?9:screenSize.width / 32,
                          ),
                        ),
                        Text(
                          '${totalNrOfDesks-totalNrOfDesksReservedForTheSelectedDay-totalNrOfDesksBlocked}',
                          style: TextStyle(
                            color: AppColors.kBlueColor,
                            fontSize: isBigWidth?12:screenSize.width / 25,
                          ),
                        ),
                        Text(
                            style: TextStyle(
                                color: Colors.yellowAccent,
                                fontSize: isBigWidth?10:screenSize.width / 29),
                            'Observation: Keep the desk as clean as possible.'),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ):Center(child: CircularProgressIndicator(),),
    );
  }
  Widget _buildButton({required String region, required int index, required double height,required double width}) {
    String regionIndex='${region}_$index';
    String status = officeStatus[regionIndex]!;
    bool available = (status=='Available');
    bool blocked = (status=='Blocked');
    bool reserved = (status=='Reserved');
    return Positioned(
      top: height,
      left: width,
      child: IgnorePointer(
        ignoring: available == false,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedDeskToReturn=regionIndex;
              _validSelectedDesk=true;
            });
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (_selectedDeskToReturn==regionIndex) return Colors.yellow.withOpacity(0.6);
                if (blocked) return Colors.red.withOpacity(0.3);
                if (reserved) return Colors.purpleAccent.withOpacity(0.3);
                return Colors.green.withOpacity(0.3);
              },
            ),
            side: MaterialStateProperty.resolveWith<BorderSide>(
                  (Set<MaterialState> states) {
                if (region=='Labs') return const BorderSide(color: Colors.purple, width: 2);
                if (region=='Experts') return const BorderSide(color: Colors.blue, width: 2);
                return const BorderSide(color: Colors.greenAccent, width: 2);
              },
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
          child: Text('$index'),
        ),
      ),
    );
  }
}
