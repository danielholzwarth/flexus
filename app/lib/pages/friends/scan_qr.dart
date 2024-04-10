import 'package:app/pages/profile/profile.dart';
import 'package:app/resources/app_settings.dart';
import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:page_transition/page_transition.dart';

class ScanQRPage extends StatefulWidget {
  const ScanQRPage({super.key});

  @override
  State<ScanQRPage> createState() => _ScanQRPageState();
}

class _ScanQRPageState extends State<ScanQRPage> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  final userBox = Hive.box("userBox");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomDefaultTextStyle(text: 'Mobile Scanner'),
        centerTitle: true,
        backgroundColor: AppSettings.background,
        actions: [
          IconButton(
            color: Colors.black,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.black,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        // fit: BoxFit.contain,
        controller: cameraController,
        onDetect: (capture) {
          final Barcode barcode = capture.barcodes.first;
          debugPrint('Barcode found! ${barcode.rawValue}');

          if (barcode.rawValue != null) {
            int? scannedUserID = int.tryParse(barcode.rawValue!);

            if (scannedUserID != null) {
              cameraController.stop();
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: ProfilePage(userID: int.parse(barcode.rawValue!)),
                ),
              ).then((value) => cameraController.start());
            } else {
              debugPrint("failed parsing barcode.rawValue");
            }
          } else {
            debugPrint("barcode.rawValue is null");
          }
        },
      ),
    );
  }
}
