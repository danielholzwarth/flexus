import 'package:app/widgets/flexus_button.dart';
import 'package:flutter/material.dart';

class ExerciseExplanationPage extends StatelessWidget {
  const ExerciseExplanationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ExerciseExplanationPage'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("hello"),
            FlexusButton(text: "CONTINUE", route: "/create_plan_splits"),
          ],
        ),
      ),
    );
  }
}
