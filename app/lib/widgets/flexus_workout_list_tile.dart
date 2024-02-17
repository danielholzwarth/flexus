import 'package:app/hive/workout.dart';
import 'package:app/pages/workout_documentation/view_workout.dart';
import 'package:app/resources/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class FlexusWorkoutListTile extends StatelessWidget {
  final Workout workout;

  const FlexusWorkoutListTile({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box('userBox');
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
      leading: CircleAvatar(
        backgroundColor: AppSettings.primaryShade48,
        child: Text(_getWeekdayAbbreviation(workout.starttime.weekday)),
      ),
      title: userBox.get("plans") != null
          ? Text("${userBox.get("plans")[workout.planID]} - ${DateFormat('dd.MM.yyyy').format(workout.starttime)}")
          : Text("Workoutplanname   ${DateFormat('dd.MM.yyyy').format(workout.starttime)}"),
      subtitle: Row(
        children: <Widget>[
          Text("${DateFormat('hh:mm').format(workout.starttime)} - "),
          workout.endtime != null ? Text("${DateFormat('hh:mm').format(workout.endtime!)} ") : const Text(" still ongoing ..."),
          workout.endtime != null ? Text("(${workout.endtime!.difference(workout.starttime).inMinutes} min)") : const SizedBox(),
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

String _getWeekdayAbbreviation(int index) {
  final weekdays = ['MO', 'DI', 'MI', 'DO', 'FR', 'SA', 'SO'];
  return weekdays[index % 7];
}
