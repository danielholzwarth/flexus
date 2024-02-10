import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class ShowQRPage extends StatelessWidget {
  const ShowQRPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShowQRPage'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
            FlexusButton(text: "Scan QR"),
          ],
        ),
      ),
    );
  }
}
