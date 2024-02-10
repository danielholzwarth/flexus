import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class CreateExercisePage extends StatelessWidget {
  const CreateExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CreateExercisePage'),
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
