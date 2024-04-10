import 'package:app/widgets/style/flexus_default_text_style.dart';
import 'package:flutter/material.dart';

class ViewWorkoutPage extends StatelessWidget {
  final int workoutID;

  const ViewWorkoutPage({
    super.key,
    this.workoutID = -1,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomDefaultTextStyle(text: 'ViewWorkoutPage $workoutID'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            CustomDefaultTextStyle(text: "Not implemented yet"),
          ],
        ),
      ),
    );
  }
}
