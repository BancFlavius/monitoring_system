import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../screens/handle_4_digit_input.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  //final Function(String?) callback;

  //const QRScannerPage({super.key, required this.callback});

  @override
  QRScannerPageState createState() => QRScannerPageState();
}

class QRScannerPageState extends State<QRScannerPage> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _isFrontCamera = true;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Find a QR'),),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FutureBuilder<List<CameraDescription>>(
                    future: availableCameras(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        return QRView(
                          key: qrKey,
                          onQRViewCreated: _onQRViewCreated,
                          cameraFacing: _isFrontCamera
                              ? CameraFacing.front
                              : CameraFacing.back,
                          overlay: QrScannerOverlayShape(
                            borderColor: Colors.blueAccent,
                            borderRadius: 10,
                            borderLength: 30,
                            borderWidth: 10,
                            cutOutSize: screenSize.width * 0.5,
                          ),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: result != null ? 1.0 : 0.0,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_drop_up, size: 50),
                        Icon(Icons.arrow_drop_up, size: 50),
                        Icon(Icons.arrow_drop_up, size: 50),
                        Icon(Icons.arrow_drop_up, size: 50),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ElevatedButton(
                  //   onPressed: _scanFromImage,
                  //   child: const Icon(
                  //     Icons.image,
                  //   ),
                  // ),
                  ElevatedButton(
                    onPressed: _toggleCamera,
                    child: const Icon(Icons.cameraswitch_sharp),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _navigate({required String? digits}) {
    if(digits!=null)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Handle4DigitInput(
          employeeCode: digits,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      print('QR Code Scanned: ${result!.code}');
      //widget.callback(result!.code);
      // if(result!=null && result?.code!=null && result?.code?.length==4) {
      //   _navigate(digits: result!.code);
      // }
      Navigator.pop(context, result!.code);
    });
  }
  void _toggleCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera; // Toggle the camera facing direction
    });
  }
  void _scanFromImage() async {
    // try {
    //   final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    //
    //   if (pickedFile != null) {
    //     // Use pickedFile.path to access the image file path
    //     String imagePath = pickedFile.path;
    //
    //     // Read the image file
    //     File imageFile = File(imagePath);
    //     List<int> imageBytes = await imageFile.readAsBytes();
    //
    //     // Decode the image using the image package
    //     img.Image? decodedImage = img.decodeImage(Uint8List.fromList(imageBytes));
    //
    //     if (decodedImage != null) {
    //       // Convert the decoded image to grayscale for QR detection
    //       img.Image grayscaleImage = img.grayscale(decodedImage);
    //
    //       // Detect QR codes in the grayscale image
    //       List<QrCode> qrCodes = QrReader.detect(grayscaleImage);
    //
    //       if (qrCodes.isNotEmpty) {
    //         // Extract QR code data
    //         String qrCodeData = qrCodes.first.data;
    //         print('Extracted QR Code Data: $qrCodeData');
    //
    //         // Handle the extracted QR code data as needed
    //       } else {
    //         print('No QR code found in the image.');
    //       }
    //   }
    // } catch (e) {
    //   print('Error picking image: $e');
    // }
  }

  void _switchCamera() async {
    // try {
    //   if (controller != null) {
    //     List<CameraDescription> cameras = await availableCameras();
    //
    //     if (cameras.length > 1) {
    //       CameraDescription newCameraDescription = (controller!.description == cameras[0])
    //           ? cameras[1]
    //           : cameras[0];
    //
    //       await controller!.dispose();
    //       controller = QRViewController(
    //         camera: CameraController(newCameraDescription, ResolutionPreset.medium),
    //         autoFocusMode: AutoFocusMode.continuous,
    //         onScan: _onQRViewCreated,
    //       );
    //       setState(() {});
    //     }
    //   }
    // } catch (e) {
    //   print('Error switching camera: $e');
    // }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
//
// class QRScannerPage extends StatefulWidget {
//   final Function(String?) callback;
//   QRScannerPage(this.callback);
//
//   @override
//   _QRScannerPageState createState() => _QRScannerPageState();
// }
//
// class _QRScannerPageState extends State<QRScannerPage> {
//   Barcode? result;
//   QRViewController? controller;
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: QRView(
//         key: qrKey,
//         onQRViewCreated: _onQRViewCreated,
//       ),
//     );
//   }
//
//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       setState(() {
//         result = scanData;
//       });
//       print('QR Code Scanned: ${result!.code}');
//       widget.callback(result!.code);
//       Navigator.pop(context, result!.code);
//     });
//   }
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }
