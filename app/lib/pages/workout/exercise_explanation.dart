import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class ExerciseExplanationPage extends StatelessWidget {
  const ExerciseExplanationPage({
    super.key,
    required this.exerciseID,
  });

  final int exerciseID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomDefaultTextStyle(text: 'ExerciseExplanationPage'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const CustomDefaultTextStyle(text: "Not implemented yet"),
            CustomDefaultTextStyle(text: "ID: $exerciseID"),
          ],
        ),
      ),
    );
  }
}
