import 'package:flutter/material.dart';

class ViewWorkoutPage extends StatelessWidget {
  final workoutID;

  const ViewWorkoutPage({
    super.key,
    this.workoutID,
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
            Text("hello"),
          ],
        ),
      ),
    );
  }
}
