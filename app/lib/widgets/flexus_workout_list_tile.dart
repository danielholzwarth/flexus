import 'package:app/pages/workout_documentation/view_workout.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class FlexusWorkoutListTile extends StatelessWidget {
  final String title;
  final String weekday;
  final DateTime date;
  final int exerciseCount;
  final int setCount;
  final int durationInMin;

  const FlexusWorkoutListTile({
    super.key,
    required this.title,
    required this.weekday,
    required this.date,
    required this.exerciseCount,
    required this.setCount,
    required this.durationInMin,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const ViewWorkoutPage(
              workoutID: 1,
            ),
          ),
        );
      },
      leading: const CircleAvatar(
        child: Text("MO"),
      ),
      title: Text("$title - ${DateFormat('dd.MM.yyyy').format(date)}"),
      subtitle: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Datum: "12.01.12"'),
          Text('Dauer: 120 min'),
        ],
      ),
      trailing: PopupMenuButton<String>(
        itemBuilder: (BuildContext context) {
          return {'Archive'}.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        },
        onSelected: (String choice) {
          print('Selected: $choice');
        },
      ),
    );
  }
}
