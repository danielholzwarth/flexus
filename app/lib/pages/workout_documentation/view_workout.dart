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
        title: Text('ViewWorkoutPage $workoutID'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          children: [
            Text("Not implemented yet"),
          ],
        ),
      ),
    );
  }
}
