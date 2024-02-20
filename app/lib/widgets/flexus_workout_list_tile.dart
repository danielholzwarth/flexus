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
      contentPadding: EdgeInsets.symmetric(horizontal: AppSettings.fontSize),
      tileColor: AppSettings.background,
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: ViewWorkoutPage(
              workoutID: workout.id,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        radius: AppSettings.fontSizeTitle,
        backgroundColor: AppSettings.primaryShade48,
        child: Text(
          _getWeekdayAbbreviation(workout.starttime.weekday),
          style: TextStyle(
            fontSize: AppSettings.fontSizeTitleSmall,
            color: AppSettings.font,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          userBox.get("splits") != null
              ? Text(
                  userBox.get("splits")[workout.splitID],
                  style: TextStyle(
                    fontSize: AppSettings.fontSize,
                    color: AppSettings.font,
                  ),
                )
              : Text(
                  "Custom Split",
                  style: TextStyle(
                    fontSize: AppSettings.fontSize,
                    color: AppSettings.font,
                  ),
                ),
          userBox.get("splits") != null
              ? Text(
                  DateFormat('dd.MM.yyyy').format(workout.starttime),
                  style: TextStyle(
                    fontSize: AppSettings.fontSize,
                    color: AppSettings.font,
                  ),
                )
              : Text(
                  DateFormat('dd.MM.yyyy').format(workout.starttime),
                  style: TextStyle(
                    fontSize: AppSettings.fontSize,
                    color: AppSettings.font,
                  ),
                ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          color: AppSettings.font,
          size: AppSettings.fontSizeTitle,
        ),
        itemBuilder: (BuildContext context) {
          return workout.isArchived
              ? {'Unarchive', 'Delete'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList()
              : {'Archive', 'Delete'}.map((String choice) {
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
      subtitle: Row(
        children: [
          Text(
            "${DateFormat('hh:mm').format(workout.starttime)} - ",
            style: TextStyle(
              fontSize: AppSettings.fontSizeDescription,
              color: AppSettings.font,
            ),
          ),
          workout.endtime != null
              ? Text(
                  "${DateFormat('hh:mm').format(workout.endtime!)} ",
                  style: TextStyle(
                    fontSize: AppSettings.fontSizeDescription,
                    color: AppSettings.font,
                  ),
                )
              : Text(
                  " still ongoing ...",
                  style: TextStyle(
                    fontSize: AppSettings.fontSizeDescription,
                    color: AppSettings.font,
                  ),
                ),
          workout.endtime != null
              ? Text(
                  "(${workout.endtime!.difference(workout.starttime).inMinutes} min)",
                  style: TextStyle(
                    fontSize: AppSettings.fontSizeDescription,
                    color: AppSettings.font,
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

String _getWeekdayAbbreviation(int index) {
  final weekdays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
  return weekdays[index % 7];
}
