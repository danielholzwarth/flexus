import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class DocumentWorkoutPage extends StatelessWidget {
  const DocumentWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DocumentWorkoutPage'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
            FlexusButton(text: "CONTINUE"),
          ],
        ),
      ),
    );
  }
}
