import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class ScanQRPage extends StatelessWidget {
  const ScanQRPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScanQRPage'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
            FlexusButton(text: "Show QR"),
          ],
        ),
      ),
    );
  }
}
