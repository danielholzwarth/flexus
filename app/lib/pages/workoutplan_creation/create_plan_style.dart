import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class CreatePlanStylePage extends StatelessWidget {
  const CreatePlanStylePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CreatePlanStylePage'),
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
